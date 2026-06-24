# OpenCamperCore — Heating/Climate QML-Seitenstruktur

Stand: 2026-05-26

---

## Übersicht der Seiten

| Seite | Dateiname | Typ | Zugang | Beschreibung |
|---|---|---|---|---|
| Heizung Hauptseite | `PageHeating.qml` | Plugin Typ 1 | Settings → Plugins → OCC | Zonenübersicht |
| Zone Detail | `PageHeatingZone.qml` | Sub-Page | Von PageHeating | Einzelzone konfigurieren |
| Klima Hauptseite | `PageClimate.qml` | Plugin Typ 1 | Settings → Plugins → OCC | Klimaanlage steuern |
| OCC Einstellungen | `PageOccSettings.qml` | Plugin Typ 1 | Settings → Plugins → OCC | Konfiguration |
| Thermostat-Einst. | `PageHeatingSettings.qml` | Sub-Page | Von PageOccSettings | Hysterese, Grenzen |

---

## Plugin-Manifest (`plugin.json`)

```json
{
  "serialNumber": "OCC001",
  "version": "1.0.0",
  "name": "OpenCamperCore",
  "pages": [
    {
      "type": "PluginSettingsPage",
      "title": "OCC Heizung",
      "source": "PageHeating.qml"
    },
    {
      "type": "PluginSettingsPage",
      "title": "OCC Klima",
      "source": "PageClimate.qml"
    },
    {
      "type": "PluginSettingsPage",
      "title": "OCC Einstellungen",
      "source": "PageOccSettings.qml"
    }
  ]
}
```

---

## Seite 1: PageHeating.qml — Zonenübersicht

### Wireframe (ASCII)

```
┌─────────────────────────────────────────────────┐
│  ← OCC Heizung                                  │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌─── Status ─────────────────────────────────┐ │
│  │  System:  ● Aktiv     Fehler: Keine        │ │
│  └────────────────────────────────────────────┘ │
│                                                 │
│  ┌─── Zone 1: Wohnbereich ───────────────────┐ │
│  │  Ist: 21.5°C    Soll: 22.0°C    🔥 Heizen │ │
│  │  Modus: Auto    Relais: EIN               │ │
│  │                                     [→]   │ │
│  └────────────────────────────────────────────┘ │
│                                                 │
│  ┌─── Zone 2: Schlafbereich ─────────────────┐ │
│  │  Ist: 18.3°C    Soll: 19.0°C    ○ Aus     │ │
│  │  Modus: Manuell Relais: AUS               │ │
│  │                                     [→]   │ │
│  └────────────────────────────────────────────┘ │
│                                                 │
└─────────────────────────────────────────────────┘
```

### QML-Struktur

```qml
import QtQuick
import Victron.VenusOS

Page {
    id: root

    readonly property string serviceUid: BackendConnection.serviceUidForType("heating")

    GradientListView {
        model: VisibleItemModel {

            // Systemstatus
            ListTextItem {
                text: qsTrId("occ_heating_system_status")
                secondaryText: {
                    switch (statusItem.value) {
                    case 0: return qsTrId("occ_status_offline")
                    case 1: return qsTrId("occ_status_standby")
                    case 2: return qsTrId("occ_status_active")
                    default: return "---"
                    }
                }
            }

            // Zone-Repeater
            Repeater {
                model: zoneCount.isValid ? zoneCount.value : 0

                delegate: ListNavigation {
                    readonly property int zoneId: index + 1
                    readonly property string zonePrefix: root.serviceUid + "/Zone/" + zoneId

                    text: zoneName.value || qsTrId("occ_zone") + " " + zoneId
                    secondaryText: {
                        if (!zoneTemp.isValid) return "---"
                        return Units.formatValue(zoneTemp.value, VenusOS.Units_Temperature)
                              + " → "
                              + Units.formatValue(zoneSetpoint.value, VenusOS.Units_Temperature)
                    }

                    onClicked: {
                        Global.pageManager.pushPage(zonePageComponent, {
                            "title": text,
                            "zoneId": zoneId,
                            "serviceUid": root.serviceUid
                        })
                    }

                    VeQuickItem { id: zoneName; uid: zonePrefix + "/Name" }
                    VeQuickItem { id: zoneTemp; uid: zonePrefix + "/Temperature" }
                    VeQuickItem { id: zoneSetpoint; uid: zonePrefix + "/Setpoint" }
                }
            }
        }
    }

    VeQuickItem { id: statusItem; uid: root.serviceUid + "/Status" }
    VeQuickItem { id: zoneCount; uid: root.serviceUid + "/NumberOfZones" }

    Component {
        id: zonePageComponent
        PageHeatingZone {}
    }
}
```

