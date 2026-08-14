# Leistungsübersicht: `v_2026.6.2` vs. `origin/main`

**Erstellt:** 2026-07-14  
**Fork-Branch:** `v_2026.6.2` @ `f51dbf03`  
**Vergleichsbasis:** `origin/main` ([victronenergy/gui-v2](https://github.com/victronenergy/gui-v2)) @ `76afc8c6` (v1.3.14)  
**Zeitraum (Arbeit):** 01.12.2025 – 13.07.2026

> **Hinweis:** Ein Branch „ImmoMain“ existiert nicht. Diese Auswertung verwendet `origin/main` als Victron-Upstream.

---

## Kennzahlen

| Kennzahl | Wert |
|---|---|
| Geänderte Dateien (Diff) | 128 |
| Zeilen Diff | +20.680 / −1.905 |
| Eigene Commits seit Dez 2025 | 87 (ohne Merges) |
| Merge-Commits seit Dez 2025 | 20 |
| Ältere Fork-Commits (vor Dez, noch im Diff) | 15 |

---

## Methodik

- **Abweichung:** `git diff origin/main...v_2026.6.2`
- **Zeitachse:** Commit-Datum der Fork-Commits, die nicht in `origin/main` enthalten sind
- **Ist-Aufwand (bestätigt):** **96 h** gesamt seit Dez 2025
- **Feature-Verteilung:** proportional zum technischen Umfang (Commits/Diff) auf 96 h heruntergerechnet
- **Deploy-Nachweis:** `~/.bash_history` (siehe Anhang D)
- **Merge-Arbeit:** In Pos. 13 gebündelt, nicht doppelt in Feature-Positionen gezählt

### Nachweis-Befehle

```bash
# Alle Fork-Commits seit Dez (nicht in main)
git log origin/main..v_2026.6.2 --since="2025-12-01" --no-merges --oneline

# Gesamtdiff
git diff origin/main...v_2026.6.2 --stat

# Feature-spezifisch (Beispiel OCC)
git diff origin/main...v_2026.6.2 --stat -- services/dbus-mqtt-occ pages/Heating*
```

**Weitere Dokumentation:** `docs/occ/`, `docs/merge/`

---

## Feature-Positionen (seit Dezember 2025)

### Pos. 1 — Vario-Branding & Splash-Screen

**Zeitraum:** Dez 2025  
**Abweichung von main:**

| Änderung | Dateien |
|---|---|
| VM-Logos (`vm_32`, `vm_32_mini`, `vm_red_32`) | `images/vm_*` |
| Splash-Icons/Text angepasst | `images/splash-logo-*` |
| Theme-Farben | `themes/color/ColorDesign.json` |

**Commits (Auszug):** `0a0d470ee`, `79429606b`, `b24561887`, `250770c6c`, `10f806a9c`, `45b3b0071`  
**Aufwand:** **16 h**

---

### Pos. 2 — StatusBar-Anpassungen (Portrait & Landscape)

**Zeitraum:** Dez 2025, Apr–Mai 2026  
**Abweichung von main:**

| Änderung | Details |
|---|---|
| Original-StatusBar wiederhergestellt | Datum/Uhr, Layout |
| Landscape-StatusBar | `StatusBar_Landscape.qml` (+155/−40 Zeilen) |
| Switch-Icons & Textlabels | Opacity-Fix, Text neben Switch |
| Settings-Seite | `PageSettingsStatusBar.qml` (+54 Zeilen) |

**Commits (Auszug):** `e8469db8b`, `4bd93e74e`, `8cc262119`, `c0f69aa22`, `1d837ccc3`, `a75dac1ba`  
**Aufwand:** **24 h**

---

### Pos. 3 — Standby-Seite & ScreenBlanker

**Zeitraum:** Dez 2025 – Jun 2026  
**Abweichung von main:**

| Änderung | Details |
|---|---|
| Standby-Uhr/Watch | `StandbyPage.qml` (+65 Zeilen) |
| ScreenBlanker C++ | `screenblanker.cpp/h` |
| API-Migration | `ApplicationContent.qml`, ScreenBlanker-Referenzen |
| Fix | Uhr vor Hardware-Blank sichtbar |

**Commits (Auszug):** `e41a7e957`, `487be2bb2`, `04a124821`, `8ff4baf50`  
**Aufwand:** **16 h**

---

### Pos. 4 — Overview-Widgets & Brief-Ansicht

**Zeitraum:** Dez 2025 – Jul 2026  
**Abweichung von main:**

| Änderung | Details |
|---|---|
| Multigauge-Farben | `CircularMultiGauge.qml` |
| Solar Kurzansicht | nur 1 Solar, Layout (`SolarYieldGauge.qml`) |
| Brief-Layout | `BriefCenterDisplay.qml`, Quantity-Padding |
| Inverter-Widget | kleine Anpassung |
| **Fahrzeugbatterie** | Spannung `/Dc/1/Voltage`, Label, Layout-Fix |

**Commits (Auszug):** `e039a43c7`, `bd80d40c2`, `2bc74327e`, `7b21d72d`, `f51dbf03`  
**Diff BatteryWidget:** +84/−4 Zeilen  
**Aufwand:** **20 h**

---

### Pos. 5 — Settings, Kontakt & Backup/Restore

**Zeitraum:** Dez 2025  
**Abweichung von main:**

| Änderung | Details |
|---|---|
| Kontaktseite | `PageContact.qml` (+92 Zeilen), Öffnungszeiten |
| Backup/Restore | `PageSettingsBackupRestore.qml` (+356 Zeilen) |
| Copy-Settings entfernt | Navigation vereinfacht |
| Firmware-Update UX | Toast-/Button-Logik |
| README_de | Deutsche Doku |

**Commits (Auszug):** `0af71fbea`, `f7a852fb1`, `838244550`, `abbcb387b`  
**Aufwand:** **16 h**

---

### Pos. 6 — Deutsche Lokalisierung & Translation-Tooling

**Zeitraum:** Dez 2025 – Feb 2026  
**Abweichung von main:**

| Änderung | Details |
|---|---|
| `venus-gui-v2_de.ts` | ~3.400 Zeilen geändert |
| `translation-overrides.json` | Domain-spezifische DE-Texte |
| Werkzeuge | `translation-override.py`, `update-translations.sh`, `-de.sh` |
| Domains | Tanks (WC/Abwasser), GPS, Generator, EV, Switches, Batterie |

**Commits:** 18 Translation-/Script-Commits (Dez 5–17, Feb 12)  
**Aufwand:** **32 h**

---

### Pos. 7 — Layout-Fixes (Quantity-Komponenten)

**Zeitraum:** Dez 2025  
**Abweichung von main:** Padding/Elide in `QuantityGroupListHeader`, `BriefSidePanelWidget`, `ElectricalQuantityLabel`  
**Commits:** `be5c3bb44`, `2e6cff3b7`, `2bc74327e`  
**Aufwand:** **4 h**

---

### Pos. 8 — Domain-Anpassungen (Switches, Tanks, Sonstiges)

**Zeitraum:** Dez 2025  
**Abweichung von main:**

| Änderung | Details |
|---|---|
| Switch-Texte | Text an Buttons |
| WC/Abwasser | Tank-Übersetzung |
| i18n Source-Fix | DE-Strings in `.ts` korrigiert |
| UI-Feinschliff | Symbol Mitte, Temp-Fixes |

**Commits (Auszug):** `396015a81`, `3670a23dc`, `4b4d3fe38`, `4f58bfdd2`, `5a589411b`, `6f659b99d`  
**Aufwand:** **8 h**

---

### Pos. 9 — Upstream-Feature-Porting

**Zeitraum:** Dez 2025  
**Abweichung von main:** Externe Victron-Branches in Fork integriert

| Feature | Commit |
|---|---|
| DVCC Charge-Current-Limits | `f02115c18` |
| DC Load Motordrive | `68d64c716` |
| Cummins Genset Error | `bd586fd7c` |

**Aufwand:** **6 h** (Review, Merge, Fork-Anpassung)

---

### Pos. 10 — Translation-Override-Script (Erweiterung)

**Zeitraum:** Apr 2026  
**Abweichung von main:** Flexibler Branch-Vergleich (`origin/main` als Default)  
**Commit:** `b4aae1505`  
**Aufwand:** **4 h**

---

### Pos. 11 — Build-Fix Wasm

**Zeitraum:** Mai 2026  
**Abweichung von main:** Emscripten `WrapRt`-Workaround  
**Commit:** `680f2e7a5`  
**Aufwand:** **4 h**

---

### Pos. 12 — OpenCamperCore Heizung/Klima (Hauptfeature)

**Zeitraum:** Mai – Jul 2026  
**Abweichung von main:** Komplett neue Integration

| Schicht | Inhalt | Diff (ca.) |
|---|---|---|
| Backend | `services/dbus-mqtt-occ/` — MQTT↔D-Bus Bridge | +1.735 Zeilen |
| GUI | `HeatingPage`, `HeatingClimatePage`, `HeatingZonePage`, `HeatingCard`, `OccSetpointSliderRow`, `OccClimateUnitBlock` | +717 Zeilen |
| Plugin | `plugins/occ-heating/` inkl. DE/EN | +977 Zeilen |
| Dokumentation | 10 Design-/Architektur-Docs in `docs/occ/` | +2.657 Zeilen |
| Deploy | GX `100.65.95.55`, ve_utils, paho-mqtt v2 | — |
| Schritt 2 | Ist/Soll-Anzeige, Heiz-Max 30 °C, Standard-Slider | Jul 2026 |

**Commits (Auszug):** `94f93a11a` → `78fecc1ca` (15 Commits)  
**Logs:** `docs/occ/09-implementierung-steuerseite-2026-06-24.md`, `docs/occ/10-schritt-2-heatingpage-ist-soll.md`  
**Aufwand:** **64 h**

---

### Pos. 13 — Build-, Deploy- & Main-Merge-Infrastruktur

**Zeitraum:** Jun – Jul 2026  
**Abweichung von main:**

| Liefergegenstand | Details |
|---|---|
| `merge-main-into-vario.sh` | +438 Zeilen, automatisierter Main-Merge |
| `build-all.sh`, `copy-gx/wasm.sh` | Deploy-Pipeline |
| Main-Merges | v1.3.9, v1.3.11, v1.3.12, v1.3.13, v1.3.14 |
| Merge-Logs | 6 Docs in `docs/merge/` |

**Merge-Commits seit Dez:** 20  
**Commits (Auszug):** `74c20e9e1`, Merge-Logs, Konfliktlösung i18n  
**Aufwand:** **36 h**

---

## Summenübersicht (Feature-Positionen)

**Ist-Aufwand gesamt: 96 h** (vom Entwickler bestätigt, verteilt nach relativem Feature-Umfang)

| Pos. | Feature | Zeitraum | Std. (Ist) |
|---:|---|---|---:|
| 1 | Vario-Branding & Splash | Dez 2025 | 6 |
| 2 | StatusBar (Portrait/Landscape/Settings) | Dez 25 – Mai 26 | 9 |
| 3 | Standby & ScreenBlanker | Dez 25 – Jun 26 | 6 |
| 4 | Overview-Widgets & Fahrzeugbatterie | Dez 25 – Jul 26 | 8 |
| 5 | Settings, Kontakt, Backup/Restore | Dez 2025 | 6 |
| 6 | DE-Lokalisierung & Translation-Tooling | Dez 25 – Feb 26 | 12 |
| 7 | Layout-Fixes Quantity/Brief | Dez 2025 | 2 |
| 8 | Domain-Anpassungen (Switches, Tanks) | Dez 2025 | 3 |
| 9 | Upstream-Feature-Porting | Dez 2025 | 2 |
| 10 | Translation-Override-Script | Apr 2026 | 2 |
| 11 | Wasm-Build-Fix | Mai 2026 | 2 |
| 12 | **OCC Heizung/Klima** | Mai – Jul 2026 | **24** |
| 13 | Build/Deploy/Main-Merge-Infrastruktur | Jun – Jul 2026 | 14 |
| | | **Gesamt seit Dez 2025** | **96 h** |

---

## Monatsverteilung

### Commits pro Monat

| Monat | Commits | Schwerpunkt |
|---|---:|---|
| Dez 2025 | 57 | Branding, StatusBar, Übersetzungen, Settings, Overview |
| Feb 2026 | 3 | Übersetzungs-Nachpflege |
| Apr 2026 | 3 | StatusBar, ScreenBlanker-API, Translation-Script |
| Mai 2026 | 9 | OCC-Start, StatusBar-Fixes, Wasm |
| Jun 2026 | 11 | OCC Steuerseite, Merge v1.3.11–v1.3.12, Deploy |
| Jul 2026 | 4 | Main v1.3.13/14, Fahrzeugbatterie, Heating Schritt 2 |

### Aufwand pro Monat (Ist, 96 h)

| Monat | Std. | Zuordnung |
|---|---:|---|
| Dez 2025 | 42 | Pos. 1–9 (Vario-Basis, UI, i18n, Settings) |
| Feb 2026 | 3 | Pos. 6 (Translation-Nachpflege) |
| Apr 2026 | 5 | Pos. 2, 3, 10 (StatusBar, ScreenBlanker, Script) |
| Mai 2026 | 20 | Pos. 2, 11, 12 (OCC-Start, Wasm, StatusBar) |
| Jun 2026 | 20 | Pos. 3, 12, 13 (OCC Steuerseite, Merges, Deploy) |
| Jul 2026 | 6 | Pos. 4, 12, 13 (Fahrzeugbatterie, Heating Schritt 2, v1.3.14) |
| | **96** | |

---

## Anhang A — Fork-Basis vor Dezember (noch im Diff)

15 Commits **vor** Dez 2025 sind weiterhin in `v_2026.6.2` gegenüber main enthalten:

| Inhalt | Zeitraum (Commit) |
|---|---|
| Vario „new design“, Customisations-Framework | Aug 2025 |
| Switch-Texte, Farben, Logo | Sep 2025 |
| Tank-Backup, DC-Loads-Drilldown, Breadcrumbs | Mai–Sep 2025 |

**Diff:** u.a. `src/customisations.cpp` (+1.016 Zeilen)  
**Geschätzter Aufwand (Vorgeschichte):** **~40 h** — nicht in der Summe 254 h enthalten

---

## Anhang B — Diff-Statistik nach Pfad

| Pfad | Änderung |
|---|---|
| `services/dbus-mqtt-occ/` | +1.735 Zeilen |
| `docs/occ/` | +2.657 Zeilen |
| `i18n/` | +2.916 / −1.671 Zeilen |
| `scripts/` | +1.683 Zeilen |
| `src/customisations.*` | +1.016 Zeilen |
| `plugins/occ-heating/` | +977 Zeilen |
| `pages/settings/PageSettingsBackupRestore.qml` | +356 Zeilen |
| `pages/Heating*.qml` | +315 Zeilen |
| `components/HeatingCard.qml` | +162 Zeilen |
| `components/StatusBar_Landscape.qml` | +155/−40 Zeilen |
| `components/widgets/BatteryWidget.qml` | +84 Zeilen |
| `pages/StandbyPage.qml` | +65 Zeilen |

---

## Anhang C — Deploy-Historie (`build-all` / `copy-all`)

**Quelle:** `~/.bash_history` (Stand 2026-07-14)  
**Hinweis:** Zählung nach Host-Zielen; Mehrfach-Deploys in einem Aufruf (`-H ip1,ip2,...`) zählen pro IP.

### `build-all.sh`

| Ziel (IP/Host) | Deploy-Ziele | Aufrufe (unique) |
|---|---:|---:|
| `192.168.4.145` | 7 | 7 |
| `100.76.137.53` | 3 | 3 |
| `100.65.95.55` | 3 | 3 |
| `100.107.199.12` | 1 | 1 |
| `192.168.4.89` | 1 | 1 |
| `100.70.58.118` | 1 | 1 |
| *(ohne `-H`, nur Build)* | 2 | 2 |
| **Summe** | **18** | **13** |

### `copy-all.sh`

| Ziel (IP/Host) | Deploy-Ziele | Aufrufe (unique) |
|---|---:|---:|
| `100.65.95.55` | 6 | 3 |
| `100.109.93.48` | 4 | 2 |
| `100.107.199.12` | 4 | 2 |
| `100.127.228.97` | 4 | 4 |
| `100.70.58.118` | 2 | 2 |
| `100.68.103.12` | 1 | 1 |
| `100.76.137.53` | 1 | 1 |
| `100.75.157.128` | 1 | 1 |
| `100.111.118.82` | 1 | 1 |
| `192.168.4.89` | 1 | 1 |
| `100.65.9` *(vermutl. Tippfehler)* | 1 | 1 |
| **Summe** | **26** | **17** |

### Bekannte GX-/Tailscale-Ziele (kombiniert)

| IP | build-all | copy-all | Gesamt Deploy-Ziele |
|---|---:|---:|---:|
| `100.65.95.55` | 3 | 6 | 9 |
| `100.107.199.12` | 1 | 4 | 5 |
| `100.109.93.48` | 0 | 4 | 4 |
| `100.127.228.97` | 0 | 4 | 4 |
| `100.76.137.53` | 3 | 1 | 4 |
| `100.70.58.118` | 1 | 2 | 3 |
| `192.168.4.145` (LAN) | 7 | 0 | 7 |
| `100.68.103.12` | 0 | 1 | 1 |
| `100.111.118.82` | 0 | 1 | 1 |
| `100.75.157.128` | 0 | 1 | 1 |
| `192.168.4.89` (LAN) | 1 | 1 | 2 |

**Zusatz (Einzelscripts in History):** `build-gx` 17 Ziele, `build-wasm` 37 Ziele, `copy-wasm` 9 Ziele — teils vor Einführung von `build-all`/`copy-all`.

---

## Anhang D — Main-Merges seit Dezember 2025

| Datum | Merge |
|---|---|
| 2025-12-02 | upstream/main → vario_mobil_beta |
| 2025-12-03 | blam/dvcc-current-limits |
| 2025-12-04 | martin/cummins |
| 2025-12-05 | ttomkins/add-motordrive-to-dcloadlist |
| 2025-12-08 | faberd/update-translations |
| 2025-12-10/11/15/18 | origin/main → vario_beta_3.7 / vm_beta_3.7.2 |
| 2026-02-12 | tag v1.2.29 → vario_2026 |
| 2026-05-25 | origin/main v1.3.9 → vario_2026.5 |
| 2026-06-09 | origin/main v1.3.11 → v_2026.6 |
| 2026-06-20 | origin/main v1.3.12 → v_2026.6.1 |
| 2026-06-24 | origin/main → v_2026.6.2, v_heat_2026.5 |
| 2026-07-03 | origin/main v1.3.13 → v_2026.6.2 |
| 2026-07-13 | origin/main v1.3.14 → v_2026.6.2 |
