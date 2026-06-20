# Scripts für GUIv2

Dieses Verzeichnis enthält Hilfsscripts für Build, Deployment und Übersetzungen.

## Inhaltsverzeichnis

- [Build- und Copy-Scripts](#build-und-copy-scripts)
- [Merge main → Vario](#merge-main--vario)
- [Übersetzungs-Scripts](#übersetzungs-scripts)
- [translation-override.py – Externe Übersetzungs-Overrides](#translation-overridepy--externe-übersetzungs-overrides)

---

## Build- und Copy-Scripts

### `build-all.sh`

Baut GUIv2 für beide Plattformen (GX-Gerät und WebAssembly) in einem Durchlauf.

**Verwendung:**
```bash
./scripts/build-all.sh [Optionen]
```

**Optionen:**
- `-P, --preserve` - Build-Dateien nicht löschen
- `-H, --host HOST` - IP(s) oder Hostname(s) des GX-Geräts für direkten Upload (kommagetrennt)
- `-h, --help` - Hilfe anzeigen

### `copy-all.sh`

Kopiert die Build-Dateien für beide Plattformen (GX-Gerät und WebAssembly) in einem Durchlauf.

**Verwendung:**
```bash
./scripts/copy-all.sh [Optionen]
```

**Optionen:**
- `-H, --host HOST` - IP(s) oder Hostname(s) des GX-Geräts für direkten Upload (kommagetrennt)
- `-h, --help` - Hilfe anzeigen

**Einzelne Builds:** `build-gx.sh`, `build-wasm.sh`, `copy-gx.sh`, `copy-wasm.sh`

Weitere Details: [README_build-all.md](./README_build-all.md)

---

## Merge main → Vario

### `merge-main-into-vario.sh`

Wiederholbarer Workflow zum Integrieren von `origin/main` in einen Vario-Branch unter Beibehaltung branch-spezifischer Features (StatusBar, ScreenBlanker, Übersetzungs-Overrides, etc.).

**Verwendung:**
```bash
./scripts/merge-main-into-vario.sh analyze    # Divergenz + Konflikt-Vorschau
./scripts/merge-main-into-vario.sh backup     # Sicherungsbranch
./scripts/merge-main-into-vario.sh merge      # Merge + Auto-Lösung (DE + veutil)
./scripts/merge-main-into-vario.sh verify     # WASM-Build
./scripts/merge-main-into-vario.sh doc        # Doku-Template docs/merge/
./scripts/merge-main-into-vario.sh all        # analyze → backup → merge → verify-Hinweis
```

**Auto-Lösungen bei bekannten Konflikten:**
- `i18n/venus-gui-v2_de.ts` → main-Basis + `translation-override.py apply`
- `src/veutil` → Submodule-Pointer von `origin/main`

**Dokumentation:** `docs/merge/`, Skill `.cursor/skills/triage-main-diff/SKILL.md`

---

## Übersetzungs-Scripts

### `update-translations.sh`

Aktualisiert alle Übersetzungen:
1. Extrahiert neue Übersetzungsstrings aus dem Quellcode (lupdate)
2. Aktualisiert `venus-gui-v2.ts`
3. Optional: Lädt Übersetzungen von POEditor herunter (wenn `POEDITOR_TOKEN` gesetzt)

**Verwendung:**
```bash
./scripts/update-translations.sh
# Oder via CMake: cmake ..; make update_translations
```

**Voraussetzungen:** Konfiguriertes Build-Verzeichnis, Qt6 lupdate

### `update-translations-de.sh`

Aktualisiert nur die deutsche Übersetzungsdatei (`venus-gui-v2_de.ts`) mit lupdate und normalisiert die Pfade.

**Verwendung:**
```bash
./scripts/update-translations-de.sh
```

**Voraussetzungen:** Konfiguriertes Build-Verzeichnis, Qt6 lupdate

---

## translation-override.py – Externe Übersetzungs-Overrides

Wenn du die deutsche Übersetzung extern pflegst und die Quellen nicht ändern kannst, erlaubt dieses Script, deine Änderungen gegenüber dem `main`-Branch zu extrahieren und als JSON zu speichern. Diese JSON kann bei jeder neuen `de.ts` vom Upstream wieder angewendet werden.

### Anwendungsfälle

- Du pflegst eigene Übersetzungsanpassungen
- Nach Merge/Rebase mit dem Upstream gehen deine Änderungen verloren
- Du willst deine Overrides versionieren und wiederverwenden

### Befehle

| Befehl | Beschreibung |
|--------|--------------|
| `extract` | Vergleicht deine `de.ts` mit dem `main`-Branch und schreibt geänderte Übersetzungen in eine JSON-Datei |
| `apply` | Wendet die gespeicherten Overrides auf die aktuelle `de.ts` an |

### Verwendung

```bash
# Deine Änderungen vs. main extrahieren und in JSON speichern:
python3 scripts/translation-override.py extract

# JSON auf die aktuelle de.ts anwenden:
python3 scripts/translation-override.py apply
```

### Optionen

| Option | Befehl | Beschreibung |
|--------|--------|--------------|
| `-t, --ts-file PATH` | beide | Pfad zur TS-Datei (Standard: `i18n/venus-gui-v2_de.ts`) |
| `-o, --output PATH` | extract | Ausgabe-JSON (Standard: `i18n/translation-overrides.json`) |
| `-i, --input PATH` | apply | Eingabe-JSON (Standard: `i18n/translation-overrides.json`) |
| `-b, --branch NAME` | extract | Vergleichs-Branch (Standard: `main`) |

### Beispiele

```bash
# Eigene JSON-Datei verwenden
python3 scripts/translation-override.py extract -o meine-uebersetzungen.json
python3 scripts/translation-override.py apply -i meine-uebersetzungen.json

# Anderen Branch zum Vergleich
python3 scripts/translation-override.py extract -b origin/main

# Auf eine andere TS-Datei anwenden
python3 scripts/translation-override.py apply -t /tmp/venus-gui-v2_de.ts
```

### Typischer Workflow bei neuer de.ts vom Upstream

1. Neue `de.ts` übernehmen (z.B. nach Merge oder Rebase mit dem Upstream)
2. `python3 scripts/translation-override.py apply` ausführen
3. Deine Overrides sind wieder angewendet ✓

### JSON-Struktur

Die generierte Datei `i18n/translation-overrides.json` hat folgendes Format:

```json
{
  "meta": {
    "description": "Externe Übersetzungs-Overrides für venus-gui-v2_de.ts",
    "compare_branch": "main",
    "ts_file": "i18n/venus-gui-v2_de.ts"
  },
  "translations": {
    "message_id": "Übersetzung",
    "levels_page_tanks": "Tankübersicht",
    "levels_page_environment": "Temperaturen"
  }
}
```

- **meta**: Metadaten zur Erstellung
- **translations**: Objekt mit Message-ID als Schlüssel und deutscher Übersetzung als Wert

### Voraussetzungen

- Python 3
- Git (für `extract` – zum Vergleich mit dem Branch)
- Ausführung im Repository-Root

### Hinweise

- Die `translation-overrides.json` solltest du versionieren (z.B. mit Git), damit deine Overrides erhalten bleiben
- `extract` speichert nur Einträge, die sich von `main` unterscheiden
- `apply` überschreibt vorhandene Übersetzungen mit den Werten aus der JSON; nicht vorhandene Keys werden ignoriert