### VeQuickItem-Bindings

| Property | UID | Typ | Beschreibung |
|---|---|---|---|
| statusItem | `<service>/Status` | int (enum) | 0=Offline, 1=Standby, 2=Active |
| zoneCount | `<service>/NumberOfZones` | int | Dynamische Zonenanzahl |
| zoneName | `<service>/Zone/<id>/Name` | string | Zonenname |
| zoneTemp | `<service>/Zone/<id>/Temperature` | float | Ist-Temperatur |
| zoneSetpoint | `<service>/Zone/<id>/Setpoint` | float | Soll-Temperatur |

---

## Seite 2: PageHeatingZone.qml — Zone Detail

### Wireframe (ASCII)

```
┌─────────────────────────────────────────────────┐
│  ← Wohnbereich                                  │
├─────────────────────────────────────────────────┤
│                                                 │
│  Ist-Temperatur           21.5 °C               │
│  ─────────────────────────────────────────────  │
│  Soll-Temperatur    [────●────────] 22.0 °C     │
│  ─────────────────────────────────────────────  │
│  Modus              [Manuell ▼]                 │
│  ─────────────────────────────────────────────  │
│  Status                   🔥 Heizen              │
│  ─────────────────────────────────────────────  │
│  Relais                   EIN                   │
│  ─────────────────────────────────────────────  │
│  Hysterese                1.0 °C                │
│  ─────────────────────────────────────────────  │
│                                                 │
└─────────────────────────────────────────────────┘
```

### QML-Struktur

```qml
import QtQuick
import Victron.VenusOS

Page {
    id: root

    required property int zoneId
    required property string serviceUid

    readonly property string zonePrefix: serviceUid + "/Zone/" + zoneId

    GradientListView {
        model: VisibleItemModel {

            ListQuantityItem {
                text: qsTrId("occ_temperature_current")
                dataItem.uid: root.zonePrefix + "/Temperature"
                unit: VenusOS.Units_Temperature
            }

            ListSlider {
                text: qsTrId("occ_temperature_setpoint")
                dataItem.uid: root.zonePrefix + "/Setpoint"
                writeAccessLevel: VenusOS.User_AccessType_User
                from: 5.0
                to: 35.0
                stepSize: 0.5
                unit: VenusOS.Units_Temperature
            }

            ListRadioButtonGroup {
                text: qsTrId("occ_mode")
                dataItem.uid: root.zonePrefix + "/Mode"
                writeAccessLevel: VenusOS.User_AccessType_User
                optionModel: [
                    { display: qsTrId("occ_mode_manual"), value: 0 },
                    { display: qsTrId("occ_mode_auto"), value: 1 },
                    { display: qsTrId("occ_mode_off"), value: 2 }
                ]
            }

            ListTextItem {
                text: qsTrId("occ_state")
                dataItem.uid: root.zonePrefix + "/State"
                secondaryText: {
                    switch (dataItem.value) {
                    case 0: return qsTrId("occ_state_off")
                    case 1: return qsTrId("occ_state_heating")
                    case 2: return qsTrId("occ_state_cooling")
                    default: return "---"
                    }
                }
            }

            ListTextItem {
                text: qsTrId("occ_relay_state")
                dataItem.uid: root.zonePrefix + "/RelayState"
                secondaryText: dataItem.value === 1
                    ? CommonWords.on : CommonWords.off
            }
        }
    }
}
```

