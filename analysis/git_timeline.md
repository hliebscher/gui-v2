# Git-Timeline: Branch `v_2026.6.2` gegenüber `main`

**Zeitraum:** 2025-08-23 bis 2026-07-03 (~10,5 Monate)  
**126 Commits** (davon 27 Merge-Commits)

---

## 2025-08 — Projektstart Vario Mobil Fork

- **23.08.** — `new design` — Erster Commit: Vario-Mobil-Design-Fork
- **25.08.** — `vario` — Grundlegende Vario-Anpassungen
- **26.08.** — `copy files` — Dateien kopieren/übertragen
- **31.08.** — `logo new` — Neues Logo/Branding

---

## 2025-09 — Upstream-Integration & Schalter-UI

- **01.09.** — Schalter-Buttons: Text neben Icon, Farbanpassungen
- **08.–26.09.** — Mehrfache Upstream-Merges:
  - DC-Load-Drilldowns (Toby Tomkins)
  - Tank-Backup/Restore (Manuel/mr-manuel)
  - Customisations-Support (Chris Adams)
  - Breadcrumb-Navigation (Daniel McInnes)

---

## 2025-12 — Vario Beta 3.7 (GUI, Branding, i18n)

### Woche 1 (03.–05.12.)
- Logo-Experimente, Revert
- StatusBar-Umbau (`org status bar`)
- Datum/Uhrzeit in StatusBar
- VM-Icons (victronenergy_32, vm_32, vm_red)
- Schalter-UI (`switches`)
- WC/Abwasser-Übersetzung

### Woche 2 (07.–10.12.)
- Layout-Anpassungen, Logo-Position
- Standby-Uhr (`standby watch`)
- Deutsche Übersetzungen (mehrere Commits)
- **StandbyPage + ScreenBlanker** (`standby Page and screenblanker`)
- Farbanpassungen (Inverter, MultiGauge, Solar)

### Woche 3 (11.–17.12.)
- Solar-Kurzansicht (nur 1 Solar)
- Temperatur-Fixes, Übersetzungen
- **Kontaktseite** (`PageContact.qml`)
- **Backup/Restore-Seite** konsolidiert
- Firmware-Update-Logik verbessert
- Layout-Fixes (BriefSidePanel, QuantityGroup)
- **update-translations.sh** überarbeitet
- Umfangreiche **DE-Übersetzungen** (venus-gui-v2_de.ts)

### Extern
- **08.12.** — Dirk-Jan Faber: Translation-Update von Victron
- **05.12.** — Toby Tomkins: Motordrive in DC-Load-Liste
- **04.12.** — Martin Bosma: Genset-Fehlerbeschreibung

---

## 2026-02 — i18n & Merge v1.2.29

- **12.02.** — Merge Tag `v1.2.29` into vario_2026
- **12.02.** — DE-Übersetzungen: GPS-Formate, EV-Laden, Backup-Messages

---

## 2026-04 — StatusBar & ScreenBlanker Refactoring

- **15.04.** — StatusBar: Icon-Größen standardisiert, Copy-Datei entfernt
- **16.04.** — ScreenBlanker-API in QML-Dateien vereinheitlicht
- **16.04.** — Translation-Override-Script: flexibler Branch-Vergleich

---

## 2026-05 — OpenCamperCore Heating (Phase 1–3)

### 25.05.
- **WASM-Build-Fix** (WrapRt/Emscripten-Workaround)
- **StatusBar-Fixes** (auxButton, Switch-Icon, Text-Label)
- Merge origin/main v1.3.9

### 26.05. — OpenCamperCore Kernentwicklung
- **01:29** — `feat(occ)`: Bridge + Plugin + Architektur-Docs (~24 Dateien)
- **01:29** — vedbus.py durch echte velib_python-Version ersetzt
- **02:07** — Phase 3: NavBar Heating + ControlCard
- **02:31** — HeatingPage bedingt (Black-Screen-Fix)
- **06:42** — Heating in Settings verschoben (NavBar revert)
- **06:49** — Heating als SwipeView-Seite (erneut)

---

## 2026-06 — Merge-Wartung & OCC Steuerseite

### 08.–09.06.
- HeatingPage vereinfacht (Minimal-Test)
- **ScreenBlanker-Fix**: Standby-Uhr vor Hardware-Blank
- Merge origin/main v1.3.11

### 20.06.
- **merge-main-into-vario.sh** — Automatisiertes Merge-Script
- Merge origin/main v1.3.12

### 24.06. — OCC Steuerseite (Hauptfeature)
- Merge v_heat_2026.5 → v_2026.6.2
- Merge origin/main → v_2026.6.2
- **15:56** — NavBar-Tab entfernt, Settings-Seite wiederhergestellt
- **18:38** — `feat(heating)`: 3 Heiz + 2 Klima Steuerseite
- **18:44** — dbus-mqtt-occ Deploy-Fixes (ve_utils, paho-mqtt v2)
- **18:52** — Wissensspeicher + Cursor-Regeln

---

## 2026-07 — HeatingPage Fix (produktionsreif)

### 03.07.
- **20:06** — `fix(heating)`: HeatingPage mit Standard-Slidern
  - ListSlider statt OccSetpointSliderRow (QML-Ladefehler behoben)
  - SettingsColumn-Wrapper
  - serviceUidFromName(100)
  - build-gx.sh: killall vor Upload
- **Deploy + Test** auf GX 100.65.95.55 — **bestätigt funktionsfähig**

---

## Meilensteine

| Datum | Meilenstein |
|-------|-------------|
| 2025-08-23 | Fork-Start (Vario Mobil) |
| 2025-09-26 | Upstream-Features integriert (Tank-Backup, Customisations) |
| 2025-12-10 | StandbyPage + ScreenBlanker |
| 2025-12-15 | Kontaktseite + Backup/Restore |
| 2025-12-16 | Translation-Workflow etabliert |
| 2026-05-26 | OpenCamperCore Heating (Bridge + Plugin + Docs) |
| 2026-06-24 | OCC Steuerseite 3+2 implementiert |
| 2026-07-03 | HeatingPage produktionsreif auf GX |

---

## Aktivitätsverteilung (Commits pro Monat, Heiko Liebscher)

| Monat | Commits (ca.) | Schwerpunkt |
|-------|---------------|-------------|
| 2025-08 | 4 | Fork-Start, Branding |
| 2025-09 | 12 | Upstream-Merges, Schalter-UI |
| 2025-12 | 45 | GUI, i18n, Standby, Branding |
| 2026-02 | 4 | i18n, Merge v1.2.29 |
| 2026-04 | 3 | StatusBar, ScreenBlanker |
| 2026-05 | 10 | OCC Phase 1–3, WASM-Fix |
| 2026-06 | 15 | Merge-Wartung, OCC Steuerseite |
| 2026-07 | 1 | HeatingPage Fix |
