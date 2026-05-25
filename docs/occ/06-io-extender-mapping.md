# OpenCamperCore — I/O Extender Kanal-Zuordnung und Konfiguration

Stand: 2026-05-26

---

## Hardware: Victron IO Extender 150

| Eigenschaft | Wert |
|---|---|
| Modell | IO Extender 150 |
| Digitale Eingänge | 4 (DI1–DI4) |
| Digitale Ausgänge | 4 (DO1–DO4, Open Drain) |
| Relais | 3 (R1–R3, potentialfrei, max 5A) |
| Schnittstelle | VE.Can |
| D-Bus Service | `com.victronenergy.ioextender.<instance>` |

---

## OCC Kanal-Zuordnung

### Relais (SwitchableOutput)

| Kanal | Hardware | OCC-Funktion | D-Bus Pfad | Function-Wert | Group |
|---|---|---|---|---|---|
| R1 | Relais 1 | Heizung Zone 1 | `/SwitchableOutput/<id_r1>` | Temperature (4) | "OCC Heating" |
| R2 | Relais 2 | Heizung Zone 2 | `/SwitchableOutput/<id_r2>` | Temperature (4) | "OCC Heating" |
| R3 | Relais 3 | Klimaanlage | `/SwitchableOutput/<id_r3>` | Manual (2) | "OCC Climate" |

### Digitale Ausgänge (SwitchableOutput)

| Kanal | Hardware | OCC-Funktion | D-Bus Pfad | Function-Wert | Group |
|---|---|---|---|---|---|
| DO1 | Digital Out 1 | Umwälzpumpe | `/SwitchableOutput/<id_do1>` | Manual (2) | "OCC Heating" |
| DO2 | Digital Out 2 | Zusatzheizung | `/SwitchableOutput/<id_do2>` | Temperature (4) | "OCC Heating" |
| DO3 | Digital Out 3 | Lüfter Klima | `/SwitchableOutput/<id_do3>` | Manual (2) | "OCC Climate" |
| DO4 | Digital Out 4 | Reserve | `/SwitchableOutput/<id_do4>` | Disabled (-1) | — |

### Digitale Eingänge (GenericInput)

| Kanal | Hardware | OCC-Funktion | D-Bus Pfad | Type-Wert | Beschreibung |
|---|---|---|---|---|---|
| DI1 | Digital In 1 | Thermostat-Kontakt | `/DigitalInput/<id_di1>` | TouchInputControl (11) | Externer Thermostat |
| DI2 | Digital In 2 | Türkontakt | `/DigitalInput/<id_di2>` | DoorAlarm (2) | Tür offen → Heizung Pause |
| DI3 | Digital In 3 | Sicherheitskontakt | `/DigitalInput/<id_di3>` | SmokeAlarm (6) | Notabschaltung |
| DI4 | Digital In 4 | Reserve | `/DigitalInput/<id_di4>` | Disabled (0) | — |

---

## D-Bus Pfad-Struktur (SwitchableOutput)

Für jeden SwitchableOutput existieren folgende D-Bus Pfade:

```
com.victronenergy.ioextender.<instance>/SwitchableOutput/<channel_id>/
├── /State                    → 0=Off, 1=On (R/W wenn Function=Manual)
├── /Status                   → Bitmaske (0x00=Off, 0x01=Powered, ...)
├── /Settings/Type            → SwitchableOutput_Type (Relay, Switch, ...)
├── /Settings/Function        → SwitchableOutput_Function (-1..6)
├── /Settings/Group           → String (Gruppierung in der GUI)
├── /Settings/Name            → String (Anzeigename)
├── /Settings/Enabled         → 0|1
└── /Settings/Inverted        → 0|1
```

---

## D-Bus Pfad-Struktur (DigitalInput)

```
com.victronenergy.digitalinput.<instance>/
├── /State                    → 0=Low, 1=High
├── /Count                    → Impulszähler (für PulseMeter)
├── /Type                     → DigitalInput_Type (0..11)
├── /Alarm                    → 0=OK, 2=Alarm
└── /ProductName              → String
```