### VeQuickItem-Bindings

| Property | UID | Typ | Zugriff | Range |
|---|---|---|---|---|
| Temperature | `<zone>/Temperature` | float | R | -40…+80 °C |
| Setpoint | `<zone>/Setpoint` | float | R/W | 5.0…35.0 °C |
| Mode | `<zone>/Mode` | int | R/W | 0=Manual, 1=Auto, 2=Off |
| State | `<zone>/State` | int | R | 0=Off, 1=Heating, 2=Cooling |
| RelayState | `<zone>/RelayState` | int | R | 0=Open, 1=Closed |
| Name | `<zone>/Name` | string | R | — |

---

## Seite 3: PageClimate.qml — Klimaanlage

### Wireframe (ASCII)

```
┌─────────────────────────────────────────────────┐
│  ← OCC Klima                                    │
├─────────────────────────────────────────────────┤
│                                                 │
│  Modus              [Aus ▼]                     │
│  ─────────────────────────────────────────────  │
│  Ist-Temperatur           23.1 °C               │
│  ─────────────────────────────────────────────  │
│  Ziel-Temperatur    [────●────────] 24.0 °C     │
│  ─────────────────────────────────────────────  │
│  Status                   Idle                  │
│  ─────────────────────────────────────────────  │
│                                                 │
└─────────────────────────────────────────────────┘
```

### QML-Struktur

```qml
import QtQuick
import Victron.VenusOS

Page {
    id: root

    readonly property string serviceUid: BackendConnection.serviceUidForType("heating")
    readonly property string climatePrefix: serviceUid + "/Climate"

    GradientListView {
        model: VisibleItemModel {

            ListRadioButtonGroup {
                text: qsTrId("occ_climate_mode")
                dataItem.uid: root.climatePrefix + "/Mode"
                writeAccessLevel: VenusOS.User_AccessType_User
                optionModel: [
                    { display: qsTrId("occ_climate_off"), value: 0 },
                    { display: qsTrId("occ_climate_cool"), value: 1 },
                    { display: qsTrId("occ_climate_heat"), value: 2 },
                    { display: qsTrId("occ_climate_auto"), value: 3 }
                ]
            }

            ListQuantityItem {
                text: qsTrId("occ_temperature_current")
                dataItem.uid: root.climatePrefix + "/Temperature"
                unit: VenusOS.Units_Temperature
            }

            ListSlider {
                text: qsTrId("occ_climate_setpoint")
                dataItem.uid: root.climatePrefix + "/Setpoint"
                writeAccessLevel: VenusOS.User_AccessType_User
                from: 16.0
                to: 30.0
                stepSize: 0.5
                unit: VenusOS.Units_Temperature
            }

            ListTextItem {
                text: qsTrId("occ_climate_state")
                dataItem.uid: root.climatePrefix + "/State"
                secondaryText: dataItem.value === 1
                    ? qsTrId("occ_climate_active")
                    : qsTrId("occ_climate_idle")
            }
        }
    }
}
```

### VeQuickItem-Bindings

| Property | UID | Typ | Zugriff | Range |
|---|---|---|---|---|
| Mode | `<climate>/Mode` | int | R/W | 0=Off, 1=Cool, 2=Heat, 3=Auto |
| Temperature | `<climate>/Temperature` | float | R | -40…+80 °C |
| Setpoint | `<climate>/Setpoint` | float | R/W | 16.0…30.0 °C |
| State | `<climate>/State` | int | R | 0=Idle, 1=Active |

---

## Seite 4: PageOccSettings.qml — Einstellungen

### Wireframe (ASCII)

