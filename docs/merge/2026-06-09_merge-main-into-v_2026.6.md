# Merge-Dokumentation: origin/main → v_2026.6

**Datum:** 2026-06-09  
**Branch:** `v_2026.6`  
**Sicherungsbranch:** `v_2026.6-backup-pre-merge-2026-06-09`

---

## 1. Ausgangslage

| Parameter | Wert |
|-----------|------|
| Merge-Base | `1315aa3bd` — „Inverter: show correct state text in solar drilldowns" (2026-05-20) |
| origin/main HEAD | `1bfe90b77` — „Bump version to v1.3.11" |
| v_2026.6 HEAD (vor Merge) | `8ff4baf50` — „fix(screenblanker): Restore standby clock before hardware blank" |
| Commits in main (nicht in Branch) | 31 |
| Commits in Branch (nicht in main) | ~100 (Vario-Historie seit v1.2.29) |

---

## 2. Konflikte — Übersicht

| # | Datei | Typ | Lösung |
|---|-------|-----|--------|
| 1 | `i18n/venus-gui-v2_de.ts` | content | **MAIN als Basis** + `translation-override.py apply` (206 Overrides) |
| — | `src/veutil` (Submodule) | Pointer | **MAIN** @ `62a0587` (Energy-per-distance Units) |

**Keine weiteren Konflikte** — alle anderen 210 Dateien wurden automatisch gemergt.

---

## 3. Konflikt-Detail

### 3.1 i18n/venus-gui-v2_de.ts

**Strategie (wie beim letzten Merge):**
1. `git checkout --theirs` → main-Version als Basis (alle neuen Keys)
2. `python3 scripts/translation-override.py apply` → 206 Vario-Overrides angewendet

**Ergebnis:** Neue upstream-Strings vorhanden, eigene DE-Übersetzungen erhalten.

### 3.2 src/veutil (Submodule)

**Problem:** Nach Auto-Merge zeigte Submodule auf `cd3b9bb` (veraltet).  
**main erfordert:** `62a0587` (enthält `Unit::WattHourPerKilometre` etc. für Boat-Page).  
**Build-Fehler ohne Fix:** `units.cpp:72` — unknown Unit enum members.

**Lösung:** `git checkout 62a0587` in `src/veutil`, staged.

---

## 4. Vario-Features — Verifikation (unverändert)

| Feature | Status |
|---------|--------|
| StatusBar: Logo, Temperatur, Uhr, Kontakt | ✅ Kein Diff in `StatusBar_Landscape.qml` |
| StatusBar: Schalter-Text neben Icon | ✅ Erhalten |
| ScreenBlanker + Standby-Uhr | ✅ `screenblanker.cpp`, `StandbyPage.qml` unverändert |
| PageContact | ✅ In CMake, unverändert |
| Backup & Restore | ✅ `PageSettingsGeneral.qml` unverändert |
| Tank-Farben (blackWater, diesel) | ✅ `#7C7267`, `#D2AA6D` in ColorDesign.json |
| Settings → Heating & Climate | ✅ Erhalten (falls auf Branch) |

---

## 5. Wichtige upstream-Änderungen (automatisch übernommen)

- **v1.3.10 / v1.3.11** — Version Bump
- **Boat Page** — Range, Consumption, Gear, Temperatures
- **DC Gensets** — neue Seiten und Mock-Daten
- **UI Controls** — ListItem inset/spacing Refactoring
- **Settings** — AC-In Limits, Internet-Gateway-Warnung, VRM-Instanzen
- **UiConfig** — `BackendConnection.needsWasmKeyboardHandler` → `UiConfig.needsWasmKeyboardHandler`
- **Switches** — product-ID-abhängige Settings
- **Translations** — faberd/update-translations-20260601

---

## 6. Gates

| Gate | Ergebnis |
|------|----------|
| Build (WASM) | ✅ Erfolgreich nach veutil-Fix |
| Konflikte | ✅ 1 Datei + Submodule, gelöst |
| Vario-Regression | ✅ Kritische Dateien unverändert |

---

## 7. Post-Merge Checkliste (manuell auf GX)

- [ ] StatusBar: Logo, Temperatur, Uhr, Schalter-Text
- [ ] ScreenBlanker: Uhr antippen → Standby mit Uhr/Datum
- [ ] ScreenBlanker: Auto-Timeout nach DisplayOff-Einstellung
- [ ] PageContact erreichbar (Logo-Klick)
- [ ] Backup & Restore in Settings
- [ ] Tank-Farben korrekt
- [ ] Portrait-Layout (main-Feature)

---

## 8. Wiederholbarer Workflow

```bash
git branch v_2026.X-backup-pre-merge-$(date +%Y-%m-%d)
git fetch origin main
git merge --no-commit --no-ff origin/main

# Konflikte:
git checkout --theirs i18n/venus-gui-v2_de.ts
python3 scripts/translation-override.py apply
git add i18n/venus-gui-v2_de.ts

# Submodule auf main-Pointer:
git checkout $(git ls-tree origin/main src/veutil | awk '{print $3}') -- src/veutil
git submodule update --init src/veutil

# Build + Commit
./scripts/build-wasm.sh
git commit
```
