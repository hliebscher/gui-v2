# OCC Steuerseite — 3 Heizung + 2 Klima (Design)

**Stand:** 2026-06-24  
**Status:** Freigegeben 2026-06-24 — Implementierung gestartet  
**Service:** `com.victronenergy.heating.occ`  
**GUI-Zugang:** Einstellungen → Heating & Climate (Fork-Seite, kein Plugin)

---

## 1. Ziel

Eine **eigene Steuerseite** mit maximaler Übersicht — analog zum Bediengefühl der **Temperatur-Slider unter Schaltern**, aber:

- Layout und Reihenfolge **frei wählbar** (nicht an Schalter-Gruppen gebunden)
- **3 Heizungszonen** + **2 Klimaanlagen** auf einer Seite
- Daten und Logik über **`dbus-mqtt-occ`** (flexibel, WASM-fähig)
- Detailseiten (Modus, Ventile, Parameter) optional über Tap auf Zeile

---

## 2. Wireframe — Landscape (Primär, GX)

```
┌─ Heating & Climate ───────────────────────────────────────────────────────────┐
│ ←                                                                             │
├───────────────────────────────────────────────────────────────────────────────┤
│  System:  ● Aktiv                                    MQTT: verbunden          │
├───────────────────────────────────────────────────────────────────────────────┤
│  HEIZUNG                                                                      │
│                                                                               │
│  Wohnraum          21.5 / 22.0 °C                                             │
│  [●────────────────●────────────────●────────────────●──────────────○]  22 °C │
│                                                    ↑ Ist (grau)  Soll (fett)  │
│                                                                               │
│  Bad               19.2 / 20.0 °C                              ○ Heizt nicht    │
│  [●────────────●────────────────●────────────────●──────────────────○]  20 °C │
│                                                                               │
│  Schlafraum        18.0 / 19.0 °C                              ↑ Heizt       │
│  [●──────────●────────────────●────────────────●────────────────────○]  19 °C │
│                                                                               │
├───────────────────────────────────────────────────────────────────────────────┤
│  KLIMA                                                                        │
│                                                                               │
│  Klima Wohnen      24.1 / 22.0 °C     [ Aus | Kühlen | Heizen | Auto ]        │
│  [●──────────────────●────────────────●────────────────○]              22 °C │
│                                                                               │
│  Klima Schlafen    23.5 / 21.0 °C     [ Aus | Kühlen | Heizen | Auto ]        │
│  [●────────────────●────────────────●───────────────○]                   21 °C │
│                                                                               │
│  [⚙ Erweitert: Zonen-Details · Pumpen · Ventile · Parameter]                  │
└───────────────────────────────────────────────────────────────────────────────┘
```

### Portrait (GX / schmal)

- Gleiche Blöcke **untereinander** (eine Spalte)
- Modus-Chips für Klima **unter** dem Slider (nicht rechts daneben)
- Systemstatus eine Zeile, kompakt

---

## 3. Interaktion

| Element | Aktion |
|---------|--------|
| **Temperatur-Slider** | Sollwert schreiben (`Setpoint`), Schritt 0,5 °C |
| **Zonenname + Ist/Soll** | Tap → `HeatingZonePage` (Modus, Ventile, Relais) |
| **Klima Modus-Chips** | Schreibt `Mode` (0= Aus, 1= Kühlen, 2= Heizen, 3= Auto) |
| **Klima-Zeile (ohne Chip)** | Tap → `HeatingClimateUnitPage` (Detail) |
| **Erweitert** | Optional: OCC-Parameter (Hysterese, MQTT-Status) |

**Kein** NavBar-Tab (Schwarzbild-Risiko). Optional: Control Card nur als **„Seite öffnen“**-Shortcut.

---

## 4. UI-Komponente: Slider-Look wie Schalter

`TemperatureSlider` ist an `SwitchableOutput` gebunden und **nicht** direkt für OCC nutzbar.