```
┌─────────────────────────────────────────────────┐
│  ← OCC Einstellungen                            │
├─────────────────────────────────────────────────┤
│                                                 │
│  Heizung Einstellungen                    [→]   │
│  ─────────────────────────────────────────────  │
│  Sensor-Zuordnung                         [→]   │
│  ─────────────────────────────────────────────  │
│  Relais-Zuordnung                         [→]   │
│  ─────────────────────────────────────────────  │
│  StatusBar Temperatur-Sensor   [Sensor 1 ▼]    │
│  ─────────────────────────────────────────────  │
│  MQTT-Status              ● Verbunden           │
│  ─────────────────────────────────────────────  │
│  Firmware-Version         1.0.0                 │
│  ─────────────────────────────────────────────  │
│                                                 │
└─────────────────────────────────────────────────┘
```

### QML-Struktur

```qml
import QtQuick
import Victron.VenusOS

Page {
    id: root

    readonly property string serviceUid: BackendConnection.serviceUidForType("heating")

    GradientListView {
        model: VisibleItemModel {

            ListNavigation {
                text: qsTrId("occ_settings_heating")
                onClicked: Global.pageManager.pushPage(heatingSettingsComponent, { "title": text })
            }

            ListNavigation {
                text: qsTrId("occ_settings_sensor_mapping")
                onClicked: Global.pageManager.pushPage(sensorMappingComponent, { "title": text })
            }

            ListNavigation {
                text: qsTrId("occ_settings_relay_mapping")
                onClicked: Global.pageManager.pushPage(relayMappingComponent, { "title": text })
            }

            ListSpinBox {
                text: qsTrId("occ_settings_statusbar_sensor")
                dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Gui2/StatusBar/TemperatureSensorIndex"
                from: 0
                to: 10
            }

            ListTextItem {
                text: qsTrId("occ_mqtt_status")
                dataItem.uid: root.serviceUid + "/Status"
                secondaryText: {
                    switch (dataItem.value) {
                    case 0: return qsTrId("occ_mqtt_disconnected")
                    case 1: return qsTrId("occ_mqtt_standby")
                    case 2: return qsTrId("occ_mqtt_connected")
                    default: return "---"
                    }
                }
            }

            ListTextItem {
                text: qsTrId("occ_firmware_version")
                dataItem.uid: root.serviceUid + "/FirmwareVersion"
            }
        }
    }

    Component { id: heatingSettingsComponent; PageHeatingSettings {} }
    Component { id: sensorMappingComponent; PageOccSensorMapping {} }
    Component { id: relayMappingComponent; PageOccRelayMapping {} }
}
```

---

## Seite 5: PageHeatingSettings.qml — Thermostat-Parameter

### QML-Struktur

```qml
import QtQuick
import Victron.VenusOS

Page {
    id: root

    readonly property string serviceUid: BackendConnection.serviceUidForType("heating")

    GradientListView {
        model: VisibleItemModel {

            PrimaryListLabel {
                text: qsTrId("occ_settings_thermostat_parameters")
            }

            ListSlider {
                text: qsTrId("occ_settings_hysteresis")
                dataItem.uid: root.serviceUid + "/Settings/Hysteresis"
                from: 0.2
                to: 5.0
                stepSize: 0.1
                unit: VenusOS.Units_Temperature
            }

            ListSlider {
                text: qsTrId("occ_settings_min_setpoint")
                dataItem.uid: root.serviceUid + "/Settings/MinSetpoint"
                from: 0.0
                to: 15.0
                stepSize: 0.5
                unit: VenusOS.Units_Temperature
            }

            ListSlider {
                text: qsTrId("occ_settings_max_setpoint")
                dataItem.uid: root.serviceUid + "/Settings/MaxSetpoint"
                from: 25.0
                to: 40.0
                stepSize: 0.5
                unit: VenusOS.Units_Temperature
            }

            ListSlider {
                text: qsTrId("occ_settings_timeout_minutes")
                dataItem.uid: root.serviceUid + "/Settings/SensorTimeout"
                from: 1
                to: 30
                stepSize: 1
                suffix: "min"
            }

            ListSwitch {
                text: qsTrId("occ_settings_frost_protection")
                dataItem.uid: root.serviceUid + "/Settings/FrostProtection"
            }

            ListSlider {
                text: qsTrId("occ_settings_frost_threshold")
                dataItem.uid: root.serviceUid + "/Settings/FrostThreshold"
                from: 0.0
                to: 10.0
                stepSize: 0.5
                unit: VenusOS.Units_Temperature
                preferredVisible: frostProtection.value === 1
            }
        }
    }

    VeQuickItem {
        id: frostProtection
        uid: root.serviceUid + "/Settings/FrostProtection"
    }
}
```

