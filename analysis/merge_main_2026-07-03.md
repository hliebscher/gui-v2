# Merge origin/main → v_2026.6.2 — Zusammenfassung

**Datum:** 2026-07-03  
**Script:** `./scripts/merge-main-into-vario.sh`  
**Status:** Merge gestaged, WASM-Build OK, Commit ausstehend/manuell

---

## Ablauf

| Schritt | Befehl | Ergebnis |
|---------|--------|----------|
| 1 | `analyze` | 13 Commits in main, **keine Konflikte** im Dry-Run |
| 2 | `backup` | Branch `v_2026.6.2-backup-pre-merge-2026-07-03` @ `66839d50` |
| 3 | `merge` | Auto-Merge OK, veutil synchronisiert |
| 4 | `verify` | **WASM Build successful** (~305 s) |
| 5 | `doc` | `docs/merge/2026-07-03_merge-main-into-v_2026.6.2.md` |

---

## Was kommt von main (v1.3.13)

- Shelly-Einstellungen überarbeitet (Kanäle in Unterseite)
- Demo-Mode-Indikator
- Battery Zellen-Messungen Layout
- Solar Drilldown Fix
- Switches/Generic Input UX
- UI-Vergleichstool `tools/uicompare/` (neu)
- Übersetzungen aller Sprachen

---

## Vario/OCC bleibt erhalten

Hotspots unverändert im Branch (nicht von main überschrieben):

- `pages/HeatingPage.qml`
- `pages/SettingsPage.qml` (Heating & Climate Eintrag)
- `components/StatusBar_Landscape.qml`
- `pages/StandbyPage.qml`, `PageContact.qml`
- `services/dbus-mqtt-occ/` (nicht im Merge, branch-only)

⚠️ **Prüfen:** `cmake/ModuleVenus_Sources.cmake` — wurde auto-gemerged

---

## Log-Dateien in diesem Ordner

| Datei | Inhalt |
|-------|--------|
| `merge_analyze_2026-07-03.log` | Analyze-Ausgabe |
| `merge_run_2026-07-03.log` | Merge-Ausgabe |
| `merge_verify_2026-07-03.log` | WASM-Build-Log |
| `git_changes.md` | Vollständige Branch-Analyse vs. main |
| `git_timeline.md` | Chronologie |
| `git_effort.md` | Aufwandsschätzung |
| `git_invoice_summary.md` | Rechnungsgrundlage |

---

## Nächste Schritte

```bash
# Merge abschließen (wenn noch nicht committed):
git commit -m "Merge origin/main (v1.3.13) into v_2026.6.2"

# GX deployen und testen:
./scripts/build-gx.sh -H <gx-ip>
./scripts/build-wasm.sh -H <gx-ip>

# Bei Problemen Rollback:
git reset --hard v_2026.6.2-backup-pre-merge-2026-07-03
```

---

## Referenzen

- Detaillierte Merge-Doku: `docs/merge/2026-07-03_merge-main-into-v_2026.6.2.md`
- Script-Hilfe: `./scripts/merge-main-into-vario.sh --help`
- Triage-Skill: `.cursor/skills/triage-main-diff/SKILL.md`
