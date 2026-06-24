#!/usr/bin/env python3
"""
dbus-mqtt-occ — OpenCamperCore Heating Bridge for Venus OS

Bridges OCC MQTT topics to Venus D-Bus, making heating zone data
visible to the Victron GUI v2 via standard VeQuickItem bindings.

Based on mr-manuel's dbus-mqtt-temperature pattern.
"""

import configparser
import logging
import os
import sys
import time
import json
from pathlib import Path

import dbus
import dbus.service
from gi.repository import GLib

sys.path.insert(1, os.path.dirname(__file__))
from vedbus import VeDbusService
from version import VERSION

try:
    import paho.mqtt.client as mqtt
except ImportError:
    print("ERROR: paho-mqtt not installed. Run: pip3 install paho-mqtt")
    sys.exit(1)

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger("dbus-mqtt-occ")

CONFIG_FILE = os.path.join(os.path.dirname(__file__), "config.ini")


class OccHeatingBridge:
    """Main bridge class: MQTT <-> D-Bus for OCC heating system."""

    STATUS_OFFLINE = 0
    STATUS_STANDBY = 1
    STATUS_ACTIVE = 2

    ZONE_STATE_OFF = 0
    ZONE_STATE_HEATING = 1
    ZONE_STATE_COOLING = 2

    ZONE_MODE_MANUAL = 0
    ZONE_MODE_AUTO = 1
    ZONE_MODE_OFF = 2

    CLIMATE_OFF = 0
    CLIMATE_COOL = 1
    CLIMATE_HEAT = 2
    CLIMATE_AUTO = 3

    SENSOR_TIMEOUT_S = 300  # 5 minutes

    def __init__(self, config):
        self.config = config
        self.zone_count = config.getint("HEATING", "Zones")
        self.zone_names = [n.strip() for n in config.get("HEATING", "ZoneNames").split(",")]
        self.topic_prefix = config.get("MQTT", "TopicPrefix")
        self.last_data_time = 0

        self.climate_enabled = config.getboolean("CLIMATE", "Enabled", fallback=False)
        if config.has_option("CLIMATE", "Units"):
            self.climate_unit_count = config.getint("CLIMATE", "Units") if self.climate_enabled else 0
        else:
            self.climate_unit_count = 1 if self.climate_enabled else 0
        unit_names_raw = config.get("CLIMATE", "UnitNames", fallback="Klima Wohnen,Klima Schlafen")
        self.climate_unit_names = [n.strip() for n in unit_names_raw.split(",")]

        self.climate_min_setpoint = config.getfloat("CLIMATE", "MinSetpoint", fallback=16.0)
        self.climate_max_setpoint = config.getfloat("CLIMATE", "MaxSetpoint", fallback=30.0)
        self.climate_default_setpoint = config.getfloat("CLIMATE", "DefaultSetpoint", fallback=22.0)

        # Valve-to-zone mapping
        self.valve_zones = {}
        if config.has_section("VALVES"):
            for valve_id, zone_str in config.items("VALVES"):
                if valve_id.upper().startswith("V"):
                    self.valve_zones[valve_id.upper()] = int(zone_str)

        self._setup_dbus()
        self._setup_mqtt()

        # Periodic status check (every 30s)
        GLib.timeout_add_seconds(30, self._check_status)

    def _setup_dbus(self):
        """Register D-Bus service with all paths."""
        service_name = self.config.get("DBUS", "ServiceName")
        device_instance = self.config.getint("DBUS", "DeviceInstance")
        product_id = int(self.config.get("DBUS", "ProductId"), 16)
        product_name = self.config.get("DBUS", "ProductName")

        self.dbus = VeDbusService(
            service_name,
            bus=dbus.SystemBus(),
            register=False,
        )

        # Mandatory management paths
        self.dbus.add_path("/Mgmt/ProcessName", "dbus-mqtt-occ")
        self.dbus.add_path("/Mgmt/ProcessVersion", VERSION)
        self.dbus.add_path("/Mgmt/Connection", "MQTT bridge")
        self.dbus.add_path("/DeviceInstance", device_instance)
        self.dbus.add_path("/ProductId", product_id)
        self.dbus.add_path("/ProductName", product_name)
        self.dbus.add_path("/FirmwareVersion", VERSION)
        self.dbus.add_path("/Connected", 1)
        self.dbus.add_path("/Status", self.STATUS_OFFLINE)
        self.dbus.add_path("/ErrorCode", 0)
        self.dbus.add_path("/NumberOfZones", self.zone_count)

        # Zone paths
        for zone_id in range(1, self.zone_count + 1):
            prefix = f"/Zone/{zone_id}"
            name = self.zone_names[zone_id - 1] if zone_id <= len(self.zone_names) else f"Zone {zone_id}"
            self.dbus.add_path(f"{prefix}/Name", name)
            self.dbus.add_path(f"{prefix}/Temperature", None)
            self.dbus.add_path(f"{prefix}/Setpoint", self.config.getfloat("HEATING", "DefaultSetpoint"),
                               writeable=True, onchangecallback=self._on_setpoint_change)
            self.dbus.add_path(f"{prefix}/State", self.ZONE_STATE_OFF)
            self.dbus.add_path(f"{prefix}/Mode", self.ZONE_MODE_AUTO,
                               writeable=True, onchangecallback=self._on_mode_change)
            self.dbus.add_path(f"{prefix}/RelayState", 0)
            self.dbus.add_path(f"{prefix}/ValveState", 0)

        # Valve paths
        for valve_id, zone_nr in self.valve_zones.items():
            self.dbus.add_path(f"/Valve/{valve_id}/State", 0)
            self.dbus.add_path(f"/Valve/{valve_id}/Zone", zone_nr)

        # Pump paths (read-only monitoring)
        for pump_id in ["P1", "P2", "Floor", "Convector"]:
            self.dbus.add_path(f"/Pump/{pump_id}/State", 0)

        # Climate unit paths (/Climate/1/…, /Climate/2/…) + legacy flat aliases on unit 1
        if self.climate_unit_count > 0:
            self.dbus.add_path("/NumberOfClimateUnits", self.climate_unit_count)
            for unit_id in range(1, self.climate_unit_count + 1):
                prefix = f"/Climate/{unit_id}"
                name = (self.climate_unit_names[unit_id - 1]
                        if unit_id <= len(self.climate_unit_names)
                        else f"Climate {unit_id}")
                self.dbus.add_path(f"{prefix}/Name", name)
                self.dbus.add_path(f"{prefix}/Temperature", None)
                self.dbus.add_path(
                    f"{prefix}/Setpoint",
                    self.climate_default_setpoint,
                    writeable=True,
                    onchangecallback=self._on_climate_setpoint_change,
                )
                self.dbus.add_path(
                    f"{prefix}/Mode",
                    self.CLIMATE_OFF,
                    writeable=True,
                    onchangecallback=self._on_climate_mode_change,
                )
                self.dbus.add_path(f"{prefix}/State", 0)

            # Legacy flat paths (mirror climate unit 1)
            self.dbus.add_path(
                "/Climate/Mode",
                self.CLIMATE_OFF,
                writeable=True,
                onchangecallback=self._on_climate_mode_change,
            )
            self.dbus.add_path(
                "/Climate/Setpoint",
                self.climate_default_setpoint,
                writeable=True,
                onchangecallback=self._on_climate_setpoint_change,
            )
            self.dbus.add_path("/Climate/Temperature", None)
            self.dbus.add_path("/Climate/State", 0)

        # Heater system status
        self.dbus.add_path("/Heater/State", 0)
        self.dbus.add_path("/Heater/Mode", 0)
        self.dbus.add_path("/Flow/State", 0)
        self.dbus.add_path("/HotWater/State", 0)

        self.dbus.register()
        log.info("D-Bus service registered: %s (instance %d)", service_name, device_instance)

    def _setup_mqtt(self):
        """Connect to MQTT broker and subscribe to OCC topics."""
        broker = self.config.get("MQTT", "BrokerAddress")
        port = self.config.getint("MQTT", "BrokerPort")
        username = self.config.get("MQTT", "Username")
        password = self.config.get("MQTT", "Password")

        try:
            self.mqtt = mqtt.Client(mqtt.CallbackAPIVersion.VERSION1, client_id="dbus-mqtt-occ")
        except TypeError:
            self.mqtt = mqtt.Client(client_id="dbus-mqtt-occ")
        if username:
            self.mqtt.username_pw_set(username, password)

        self.mqtt.on_connect = self._on_mqtt_connect
        self.mqtt.on_disconnect = self._on_mqtt_disconnect
        self.mqtt.on_message = self._on_mqtt_message

        try:
            self.mqtt.connect(broker, port, keepalive=60)
            self.mqtt.loop_start()
            log.info("MQTT connecting to %s:%d", broker, port)
        except Exception as e:
            log.error("MQTT connection failed: %s", e)
            self.dbus["/Status"] = self.STATUS_OFFLINE
            self.dbus["/ErrorCode"] = 1

    def _on_mqtt_connect(self, client, userdata, flags, rc):
        """Subscribe to all OCC topics on connect."""
        if rc == 0:
            log.info("MQTT connected")
            prefix = self.topic_prefix
            client.subscribe(f"{prefix}/heating/zone/+/+")
            client.subscribe(f"{prefix}/climate/+")
            client.subscribe(f"{prefix}/climate/+/+")
            client.subscribe(f"{prefix}/valve/+/+")
            client.subscribe(f"{prefix}/pump/+/+")
            client.subscribe(f"{prefix}/system/+")
            client.subscribe(f"{prefix}/heater/+")
            client.subscribe(f"{prefix}/flow/+")
            client.subscribe(f"{prefix}/hotwater/+")
            self.dbus["/Status"] = self.STATUS_STANDBY
            self.dbus["/ErrorCode"] = 0
        else:
            log.error("MQTT connect failed with rc=%d", rc)
            self.dbus["/ErrorCode"] = 1

    def _on_mqtt_disconnect(self, client, userdata, rc):
        """Handle MQTT disconnection."""
        log.warning("MQTT disconnected (rc=%d), will reconnect", rc)
        self.dbus["/Status"] = self.STATUS_OFFLINE
        self.dbus["/ErrorCode"] = 1

    def _on_mqtt_message(self, client, userdata, msg):
        """Route incoming MQTT messages to appropriate D-Bus paths."""
        try:
            topic = msg.topic
            payload = msg.payload.decode("utf-8").strip()
            value = self._parse_value(payload)
            self.last_data_time = time.time()

            prefix = self.topic_prefix
            rel = topic[len(prefix) + 1:]  # strip "occ/" prefix

            if rel.startswith("heating/zone/"):
                self._handle_zone_message(rel, value)
            elif rel.startswith("climate/"):
                self._handle_climate_message(rel, value)
            elif rel.startswith("valve/"):
                self._handle_valve_message(rel, value)
            elif rel.startswith("pump/"):
                self._handle_pump_message(rel, value)
            elif rel.startswith("system/"):
                self._handle_system_message(rel, value)
            elif rel.startswith("heater/"):
                self._handle_heater_message(rel, value)
            elif rel.startswith("flow/"):
                self._handle_flow_message(rel, value)
            elif rel.startswith("hotwater/"):
                self._handle_hotwater_message(rel, value)

            if self.dbus["/Status"] != self.STATUS_ACTIVE:
                self.dbus["/Status"] = self.STATUS_ACTIVE

        except Exception as e:
            log.error("Error processing MQTT message %s: %s", msg.topic, e)

    def _handle_zone_message(self, rel, value):
        """Process: heating/zone/<id>/<field>"""
        parts = rel.split("/")
        if len(parts) < 4:
            return
        zone_id = parts[2]
        field = parts[3]

        path_map = {
            "temperature": f"/Zone/{zone_id}/Temperature",
            "setpoint": f"/Zone/{zone_id}/Setpoint",
            "state": f"/Zone/{zone_id}/State",
            "mode": f"/Zone/{zone_id}/Mode",
            "relay": f"/Zone/{zone_id}/RelayState",
            "valve": f"/Zone/{zone_id}/ValveState",
        }

        dbus_path = path_map.get(field)
        if dbus_path:
            if field == "state":
                value = self._state_str_to_int(value)
            elif field == "mode":
                value = self._mode_str_to_int(value)
            self.dbus[dbus_path] = value

    def _handle_climate_message(self, rel, value):
        """Process: climate/<field> (legacy) or climate/<id>/<field>"""
        parts = rel.split("/")
        if len(parts) < 2:
            return

        if len(parts) >= 3 and parts[1].isdigit():
            unit_id = parts[1]
            field = parts[2]
            indexed_prefix = f"/Climate/{unit_id}"
        else:
            unit_id = "1"
            field = parts[1]
            indexed_prefix = f"/Climate/{unit_id}"

        path_map = {
            "mode": f"{indexed_prefix}/Mode",
            "setpoint": f"{indexed_prefix}/Setpoint",
            "temperature": f"{indexed_prefix}/Temperature",
            "state": f"{indexed_prefix}/State",
        }

        dbus_path = path_map.get(field)
        if not dbus_path:
            return

        if field == "mode":
            value = self._climate_mode_str_to_int(value)
        elif field == "state":
            value = 1 if str(value).lower() in ("active", "1") else 0

        self.dbus[dbus_path] = value
        if unit_id == "1":
            self._sync_legacy_climate_from_unit(1)

    def _sync_legacy_climate_from_unit(self, unit_id):
        """Mirror climate unit 1 onto legacy flat /Climate/* paths."""
        prefix = f"/Climate/{unit_id}"
        for field in ("Mode", "Setpoint", "Temperature", "State"):
            src = f"{prefix}/{field}"
            dst = f"/Climate/{field}"
            self.dbus[dst] = self.dbus[src]

    def _climate_unit_id_from_path(self, path):
        parts = path.strip("/").split("/")
        if len(parts) >= 2 and parts[1].isdigit():
            return int(parts[1])
        return 1

    def _handle_valve_message(self, rel, value):
        """Process: valve/<id>/state"""
        parts = rel.split("/")
        if len(parts) < 3:
            return
        valve_id = parts[1].upper()
        field = parts[2]
        if field == "state" and valve_id in self.valve_zones:
            self.dbus[f"/Valve/{valve_id}/State"] = int(float(value))

    def _handle_pump_message(self, rel, value):
        """Process: pump/<id>/state"""
        parts = rel.split("/")
        if len(parts) < 3:
            return
        pump_id_map = {"p1": "P1", "p2": "P2", "floor": "Floor", "convector": "Convector"}
        pump_id = pump_id_map.get(parts[1].lower())
        if pump_id and parts[2] == "state":
            self.dbus[f"/Pump/{pump_id}/State"] = int(float(value))

    def _handle_system_message(self, rel, value):
        """Process: system/<field>"""
        parts = rel.split("/")
        if len(parts) < 2:
            return
        if parts[1] == "status":
            self.dbus["/Status"] = int(float(value))
        elif parts[1] == "error":
            self.dbus["/ErrorCode"] = int(float(value))

    def _handle_heater_message(self, rel, value):
        """Process: heater/<field>"""
        parts = rel.split("/")
        if len(parts) < 2:
            return
        if parts[1] == "state":
            self.dbus["/Heater/State"] = int(float(value))
        elif parts[1] == "mode":
            self.dbus["/Heater/Mode"] = int(float(value))

    def _handle_flow_message(self, rel, value):
        """Process: flow/<field>"""
        parts = rel.split("/")
        if len(parts) < 2:
            return
        if parts[1] == "state":
            self.dbus["/Flow/State"] = int(float(value))

    def _handle_hotwater_message(self, rel, value):
        """Process: hotwater/<field>"""
        parts = rel.split("/")
        if len(parts) < 2:
            return
        if parts[1] == "state":
            self.dbus["/HotWater/State"] = int(float(value))

    # --- Bidirectional: D-Bus writes -> MQTT publishes ---

    def _on_setpoint_change(self, path, value):
        """GUI changed a zone setpoint -> publish to MQTT."""
        zone_id = path.split("/")[2]
        min_sp = self.config.getfloat("HEATING", "MinSetpoint")
        max_sp = self.config.getfloat("HEATING", "MaxSetpoint")
        value = max(min_sp, min(max_sp, float(value)))
        topic = f"{self.topic_prefix}/heating/zone/{zone_id}/setpoint/set"
        self.mqtt.publish(topic, str(value), qos=1)
        log.info("Setpoint zone %s -> %.1f", zone_id, value)
        return True

    def _on_mode_change(self, path, value):
        """GUI changed a zone mode -> publish to MQTT."""
        zone_id = path.split("/")[2]
        mode_map = {0: "manual", 1: "auto", 2: "off"}
        topic = f"{self.topic_prefix}/heating/zone/{zone_id}/mode/set"
        self.mqtt.publish(topic, mode_map.get(int(value), "off"), qos=1)
        log.info("Mode zone %s -> %s", zone_id, mode_map.get(int(value)))
        return True

    def _on_climate_mode_change(self, path, value):
        """GUI changed climate mode -> publish to MQTT."""
        unit_id = self._climate_unit_id_from_path(path)
        mode_map = {0: "off", 1: "cool", 2: "heat", 3: "auto"}
        mode_str = mode_map.get(int(value), "off")
        indexed_path = f"/Climate/{unit_id}/Mode"
        self.dbus[indexed_path] = int(value)
        if unit_id == 1:
            self.dbus["/Climate/Mode"] = int(value)
            self.mqtt.publish(f"{self.topic_prefix}/climate/mode/set", mode_str, qos=1)
        self.mqtt.publish(f"{self.topic_prefix}/climate/{unit_id}/mode/set", mode_str, qos=1)
        log.info("Climate mode unit %d -> %s", unit_id, mode_str)
        return True

    def _on_climate_setpoint_change(self, path, value):
        """GUI changed climate setpoint -> publish to MQTT."""
        unit_id = self._climate_unit_id_from_path(path)
        value = max(self.climate_min_setpoint, min(self.climate_max_setpoint, float(value)))
        indexed_path = f"/Climate/{unit_id}/Setpoint"
        self.dbus[indexed_path] = value
        if unit_id == 1:
            self.dbus["/Climate/Setpoint"] = value
            self.mqtt.publish(f"{self.topic_prefix}/climate/setpoint/set", str(value), qos=1)
        self.mqtt.publish(f"{self.topic_prefix}/climate/{unit_id}/setpoint/set", str(value), qos=1)
        log.info("Climate setpoint unit %d -> %.1f", unit_id, value)
        return True

    # --- Status monitoring ---

    def _check_status(self):
        """Periodic check: invalidate stale data if MQTT silent too long."""
        if self.dbus["/Status"] == self.STATUS_ACTIVE:
            elapsed = time.time() - self.last_data_time
            if elapsed > self.SENSOR_TIMEOUT_S:
                log.warning("Sensor timeout (%.0fs), invalidating data", elapsed)
                self.dbus["/Status"] = self.STATUS_STANDBY
                for zone_id in range(1, self.zone_count + 1):
                    self.dbus[f"/Zone/{zone_id}/Temperature"] = None
                for unit_id in range(1, self.climate_unit_count + 1):
                    self.dbus[f"/Climate/{unit_id}/Temperature"] = None
                    if unit_id == 1:
                        self.dbus["/Climate/Temperature"] = None
        return True  # keep timer running

    # --- Helpers ---

    @staticmethod
    def _parse_value(payload):
        """Parse MQTT payload to appropriate Python type."""
        try:
            return json.loads(payload)
        except (json.JSONDecodeError, ValueError):
            pass
        try:
            return float(payload)
        except ValueError:
            return payload

    @staticmethod
    def _state_str_to_int(value):
        """Convert state string to integer enum."""
        if isinstance(value, (int, float)):
            return int(value)
        mapping = {"off": 0, "heating": 1, "cooling": 2}
        return mapping.get(str(value).lower(), 0)

    @staticmethod
    def _mode_str_to_int(value):
        """Convert mode string to integer enum."""
        if isinstance(value, (int, float)):
            return int(value)
        mapping = {"manual": 0, "auto": 1, "off": 2}
        return mapping.get(str(value).lower(), 2)

    @staticmethod
    def _climate_mode_str_to_int(value):
        """Convert climate mode string to integer enum."""
        if isinstance(value, (int, float)):
            return int(value)
        mapping = {"off": 0, "cool": 1, "heat": 2, "auto": 3}
        return mapping.get(str(value).lower(), 0)


def main():
    log.info("dbus-mqtt-occ v%s starting", VERSION)

    config = configparser.ConfigParser()
    config.read(CONFIG_FILE)

    if not config.has_section("MQTT"):
        log.error("Config file missing or invalid: %s", CONFIG_FILE)
        sys.exit(1)

    from dbus.mainloop.glib import DBusGMainLoop
    DBusGMainLoop(set_as_default=True)

    bridge = OccHeatingBridge(config)

    mainloop = GLib.MainLoop()
    log.info("Entering main loop")
    try:
        mainloop.run()
    except KeyboardInterrupt:
        log.info("Shutting down")
        bridge.mqtt.loop_stop()
        bridge.mqtt.disconnect()


if __name__ == "__main__":
    main()
