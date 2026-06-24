# OpenCamperCore — Featurevergleich und Kollisionsmatrix

Stand: 2026-05-26

---

## Featurevergleich: Integrationsmethoden

| Feature | Plugin Typ 1/2 | Fork/Branch | MQTT-Bridge + Plugin | Node-RED |
|---|---|---|---|---|
| Custom Menüs | Typ 3 (TODO) | Direkt in QML | Typ 1 + Bridge | Nein |
| Unterseiten (Detail) | Typ 1+2 (fertig) | Direkt | Typ 1+2 | Nein |
| Widgets/Cards (Switch Panel) | Typ 5 (TODO) | Direkt | Nicht möglich | Nein |
| MQTT-Anbindung | Via VeQuickItem | Via VeQuickItem | dbus-mqtt-* | Ja |
| D-Bus-Integration | Direkt | Direkt | Automatisch via Bridge | Via MQTT→D-Bus |
| Relais/IO-Steuerung | Via IOChannel | Via IOChannel | Via dbus-switch | Via MQTT |
| Temperatur-Anzeige | Via VeQuickItem | Direkt | dbus-mqtt-temperature | Via MQTT |
| StatusBar-Erweiterung | Nicht möglich | Direkt im Fork | Nicht möglich | Nein |
| NavBar-Icon | Nicht möglich (Typ 3 TODO) | Direkt | Nicht möglich | Nein |
| Update-Sicherheit | Hoch | Niedrig | Hoch | Hoch |
| Offline-Fähigkeit | Ja | Ja | Bridge muss laufen | Node-RED muss laufen |

---

## Plugin-Typen im Detail

| Typ | Name | Status | Beschreibung | Zugang |
|---|---|---|---|---|
| 1 | PluginSettingsPage | Fertig | Eigene Seite unter Settings → Integrations → UI Plugins | Immer |
| 2 | DeviceListSettingsPage | Fertig | Menü-Eintrag in Geräte-Detailseite (productId-Filter) | Bei passendem Gerät |
| 3 | NavigationPage | TODO | Neues NavBar-Icon + eigene Hauptseite | Immer |
| 4 | QuickAccessPane | TODO | StatusBar-Icon mit Quick-Access-Panel | Immer |
| 5 | QuickAccessPaneCard | TODO | Karte in Controls/Switches-Panel | Bei Bedingung |

---

## Kollisionsmatrix: Bestehende Vario-Features vs. Main

### Bestehende Features (nach Merge 2026-05-25)

| Feature | Dateien | Letzte Main-Änderung | Kollisions-Risiko | Merge-Strategie |
|---|---|---|---|---|
| StatusBar Temperatur+Logo+Uhr | `components/StatusBar_Landscape.qml` | 2026-05 (Portrait-Refactoring) | **HOCH** | Eigene Version in Landscape behalten |
| StatusBar Wrapper (Loader) | `components/StatusBar.qml` | 2026-05 | Niedrig | Main folgen |
| PageContact | `pages/PageContact.qml` | — (eigene Datei) | Keins | Isoliert |
| StandbyPage | `pages/StandbyPage.qml` | — (eigene Datei) | Keins | Isoliert |
| ScreenBlanker | `src/screenblanker.cpp/.h` | 2026-03 (detect unsuccessful) | **HOCH** | setBlanked(bool,bool) behalten, Main-Features integrieren |
| Tank Backup/Restore | `PageSettingsBackupRestore.qml`, `enums.h` | enums.h monatlich | Mittel | Eigene Enums am Ende der Liste |
| Custom Farben | `themes/color/ColorDesign.json` | Selten | Niedrig | Eigene Werte behalten |
| Deutsche Übersetzungen | `i18n/venus-gui-v2_de.ts` | Alle 2 Wochen | **HOCH** | translation-override.py nutzen |
| Build-Scripts | `scripts/build-*.sh` | — (eigene Dateien) | Keins | Isoliert |
| StatusBar Settings | `pages/settings/PageSettingsStatusBar.qml` | — (eigene Datei) | Keins | Isoliert |
| WrapRt CMake Fix | `cmake/BuildRequirements.cmake` | Selten | Niedrig | Workaround beibehalten |

### Geplante Features — Kollisionsprognose

| Geplantes Feature | Betroffene Dateien | Main-Aktivität | Risiko | Empfehlung |
|---|---|---|---|---|
| Heating NavBar-Icon | `components/SwipePageModel.qml`, `components/NavBar.qml` | Mittel (NavBar gerade stabil) | **HOCH** | Fork: minimal-invasiv einfügen |
| Heating Settings-Seite | `pages/SettingsPage.qml` | Hoch (neue Features = neue Einträge) | Mittel | Fork: eigene ListNavigation am Ende |
| Heating Plugin (Typ 1) | Plugin-Verzeichnis (extern) | Keins | Keins | Plugin: komplett isoliert |
| Climate Cards | `components/CardViewLoader.qml` | Mittel | Mittel | Fork: eigene Card-Komponente |
| MQTT Backend | Keine GUI-Dateien | — | Keins | Bridge: komplett extern |
| I/O Extender | Keine Änderung nötig | — | Keins | Natives IOChannel-System nutzen |
| Custom Übersetzungen | `i18n/venus-gui-v2_de.ts` | Hoch | **HOCH** | translation-override.py Workflow |

---

## Merge-Workflow für zukünftige Updates

```
1. git fetch origin
2. python3 scripts/translation-override.py extract    # Overrides sichern
3. git merge origin/main
4. Konflikte lösen (Prioritäten: siehe Tabelle oben)
5. python3 scripts/translation-override.py apply      # Overrides anwenden
6. Build testen (GX + Wasm)
7. Commit + Push
```

### Prioritätsregeln bei Konflikten

1. Eigene Übersetzungen > Main-Übersetzungen
2. Eigene UI-Anpassungen (Logo, Farben, Kontakt) > Main
3. Main's Architektur-Änderungen > Eigene Workarounds
4. Submodule (veutil): immer Main folgen
5. Neue Main-Features: übernehmen wenn kein Konflikt
6. Eigene neue Dateien: keine Konflikte möglich

---

## Empfehlung: Drei-Schichten-Modell

```
┌──────────────────────────────────────────────┐
│  Fork-Layer (vario_2026.5)                   │
│  StatusBar, NavBar, StandbyPage, Cards       │
│  → Erfordert Merge-Pflege                    │
├──────────────────────────────────────────────┤
│  Plugin-Layer (gui-v2 Plugin System)         │
│  Heating Pages, Climate Pages, OCC Settings  │
│  → Update-sicher, extern deploybar           │
├──────────────────────────────────────────────┤
│  Bridge-Layer (dbus-mqtt-occ)                │
│  MQTT→D-Bus, Temperatur, Heizungszonen       │
│  → Komplett unabhängig von GUI               │
└──────────────────────────────────────────────┘
```
