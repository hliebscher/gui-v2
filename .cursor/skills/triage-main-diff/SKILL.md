---
name: triage-main-diff
description: Vergleicht aktuellen Branch gegen origin/main, analysiert Änderungen, und übernimmt nur sicher triagierte Teile ohne branch-spezifische Features zu regressieren.
---

## Zweck
Dieser Skill liefert einen **reproduzierbaren Workflow**, um Änderungen zwischen dem aktuellen Branch und `origin/main` zu analysieren und selektiv zu übernehmen – mit **klaren Risiko-Regeln** und **Verifikations-Gates**.

Er ist absichtlich prozesslastig: Er soll **Regressionen** (insb. in QML/UI-Flows) verhindern, nicht „schnell irgendwas mergen“.

## Wann benutzen?
- Du hast länger auf einem Feature/Release-Branch gearbeitet und willst **gezielt** Teile nachziehen/übernehmen, ohne eure abweichenden Features kaputt zu machen.
- Du willst einen **Integrations-Branch** von `origin/main` aufbauen und nur „sichere“ Änderungen aus deinem Branch hineintragen.

## Grundprinzipien (nicht verhandelbar)
- **Nie blind cherry-picken.** Immer vorher klassifizieren und nachher verifizieren.
- **Kleinste sinnvolle Einheit** bevorzugen: Commit → falls gemischt, Hunks.
- **Nach jeder übernommenen Einheit**: Build/Test/Smoke (Gates unten).
- Wenn unklar: **nicht übernehmen** (und begründen).

## Dokumentationspflicht (immer)
Jeder Triage-Lauf erzeugt ein **Entscheidungslog**. Ohne Log gilt der Lauf als „nicht gemacht“.

- **Vor der Übernahme**: Kandidaten, Risiko, geplante Gates notieren.
- **Nach jeder Einheit** (Commit oder Hunk-Commit): Ergebnis der Gates + ggf. Abweichungen notieren.
- **Nicht übernommen**: explizit dokumentieren (warum, was wäre nötig).

Empfohlene Ablage (eine davon wählen, aber konsequent bleiben):
- `docs/triage/<datum>-<topic>.md` oder
- MR/PR-Beschreibung (Abschnitt „Triage log“)

## Vorbereitung
### Basis aktualisieren

```bash
git fetch origin main
```

### Divergenz sichtbar machen

```bash
# Commits, die nur auf deinem Branch liegen
git log --oneline --decorate origin/main..HEAD

# Gesamtänderungen (Merge-Base basiert, robust bei Merges)
git diff --stat origin/main...HEAD

# (Optional) Strukturvergleich bei Rewrite/Rebase
git range-diff origin/main...HEAD
```

### Schnelle Hotspot-Liste (Dateien)

```bash
git diff --name-only origin/main...HEAD
```

## Risiko-Klassifikation (Regeln)
Klassifiziere jede Änderung/Commit (oder Datei, wenn nötig) in **niedrig / mittel / hoch**. Ziel: nur „niedrig“ direkt übernehmen; „mittel/hoch“ nur mit zusätzlicher Absicherung.

### Niedriges Risiko (typisch: sofort übernehmbar)
- `docs/`, `README*`, `TRANSLATIONS.md`
- reine Testdaten/Fixtures
- reine CI-/Meta-Änderungen (wenn vorhanden: `.github/`, `scripts/`), **ohne** Build-Toolchain umzubauen
- reine Übersetzungen, **sofern sie kein aktives Override-System beeinflussen** (siehe unten)

### Übersetzungen mit Override-System (bei euch: `scripts/translation-override.py`)
Wenn Übersetzungen über eine eigene Override-Pipeline stabilisiert werden (z.B. `translation-overrides.json` + Apply/Extract-Workflow), sind diese Änderungen **mindestens mittleres Risiko**:
- Overrides können Upstream-Strings absichtlich übersteuern oder auch unbeabsichtigt „leerziehen“ (leere Werte).
- Der Vergleichs-Ref (z.B. `origin/main`) muss klar sein, sonst extrahierst du falsche Diffs.

Zusätzliches Gate für Übersetzungs-Overrides:
- `python3 scripts/translation-override.py extract -b origin/main` (oder der Ref, den ihr als Basis benutzt)
- Prüfen: Anzahl Overrides plausibel, leere Werte sind **intentional** und begründet (im Log).

### Mittleres Risiko (übernehmen möglich, aber nur mit enger Verifikation)
- begrenzte QML-Änderungen mit klarer Lokalität (z.B. Text/Label/Visibility), **ohne** Navigation/State/Bindings umzubauen
- kleinere C++-Änderungen, die keine Start-/Boot-Reihenfolge betreffen
- CMake-Anpassungen, die nur Quellenlisten/Optionen erweitern (keine Toolchain-Wechsel)

### Hohes Risiko (nicht übernehmen, außer du kannst die branch-spezifischen Features explizit absichern)
- UI/Navigation/State: `pages/`, `components/`, `Main.qml`, `ApplicationContent.qml`, `pages/DialogLayer.qml`
- App-Start/Boot: `src/main.cpp` (oder Plattform-Init)
- Build/Packaging/Module-Infrastruktur: `cmake/` (insb. Module, Source-Lists), `wasm/`, Deployment-Skripte
- Änderungen, die „Feature-Flags“/Plugin-Mechanismen beeinflussen (z.B. Integrations-/Plugin-Loader)

## Änderungszerlegung: Commit vs. Hunk
### 1) Erst commitweise triagieren
Für jeden Kandidaten-Commit:
- **Was ist der Zweck?** (Bugfix/Refactor/Build/Docs/Test)
- **Welche Pfade?** (Riskoklasse)
- **Ist es gemischt?** (z.B. QML + Docs + Build in einem Commit)

