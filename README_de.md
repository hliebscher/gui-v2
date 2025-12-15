# GUI-Variablen und Werte-Definitionen

Dieses Dokument beschreibt, wo die verschiedenen Variablen und Werte für die GUI definiert sind.

## 1. Theme-Variablen (JSON-Dateien)

Die Theme-Variablen (Farben, Geometrie, Typografie, Animationen) werden in JSON-Dateien definiert und von einem Python-Script in C++-Code umgewandelt.

### Farben

- **`themes/color/ColorDesign.json`**: Basis-Farbdefinitionen
  - Enthält alle Grundfarben wie `color_blue`, `color_freshWater`, `color_lpg`, etc.
  - Diese werden von den Theme-spezifischen Dateien referenziert

- **`themes/color/Dark.json`**: Dark Theme Farben
  - Definiert alle Farben für das dunkle Theme
  - Verwendet Referenzen auf `ColorDesign.json` (z.B. `"color_ok": "color_blue"`)

- **`themes/color/Light.json`**: Light Theme Farben
  - Definiert alle Farben für das helle Theme
  - Verwendet ebenfalls Referenzen auf `ColorDesign.json`

### Weitere Theme-Dateien

- **`themes/geometry/*.json`**: Geometrie-Definitionen (z.B. `FiveInch.json`, `SevenInch.json`)
- **`themes/typography/*.json`**: Typografie-Definitionen (Schriftarten, Größen)
- **`themes/animation/Animation.json`**: Animation-Definitionen

### Verarbeitung

Die JSON-Dateien werden von `tools/themeparser.py` verarbeitet und in C++-Code (`src/themeobjects.h`) umgewandelt. Das Theme ist dann als Singleton `Theme` in QML verfügbar.

**Beispiel-Verwendung in QML:**
```qml
Rectangle {
    color: Theme.color_background_primary
    border.color: Theme.color_ok
}
```

## 2. Settings und Backend-Werte (JSON für Mock-Builds)

Für Mock-Builds (z.B. WASM oder Desktop-Tests) werden die initialen Settings und Backend-Werte aus JSON-Dateien geladen.

### Mock-Konfigurationen

- **`data/mock/conf/setup-common.json`**: Initiale Settings-Werte
  - Enthält alle Standard-Settings wie:
    - `/Settings/Gui2/StatusBar/TemperatureSensorIndex`
    - `/Settings/System/TimeZone`
    - `/Settings/System/Units/Temperature`
    - etc.
  - Wird beim Start eines Mock-Builds geladen

- **`data/mock/conf/services/*.json`**: Service-spezifische Mock-Daten
  - Beispiel: `tank-lpg.json`, `mppt1.json`, `pylontech.json`
  - Simulieren reale Geräte-Daten für Tests

- **`data/mock/conf/*.json`**: Vollständige Mock-Konfigurationen
  - `maximal.json`: Maximale Konfiguration mit vielen Services
  - `barebones.json`: Minimale Konfiguration
  - `multi-rs.json`: Multi RS Inverter/Charger Konfiguration
  - etc.

### Verarbeitung

Die JSON-Dateien werden von `src/mockmanager.cpp` geladen und in den Mock-Backend eingespielt. Die Werte sind dann über `VeQuickItem` mit den entsprechenden UIDs verfügbar.

## 3. QML-Datenquellen

Die Datenquellen für die GUI werden in QML-Dateien definiert und über `Global.qml` als Singleton bereitgestellt.

### Global.qml

Definiert die globalen Variablen und Datenquellen:

```qml
property var acInputs
property var dcInputs
property var environmentInputs
property var evChargers
property var generators
property var inverterChargers
property var notifications
property var solarInputs
property var system
property var switches
property var systemSettings
property var tanks
```

### Datenquellen-Dateien

- **`data/EnvironmentInputs.qml`**: Filtert Temperatursensoren
  - Verwendet `FilteredDeviceModel` mit `serviceTypes: ["temperature"]`
  - Stellt `Global.environmentInputs.model` bereit

- **`data/Tanks.qml`**: Tank-Datenquelle
- **`data/SolarInputs.qml`**: Solar-Datenquelle
- **`data/AcInputs.qml`**: AC-Eingangs-Datenquelle
- **`data/DcInputs.qml`**: DC-Eingangs-Datenquelle
- **`data/SystemSettings.qml`**: System-Settings
- etc.

**Beispiel-Verwendung:**
```qml
Repeater {
    model: Global.environmentInputs.model
    // ...
}
```

## 4. Settings im laufenden System

Settings werden über `VeQuickItem` mit UIDs (Unique Identifiers) gelesen und geschrieben.

### UID-Format

- **D-Bus (echtes System)**: `com.victronenergy.settings/Settings/Gui2/StatusBar/TemperatureSensorIndex`
- **MQTT/WASM**: `mqtt/settings/0/Settings/Gui2/StatusBar/TemperatureSensorIndex`
- **Mock**: Wird aus JSON-Dateien geladen, aber verwendet das gleiche UID-Format

### VeQuickItem-Verwendung

```qml
VeQuickItem {
    id: statusBarTemperatureSensorIndex
    uid: Global.systemSettings.serviceUid + "/Settings/Gui2/StatusBar/TemperatureSensorIndex"
    onValueChanged: {
        if (valid) {
            // Wert wurde geändert
        }
    }
}
```

### Settings-Speicherung

- **Echtes System**: Settings werden im Backend (Venus OS) gespeichert
- **Mock**: Settings werden in `data/mock/conf/setup-common.json` initialisiert
- **WASM**: Settings werden über MQTT kommuniziert

## 5. Zusammenfassung

| Typ | Ort | Format | Verwendung |
|-----|-----|--------|------------|
| **Theme-Farben** | `themes/color/*.json` | JSON | `Theme.color_*` in QML |
| **Theme-Geometrie** | `themes/geometry/*.json` | JSON | `Theme.*` in QML |
| **Theme-Typografie** | `themes/typography/*.json` | JSON | `Theme.*` in QML |
| **Mock-Settings** | `data/mock/conf/setup-common.json` | JSON | Initiale Settings für Mock |
| **Mock-Services** | `data/mock/conf/services/*.json` | JSON | Mock-Gerätedaten |
| **Datenquellen** | `data/*.qml` | QML | `Global.*` in QML |
| **Runtime-Settings** | D-Bus/MQTT | VeQuickItem | `/Settings/...` UIDs |

## 6. Wichtige Hinweise

1. **Theme-Änderungen**: Nach Änderungen an Theme-JSON-Dateien muss das Projekt neu gebaut werden, damit `themeparser.py` die Änderungen verarbeitet.

2. **Mock-Settings**: Neue Settings sollten in `data/mock/conf/setup-common.json` initialisiert werden, damit sie in Mock-Builds verfügbar sind.

3. **WASM-Cache**: Bei WASM-Builds kann ein Browser-Cache-Flush notwendig sein, damit Theme-Änderungen sichtbar werden.

4. **UID-Konsistenz**: Settings-UIDs müssen konsistent sein zwischen:
   - Der Definition in QML (`VeQuickItem.uid`)
   - Der Initialisierung in Mock-Konfigurationen (`setup-common.json`)
   - Dem Backend-System (Venus OS)

