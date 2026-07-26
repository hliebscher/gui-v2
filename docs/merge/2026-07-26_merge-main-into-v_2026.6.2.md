# Merge-Dokumentation: origin/main → v_2026.6.2

**Datum:** 2026-07-26  
**Branch:** `v_2026.6.2`  
**Sicherungsbranch:** `v_2026.6.2-backup-pre-merge-2026-07-26`  
**Merge-Commit:** `7737dc65`

---

## 1. Ausgangslage

| Parameter | Wert |
|-----------|------|
| Merge-Base (vor Merge) | `76afc8c6` |
| origin/main HEAD | `0a4f9a4b` |
| v_2026.6.2 HEAD (vor Merge) | `f51dbf03` |
| Commits in main (nicht im Branch) | 8 |

### Neue Commits aus origin/main

| Hash | Message |
|------|---------|
| `0a4f9a4b` | Dev: expand the copilot review instructions |
| `6c6402e47` | Dev: command copilot to follow the code review instructions |
| `5c8bcaf7f` | Dev: provide copilot with thorough code review instructions |
| `39039339b` | Update translations faberd/update-translations-20260713-1238 |
| `b3eed933e` | Settings: Add bt sensors UDP/BLE gateway access setting |
| `f8ecb0628` | Battery: hide battery bank settings menu when empty |
| `c5f63e7ff` | Tests: fix unit test working directory |
| `731aaf527` | Dev: Write comprehensive copilot CLI context docs |

---

## 2. Konflikte — Übersicht

| # | Datei | Lösung |
|---|-------|--------|
| — | — | **Keine Konflikte** (Dry-Run + Merge clean) |
| — | `src/veutil` (Submodule) | Pointer auf origin/main @ `62a0587` gesetzt |

Auto-Merge: `cmake/ModuleVenus_Sources.cmake`, `data/mock/conf/setup-common.json`, `i18n/venus-gui-v2_de.ts`

---

## 3. Vario-Features — Verifikation

- [ ] StatusBar: Logo, Temperatur, Uhr, Schalter-Text
- [ ] ScreenBlanker: Uhr antippen → Standby mit Uhr/Datum
- [ ] ScreenBlanker: Auto-Timeout nach DisplayOff-Einstellung
- [ ] PageContact erreichbar (Logo-Klick)
- [ ] Backup & Restore in Settings
- [ ] Tank-Farben korrekt
- [ ] Settings → Heating & Climate
- [x] `HeatingPage` / `HeatingCard` weiterhin in `ModuleVenus_Sources.cmake`
- [x] `BatteryBankModel.qml` von main übernommen

---

## 4. Gates

| Gate | Ergebnis |
|------|----------|
| Konflikte | ✅ keine |
| Build (GX) | ✅ erfolgreich (~147 s) |
| Build (WASM) | ❌ Toolchain: Qt6Gui/EGL nicht gefunden (`HAVE_EGL` Failed) — Umgebungsproblem, nicht Merge-bedingt |
| Vario-Regression (GX) | ⬜ manuell auf Gerät |

---

## 5. Notizen

- Workflow: `./scripts/merge-main-into-vario.sh analyze` → `backup` → `merge --commit`
- WASM-Verify (`scripts/build-wasm.sh`) schlägt in dieser Umgebung an Qt/EGL fehl; GX-Build als Gate genutzt
- Hotspot-Hinweis nur bei `cmake/ModuleVenus_Sources.cmake` (erwartet: BatteryBankModel hinzu, PageBatterySettingsBattery entfernt)
