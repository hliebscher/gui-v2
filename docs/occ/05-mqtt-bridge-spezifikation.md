# OpenCamperCore — dbus-mqtt-occ Bridge-Treiber Spezifikation

Stand: 2026-05-26

---

## Überblick

Der `dbus-mqtt-occ` Treiber ist ein Python-Service, der OCC-spezifische MQTT-Topics in Venus-OS-kompatible D-Bus-Services übersetzt. Er basiert auf der bewährten Architektur von mr-manuels `dbus-mqtt-temperature`.

---

## Service-Registrierung

| Eigenschaft | Wert |
|---|---|
| D-Bus Service | `com.victronenergy.heating.occ` |
| D-Bus Instanz | 0 (Single-Instance) |
| DeviceInstance | 100 (vermeidet Konflikte mit physischen Geräten) |
| ProductId | 0xFFE0 (Custom-Bereich) |
| ProductName | "OpenCamperCore Heating" |
| FirmwareVersion | Semver aus `version.py` |

---

## MQTT Topic-Mapping

### Eingehende Topics (MQTT → D-Bus)

| MQTT Topic | D-Bus Pfad | Typ | Einheit | Beschreibung |
|---|---|---|---|---|
| `occ/heating/zone/<id>/temperature` | `/Zone/<id>/Temperature` | float | °C | Ist-Temperatur |
| `occ/heating/zone/<id>/setpoint` | `/Zone/<id>/Setpoint` | float | °C | Soll-Temperatur |
| `occ/heating/zone/<id>/state` | `/Zone/<id>/State` | int | enum | 0=Aus, 1=Heizen, 2=Kühlen |
| `occ/heating/zone/<id>/mode` | `/Zone/<id>/Mode` | int | enum | 0=Manuell, 1=Auto, 2=Aus |
| `occ/heating/zone/<id>/relay` | `/Zone/<id>/RelayState` | int | bool | 0=Offen, 1=Geschlossen |
| `occ/heating/zone/<id>/name` | `/Zone/<id>/Name` | string | — | Zonenname |
| `occ/climate/mode` | `/Climate/Mode` | int | enum | 0=Aus, 1=Kühlen, 2=Heizen, 3=Auto |
| `occ/climate/setpoint` | `/Climate/Setpoint` | float | °C | Ziel-Temperatur |
| `occ/climate/temperature` | `/Climate/Temperature` | float | °C | Ist-Temperatur |
| `occ/climate/state` | `/Climate/State` | int | enum | 0=Idle, 1=Active |
| `occ/system/status` | `/Status` | int | enum | 0=Offline, 1=Standby, 2=Active |
| `occ/system/error` | `/ErrorCode` | int | — | Fehlercode |

### Ausgehende Topics (D-Bus → MQTT, Steuerung)

| D-Bus Pfad | MQTT Topic | Trigger | Beschreibung |
|---|---|---|---|
| `/Zone/<id>/Setpoint` (SetValue) | `occ/heating/zone/<id>/setpoint/set` | GUI schreibt | Sollwert ändern |
| `/Zone/<id>/Mode` (SetValue) | `occ/heating/zone/<id>/mode/set` | GUI schreibt | Modus ändern |
| `/Climate/Mode` (SetValue) | `occ/climate/mode/set` | GUI schreibt | Klima-Modus ändern |
| `/Climate/Setpoint` (SetValue) | `occ/climate/setpoint/set` | GUI schreibt | Klima-Sollwert |

---

## D-Bus Service-Struktur

```
com.victronenergy.heating.occ
├── /ProductId                    → 0xFFE0
├── /ProductName                  → "OpenCamperCore Heating"
├── /FirmwareVersion              → "1.0.0"
├── /DeviceInstance               → 100
├── /Connected                    → 1
├── /Status                       → 0|1|2
├── /ErrorCode                    → 0
│
├── /Zone/1/Temperature           → 21.5
├── /Zone/1/Setpoint              → 22.0
├── /Zone/1/State                 → 0|1|2
├── /Zone/1/Mode                  → 0|1|2
├── /Zone/1/RelayState            → 0|1
├── /Zone/1/Name                  → "Wohnbereich"
│
├── /Zone/2/Temperature           → 18.3
├── /Zone/2/Setpoint              → 19.0
├── /Zone/2/State                 → 0|1|2
├── /Zone/2/Mode                  → 0|1|2
├── /Zone/2/RelayState            → 0|1
├── /Zone/2/Name                  → "Schlafbereich"
│
├── /Climate/Mode                 → 0|1|2|3
├── /Climate/Setpoint             → 24.0
├── /Climate/Temperature          → 23.1
└── /Climate/State                → 0|1
```

---

## VeQuickItem UIDs (GUI-Perspektive)

Für die GUI über MQTT-Backend (Wasm):
```
mqtt/heating.occ/Zone/1/Temperature
mqtt/heating.occ/Zone/1/Setpoint
mqtt/heating.occ/Zone/1/State
mqtt/heating.occ/Zone/1/Mode
mqtt/heating.occ/Climate/Mode
mqtt/heating.occ/Climate/Setpoint
```

Für die GUI über D-Bus-Backend (GX nativ):
```
dbus/com.victronenergy.heating.occ/Zone/1/Temperature
dbus/com.victronenergy.heating.occ/Zone/1/Setpoint
dbus/com.victronenergy.heating.occ/Zone/1/State
dbus/com.victronenergy.heating.occ/Zone/1/Mode
dbus/com.victronenergy.heating.occ/Climate/Mode
dbus/com.victronenergy.heating.occ/Climate/Setpoint
```

---

## Konfiguration (config.ini)