---

## GUI-Darstellung (automatisch)

Das IOChannel-System der GUI erkennt neue SwitchableOutputs und GenericInputs **automatisch** über D-Bus/MQTT — es sind keine GUI-Code-Änderungen für die Basis-Funktionalität nötig:

1. **SwitchableOutput** mit `Function = Manual` → erscheint im Switch-Panel als Schalter
2. **SwitchableOutput** mit `Function = Temperature` → wird vom Temperatur-Relay-System gesteuert
3. **GenericInput** → erscheint im DeviceList unter dem konfigurierten Typ
4. **Group**-Einstellung → gruppiert Kanäle visuell in der GUI

### IOChannelGroupModel (C++)

```cpp
// Automatische Erkennung über:
IOChannelGroupModel::addChannel(IOChannel *channel) {
    // Channel wird anhand von serviceType und channelId identifiziert
    // Group-Property bestimmt die Gruppierung im UI
}
```

### IOChannelProxyModel (C++)

```cpp
// Filter für spezifische Ansichten:
IOChannelProxyModel::filterAcceptsRow(...) {
    // Filtert nach Function != Disabled
    // Filtert nach Function == Manual (für Switch-Panel)
}
```

---

## Konfigurationsscript (`occ-io-setup.sh`)

Dieses Script wird einmalig auf dem GX-Gerät ausgeführt, um die I/O-Kanäle für OCC zu konfigurieren:

