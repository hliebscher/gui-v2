# Merge-Dokumentation: origin/main → v_2026.6.3

**Datum:** 2026-09-16  
**Branch:** `v_2026.6.3`  
**Sicherungsbranch:** `v_2026.6.3-backup-pre-merge-2026-09-16` @ `22f51c16`  
**Merge-Commit:** `70b9f744`

---

## 1. Ausgangslage

| Parameter | Wert |
|-----------|------|
| Merge-Base (vor Merge) | `2ffcc3cb` |
| origin/main HEAD | `d680c66e` (v1.3.22) |
| v_2026.6.3 HEAD (vor Merge) | `22f51c16` |
| Commits in main (nicht im Branch) | 34 |

### Themen aus origin/main (Auswahl)

- Version Bumps **v1.3.18 → v1.3.22**
- BLE Sensor Encryption / Re-enable Fixes
- Boat charging layout (kein Consumption/Range)
- Microgrid F0/U0 Ranges
- Switches / Generic Inputs / Unpair Dialog
- Übersetzungs-Updates

---

## 2. Konflikte — Übersicht

| # | Datei | Lösung |
|---|-------|--------|
| — | — | **Keine Konflikte** (Dry-Run + Merge clean) |
| — | `i18n/venus-gui-v2_de.ts` | Auto-Merge + **239 Overrides** via `translation-override.py apply` |
| — | `src/veutil` (Submodule) | Pointer auf origin/main @ `1c2e8e3` |

Auto-Merge u.a.: `ApplicationContent.qml`, `cmake/ModuleVenus_Sources.cmake`, `pages/ControlCardsPage.qml`

### Hotspot-Hinweis

- `cmake/ModuleVenus_Sources.cmake`: Upstream entfernt `CaptionLabel.qml`, ergänzt Unpair/Pairing-Dialoge — Vario-Quellen (`HeatingPage`, `StandbyPage`, `screenblanker`) bleiben.
- `ApplicationContent.qml`: nur Upstream-Cleanup (`_inputComponent` / VKB-Kommentar); **StandbyClock-Binding erhalten**.

---

## 3. Vario-Features — Verifikation

- [ ] StatusBar / ScreenBlanker / Standby-Uhr-Dauer Setting
- [ ] PageContact, Backup & Restore, Heating & Climate
- [x] `HeatingPage` / `StandbyPage` / `screenblanker` in Sources
- [x] `StandbyClockDuration` Binding + Setting-UI + `BackendConnection` AddSettings
- [x] DE-Overrides nach Merge angewendet

---

## 4. Gates

| Gate | Ergebnis |
|------|----------|
| Konflikte | ✅ keine |
| Build (GX) | ✅ erfolgreich (~150 s) |
| Build (WASM) | ⬜ optional (Toolchain EGL oft problematisch) |
| Vario-Regression (GX) | ⬜ manuell |

---

## 5. Notizen

- Workflow: `./scripts/merge-main-into-vario.sh analyze` → `backup` → `merge --commit`
- Vario-Änderungen (Heating, Standby-Uhr Blank-Timeout, StatusBar, …) erhalten
- Push: bewusst nicht ausgeführt
