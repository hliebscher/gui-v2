# OpenCamperCore — Finale Architektur-Entscheidung und Implementierungsreihenfolge

Stand: 2026-05-26

---

## Entscheidung: Hybrid-Architektur (Option C)

### Begründung

Nach Analyse aller drei Optionen (Plugin-Only, Fork-Only, Hybrid) wird die **Hybrid-Architektur** als optimale Lösung gewählt:

| Kriterium | Plugin-Only | Fork-Only | Hybrid |
|---|---|---|---|
| Update-Sicherheit | ★★★ | ★ | ★★ |
| Feature-Umfang | ★ | ★★★ | ★★★ |
| Wartungsaufwand | ★★★ | ★ | ★★ |
| Benutzer-Erfahrung (UX) | ★ | ★★★ | ★★★ |
| Entwicklungsaufwand | ★★ | ★★ | ★★ |
| Zukunftssicherheit | ★★ | ★ | ★★★ |

**Entscheidung:** Hybrid — weil die Limitierungen des Plugin-Systems (keine NavBar, keine StatusBar, keine Cards) eine vollständige Plugin-Lösung ausschließen, und ein reiner Fork die Update-Kosten langfristig untragbar macht.

---

## Drei-Schichten-Architektur

```
┌─────────────────────────────────────────────────────────────────┐
│                    SCHICHT 3: Fork-Layer                         │
│              (vario_2026.5 Branch, Merge-Pflege)                │
│                                                                 │
│  ┌──────────┐  ┌──────────────┐  ┌──────────┐  ┌───────────┐  │
│  │ StatusBar│  │ NavBar-Icon  │  │  Switch  │  │ Standby   │  │
│  │ Temp/Logo│  │ (Heating)    │  │  Cards   │  │ Page      │  │
│  └──────────┘  └──────────────┘  └──────────┘  └───────────┘  │
├─────────────────────────────────────────────────────────────────┤
│                    SCHICHT 2: Plugin-Layer                       │
│              (Extern, update-sicher, RCC-Paket)                 │
│                                                                 │
│  ┌──────────────┐  ┌───────────────┐  ┌─────────────────────┐  │
│  │ PageHeating  │  │ PageClimate   │  │ PageOccSettings     │  │
│  │ + Zone-Pages │  │               │  │ + Thermostat-Config │  │
│  └──────────────┘  └───────────────┘  └─────────────────────┘  │
├─────────────────────────────────────────────────────────────────┤
│                    SCHICHT 1: Bridge-Layer                       │
│              (Backend, komplett GUI-unabhängig)                  │
│                                                                 │
│  ┌─────────────────┐  ┌────────────────────┐  ┌─────────────┐  │
│  │ dbus-mqtt-occ   │  │ dbus-mqtt-temp     │  │ dbus-switch │  │
│  │ (Heizung/Klima) │  │ (Temperaturen)     │  │ (IO Ext.)   │  │
│  └─────────────────┘  └────────────────────┘  └─────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                    ┌─────────▼──────────┐
                    │   OCC-Hardware      │
                    │  ESP32 / Sensoren   │
                    │  MQTT Broker        │
                    └────────────────────┘
```

---

## Was gehört wohin?

### Fork-Layer (Merge-pflichtig)

| Komponente | Datei(en) | Änderungsart |
|---|---|---|
| StatusBar Temperatur | `StatusBar_Landscape.qml` | Bestehend (bereits integriert) |
| StatusBar Logo/Uhr | `StatusBar_Landscape.qml` | Bestehend (bereits integriert) |
| NavBar Heating-Icon | `SwipePageModel.qml`, `NavBar.qml` | NEU (minimal) |
| Switch-Card für Heizung | `ControlCard_Heating.qml` (neu) | NEU |
| StandbyPage | `pages/StandbyPage.qml` | Bestehend |
| PageContact | `pages/PageContact.qml` | Bestehend |
| Custom Farben | `ColorDesign.json` | Bestehend |
| ScreenBlanker | `screenblanker.cpp/.h` | Bestehend |

### Plugin-Layer (Update-sicher)

| Komponente | Datei(en) | Deployment |
|---|---|---|
| PageHeating.qml | Plugin-RCC | Filesystem oder MQTT |
| PageHeatingZone.qml | Plugin-RCC | Filesystem oder MQTT |
| PageClimate.qml | Plugin-RCC | Filesystem oder MQTT |
| PageOccSettings.qml | Plugin-RCC | Filesystem oder MQTT |
| PageHeatingSettings.qml | Plugin-RCC | Filesystem oder MQTT |
| plugin.json | Plugin-Manifest | Filesystem oder MQTT |

### Bridge-Layer (GUI-unabhängig)