Hilfreich:

```bash
git show --name-status --stat <commit>
git show <commit>
```

### 2) „Gemischte“ Commits auftrennen (Hunk-basiert)
Wenn ein Commit sowohl sichere als auch riskante Teile enthält, nimm **nur die sicheren Hunks**.

Empfohlener Ablauf (lokal auf Integrations-Branch):

```bash
# Starte auf einem Integrations-Branch, der von origin/main kommt
git checkout -b triage/<topic> origin/main

# Hol dir die betroffenen Dateien aus deinem Arbeits-Branch als Basis…
git restore --source <dein-branch> -- <pfad1> <pfad2>

# …und stage dann nur die sicheren Hunks
git add -p

# Rest wieder verwerfen (damit nichts „aus Versehen“ mitkommt)
git restore --worktree --staged -- <pfade>
```

Alternative, wenn du commitweise starten willst:
- `git cherry-pick -n <commit>` (nicht committen)
- dann `git reset`/`git restore -p` nutzen, um riskante Hunks rauszunehmen
- erst danach committen

## Integrations-Workflow (empfohlen)
### 1) Integrations-Branch erstellen

```bash
git checkout -b triage/<topic> origin/main
```

### 2) Übernahme-Regel
- **Niedriges Risiko**: commitweise übernehmen ist ok (mit Gates).
- **Mittel**: commitweise oder hunks, aber Gates + ggf. extra Smoke.
- **Hoch**: nur übernehmen, wenn du eine **konkrete Absicherung** für die branch-spezifischen Features definierst (siehe Smoke-Gates).

## Verifikations-Gates (Definition „zerstört keine aktuellen Features“)
Eine Übernahme gilt nur als „safe“, wenn **alle** relevanten Gates für ihre Risikoklasse erfüllt sind.

### Gate A: Build (Pflicht)
Mindestens ein lokaler Build, passend zu eurem Standard:

```bash
# Beispiel (anpassen an euren Setup)
cmake -S . -B build && cmake --build build -j
```

Wenn ihr mehrere Targets pflegt (z.B. Desktop/wasm), mindestens dasjenige, das für eure Team-Entwicklung der Standard ist.

### Gate B: Tests (wenn vorhanden)
Wenn es Test-Suiten gibt:

```bash
ctest --test-dir build --output-on-failure
```

Wenn keine Tests existieren/konfiguriert sind: dokumentieren („nicht vorhanden“), dann Gate C strenger fahren.

### Gate C: GUI-Smoke (Pflicht für UI-relevante Änderungen)
Ziel: branch-spezifische Features bleiben **vorhanden und erreichbar**, keine offensichtlichen Runtime-Probleme.

Minimaler Smoke (anpassen an eure App, aber diese Punkte als Standard behalten):
- App startet ohne Crash.
- Navigation zu Settings funktioniert.
- **Integrations-Settings** (z.B. „Device Integrations“) ist sichtbar und öffnet Unterseiten.
- Statusbar/Dialogs funktionieren im Standardfluss (kein Overlay-Deadlock).
- Keine neuen QML-Errors/Warnings im Start-Log (soweit sichtbar).

Für „hoch“-Risiko-Änderungen muss der Smoke zusätzlich beinhalten:
- Branch-spezifische Feature-Flows, die nicht in `origin/main` existieren, sind weiterhin erreichbar.
- Mindestens 1 negativer Test: ein bewusstes Edge-Case-Navigieren (zurück/abbrechen), um State/Stack-Probleme zu sehen.

## Entscheidungslog (Output, damit es nachvollziehbar ist)
Für jede übernommene Einheit (Commit oder Hunk-Commit) dokumentiere kurz:
- **Warum übernommen** (z.B. Bugfix, harmloser Refactor, Docs)
- **Risiko** (niedrig/mittel/hoch) + Begründung (Pfade/Subsysteme)
- **Dateien** (kurz)
- **Gates** (Build/Test/Smoke) + Ergebnis

Für nicht übernommene Kandidaten:
- **Warum nicht** (z.B. UI-State betrifft branch-spezifische Navigation; unklarer Impact)
- **Was wäre nötig**, um es sicher zu übernehmen (zusätzlicher Smoke, Split, Feature-Flag, etc.)

### Log-Vorlage (kopieren & ausfüllen)

```text
Topic:
Datum:
Basis: origin/main @ <sha>
Quelle: <dein-branch> @ <sha>

Kandidaten (Kurzliste):
- <commit> | Risiko: niedrig/mittel/hoch | Pfade: ... | Plan: übernehmen/nicht

Übernommen:
- Einheit: <commit oder hunk-commit-sha>
  - Warum:
  - Risiko + Begründung:
  - Dateien:
  - Gates:
    - Build:
    - Tests:
    - GUI-Smoke:
  - Ergebnis/Notes:

Nicht übernommen:
- Kandidat: <commit>
  - Warum nicht:
  - Was wäre nötig:
```

## Optional: Script/Hook-Konzept (nicht verpflichtend)
Wenn ihr den Ablauf später teil-automatisieren wollt, bietet sich ein kleines Script an, das **nur analysiert** und eine Triage-Checkliste ausgibt (keine automatischen Merges!).

Vorschlag:
- `.cursor/scripts/triage-main-diff.sh`
  - `git fetch origin main`
  - Ausgabe: Divergenz, `--name-only`, grobe Risiko-Klassifikation per Pfadregex, Liste der Kandidaten-Commits
  - Exit-Code != 0, wenn „hoch“-Risiko-Pfade gefunden wurden (damit CI/Hooks warnen können)

Das Script sollte bewusst keine interaktiven Schritte automatisieren (kein `cherry-pick`), sondern nur die Vorbereitung beschleunigen.
