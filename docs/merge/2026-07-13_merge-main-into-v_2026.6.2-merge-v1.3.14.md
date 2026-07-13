# Merge-Dokumentation: origin/main → v_2026.6.2-merge-v1.3.14

**Datum:** 2026-07-13
**Branch:** `v_2026.6.2-merge-v1.3.14`
**Sicherungsbranch:** `v_2026.6.2-merge-v1.3.14-backup-pre-merge-2026-07-13`

---

## 1. Ausgangslage

| Parameter | Wert |
|-----------|------|
| Merge-Base | `a9d4d6e02d9c4305372add8def8d74c90b30b816` |
| origin/main HEAD | `76afc8c6` |
| v_2026.6.2-merge-v1.3.14 HEAD | `78fecc1c` |
| Commits in main (nicht in Branch) | 19 |

---

## 2. Konflikte — Übersicht

| # | Datei | Lösung |
|---|-------|--------|
| 1 | `i18n/venus-gui-v2_de.ts` | main als Basis + `translation-override.py apply` |
| — | `src/veutil` (Submodule) | Pointer von origin/main |

---

## 3. Vario-Features — Verifikation

- [ ] StatusBar: Logo, Temperatur, Uhr, Schalter-Text
- [ ] ScreenBlanker: Uhr antippen → Standby mit Uhr/Datum
- [ ] ScreenBlanker: Auto-Timeout nach DisplayOff-Einstellung
- [ ] PageContact erreichbar (Logo-Klick)
- [ ] Backup & Restore in Settings
- [ ] Tank-Farben korrekt (`#7C7267`, `#D2AA6D`)
- [ ] Settings → Heating & Climate (falls aktiv)

---

## 4. Gates

| Gate | Ergebnis |
|------|----------|
| Build (WASM) | ✅ OK (~546 s) |
| Konflikte | ✅ Keine (Auto-Merge) |
| Vario-Regression (GX) | ⬜ Manuell auf GX testen |

---

## 5. Notizen

- **19 Upstream-Commits** integriert (v1.3.14): Switches, Boat, Opportunity Loads, Settings IO, Cleanup, uicompare.
- `cmake/ModuleVenus_Sources.cmake`: OCC-Dateien (HeatingPage, OccSetpointSliderRow, HeatingCard) **erhalten**.
- `pages/SettingsPage.qml`: Eintrag **Heating & Climate** unverändert vorhanden.
- `src/veutil` auf main-Pointer `62a0587` gesetzt.