| Komponente | Verzeichnis | Service |
|---|---|---|
| dbus-mqtt-occ | `/data/apps/dbus-mqtt-occ/` | daemontools |
| dbus-mqtt-temperature | `/data/apps/dbus-mqtt-temperature/` | daemontools |
| occ-io-setup.sh | `/data/apps/dbus-mqtt-occ/` | Einmalig |

---

## Implementierungsreihenfolge

### Phase 1: Backend (Bridge-Layer) — Woche 1–2

| # | Aufgabe | Priorität | Abhängigkeit |
|---|---|---|---|
| 1.1 | dbus-mqtt-temperature installieren + konfigurieren | Hoch | Hardware (Sensoren) |
| 1.2 | dbus-mqtt-occ Grundgerüst (Service-Registrierung) | Hoch | Keine |
| 1.3 | MQTT Topic-Subscription + D-Bus Mapping | Hoch | 1.2 |
| 1.4 | Bidirektionale Steuerung (Setpoint schreiben) | Mittel | 1.3 |
| 1.5 | Sign-of-Life + Fehlerbehandlung | Mittel | 1.3 |
| 1.6 | I/O Extender Setup-Script ausführen | Hoch | Hardware (IO Ext.) |

**Ergebnis:** Heizungsdaten auf dem D-Bus sichtbar, via `dbus-spy` und MQTT verifizierbar.

### Phase 2: Plugin (Plugin-Layer) — Woche 2–3

| # | Aufgabe | Priorität | Abhängigkeit |
|---|---|---|---|
| 2.1 | Plugin-Manifest (`plugin.json`) erstellen | Hoch | Keine |
| 2.2 | PageHeating.qml (Zonenübersicht) | Hoch | 1.3 (Daten auf D-Bus) |
| 2.3 | PageHeatingZone.qml (Zonen-Detail) | Hoch | 2.2 |
| 2.4 | PageClimate.qml (Klima-Steuerung) | Mittel | 1.3 |
| 2.5 | PageOccSettings.qml + PageHeatingSettings.qml | Mittel | 2.2 |
| 2.6 | Plugin kompilieren (gui-v2-plugin-compiler.py) | Hoch | 2.2–2.5 |
| 2.7 | Plugin auf GX deployen + testen | Hoch | 2.6, 1.1–1.6 |

**Ergebnis:** Heating/Climate-Seiten über Settings → Plugins → OCC erreichbar.

### Phase 3: Fork-Integration (Fork-Layer) — Woche 3–4

| # | Aufgabe | Priorität | Abhängigkeit |
|---|---|---|---|
| 3.1 | NavBar-Icon für Heating (SwipePageModel) | Mittel | 2.7 (Plugin funktioniert) |
| 3.2 | ControlCard_Heating für Switch-Panel | Niedrig | 2.7 |
| 3.3 | StatusBar-Erweiterung (Heating-Status-Icon) | Niedrig | 1.5 |
| 3.4 | Wasm-Build verifizieren | Hoch | 3.1–3.3 |
| 3.5 | GX-Build verifizieren | Hoch | 3.1–3.3 |

**Ergebnis:** Vollständige OCC-Integration mit NavBar-Zugang und Switch-Cards.

### Phase 4: Stabilisierung — Woche 4–5

| # | Aufgabe | Priorität | Abhängigkeit |
|---|---|---|---|
| 4.1 | Übersetzungen (DE/EN) finalisieren | Mittel | 2.2–2.5 |
| 4.2 | Error-Handling End-to-End testen | Hoch | Alle |
| 4.3 | Dokumentation vervollständigen | Mittel | Alle |
| 4.4 | Main-Update Testmerge durchführen | Hoch | Alle |
| 4.5 | Merge-Workflow dokumentieren + testen | Mittel | 4.4 |

---

## Technische Entscheidungen

### E1: Service-Typ-Registrierung

**Problem:** `BackendConnection.serviceUidForType("heating")` existiert nicht nativ.

**Lösung:** Im Plugin wird die UID direkt konstruiert:
```qml
readonly property string serviceUid: BackendConnection.type === BackendConnection.MqttSource
    ? "mqtt/heating.occ"
    : "dbus/com.victronenergy.heating.occ"
```

Alternativ (wenn Fork verfügbar): `BackendConnection` erweitern um `"heating"` Typ.

### E2: Zonen-Anzahl dynamisch

**Problem:** Die Anzahl der Heizungszonen kann variieren.

**Lösung:** dbus-mqtt-occ publiziert `/NumberOfZones` als Integer. Die GUI nutzt einen Repeater:
```qml
Repeater { model: zoneCount.isValid ? zoneCount.value : 0 }
```

### E3: Plugin-Deployment-Methode

**Problem:** Wie kommt das Plugin auf das GX-Gerät?

**Lösung (Prio-Reihenfolge):**
1. Filesystem: `/data/apps/gui-v2-plugins/occ-heating/` (empfohlen für Entwicklung)
2. MQTT: Base64-chunks über `N/<portal-id>/gui-v2/plugin/<serial>/chunk/<n>` (für Remote-Deployment)

