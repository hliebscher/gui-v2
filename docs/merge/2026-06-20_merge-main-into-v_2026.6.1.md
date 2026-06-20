# Merge-Dokumentation: origin/main → v_2026.6.1

**Datum:** 2026-06-20
**Branch:** `v_2026.6.1`
**Sicherungsbranch:** `v_2026.6.1-backup-pre-merge-2026-06-20`

---

## 1. Ausgangslage

| Parameter | Wert |
|-----------|------|
| Merge-Base | `1bfe90b777632c12e49932b55e4b2d7904f7cc3f` |
| origin/main HEAD | `b7917d26` |
| v_2026.6.1 HEAD | `74c20e9e` |
| Commits in main (nicht in Branch) | 22 |
| Override(s) angewendet | 205 |

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
| Build (WASM) | ✅ Erfolgreich |
| Konflikte | ✅ 1 Datei (`venus-gui-v2_de.ts`) + veutil, gelöst |
| Vario-Regression (GX) | ⬜ Manuell prüfen |

---

## 5. Notizen

<!-- Konflikt-Details, unerwartete Änderungen, manuelle Eingriffe -->

