# Aufwandsschätzung: Branch `v_2026.6.2` gegenüber `main`

**Methodik:** Konservative Schätzung anhand Codeumfang, Commit-Historie, Komplexität und Test-/Deploy-Zyklen.  
**Basis:** 99 nicht-Merge-Commits von Heiko Liebscher + Integrationsarbeit für Upstream-Merges.

---

## 1. Aufwand pro Bereich

### OpenCamperCore / Heating / Climate (GUI + Backend)

| Arbeitspaket | Dateien | Zeilen | Aufwand | Begründung |
|--------------|---------|--------|---------|------------|
| Architektur-Analyse & Docs (10 OCC-Docs) | 12 | ~3.200 | **groß (1–2 Tage)** | Umfangreiche Spezifikation, Schaltplan-Analyse, Architekturentscheidungen |
| `dbus-mqtt-occ` Bridge (Python) | 11 | ~1.900 | **groß (1–2 Tage)** | D-Bus-Service, MQTT, 3 Zonen + 2 Klima, Legacy-Pfade, Deploy |
| GUI Steuerseite (HeatingPage, Zone, Climate) | 4 | ~360 | **mittel (4–6 h)** | QML-Seiten, Iterationen, QML-Fehlerdebugging |
| Custom-Komponenten (Slider, ClimateBlock, Card) | 3 | ~400 | **mittel (3–5 h)** | OccSetpointSliderRow, OccClimateUnitBlock, HeatingCard |
| GUI Plugin (occ-heating) | 8 | ~700 | **mittel (4–6 h)** | 4 QML-Seiten, compile.sh, Übersetzungen |
| Settings/Controls-Integration | 3 | ~50 | **klein (1–2 h)** | SettingsPage, ControlCardsPage |
| **Zwischensumme OCC/Heating** | | | **~28–40 h** | |

### GUI — Vario Mobil Anpassungen

| Arbeitspaket | Aufwand | Begründung |
|--------------|---------|------------|
| StatusBar-Umbau (Landscape, Icons, Datum, Schalter) | **groß (1 Tag)** | 195 Zeilen geändert, mehrere Iterationen |
| StandbyPage + ScreenBlanker | **mittel (4–6 h)** | Neue Seite + C++-Anpassungen |
| Branding (Logos, Splash, vm_32, device-frame) | **mittel (3–5 h)** | 15+ Bilddateien |
| Layout-Fixes (Brief, Quantity, Solar, MultiGauge) | **klein (2–4 h)** | Mehrere kleine Anpassungen |
| Kontaktseite (PageContact) | **klein (1–2 h)** | 92 Zeilen neue Seite |
| Backup/Restore-Seite | **mittel (4–6 h)** | 356 Zeilen, Upstream-Integration |
| **Zwischensumme GUI Vario** | | **~22–33 h** | |

### i18n / Übersetzungen

| Arbeitspaket | Aufwand | Begründung |
|--------------|---------|------------|
| DE-Übersetzungen (venus-gui-v2_de.ts, Overrides) | **groß (1–2 Tage)** | ~30+ Commits, 3500+ Zeilen TS |
| translation-override.py | **mittel (3–4 h)** | 267 Zeilen, Branch-Vergleich |
| update-translations.sh / -de.sh | **klein (2–3 h)** | Script-Verbesserungen |
| TRANSLATIONS.md, README_de.md | **klein (1–2 h)** | Dokumentation |
| **Zwischensumme i18n** | | **~18–28 h** | |

### Buildsystem / Deploy / Merge

| Arbeitspaket | Aufwand | Begründung |
|--------------|---------|------------|
| build-all.sh, copy-gx/wasm.sh, copy-all.sh | **mittel (4–6 h)** | Deploy-Pipeline für GX + WASM |
| merge-main-into-vario.sh | **groß (1 Tag)** | 438 Zeilen, Konflikt-Handling, Dokumentation |
| WASM-Build-Fix (WrapRt/Emscripten) | **mittel (3–5 h)** | CMake-Anpassung, Debugging |
| build-gx.sh Deploy-Fix (killall) | **sehr klein (<30 min)** | 3 Zeilen |
| Wiederholte Merge-Durchläufe (v1.2.29→v1.3.12) | **groß (1–2 Tage)** | 6+ Merges, Konfliktlösung, Build-Tests |
| **Zwischensumme Build/Merge** | | **~24–38 h** | |

### Upstream-Integration (nicht eigenentwickelt, aber Integrationsaufwand)

