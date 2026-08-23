# Merge-Dokumentation: origin/main → v_2026.6.3

**Datum:** 2026-08-23  
**Branch:** `v_2026.6.3`  
**Sicherungsbranch:** `v_2026.6.3-backup-pre-merge-2026-08-23` @ `e974e41c`  
**Merge-Commit:** `86181a1f`

---

## 1. Ausgangslage

| Parameter | Wert |
|-----------|------|
| Merge-Base (vor Merge) | `97f659b5` |
| origin/main HEAD | `2ffcc3cb` |
| v_2026.6.3 HEAD (vor Merge) | `e974e41c` |
| Commits in main (nicht im Branch) | 5 |

### Neue Commits aus origin/main

| Hash | Message |
|------|---------|
| `2ffcc3cb` | AC System: rename "RS devices" to "Inverters" |
| `ce6cf275` | MQTT: Device product names should not be translated |
| `35d5f2ea` | Portrait: fix clicks on first button of navigation bar "more" dialog |
| `cc14e21b` | Settings: clean up use of SettingsListNavigation |
| `6ae45544` | Update translations faberd/update-translations-20260817-1238 |

---

## 2. Konflikte — Übersicht

| # | Datei | Lösung |
|---|-------|--------|
| — | — | **Keine Konflikte** (Dry-Run + Merge clean) |
| — | `i18n/venus-gui-v2_de.ts` | Auto-Merge + **239 Overrides** via `translation-override.py apply` |
| — | `src/veutil` (Submodule) | Pointer auf origin/main @ `c69bfeb` |

### Hotspot-Hinweise

- `pages/SettingsPage.qml`: Upstream zieht `SettingsListNavigation` als Inline-Component; Heating-Navigation bleibt.
- `cmake/ModuleVenus_Sources.cmake`: entfernt `components/listitems/core/SettingsListNavigation.qml` (jetzt inline in SettingsPage).

Vario weiterhin vorhanden: `HeatingPage`, `StandbyPage`, `screenblanker`, `StandbyClockDuration`-Binding.

---

## 3. Vario-Features — Verifikation

- [ ] StatusBar: Logo, Temperatur, Uhr, Schalter-Text
- [ ] ScreenBlanker: Uhr antippen → Standby mit Uhr/Datum
- [ ] ScreenBlanker: Auto-Timeout nach DisplayOff-Einstellung
- [ ] Standby-Uhr-Dauer Setting (Gui2/StandbyClockDuration)
- [ ] PageContact erreichbar (Logo-Klick)
- [ ] Backup & Restore in Settings
- [ ] Tank-Farben korrekt
- [ ] Settings → Heating & Climate
- [x] `HeatingPage` / `StandbyPage` / `screenblanker` in Sources
- [x] DE-Overrides nach Merge angewendet

---

## 4. Gates

| Gate | Ergebnis |
|------|----------|
| Konflikte | ✅ keine |
| Build (WASM) | ❌ Toolchain: Qt6Gui/EGL nicht gefunden (`HAVE_EGL` Failed) — Umgebungsproblem, nicht Merge-bedingt |
| Build (GX) | ✅ erfolgreich (~240 s) |
| Vario-Regression (GX) | ⬜ manuell |

---

## 5. Notizen

- Workflow: `./scripts/merge-main-into-vario.sh analyze` → `backup` → `merge --commit` → `verify` → `doc`
- Vario-Änderungen (Standby-Uhr Blank-Timeout inkl. Setting-Registrierung) erhalten
- Push: bewusst nicht ausgeführt
