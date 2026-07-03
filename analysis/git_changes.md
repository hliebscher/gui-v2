# Git-Analyse: Änderungen gegenüber `main`

**Erstellt:** 2026-07-03  
**Repository:** `hliebscher/gui-v2`  
**Aktueller Branch:** `v_2026.6.2`  
**Vergleichsbasis:** `main` (`df99c39a`)  
**Merge-Base:** `df99c39a89b34f084fd3c6b190511c7648c70131`  
**HEAD:** `66839d5098d78334a9c8614fd7fd06243addafa2`

---

## Zusammenfassung

| Kennzahl | Wert |
|----------|------|
| Commits gesamt (nicht in `main`) | **126** |
| Commits ohne Merge-Commits | **99** |
| Commits von Heiko Liebscher | **115** |
| Geänderte Dateien | **114** |
| Zeilen hinzugefügt | **+14.718** |
| Zeilen entfernt | **−1.898** |
| Netto-Zuwachs | **+12.820 Zeilen** |
| Zeitraum | **2025-08-23** bis **2026-07-03** |

### Autorenverteilung

| Autor | Commits |
|-------|---------|
| Heiko Liebscher | 115 |
| Manuel (mr-manuel) | 4 |
| Toby Tomkins | 2 |
| Martin Bosma | 1 |
| Dirk-Jan Faber | 1 |
| Daniel McInnes | 1 |
| Chris Adams | 1 |
| Bea Lam | 1 |

> **Hinweis:** Externe Autoren stammen überwiegend aus Upstream-Merges (Tank-Backup, Customisations, DC-Load-Drilldowns, Breadcrumbs, DVCC).

---

## 1. Commit-Historie (alle 126 Commits)

### 2026-07

| Datum | Uhrzeit | Commit-ID | Autor | Message |
|-------|---------|-----------|-------|---------|
| 2026-07-03 | 20:06:12 | `66839d50` | Heiko Liebscher | fix(heating): HeatingPage mit Standard-Slidern und Deploy-Fixes |

### 2026-06

| Datum | Uhrzeit | Commit-ID | Autor | Message |
|-------|---------|-----------|-------|---------|
| 2026-06-24 | 18:52:09 | `41cac6e1` | Heiko Liebscher | docs(occ): Wissensspeicher, Implementierungslog und Dokumentations-Regeln |
| 2026-06-24 | 18:44:23 | `cf90d590` | Heiko Liebscher | fix(dbus-mqtt-occ): Deploy auf Venus OS (ve_utils, paho-mqtt v2) |
| 2026-06-24 | 18:38:53 | `02cd95ea` | Heiko Liebscher | feat(heating): OCC Steuerseite mit 3 Heiz- und 2 Klima-Zonen |
| 2026-06-24 | 15:56:34 | `f07845aa` | Heiko Liebscher | fix(heating): NavBar-Tab entfernen, Settings-Seite wiederherstellen |
| 2026-06-24 | 13:01:28 | `7b799415` | Heiko Liebscher | Merge v_heat_2026.5 into v_2026.6.2 |
| 2026-06-24 | 12:58:12 | `f38d8745` | Heiko Liebscher | docs(merge): Mark WASM build gate as passed for v_2026.6.2 |
| 2026-06-24 | 12:57:57 | `c8663e0d` | Heiko Liebscher | docs(merge): Document main merge into v_2026.6.2 |
| 2026-06-24 | 12:57:57 | `1490df51` | Heiko Liebscher | Merge origin/main into v_2026.6.2 |
| 2026-06-20 | 23:50:59 | `94308ea2` | Heiko Liebscher | docs(merge): Document v1.3.12 merge + fix veutil fetch in merge script |
| 2026-06-20 | 23:50:53 | `2f461dea` | Heiko Liebscher | Merge origin/main (v1.3.12) into v_2026.6.1 |
| 2026-06-20 | 23:30:08 | `74c20e9e` | Heiko Liebscher | chore(scripts): Add merge-main-into-vario.sh for repeatable main integration |
| 2026-06-09 | 14:38:25 | `d64f2f07` | Heiko Liebscher | docs(merge): Document main → v_2026.6 merge (v1.3.11) |
| 2026-06-09 | 14:38:09 | `5daeeb7f` | Heiko Liebscher | Merge origin/main (v1.3.11) into v_2026.6 |
| 2026-06-09 | 13:07:38 | `8ff4baf5` | Heiko Liebscher | fix(screenblanker): Restore standby clock before hardware blank |
| 2026-06-08 | 23:53:11 | `6d197f83` | Heiko Liebscher | refactor(occ): Simplify HeatingPage for minimal testing |