**Neu:** `OccSetpointSliderRow.qml` (Fork, `components/`)

| Property | Typ | Beschreibung |
|----------|-----|--------------|
| `title` | string | z. B. „Wohnraum“ |
| `setpointUid` | string | D-Bus-Pfad Sollwert (schreibbar) |
| `temperatureUid` | string | D-Bus-Pfad Istwert (read-only) |
| `from` / `to` / `stepSize` | real | Grenzen aus Config oder `/Settings/*` |
| `stateUid` | string | optional, für „Heizt“-Indikator |
| `stateHeatingValue` | int | z. B. `1` = heizt |

Visuell: gleiche Farbverläufe / Dot-Anzeige wie `TemperatureSlider` (Theme-Farben wiederverwenden).

---

## 5. D-Bus-Modell (Erweiterung)

**Basis-UID:**

| Backend | UID |
|---------|-----|
| GX (D-Bus) | `dbus/com.victronenergy.heating.occ` |
| WASM (MQTT) | `mqtt/heating.occ` |

### 5.1 Bestehend — Heizung (unverändert)

```
/NumberOfZones                    int     R      3
/Status                           int     R      0=Offline, 1=Standby, 2=Aktiv

/Zone/<n>/Name                    string  R
/Zone/<n>/Temperature             float   R      °C, Ist
/Zone/<n>/Setpoint                float   R/W    °C, Soll  ← Slider
/Zone/<n>/State                   int     R      0=Aus, 1=Heizen, 2=Kühlen
/Zone/<n>/Mode                    int     R/W    0=Manuell, 1=Auto, 2=Aus
/Zone/<n>/RelayState              int     R
/Zone/<n>/ValveState              int     R      Bitmaske Ventile
```

`<n>` = 1 … 3 (Wohnraum, Bad, Schlafraum)

### 5.2 Neu — Klima (2 Einheiten)

**Bisher:** flache Pfade `/Climate/Mode`, `/Climate/Setpoint`, …  
**Neu:** indexierte Pfade (Migration siehe §7)

```
/NumberOfClimateUnits             int     R      2

/Climate/<n>/Name                 string  R      z. B. „Klima Wohnen“
/Climate/<n>/Temperature          float   R      °C, Ist
/Climate/<n>/Setpoint             float   R/W    °C, Soll  ← Slider
/Climate/<n>/Mode                 int     R/W    0=Aus, 1=Kühlen, 2=Heizen, 3=Auto
/Climate/<n>/State                int     R      0=Idle, 1=Aktiv
```

`<n>` = 1 … 2

### 5.3 Globale Hilfspfade (optional Phase 2)

```
/Settings/MinSetpoint             float   R
/Settings/MaxSetpoint             float   R
/Settings/ClimateMinSetpoint      float   R
/Settings/ClimateMaxSetpoint      float   R
/Mgmt/Connection                  string  R      „MQTT verbunden“ / Fehler
```

---

## 6. MQTT-Mapping (Bridge)

Topic-Prefix: `occ` (aus `config.ini`)

### Heizung (bestehend)

| MQTT Topic | D-Bus |
|------------|-------|
| `occ/heating/zone/<id>/temperature` | `/Zone/<id>/Temperature` |
| `occ/heating/zone/<id>/setpoint` | `/Zone/<id>/Setpoint` |
| `occ/heating/zone/<id>/setpoint/set` | SetValue Setpoint |
| `occ/heating/zone/<id>/state` | `/Zone/<id>/State` |
| `occ/heating/zone/<id>/mode` | `/Zone/<id>/Mode` |

### Klima (neu, symmetrisch zu Zonen)

