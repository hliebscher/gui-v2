Topic: triage-main-diff_skill_test
Datum: 2026-04-16
Basis: origin/main @ 2ea2f366a74daa6a5e8f4cd0a39d39a64e259580
Quelle: vario_2026.1 @ 04a124821d06f83147a46505c9ec5afa9ec72b12

## Kontext
Dieses Log wurde erstellt, indem der Skill `triage-main-diff` auf den aktuellen Branch angewandt wurde.
Es dokumentiert **Analyse + Triage-Entscheidungen**. Es wurden **keine** Cherry-Picks/Übernahmen durchgeführt.

## Kandidaten (Kurzliste)
- 04a124821 Refactor ScreenBlanker API usage (QML) | Risiko: hoch | Pfade: ApplicationContent.qml, components/StatusBar.qml, pages/StandbyPage.qml | Plan: nicht direkt übernehmen (erst isolieren + UI-Smoke)
- c0f69aa22 StatusBar Refactor/Icon-Größen | Risiko: hoch | Pfade: components/StatusBar.qml (+ ggf. weitere UI) | Plan: nicht direkt übernehmen
- 96e9e89e3 DE-Übersetzungen/Overrides | Risiko: mittel | Pfade: i18n/translation-overrides.json, i18n/venus-gui-v2_de.ts, scripts/translation-override.py | Plan: nur zusammen triagieren (Override-Gate + Plausibilitätscheck)
- 557b11068 DE-Übersetzungen | Risiko: mittel | Pfade: i18n/venus-gui-v2_de.ts (+ Override-System) | Plan: nur zusammen triagieren (Override-Gate + Plausibilitätscheck)

## Risiko-Sichtung (Pfad-basiert)
Gesamt: 62 Dateien verändert (gegen `origin/main...HEAD`)

### Hoch (24)
- ApplicationContent.qml
- cmake/ModuleVenus_Sources.cmake
- components/* (mehrere, inkl. StatusBar.qml)
- pages/* (mehrere, inkl. Settings/BackupRestore)
- src/* (customisations.*, screenblanker.*, enums.h, veutil)

### Niedrig (5)
- README_de.md
- TRANSLATIONS.md
- i18n/translation-overrides.json
- i18n/venus-gui-v2.ts
- i18n/venus-gui-v2_de.ts

Hinweis: Obwohl `i18n/*` pfadbasiert „niedrig“ wirkt, ist es in diesem Branch **prozesskritisch**, weil:
- `scripts/translation-override.py` Übersetzungs-Overrides extrahiert/anwendet (stabilisiert gegen Upstream-Updates)
- `i18n/translation-overrides.json` enthält **263** Overrides, davon **48** leere Werte (muss intentional sein, sonst riskant)

### Mittel (33)
- images/* (SVG/AF, inkl. neue Assets)
- scripts/* (Build/Copy/Translations)
- tools/customisationcompiler.py
- themes/color/ColorDesign.json
- data/mock/conf/setup-common.json
- .github/save/rc.local

## Übernommen
- (keine) — Analyse/Skill-Test-Run

## Nicht übernommen (Begründung)
- **UI/QML/C++/CMake gemischt in vielen Commits**: hoher Regression-Impact für branch-spezifische Features wahrscheinlich.
- **Empfohlenes Vorgehen**: Integrations-Branch von `origin/main` anlegen und dann nur „niedrig“-Risiko-Commits (z.B. reine Übersetzungen) separat triagieren; alles UI/C++ nur mit explizitem GUI-Smoke pro Einheit.

## Gates
Da keine Übernahme durchgeführt wurde, wurden keine Build/Test/Smoke-Gates ausgeführt.
Beim ersten tatsächlichen Übernahme-Schritt sind mindestens diese Gates Pflicht:
- Build: `cmake -S . -B build && cmake --build build -j`
- Tests (falls konfiguriert): `ctest --test-dir build --output-on-failure`
- GUI-Smoke: App-Start, Settings, Integrations-Seiten, Statusbar/Dialogs, keine neuen QML-Errors

## Übersetzungs-Triage (vertieft, da „wirklich wichtig“)
### Override-System-Check (gegen `origin/main`)
Mit `python3 scripts/translation-override.py extract -b origin/main` ergibt sich aktuell:
- Extrahiert: **269** Overrides (davon **48** leere Werte)
- Repo-JSON: **263** Overrides (davon **48** leere Werte)
- **Wichtig**: Es gibt **25 Keys nur in eurer JSON** und **31 Keys, die extrahiert werden, aber in eurer JSON fehlen**.
  - Konsequenz: fehlende Keys gehen euch beim nächsten Upstream-Update **nicht** automatisch wieder rein (Overrides werden nicht angewendet).

### Auffällige/gefährliche Overrides (funktional falsch)
Diese Keys sind in eurer `translation-overrides.json` offensichtlich nicht als Himmelsrichtung übersetzt und sollten als Regression betrachtet werden:
- `cardinalDirection_short_south` = `mit einer`
- `cardinalDirection_short_east` = `E-Mail`

### Keys nur in aktueller JSON (25)
Diese Keys sind Overrides, die **nicht** mehr als Diff vs `origin/main` auftauchen (mögliche Altlast / veraltete Abweichung):
- `cardinalDirection_short_north` = 'N'
- `cardinalDirection_short_west` = 'W'
- `common_words_go_to_redetect_system` = "Wenn die Verbindung kürzlich getrennt wurde, gehen Sie zu Einstellungen → Geräte → %1 → Erweitert, und wählen Sie 'VE.Bus-System erneut erkennen'."
- `ev_*` (mehrere Status/Labels)
- `settings_logging_vrm_portal`, `settings_units_mixed`, `settings_vrm_device_registration`
- `switchable_output_*` (mehrere Status-Texte)

### Keys nur in extrahiertem Diff vs `origin/main` (31)
Diese Keys fehlen in eurer JSON, würden aber nach aktuellem Stand **neu** als Override gelten:
- `microgrid_*` (mehrere)
- `page_switchable_output_*` (mehrere)
- `pagesettingssupportstate_*` (mehrere)
- `settings_security_profile_change_password_title`
- `settings_display_boat_page`, `settings_minmax_time_to_go`, `boat_page_time_to_go`
- `vebus_device_phase_x_device_x_index_x`
- `solarchargers_state_external control`

### Empfehlung (sicherster Weg)
- Übersetzungen/Overrides **nicht** als „low risk“ behandeln.
- Für „safe“: erst `extract -b origin/main` laufen lassen und die **Key-Differenzen** erklären/aufräumen.
- Insbesondere die kaputten Himmelsrichtungen (`cardinalDirection_short_*`) fixen und in der GUI verifizieren (Smoke).