### 2026-05 (OpenCamperCore / Heating)

| Datum | Uhrzeit | Commit-ID | Autor | Message |
|-------|---------|-----------|-------|---------|
| 2026-05-26 | 06:49:31 | `65da7836` | Heiko Liebscher | feat(occ): Add Heating as SwipeView page in NavBar |
| 2026-05-26 | 06:42:00 | `ec010ee0` | Heiko Liebscher | fix(occ): Move Heating to Settings menu, revert SwipePageModel |
| 2026-05-26 | 02:31:37 | `ab86f9f1` | Heiko Liebscher | fix(occ): Make HeatingPage conditional to prevent black screen |
| 2026-05-26 | 02:07:42 | `2597ca6a` | Heiko Liebscher | feat(occ): Phase 3 — NavBar Heating page + ControlCard integration |
| 2026-05-26 | 01:29:56 | `0cec00d6` | Heiko Liebscher | chore(occ): Replace vedbus stub with real velib_python implementation |
| 2026-05-26 | 01:29:18 | `94f93a11` | Heiko Liebscher | feat(occ): Add OpenCamperCore heating integration (bridge + plugin + docs) |
| 2026-05-26 | 00:10:50 | `a75dac1b` | Heiko Liebscher | StatusBar: always show text label beside switch icon |
| 2026-05-25 | 23:45:01 | `1d837ccc` | Heiko Liebscher | Fix auxButton in StatusBar: restore switch icon and fix opacity |
| 2026-05-25 | 23:01:40 | `680f2e7a` | Heiko Liebscher | Fix Wasm build: add WrapRt workaround for Emscripten |
| 2026-05-25 | 21:18:21 | `695c77b6` | Heiko Liebscher | Merge origin/main (v1.3.9) into vario_2026.5 |

### 2026-04 bis 2026-02 (StatusBar, ScreenBlanker, i18n)

| Datum | Commit-ID | Autor | Message |
|-------|-----------|-------|---------|
| 2026-04-16 | `b4aae150` | Heiko Liebscher | Enhance translation override script (flexible branch comparison) |
| 2026-04-16 | `04a12482` | Heiko Liebscher | Refactor screen blanker references in QML files |
| 2026-04-15 | `c0f69aa2` | Heiko Liebscher | Remove deprecated StatusBar copy.qml, standardize icon sizes |
| 2026-02-12 | `96e9e89e` | Heiko Liebscher | Update German translations (EV charging, external control) |
| 2026-02-12 | `557b1106` | Heiko Liebscher | Update German translations (GPS formats, speed units) |
| 2026-02-12 | `f1053fed` | Heiko Liebscher | Merge tag 'v1.2.29' into vario_2026 |
| 2026-02-12 | `247f7e7d` | Heiko Liebscher | Update German translations (backup messages) |

### 2025-12 (Vario Mobil Beta — GUI, Branding, i18n)

| Datum | Commit-ID | Autor | Message (Auszug) |
|-------|-----------|-------|------------------|
| 2025-12-17 | `a57d14ac` | Heiko Liebscher | German translations (EV charging, generator controls) |
| 2025-12-17 | `7c1a68e1` | Heiko Liebscher | Add opening hours text translation in PageContact.qml |
| 2025-12-17 | `d1cc9d25` | Heiko Liebscher | Fix translation key for backup message |
| 2025-12-16 | `cac0604f` | Heiko Liebscher | Refactor update-translations.sh |
| 2025-12-16 | `a9045330` | Heiko Liebscher | Enhance update-translations.sh (lupdate detection) |
| 2025-12-15 | `0af71fbe` | Heiko Liebscher | Add contact page and update translations |
| 2025-12-15 | `f7a852fb` | Heiko Liebscher | Remove PageSettingsCopySettings, consolidate backup/restore |
| 2025-12-10 | `e41a7e95` | Heiko Liebscher | standby Page and screenblanker |
| 2025-12-08 | `487be2bb` | Heiko Liebscher | standby watch |
| 2025-12-05 | `3670a23d` | Heiko Liebscher | WC Abwasser |
| 2025-12-05 | `396015a8` | Heiko Liebscher | switches |
| 2025-12-05 | `250770c6` | Heiko Liebscher | vm logo |
| 2025-12-04 | `e8469db8` | Heiko Liebscher | org status bar |