```bash
#!/bin/bash
# occ-io-setup.sh — Konfiguriert IO Extender Kanäle für OpenCamperCore
# Ausführung: ssh root@<gx-ip> "bash /data/apps/dbus-mqtt-occ/occ-io-setup.sh"

set -e

SETTINGS_PREFIX="com.victronenergy.settings"

echo "=== OpenCamperCore I/O Setup ==="
echo ""

# Hilfsfunktion: D-Bus Wert setzen
dbus_set() {
    local service="$1"
    local path="$2"
    local value="$3"
    dbus -y "$service" "$path" SetValue "$value" 2>/dev/null || \
        echo "WARN: Konnte $service $path nicht setzen"
}

# IO Extender Instance finden
IO_SERVICE=$(dbus -y | grep "com.victronenergy.ioextender" | head -1)
if [ -z "$IO_SERVICE" ]; then
    echo "FEHLER: Kein IO Extender gefunden!"
    echo "Stelle sicher, dass ein IO Extender 150 am VE.Can angeschlossen ist."
    exit 1
fi

echo "IO Extender gefunden: $IO_SERVICE"
echo ""

# === RELAIS KONFIGURATION ===
echo "--- Relais konfigurieren ---"

# R1: Heizung Zone 1
echo "R1 → Heizung Zone 1 (Function=Temperature)"
dbus_set "$IO_SERVICE" "/SwitchableOutput/relay1/Settings/Function" 4
dbus_set "$IO_SERVICE" "/SwitchableOutput/relay1/Settings/Name" "Heizung Zone 1"
dbus_set "$IO_SERVICE" "/SwitchableOutput/relay1/Settings/Group" "OCC Heating"
dbus_set "$IO_SERVICE" "/SwitchableOutput/relay1/Settings/Enabled" 1

# R2: Heizung Zone 2
echo "R2 → Heizung Zone 2 (Function=Temperature)"
dbus_set "$IO_SERVICE" "/SwitchableOutput/relay2/Settings/Function" 4
dbus_set "$IO_SERVICE" "/SwitchableOutput/relay2/Settings/Name" "Heizung Zone 2"
dbus_set "$IO_SERVICE" "/SwitchableOutput/relay2/Settings/Group" "OCC Heating"
dbus_set "$IO_SERVICE" "/SwitchableOutput/relay2/Settings/Enabled" 1

# R3: Klimaanlage
echo "R3 → Klimaanlage (Function=Manual)"
dbus_set "$IO_SERVICE" "/SwitchableOutput/relay3/Settings/Function" 2
dbus_set "$IO_SERVICE" "/SwitchableOutput/relay3/Settings/Name" "Klimaanlage"
dbus_set "$IO_SERVICE" "/SwitchableOutput/relay3/Settings/Group" "OCC Climate"
dbus_set "$IO_SERVICE" "/SwitchableOutput/relay3/Settings/Enabled" 1

echo ""

# === DIGITAL OUTPUTS KONFIGURATION ===
echo "--- Digitale Ausgänge konfigurieren ---"

# DO1: Umwälzpumpe
echo "DO1 → Umwälzpumpe (Function=Manual)"
dbus_set "$IO_SERVICE" "/SwitchableOutput/do1/Settings/Function" 2
dbus_set "$IO_SERVICE" "/SwitchableOutput/do1/Settings/Name" "Umwälzpumpe"
dbus_set "$IO_SERVICE" "/SwitchableOutput/do1/Settings/Group" "OCC Heating"
dbus_set "$IO_SERVICE" "/SwitchableOutput/do1/Settings/Enabled" 1

# DO2: Zusatzheizung
echo "DO2 → Zusatzheizung (Function=Temperature)"
dbus_set "$IO_SERVICE" "/SwitchableOutput/do2/Settings/Function" 4
dbus_set "$IO_SERVICE" "/SwitchableOutput/do2/Settings/Name" "Zusatzheizung"
dbus_set "$IO_SERVICE" "/SwitchableOutput/do2/Settings/Group" "OCC Heating"
dbus_set "$IO_SERVICE" "/SwitchableOutput/do2/Settings/Enabled" 1

# DO3: Lüfter Klima
echo "DO3 → Lüfter Klima (Function=Manual)"
dbus_set "$IO_SERVICE" "/SwitchableOutput/do3/Settings/Function" 2
dbus_set "$IO_SERVICE" "/SwitchableOutput/do3/Settings/Name" "Lüfter Klima"
dbus_set "$IO_SERVICE" "/SwitchableOutput/do3/Settings/Group" "OCC Climate"
dbus_set "$IO_SERVICE" "/SwitchableOutput/do3/Settings/Enabled" 1

# DO4: Reserve (deaktiviert)
echo "DO4 → Reserve (Function=Disabled)"
dbus_set "$IO_SERVICE" "/SwitchableOutput/do4/Settings/Function" -1
dbus_set "$IO_SERVICE" "/SwitchableOutput/do4/Settings/Name" "Reserve"
dbus_set "$IO_SERVICE" "/SwitchableOutput/do4/Settings/Enabled" 0

echo ""

# === DIGITAL INPUTS KONFIGURATION ===
echo "--- Digitale Eingänge konfigurieren ---"

# DI-Service finden
DI_SERVICE=$(dbus -y | grep "com.victronenergy.digitalinput" | head -1)
if [ -z "$DI_SERVICE" ]; then
    echo "WARN: Kein DigitalInput-Service gefunden (wird ggf. automatisch erstellt)"
else
    echo "DigitalInput-Service: $DI_SERVICE"

    # DI1: Thermostat-Kontakt
    echo "DI1 → Thermostat (Type=TouchInputControl)"
    dbus_set "$DI_SERVICE" "/Type" 11

    # DI2: Türkontakt
    DI2_SERVICE=$(dbus -y | grep "com.victronenergy.digitalinput" | sed -n '2p')
    if [ -n "$DI2_SERVICE" ]; then
        echo "DI2 → Türkontakt (Type=DoorAlarm)"
        dbus_set "$DI2_SERVICE" "/Type" 2
    fi

    # DI3: Sicherheitskontakt
    DI3_SERVICE=$(dbus -y | grep "com.victronenergy.digitalinput" | sed -n '3p')
    if [ -n "$DI3_SERVICE" ]; then
        echo "DI3 → Rauchmelder (Type=SmokeAlarm)"
        dbus_set "$DI3_SERVICE" "/Type" 6
    fi
fi

echo ""
echo "=== OCC I/O Setup abgeschlossen ==="
echo ""
echo "Verifizierung:"
echo "  dbus -y $IO_SERVICE / GetValue"
echo ""
echo "GUI-Neustart empfohlen:"
echo "  svc -t /service/gui"
```