| Arbeitspaket | Aufwand | Begründung |
|--------------|---------|------------|
| Tank-Backup/Restore (Manuel) | **klein (1–2 h)** | Merge + Test |
| Customisations (Chris Adams) | **klein (1–2 h)** | Merge + Test |
| DC-Load-Drilldowns, Breadcrumbs, DVCC | **sehr klein (<1 h)** | Merge only |
| **Zwischensumme Upstream** | | **~3–5 h** | |

### Dokumentation / Projektmanagement

| Arbeitspaket | Aufwand | Begründung |
|--------------|---------|------------|
| Merge-Dokumentation (4 Dateien) | **klein (2–3 h)** | Pro Merge-Lauf dokumentiert |
| Cursor Rules + Skills | **klein (1–2 h)** | occ-dokumentation.mdc, Skills |
| Triage-Dokumentation | **klein (1 h)** | |
| **Zwischensumme Docs/PM** | | **~4–6 h** | |

### Test, Deploy, Debugging (querliegend)

| Arbeitspaket | Aufwand | Begründung |
|--------------|---------|------------|
| GX-Build + Deploy + Test-Zyklen | **groß (1–2 Tage)** | Mehrfache Deploys, scp-Fehler, GUI-Neustart |
| HeatingPage QML-Debugging (ListTextItem, SettingsColumn) | **mittel (4–6 h)** | Mehrere Iterationen bis funktionsfähig |
| dbus-mqtt-occ Deploy/Troubleshooting | **mittel (3–4 h)** | paho-mqtt v2, ve_utils, Service-Installation |
| **Zwischensumme Test/Deploy** | | **~15–22 h** | |

---

## 2. Zusammenfassung nach Bereichen

| Bereich | Minimal (h) | Realistisch (h) | Maximal (h) |
|---------|-------------|-----------------|-------------|
| OpenCamperCore / Heating / Climate | 28 | 34 | 40 |
| GUI — Vario Mobil | 22 | 27 | 33 |
| i18n / Übersetzungen | 18 | 23 | 28 |
| Buildsystem / Deploy / Merge | 24 | 31 | 38 |
| Upstream-Integration | 3 | 4 | 5 |
| Dokumentation / PM | 4 | 5 | 6 |
| Test / Deploy / Debugging | 15 | 18 | 22 |
| **Gesamt** | **114** | **142** | **172** |

---

## 3. Gesamtschätzung

| Kennzahl | Wert |
|----------|------|
| **Minimalaufwand** | **114 Stunden** (~14,3 Tage à 8 h) |
| **Realistischer Aufwand** | **142 Stunden** (~17,8 Tage à 8 h) |
| **Maximalaufwand** | **172 Stunden** (~21,5 Tage à 8 h) |

### Empfohlene Rechnungsgrundlage

**142 Stunden** (realistisch, konservativ geschätzt)

Bei Tagessatz-Rechnung: **~18 Arbeitstage**

---

## 4. Aufwand pro Commit-Typ (Heiko Liebscher, 88 eigene Feature/Fix-Commits)

| Typ | Anzahl | Ø Aufwand | Summe |
|-----|--------|-----------|-------|
| Feature (feat/occ, neue Seiten) | ~8 | 4–8 h | ~40 h |
| Bugfix (fix/heating, QML, Deploy) | ~12 | 1–3 h | ~24 h |
| i18n (Übersetzungen) | ~25 | 0,5–1,5 h | ~25 h |
| GUI-Anpassung (Layout, Farbe, Logo) | ~20 | 0,5–1 h | ~15 h |
| Merge-Dokumentation | ~6 | 0,5–1 h | ~4 h |
| Build/Chore (Scripts, Merge) | ~8 | 2–6 h | ~24 h |
| Refactoring | ~3 | 1–2 h | ~5 h |
| Docs (OCC, Wissensspeicher) | ~6 | 2–4 h | ~15 h |

---

## 5. Nicht committete Änderungen

| Status | Aufwand |
|--------|---------|
| `services/dbus-mqtt-occ/__pycache__/` (untracked) | **0 h** — ignorieren |

Keine weiteren offenen Änderungen.

---

## 6. Hinweise zur Schätzung

- **Enthalten:** Entwicklung, Debugging, Deploy-Zyklen, Dokumentation, Merge-Arbeit
- **Nicht enthalten:** Projektmanagement extern, Hardware-Beschaffung, Reisekosten
- **Upstream-Code** (Manuel, Victron-Mitarbeiter) ist nicht als Eigenentwicklung gezählt, nur Integrationsaufwand
- Schätzung basiert auf **126 Commits über 10,5 Monate** — tatsächliche Arbeitszeit kann durch parallele Sessions und Kontextwechsel höher liegen
- Die **142 h realistisch** entsprechen ~3,5 Wochen Vollzeit oder verteilt über den Projektzeitraum
