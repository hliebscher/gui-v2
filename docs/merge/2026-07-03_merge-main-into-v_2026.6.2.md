# Merge-Dokumentation: origin/main → v_2026.6.2

**Datum:** 2026-07-03  
**Branch:** `v_2026.6.2`  
**Sicherungsbranch:** `v_2026.6.2-backup-pre-merge-2026-07-03` @ `66839d50`  
**Script:** `./scripts/merge-main-into-vario.sh`

---

## 1. Ausgangslage

| Parameter | Wert |
|-----------|------|
| Merge-Base | `df99c39a` |
| origin/main HEAD | `a9d4d6e0` (v1.3.13 + 12 weitere Commits) |
| v_2026.6.2 HEAD (vor Merge) | `66839d50` |
| Commits in main (nicht in Branch) | **13** |
| Commits im Branch (nicht in main) | **126** |

### Neue Upstream-Commits (Auszug)

- v1.3.13 Version Bump
- Demo-Mode-Indikator verbessert
- Shelly Settings Rework (Sub-Page für Kanäle)
- Battery: Cell-Measurements Layout-Fix
- Solar Drilldown PV-Charger Fix
- Switches: Type read-only bei nur einem Typ
- Generic Inputs: Label-Update
- UI-Test-Utility `tools/uicompare/` (neu)
- Übersetzungs-Updates (2026-06-29, 2026-07-01)

---

## 2. Konflikte — Übersicht

| # | Datei | Ergebnis |
|---|-------|----------|
| — | **Keine manuellen Konflikte** | Dry-Run und Merge ohne `--diff-filter=U` |
| Auto | `i18n/venus-gui-v2_de.ts` | Auto-Merge OK (kein Konflikt-Marker) |
| Auto | `cmake/ModuleVenus_Sources.cmake` | Auto-Merge OK — **manuell prüfen** (Vario OCC-Quellen) |
| Auto | `src/veutil` (Submodule) | Auf main @ `62a0587` gesetzt |

---

## 3. Geänderte Dateien durch Merge (55)

| Bereich | Dateien | Beschreibung |
|---------|---------|--------------|
| Shelly | 2 | PageSettingsShelly + neue PageSettingsShellyDevice |
| i18n | 18 | Alle TS-Sprachen aktualisiert |
| UI Tests | 1 | tst_solarinputmodel.qml |
| Demo Mode | 1 | DemoModeIndicator.qml |
| Switches/IO | 3 | Type-Auswahl, Generic Input Labels |
| Solar | 1 | solarinputmodel.cpp |
| Battery | 1 | LynxIon cell measurements layout |
| Themes | 6 | Geometry/Typography Anpassungen |
| Tools | 14 | **Neu:** tools/uicompare/ (UI-Vergleichstool) |
| CMake | 2 | CMakeLists.txt, ModuleVenus_Sources.cmake |

**Statistik:** +4.332 / −1.897 Zeilen

---

## 4. Gates

| Gate | Ergebnis |
|------|----------|
| Dry-Run Konflikte | ✅ Keine |
| Build (WASM) | ✅ Erfolgreich (~5 Min) |
| Konflikte nach Auto-Lösung | ✅ Keine offenen |
| Vario-Regression (GX) | ⬜ Manuell auf Gerät prüfen |

Log-Dateien: `analysis/merge_*_2026-07-03.log`

---

## 5. Vario-Features — Verifikation (GX)

- [ ] StatusBar: Logo, Temperatur, Uhr, Schalter-Text
- [ ] ScreenBlanker: Uhr antippen → Standby mit Uhr/Datum
- [ ] PageContact erreichbar (Logo-Klick)
- [ ] Backup & Restore in Settings
- [ ] Tank-Farben korrekt
- [ ] **Settings → Heating & Climate** (OCC Steuerseite)
- [ ] Shelly-Settings (neu aus main)

---

## 6. Notizen

- Vario-Hotspot `cmake/ModuleVenus_Sources.cmake` wurde durch Merge berührt — OCC-Dateien (HeatingPage, OccSetpointSliderRow, …) im Build prüfen
- Backup-Branch vorhanden: `v_2026.6.2-backup-pre-merge-2026-07-03`
- Rollback: `git reset --hard v_2026.6.2-backup-pre-merge-2026-07-03`
