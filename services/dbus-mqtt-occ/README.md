# dbus-mqtt-occ — OpenCamperCore Heating Bridge

Venus OS D-Bus Service, der OCC MQTT-Topics auf einen Standard-Victron-D-Bus-Service mappt.
Dadurch erscheinen Heizungsdaten in der GUI v2 wie jeder andere Victron-Service.

## Architektur

```
OCC-Hardware (ESP32/Sensoren)
    ↓ MQTT
mosquitto (lokal auf GX)
    ↓ Subscribe
dbus-mqtt-occ (dieser Service)
    ↓ D-Bus
com.victronenergy.heating.occ
    ↓ VeQuickItem
GUI v2 (OCC Heating Plugin)
```

## Installation auf GX-Gerät

```bash
# Dateien auf GX kopieren
rsync -avc . root@<gx-ip>:/tmp/dbus-mqtt-occ/

# Installation ausführen
ssh root@<gx-ip> "cd /tmp/dbus-mqtt-occ && bash install.sh"
```

## Konfiguration

Datei: `/data/apps/dbus-mqtt-occ/config.ini`

| Sektion | Parameter | Beschreibung |
|---|---|---|
| MQTT | BrokerAddress | MQTT-Broker IP (Standard: localhost) |
| MQTT | BrokerPort | MQTT-Port (Standard: 1883) |
| MQTT | TopicPrefix | Basis-Topic (Standard: occ) |
| HEATING | Zones | Anzahl Heizungszonen |
| HEATING | ZoneNames | Komma-separierte Zonennamen |
| VALVES | V17..V25 | Ventil-zu-Zone Zuordnung |
| CLIMATE | Enabled | Klimaanlage aktiviert |
| DBUS | ServiceName | D-Bus Service-Name |
| DBUS | DeviceInstance | Geräte-Instanz (100) |

## MQTT Topics

### Eingehend (Sensoren → D-Bus)

```
occ/heating/zone/<id>/temperature    → Ist-Temperatur (float, °C)
occ/heating/zone/<id>/setpoint       → Soll-Temperatur (float, °C)
occ/heating/zone/<id>/state          → off|heating|cooling
occ/heating/zone/<id>/mode           → manual|auto|off
occ/heating/zone/<id>/relay          → 0|1
occ/valve/<id>/state                 → 0|1
occ/pump/<id>/state                  → 0|1
occ/climate/mode                     → off|cool|heat|auto
occ/climate/setpoint                 → float
occ/climate/temperature              → float
```

### Ausgehend (GUI-Steuerung → OCC)

```
occ/heating/zone/<id>/setpoint/set   → Neuer Sollwert
occ/heating/zone/<id>/mode/set       → Neuer Modus
occ/climate/mode/set                 → Neuer Klima-Modus
occ/climate/setpoint/set             → Neuer Klima-Sollwert
```

## D-Bus Pfade

```
com.victronenergy.heating.occ/
├── /Status                → 0=Offline, 1=Standby, 2=Active
├── /NumberOfZones         → 3
├── /Zone/1/Temperature    → float
├── /Zone/1/Setpoint       → float (R/W)
├── /Zone/1/State          → 0=Off, 1=Heating, 2=Cooling
├── /Zone/1/Mode           → 0=Manual, 1=Auto, 2=Off (R/W)
├── /Zone/1/ValveState     → int
├── /Valve/V17/State       → 0|1
├── /Valve/V17/Zone        → 3
├── /Pump/P1/State         → 0|1
├── /Climate/Mode          → 0=Off, 1=Cool, 2=Heat, 3=Auto (R/W)
├── /Climate/Setpoint      → float (R/W)
└── /Climate/Temperature   → float
```

## Wartung

```bash
svstat /service/dbus-mqtt-occ          # Status prüfen
svc -t /service/dbus-mqtt-occ          # Neustart
tail -f /var/log/dbus-mqtt-occ/current # Logs
dbus -y com.victronenergy.heating.occ / GetValue  # Alle Werte
```

## Deinstallation

```bash
ssh root@<gx-ip> "bash /data/apps/dbus-mqtt-occ/uninstall.sh"
```

## Voraussetzungen

- Venus OS >= 3.40
- Python 3 mit paho-mqtt
- mosquitto MQTT-Broker (Standard auf GX)
- OCC-Hardware publiziert auf occ/... Topics