### 2025-09 bis 2025-08 (Vario Mobil Fork — Start)

| Datum | Commit-ID | Autor | Message |
|-------|-----------|-------|---------|
| 2025-09-26 | `779a129f` | Heiko Liebscher | Merge upstream/chriadam/support-customisations |
| 2025-09-26 | `4aaa3eb4` | Heiko Liebscher | Merge upstream/mr-manuel/tank-backup-restore |
| 2025-09-01 | `b32bc02d` | Heiko Liebscher | add Text to Button switch |
| 2025-08-31 | `fd520107` | Heiko Liebscher | logo new |
| 2025-08-25 | `df205058` | Heiko Liebscher | vario |
| 2025-08-23 | `de0a56a4` | Heiko Liebscher | new design |

### Upstream-Commits (via Merge, nicht von Heiko)

| Commit-ID | Autor | Message |
|-----------|-------|---------|
| `9f10352c` | Manuel | Add tank backup and restore page |
| `5a12763b` | Chris Adams | Customisations: Support dynamically-loaded customisations |
| `cc85c2a4` | Toby Tomkins | Overview: new DC Loads drilldowns |
| `01b5edb9` | Daniel McInnes | UI Controls: pop to correct page on breadcrumb click |
| `68d64c71` | Toby Tomkins | DC Load: add motordrive to DC Load device list |
| `f02115c1` | Bea Lam | DVCC: ensure 'Charge current limits' page can be loaded |
| `4273ce3d` | Dirk-Jan Faber | Update translations |
| `bd586fd7` | Martin Bosma | Genset: fix error description |

---

## 2. Geänderte Dateien (114 Dateien)

### Legende

- **A** = Neu erstellt
- **M** = Geändert
- **D** = Gelöscht (keine in diesem Diff)
- **R** = Umbenannt (keine expliziten in diesem Diff)

### Gesamtstatistik

```
114 files changed, 14718 insertions(+), 1898 deletions(-)
```

### Neu erstellt (A) — 78 Dateien

| Datei | +Zeilen | Bereich |
|-------|---------|---------|
| `services/dbus-mqtt-occ/dbus-mqtt-occ.py` | 539 | MQTT/D-Bus Bridge |
| `services/dbus-mqtt-occ/vedbus.py` | 655 | MQTT/D-Bus Bridge |
| `services/dbus-mqtt-occ/ve_utils.py` | 275 | MQTT/D-Bus Bridge |
| `src/customisations.cpp` | 712 | GUI Backend |
| `docs/occ/04-heating-climate-ui-spezifikation.md` | 584 | Dokumentation |
| `scripts/merge-main-into-vario.sh` | 438 | Buildsystem |
| `pages/settings/PageSettingsBackupRestore.qml` | 356 | GUI |
| `docs/occ/03-scheer-selection-schaltplan-analyse.md` | 333 | Dokumentation |
| `src/customisations.h` | 304 | GUI Backend |
| `scripts/translation-override.py` | 267 | i18n/Build |
| `docs/merge/2026-05-25_merge-main-into-vario_2026.5.md` | 267 | Dokumentation |
| `docs/occ/05-mqtt-bridge-spezifikation.md` | 276 | Dokumentation |
| `docs/occ/06-io-extender-mapping.md` | 322 | Dokumentation |
| `docs/occ/07-architektur-entscheidung.md` | 288 | Dokumentation |
| `components/OccSetpointSliderRow.qml` | 193 | GUI (Heating) |
| `components/HeatingCard.qml` | 162 | GUI (Heating) |
| `plugins/occ-heating/OccHeatingMain.qml` | 159 | GUI Plugin |
| `scripts/copy-gx.sh` | 157 | Buildsystem |
| `scripts/copy-wasm.sh` | 169 | Buildsystem |
| `pages/HeatingPage.qml` | 123 | GUI (Heating) |
| `docs/occ/08-steuerseite-3heizung-2klima-design.md` | 253 | Dokumentation |
| `docs/occ/00-wissensspeicher.md` | 164 | Dokumentation |
| `README_de.md` | 167 | Dokumentation |
| `i18n/translation-overrides.json` | 272 | i18n |
| `meine-uebersetzungen.json` | 278 | i18n |
| `meine-uebersetzungen2026.json` | 278 | i18n |
| … | … | (weitere 52 neue Dateien, siehe unten) |