| MQTT Topic | D-Bus |
|------------|-------|
| `occ/climate/<id>/temperature` | `/Climate/<id>/Temperature` |
| `occ/climate/<id>/setpoint` | `/Climate/<id>/Setpoint` |
| `occ/climate/<id>/setpoint/set` | SetValue Setpoint |
| `occ/climate/<id>/mode` | `/Climate/<id>/Mode` |
| `occ/climate/<id>/mode/set` | SetValue Mode |
| `occ/climate/<id>/state` | `/Climate/<id>/State` |

**Legacy (Übergang):** `occ/climate/mode` → spiegelt `/Climate/1/Mode` (nur lesend/schreibend auf Unit 1)

---

## 7. config.ini (Erweiterung)

```ini
[HEATING]
Zones = 3
ZoneNames = Wohnraum,Bad,Schlafraum
DefaultSetpoint = 20.0
MinSetpoint = 5.0
MaxSetpoint = 35.0

[CLIMATE]
Units = 2
UnitNames = Klima Wohnen,Klima Schlafen
DefaultSetpoint = 22.0
MinSetpoint = 16.0
MaxSetpoint = 30.0

; Legacy-Kompatibilität: Enabled = true wenn Units >= 1
Enabled = true
```

---

## 8. GUI-Dateien (Implementierung)

| Datei | Änderung |
|-------|----------|
| `pages/HeatingPage.qml` | **Neu layout:** 3× `OccSetpointSliderRow` + 2× Klima-Block mit Slider + Modus |
| `pages/HeatingZonePage.qml` | Unverändert (Detail), von Zeilen-Tap |
| `pages/HeatingClimatePage.qml` | → `HeatingClimateUnitPage.qml` mit `climateId` (1 oder 2) |
| `components/OccSetpointSliderRow.qml` | **Neu** — Slider-Zeile |
| `components/HeatingCard.qml` | Kompakt: 3+2 Kurzzeilen, Button „Steuerseite öffnen“ |
| `services/dbus-mqtt-occ/dbus-mqtt-occ.py` | `/Climate/<n>/…`, `/NumberOfClimateUnits` |
| `i18n/translation-overrides.json` | DE-Texte für neue Keys |

**Entfernen / nicht nutzen:** flache `/Climate/*`-Only-UI auf der Hauptseite nach Migration.

---

## 9. Implementierungsreihenfolge

1. **Backend:** `Climate/1`, `Climate/2` + MQTT + Legacy-Alias  
2. **OccSetpointSliderRow** + statisches Layout in `HeatingPage` (3+2 hardcoded, Namen aus D-Bus)  
3. **Dynamisch:** `Repeater` über `NumberOfZones` / `NumberOfClimateUnits`  
4. **Übersetzungen** + GX/WASM-Test  
5. **HeatingCard** an neues Layout anpassen  

---

## 10. Abnahme-Kriterien

- [ ] Steuerseite zeigt **5 Slider-Zeilen** (3 Heiz + 2 Klima) ohne Unterseite nötig
- [ ] Slider schreiben Sollwert, Istwert aktualisiert sich (MQTT/D-Bus)
- [ ] Klima-Modus pro Einheit unabhängig schaltbar
- [ ] Tap auf Heizzeile → Zonen-Detail; Tap auf Klima → Klima-Detail
- [ ] WASM + GX ohne Schwarzbild / ohne NavBar-Tab
- [ ] `dbus -y com.victronenergy.heating.occ /Climate/2/Setpoint 21.5` funktioniert

---

## 11. Offene Punkte (vor Implementierung klären)

1. **Exakte Default-Namen** der 2 Klimaanlagen (Vorschlag: „Klima Wohnen“, „Klima Schlafen“)
2. **Soll Modus auf der Hauptseite** als Chip-Leiste oder nur in Detailseite?
3. **Hardware-Mapping** in Bridge: welches Relais/MQTT-Topic pro Klima-Unit?

---

## Freigabe

- [x] Design freigegeben durch Auftraggeber (2026-06-24, Punkte 1–3)
- [ ] Abnahme-Kriterien auf GX/WASM erfüllt