### E4: NavBar-Integration (Fork)

**Problem:** Plugin-Typ 3 (NavigationPage) ist noch nicht implementiert.

**Lösung:** Minimaler Fork-Eingriff in `SwipePageModel.qml`:
```qml
// Heating-Icon einfügen (nach Solar, vor Settings)
ListElement {
    pageUrl: "/pages/PageHeating.qml"
    navButtonIcon: "qrc:/images/icon_heating_32.svg"
    navButtonText: qsTr("Heating")
}
```

### E5: Übersetzungs-Strategie

**Problem:** Eigene Translation-Keys dürfen nicht bei Main-Updates überschrieben werden.

**Lösung:** Alle OCC-Keys beginnen mit `occ_` Präfix. Bei Merge-Konflikten in `.ts`-Dateien greift das Skript `translation-override.py`, das eigene Keys immer bevorzugt.

---

## Risiko-Matrix mit Mitigationen

| Risiko | Wahrsch. | Auswirkung | Mitigation | Verantwortlich |
|---|---|---|---|---|
| Main ändert StatusBar erneut | Hoch | Merge-Aufwand | Wrapper-Pattern, diff-monitoring | Fork-Layer |
| Plugin-System Typ 3 kommt | Mittel | Fork-Code obsolet | Migration vorbereiten | Fork-Layer |
| MQTT-Broker-Ausfall | Niedrig | Keine Heizungsdaten | mosquitto Watchdog | Bridge-Layer |
| Qt 6.9 Breaking Changes | Mittel | Build-Fehler | CI mit beiden Versionen | Alle |
| OCC-Hardware-Varianten | Mittel | Mehr Zonen/Kanäle | Dynamische Zonen-Konfiguration | Bridge-Layer |

---

## Erfolgskriterien pro Phase

### Phase 1 (Backend) — DONE wenn:
- [ ] `dbus-spy` zeigt `com.victronenergy.heating.occ` mit allen Zone-Pfaden
- [ ] MQTT-Werte propagieren innerhalb von <1s zum D-Bus
- [ ] GUI schreibt Setpoint über D-Bus → MQTT-Publish verifiziert
- [ ] Sign-of-Life funktioniert (Sensor-Timeout → Werte invalid)

### Phase 2 (Plugin) — DONE wenn:
- [ ] Plugin erscheint unter Settings → Integrations → UI Plugins
- [ ] Alle 4 Seiten navigierbar und funktional
- [ ] Temperaturen zeigen aktuelle Werte (oder "---" wenn offline)
- [ ] Setpoint-Slider ändert D-Bus-Wert
- [ ] Modus-Umschaltung funktioniert

### Phase 3 (Fork) — DONE wenn:
- [ ] NavBar zeigt Heating-Icon
- [ ] Switch-Panel zeigt Heating-Card
- [ ] Wasm-Build erfolgreich
- [ ] GX-Build erfolgreich
- [ ] Main-Testmerge ohne neue Konflikte in OCC-Dateien

### Phase 4 (Stabilisierung) — DONE wenn:
- [ ] Alle Übersetzungskeys vorhanden (DE + EN)
- [ ] Kompletter Fehlerpfad getestet (MQTT-Ausfall, Sensor-Timeout)
- [ ] Dokumentation vollständig
- [ ] Merge-Workflow einmal erfolgreich durchlaufen

---

## Datei-Übersicht (finale Struktur)

```
gui-v2/
├── docs/occ/
│   ├── 01-repository-katalog.md
│   ├── 02-feature-matrix-kollisionen.md
│   ├── 04-heating-climate-ui-spezifikation.md
│   ├── 05-mqtt-bridge-spezifikation.md
│   ├── 06-io-extender-mapping.md
│   └── 07-architektur-entscheidung.md          ← dieses Dokument
│
├── plugins/occ-heating/                         (Phase 2)
│   ├── plugin.json
│   ├── PageHeating.qml
│   ├── PageHeatingZone.qml
│   ├── PageClimate.qml
│   ├── PageOccSettings.qml
│   └── PageHeatingSettings.qml
│
├── components/
│   ├── StatusBar_Landscape.qml                  (Phase 3, bestehend)
│   └── ControlCard_Heating.qml                  (Phase 3, neu)
│
└── images/
    └── icon_heating_32.svg                      (Phase 3, neu)

/data/apps/dbus-mqtt-occ/                        (GX-Gerät, Phase 1)
├── dbus-mqtt-occ.py
├── config.ini
├── version.py
├── vedbus.py
├── ve_utils.py
├── dbushelper.py
├── service/run
├── log/run
├── occ-io-setup.sh
├── install.sh
└── uninstall.sh
```
