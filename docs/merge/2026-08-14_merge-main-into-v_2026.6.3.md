# Merge-Dokumentation: origin/main → v_2026.6.3

**Datum:** 2026-08-14  
**Branch:** `v_2026.6.3`  
**Sicherungsbranch:** `v_2026.6.3-backup-pre-merge-2026-08-14` @ `afca6d36`  
**Merge-Commit:** `228c63ba`

---

## 1. Ausgangslage

| Parameter | Wert |
|-----------|------|
| Merge-Base (vor Merge) | `0a4f9a4b` |
| origin/main HEAD | `97f659b5` (v1.3.15 + Folge) |
| v_2026.6.3 HEAD (vor Merge) | `afca6d36` |
| Commits in main (nicht im Branch) | 43 |
| Branch voraus vs. main | 134 |

### Themen aus origin/main (Auswahl)

- Bump **v1.3.15**
- BLE encrypted instant readout
- EVCS auto mode source / charge current
- Generator UI + total run time fixes
- Notifications toast / bulk init
- PowerGuard API (ersetzt AcLimits-Settings)
- WASM Touch/Keyboard/Perf-Instrumentierung
- UI Compare / headless Tests + `tools/ui_capture_and_compare.py`
- Übersetzungs-Updates

---

## 2. Konflikte — Übersicht

| # | Datei | Lösung |
|---|-------|--------|
| — | — | **Keine Konflikte** (Dry-Run + Merge clean) |
| — | `i18n/venus-gui-v2_de.ts` | Auto-Merge + **231 Overrides** via `translation-override.py apply` |
| — | `src/veutil` (Submodule) | Pointer auf origin/main @ `c69bfeb` |

Auto-Merge u.a.: `cmake/ModuleVenus_Sources.cmake`, `i18n/venus-gui-v2_de.ts`

### Hotspot-Hinweis `ModuleVenus_Sources.cmake`

Erwartete Upstream-Änderung (Vario-Quellen bleiben):

- `+ pages/settings/BleSensorDelegate.qml`
- AcLimits* → **PowerGuard**Consumption/ProductionSettings

Weiterhin vorhanden: `HeatingPage`, `HeatingCard`, `PageContact`, `StandbyPage`, `BatteryWidget`, StatusBar-Varianten, `screenblanker`.

---

## 3. Vario-Features — Verifikation

- [ ] StatusBar: Logo, Temperatur, Uhr, Schalter-Text
- [ ] ScreenBlanker: Uhr antippen → Standby mit Uhr/Datum
- [ ] ScreenBlanker: Auto-Timeout nach DisplayOff-Einstellung
- [ ] PageContact erreichbar (Logo-Klick)
- [ ] Backup & Restore in Settings
- [ ] Tank-Farben korrekt (`#7C7267`, `#D2AA6D`)
- [ ] Settings → Heating & Climate
- [x] `HeatingPage` / `HeatingCard` in `ModuleVenus_Sources.cmake`
- [x] DE-Overrides (u.a. Fahrzeugbatterie, Kontakt) nach Merge angewendet

---

## 4. Gates

| Gate | Ergebnis |
|------|----------|
| Konflikte | ✅ keine |
| Build (WASM) | ✅ erfolgreich (~195 s) |
| Build (GX) | ⬜ optional auf Gerät |
| Vario-Regression (GX) | ⬜ manuell |

---

## 5. Notizen

- Workflow: `./scripts/merge-main-into-vario.sh analyze` → `backup` → `merge --commit` → `verify` → `doc`
- Vor Merge: lokale OCC-Docs/Rules gestasht, nach Merge wiederhergestellt (`stash pop`)
- Untracked nach Merge (noch nicht committed): OCC-Docs, Cursor-Rules, diese Merge-Doku
- Push: bewusst nicht ausgeführt

---

## 6. Nächste Schritte

1. Optional GX-Build: `./scripts/build-all.sh -H <gx-ip>`
2. Manuelle Vario-Smoke-Checks (Abschnitt 3)
3. Bei Bedarf Merge-Doku + OCC-Docs committen / `v_2026.6.3` pushen