### Geändert (M) — 36 Dateien

| Datei | +/− | Bereich |
|-------|-----|---------|
| `i18n/venus-gui-v2.ts` | +2449/−1487 | i18n |
| `components/StatusBar_Landscape.qml` | +155/−40 | GUI |
| `i18n/venus-gui-v2_de.ts` | +181/−181 | i18n |
| `components/SolarYieldGauge.qml` | +13/−27 | GUI |
| `pages/ControlCardsPage.qml` | +24/−10 | GUI (Heating) |
| `src/screenblanker.cpp` | +28/−16 | Screen Blanker |
| `pages/SettingsPage.qml` | +9/−0 | GUI (Heating) |
| `cmake/ModuleVenus_Sources.cmake` | +16/−0 | Buildsystem |
| `scripts/build-gx.sh` | +2/−1 | Buildsystem |
| `themes/color/ColorDesign.json` | +5/−5 | GUI/Theming |
| `images/victronenergy.svg` | +1/−24 | Branding |
| `images/device-frame.svg` | +1/−42 | Branding |
| … | … | (weitere 24 geänderte Dateien) |

### Vollständige Dateiliste nach Bereich

#### OpenCamperCore / Heating / Climate
- `A` components/HeatingCard.qml (+162)
- `A` components/OccClimateUnitBlock.qml (+47)
- `A` components/OccSetpointSliderRow.qml (+193)
- `A` pages/HeatingPage.qml (+123)
- `A` pages/HeatingZonePage.qml (+78)
- `A` pages/HeatingClimatePage.qml (+59)
- `M` pages/ControlCardsPage.qml (+24/−10)
- `M` pages/SettingsPage.qml (+9)
- `A` images/heating.svg (+12)
- `A` plugins/occ-heating/* (8 QML/JSON/TS-Dateien + Binaries)
- `A` services/dbus-mqtt-occ/* (11 Dateien, ~1900 Zeilen)
- `A` docs/occ/* (10 Markdown + 1 PNG + 1 PDF)

#### GUI / StatusBar / Standby / Branding
- `M` components/StatusBar_Landscape.qml (+155/−40)
- `A` pages/StandbyPage.qml (+65)
- `A` pages/VMCardsPage.qml (+45)
- `A` pages/PageContact.qml (+92)
- `M` ApplicationContent.qml (+8)
- `M` components/BriefCenterDisplay.qml (+8)
- `M` components/CircularMultiGauge.qml (+17/−4)
- `M` components/SolarYieldGauge.qml (+13/−27)
- `M` components/QuantityLabel.qml (+1)
- `M` components/widgets/InverterChargerWidget.qml (+1/−1)
- `A/M` images/* (Logos, vm_32, splash, device-frame)

#### Screen Blanker
- `M` src/screenblanker.cpp (+28/−16)
- `M` src/screenblanker.h (+4/−1)

#### Customisations (Upstream-Integration)
- `A` src/customisations.cpp (+712)
- `A` src/customisations.h (+304)
- `A` components/CustomDevicePageEntry.qml (+6)
- `A` tools/customisationcompiler.py (+205)
- `M` src/enums.h (+33)

#### i18n / Übersetzungen
- `M` i18n/venus-gui-v2.ts (+2449/−1487)
- `M` i18n/venus-gui-v2_de.ts (+181/−181)
- `A` i18n/translation-overrides.json (+272)
- `A` meine-uebersetzungen.json (+278)
- `A` meine-uebersetzungen2026.json (+278)
- `A` TRANSLATIONS.md (+159)

#### Buildsystem / Deploy / Merge
- `A` scripts/build-all.sh (+70)
- `A` scripts/copy-all.sh (+69)
- `A` scripts/copy-gx.sh (+157)
- `A` scripts/copy-wasm.sh (+169)
- `A` scripts/merge-main-into-vario.sh (+438)
- `A` scripts/translation-override.py (+267)
- `A` scripts/update-translations.sh (+143)
- `A` scripts/update-translations-de.sh (+82)
- `M` scripts/build-gx.sh (+2/−1)
- `M` cmake/BuildRequirements.cmake (+7)
- `M` cmake/ModuleVenus_Sources.cmake (+16)

#### Settings / Backup
- `A` pages/settings/PageSettingsBackupRestore.qml (+356)
- `A` pages/settings/PageSettingsStatusBar.qml (+54)
- `M` pages/settings/PageSettingsGeneral.qml (+12)
- `M` pages/settings/PageSettingsDisplayAndAppearance.qml (+8)

#### Dokumentation / Cursor
- `A` docs/occ/* (10 Dateien)
- `A` docs/merge/* (4 Dateien)
- `A` docs/triage/2026-04-16-triage-main-diff.md (+95)
- `A` README_de.md (+167)
- `A` .cursor/rules/occ-dokumentation.mdc (+30)
- `A` .cursor/skills/* (2 Skills)

---

## 3. Änderungen nach Bereichen

| Bereich | Dateien | +Zeilen (ca.) | Beschreibung |
|---------|---------|---------------|--------------|
| **OpenCamperCore / Heating** | 25+ | ~3.500 | D-Bus-Bridge, GUI-Steuerseite, Plugin, Komponenten |
| **MQTT / D-Bus Bridge** | 11 | ~1.900 | `dbus-mqtt-occ` Service für Heizung/Klima |
| **GUI (Vario Mobil)** | 20+ | ~800 | StatusBar, Standby, Branding, Layout |
| **GUI (Heating/Climate)** | 10 | ~800 | HeatingPage, ControlCard, Slider-Komponenten |
| **Dokumentation** | 18+ | ~3.500 | OCC-Architektur, Merge-Logs, Wissensspeicher |
| **i18n / Übersetzungen** | 6 | ~3.500 | DE-Übersetzungen, Override-Script, TS-Updates |
| **Buildsystem** | 12 | ~1.600 | GX/WASM Build, Deploy, Merge-Scripts |
| **Screen Blanker** | 4 | ~50 | Standby-Uhr, Blanker-API |
| **Customisations** | 4 | ~1.230 | Dynamisch geladene Customisations (Upstream) |
| **Settings / Backup** | 5 | ~430 | Kontaktseite, Backup/Restore, StatusBar-Settings |
| **Theming / Images** | 15+ | ~200 | Vario-Logos, Splash, Icons |
| **Bugfixes / Refactoring** | diverse | ~300 | QML-Fehler, WASM-Build, Deploy-Fixes |
| **Upstream-Merges** | — | — | Tank-Backup, Breadcrumbs, DC-Loads, DVCC |

---

## 4. Nicht committete Änderungen

| Status | Pfad | Aufwand |
|--------|------|---------|
| Untracked (ignorieren) | `services/dbus-mqtt-occ/__pycache__/` | 0 h (Build-Artefakt) |

**Keine relevanten uncommitteten Code-Änderungen.** Working Tree ist sauber bis auf Python-Cache.

---

## 5. Technische Schwerpunkte (für Rechnung)

1. **Fork Victron GUI v2** als Vario-Mobil-/OpenCamperCore-Basis
2. **Neue Heizungs-/Klima-Steuerung** (3 Zonen + 2 Klima) inkl. Backend-Bridge
3. **MQTT↔D-Bus Integration** für externe Steuerung (Scheer Selection / OCC)
4. **Umfangreiche deutsche Lokalisierung** mit Override-Workflow
5. **Build- und Deploy-Pipeline** für GX-Hardware und WASM-Browser
6. **Wiederholte Upstream-Merges** (Victron main v1.2.29 → v1.3.12)
7. **Architektur- und Projektdokumentation** für OCC-Integration