---

## Service-UID Auflösung

Die GUI-v2 verwendet `BackendConnection.serviceUidForType()` um den korrekten Präfix zu erhalten:

| Backend | serviceUidForType("heating") | Ergebnis |
|---|---|---|
| D-Bus (GX) | `dbus/com.victronenergy.heating.occ` | Direkter D-Bus Zugriff |
| MQTT (Wasm) | `mqtt/heating.occ` | Via MQTT-Broker |
| Mock | `mock/com.victronenergy.heating.occ` | Für Entwicklung |

Voraussetzung: Der Service `com.victronenergy.heating.occ` muss in `BackendConnection` als bekannter Typ registriert sein. Falls nicht nativ unterstützt, wird die UID direkt konstruiert:

```qml
readonly property string serviceUid: BackendConnection.type === BackendConnection.MqttSource
    ? "mqtt/heating.occ"
    : "dbus/com.victronenergy.heating.occ"
```

---

## Übersetzungs-Keys

| Key | DE | EN |
|---|---|---|
| `occ_heating_system_status` | Systemstatus | System status |
| `occ_status_offline` | Offline | Offline |
| `occ_status_standby` | Standby | Standby |
| `occ_status_active` | Aktiv | Active |
| `occ_zone` | Zone | Zone |
| `occ_temperature_current` | Ist-Temperatur | Current temperature |
| `occ_temperature_setpoint` | Soll-Temperatur | Setpoint |
| `occ_mode` | Modus | Mode |
| `occ_mode_manual` | Manuell | Manual |
| `occ_mode_auto` | Automatik | Automatic |
| `occ_mode_off` | Aus | Off |
| `occ_state` | Status | State |
| `occ_state_off` | Aus | Off |
| `occ_state_heating` | Heizen | Heating |
| `occ_state_cooling` | Kühlen | Cooling |
| `occ_relay_state` | Relais | Relay |
| `occ_climate_mode` | Klima-Modus | Climate mode |
| `occ_climate_off` | Aus | Off |
| `occ_climate_cool` | Kühlen | Cooling |
| `occ_climate_heat` | Heizen | Heating |
| `occ_climate_auto` | Automatik | Automatic |
| `occ_climate_setpoint` | Ziel-Temperatur | Target temperature |
| `occ_climate_state` | Klima-Status | Climate state |
| `occ_climate_active` | Aktiv | Active |
| `occ_climate_idle` | Bereit | Idle |
| `occ_settings_heating` | Heizung Einstellungen | Heating settings |
| `occ_settings_sensor_mapping` | Sensor-Zuordnung | Sensor mapping |
| `occ_settings_relay_mapping` | Relais-Zuordnung | Relay mapping |
| `occ_settings_statusbar_sensor` | StatusBar Temperatur-Sensor | StatusBar temperature sensor |
| `occ_mqtt_status` | MQTT-Status | MQTT status |
| `occ_mqtt_disconnected` | Nicht verbunden | Disconnected |
| `occ_mqtt_standby` | Warte auf Daten | Waiting for data |
| `occ_mqtt_connected` | Verbunden | Connected |
| `occ_firmware_version` | Firmware-Version | Firmware version |
| `occ_settings_hysteresis` | Hysterese | Hysteresis |
| `occ_settings_min_setpoint` | Min. Sollwert | Min. setpoint |
| `occ_settings_max_setpoint` | Max. Sollwert | Max. setpoint |
| `occ_settings_timeout_minutes` | Sensor-Timeout | Sensor timeout |
| `occ_settings_frost_protection` | Frostschutz | Frost protection |
| `occ_settings_frost_threshold` | Frostschutz-Schwelle | Frost threshold |