```ini
[DEFAULT]
AccessType = OnPremise
SignOfLifeLog = 60

[MQTT]
BrokerAddress = localhost
BrokerPort = 1883
Username =
Password =
TopicPrefix = occ

[HEATING]
Zones = 2
ZoneNames = Wohnbereich,Schlafbereich
DefaultSetpoint = 20.0
MinSetpoint = 5.0
MaxSetpoint = 35.0

[CLIMATE]
Enabled = true
DefaultSetpoint = 22.0
MinSetpoint = 16.0
MaxSetpoint = 30.0

[DBUS]
ServiceName = com.victronenergy.heating.occ
DeviceInstance = 100
ProductId = 0xFFE0
ProductName = OpenCamperCore Heating
```

---

## Verzeichnisstruktur

```
/data/apps/dbus-mqtt-occ/
├── dbus-mqtt-occ.py              # Hauptservice
├── config.ini                    # Konfiguration
├── version.py                    # VERSION = "1.0.0"
├── vedbus.py                     # Venus D-Bus Helper (aus velib_python)
├── ve_utils.py                   # Utility-Funktionen (aus velib_python)
├── dbushelper.py                 # D-Bus Service Setup
├── service/
│   └── run                       # daemontools Service-Script
├── log/
│   └── run                       # Log-Service
├── install.sh                    # Installation + Service-Registrierung
├── uninstall.sh                  # Deinstallation
└── README.md                     # Dokumentation
```

---

## Service-Script (`service/run`)

```bash
#!/bin/sh
exec 2>&1
exec softlimit -d 100000000 -s 1000000 -a 100000000 \
    /usr/bin/python3 /data/apps/dbus-mqtt-occ/dbus-mqtt-occ.py
```

---

## Hauptlogik (Pseudocode)

```python
class OccHeatingService:
    def __init__(self, config):
        self.mqtt_client = mqtt.Client()
        self.dbus_service = create_dbus_service(config)
        self.zones = config.getint('HEATING', 'Zones')

        # D-Bus Pfade registrieren
        for zone_id in range(1, self.zones + 1):
            self.dbus_service.add_path(f'/Zone/{zone_id}/Temperature', None)
            self.dbus_service.add_path(f'/Zone/{zone_id}/Setpoint', config.getfloat('HEATING', 'DefaultSetpoint'),
                                       writeable=True, onchangecallback=self.on_setpoint_change)
            self.dbus_service.add_path(f'/Zone/{zone_id}/State', 0)
            self.dbus_service.add_path(f'/Zone/{zone_id}/Mode', 2,
                                       writeable=True, onchangecallback=self.on_mode_change)
            self.dbus_service.add_path(f'/Zone/{zone_id}/RelayState', 0)
            self.dbus_service.add_path(f'/Zone/{zone_id}/Name', zone_names[zone_id-1])

        # Climate
        self.dbus_service.add_path('/Climate/Mode', 0, writeable=True, onchangecallback=self.on_climate_mode)
        self.dbus_service.add_path('/Climate/Setpoint', 22.0, writeable=True, onchangecallback=self.on_climate_setpoint)
        self.dbus_service.add_path('/Climate/Temperature', None)
        self.dbus_service.add_path('/Climate/State', 0)

    def on_mqtt_message(self, topic, payload):
        """MQTT → D-Bus: Eingehende Sensorwerte"""
        dbus_path = self.topic_to_path(topic)
        value = self.parse_payload(payload)
        self.dbus_service[dbus_path] = value

    def on_setpoint_change(self, path, value):
        """D-Bus → MQTT: GUI setzt neuen Sollwert"""
        mqtt_topic = self.path_to_topic(path) + '/set'
        self.mqtt_client.publish(mqtt_topic, str(value))
        return True

    def on_mode_change(self, path, value):
        """D-Bus → MQTT: GUI ändert Modus"""
        mqtt_topic = self.path_to_topic(path) + '/set'
        self.mqtt_client.publish(mqtt_topic, str(value))
        return True
```

---

## Sign-of-Life

Der Service sendet alle 60s ein Update auf `/Status`:
- `0` = MQTT-Broker nicht erreichbar
- `1` = Verbunden, warte auf Daten
- `2` = Verbunden, aktive Daten

Bei Ausbleiben von MQTT-Daten > 5 Minuten:
- Alle Temperaturwerte → `None` (invalid)
- Status → `1` (Standby)
- GUI zeigt "---" statt ungültige Werte

---

## Fehlerbehandlung

| Fehlercode | Bedeutung | Reaktion |
|---|---|---|
| 0 | Kein Fehler | Normal |
| 1 | MQTT nicht verbunden | Reconnect alle 30s |
| 2 | Sensor-Timeout (>5min) | Werte invalidieren |
| 3 | Konfigurationsfehler | Service startet nicht |
| 4 | D-Bus Registration fehlgeschlagen | Service startet nicht |
| 5 | Setpoint außerhalb Limits | Clamp auf Min/Max |

---

## Separater Temperatursensor-Service

Für Temperatursensoren, die nicht Teil der Heizungslogik sind (z.B. Außentemperatur für StatusBar), wird `dbus-mqtt-temperature` (mr-manuel) direkt genutzt:

```
MQTT: occ/sensors/outdoor/temperature → 15.3
D-Bus: com.victronenergy.temperature.occ_outdoor/Temperature → 15.3
GUI UID: mqtt/temperature.occ_outdoor/Temperature
```

Konfiguration in `dbus-mqtt-temperature/config.ini`:
```ini
[MQTT]
BrokerAddress = localhost
TopicPrefix = occ/sensors

[TEMPERATURE]
TemperatureType = 1  # outdoor
Scale = 1
Offset = 0
```