---

## Steuerung durch dbus-mqtt-occ

Der `dbus-mqtt-occ` Bridge-Treiber steuert die Relais **nicht** direkt über den IO-Extender-D-Bus-Service, sondern über das Temperature-Relay-System von Venus OS oder per Manual-Function:

### Variante A: Temperature-Relay-System (empfohlen für Heizung)

Wenn `Function = Temperature` gesetzt ist, übernimmt der Venus-interne `temprelay`-Service die Steuerung basierend auf Temperatur-Schwellen. Der `dbus-mqtt-occ` Service liefert die Temperaturen als `com.victronenergy.temperature.occ_zone<n>`, und die Schwellen werden über localsettings konfiguriert:

```
/Settings/Relay/<n>/TemperatureRule/<sensor>/Condition  → 0=Above, 1=Below
/Settings/Relay/<n>/TemperatureRule/<sensor>/SetValue   → Schwellwert
/Settings/Relay/<n>/TemperatureRule/<sensor>/Enabled    → 0|1
```

### Variante B: Direkte Steuerung (für Klima, Pumpe)

Wenn `Function = Manual` gesetzt ist, kann der `dbus-mqtt-occ` Service den Output direkt schalten:

```python
# D-Bus Pfad des SwitchableOutput direkt setzen
dbus_service['/SwitchableOutput/<id>/State'] = 1  # EIN
dbus_service['/SwitchableOutput/<id>/State'] = 0  # AUS
```

Oder per MQTT über den Standard-MQTT-Proxy von Venus:
```
W/<portal-id>/ioextender/<instance>/SwitchableOutput/<id>/State → {"value": 1}
```

---

## Zusammenfassung: Was ist nativ, was braucht OCC?

| Funktion | Native Venus-Unterstützung | OCC-Beitrag |
|---|---|---|
| Relais ein/aus (Manual) | Ja (GUI Switch-Panel) | Automatisierung per MQTT |
| Relais per Temperatur | Ja (temprelay Service) | OCC liefert Temperaturen per Bridge |
| Digital Input Alarm | Ja (Notification System) | OCC reagiert auf Events |
| Gruppierung in GUI | Ja (Settings/Group) | Setup-Script setzt Groups |
| Benannte Kanäle | Ja (Settings/Name) | Setup-Script setzt Namen |
| Zonenlogik (Auto-Modus) | Nein | OCC-eigene Logik im Bridge-Service |
| Zeitprogramme | Nein | OCC-Backend (MQTT-seitig) |
| Frostschutz-Automatik | Nein | OCC-Backend-Logik |

---

## Enum-Referenz (aus `src/enums.h`)

### SwitchableOutput_Function

| Wert | Enum | Beschreibung |
|---|---|---|
| -1 | Disabled | Kanal deaktiviert |
| 0 | Alarm | Alarm-Relais |
| 1 | GeneratorStartStop | Generator-Steuerung |
| 2 | Manual | Manuell schaltbar (GUI Switch) |
| 3 | Tank_Pump | Tankpumpe |
| 4 | Temperature | Temperaturgesteuert |
| 5 | GensetHelperRelay | Genset-Hilfsrelais |
| 6 | OpportunityLoad | Überschuss-Ladung |

### DigitalInput_Type

| Wert | Enum | Beschreibung |
|---|---|---|
| 0 | Disabled | Deaktiviert |
| 1 | PulseMeter | Impulszähler |
| 2 | DoorAlarm | Türalarm |
| 3 | BilgePump | Bilgenpumpe |
| 4 | BilgeAlarm | Bilgenalarm |
| 5 | BurglarAlarm | Einbruchalarm |
| 6 | SmokeAlarm | Rauchmelder |
| 7 | FireAlarm | Feueralarm |
| 8 | CO2Alarm | CO2-Alarm |
| 9 | Generator | Generator-Status |
| 11 | TouchInputControl | Touch/Thermostat-Kontakt |
