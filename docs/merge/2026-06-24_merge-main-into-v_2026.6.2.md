# Merge-Dokumentation: origin/main → v_2026.6.2

**Datum:** 2026-06-24
**Branch:** `v_2026.6.2`
**Sicherungsbranch:** `v_2026.6.2-backup-pre-merge-2026-06-24`

---

## 1. Ausgangslage

| Parameter | Wert |
|-----------|------|
| Merge-Base | `b7917d26597b233bfd0899b98be9cac329f4ab56` |
| origin/main HEAD | `df99c39a` |
| v_2026.6.2 HEAD | `94308ea2` |
| Commits in main (nicht in Branch) | 20 |

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
| Konflikte | ✅ Keine (clean merge) |
| Vario-Regression (GX) | ⬜ Manuell prüfen |

---

## 5. Notizen

<!-- Konflikt-Details, unerwartete Änderungen, manuelle Eingriffe -->

