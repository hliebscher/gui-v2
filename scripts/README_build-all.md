# Build- und Copy-Scripts für GUIv2

## Übersicht

Diese Scripts vereinfachen den Build- und Copy-Prozess für GUIv2, indem sie sowohl die GX- als auch die WASM-Version in einem Durchlauf erstellen oder kopieren.

## Scripts

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

**Beispiele:**
```bash
# Beide Builds ausführen
./scripts/build-all.sh

# Build mit Erhaltung der Build-Dateien
./scripts/build-all.sh --preserve

# Build und direkter Upload zu einem GX-Gerät
./scripts/build-all.sh --host venus.local

# Build und Upload zu mehreren GX-Geräten
./scripts/build-all.sh --host 192.168.1.10,192.168.1.11
```

**Hinweis:** Alle Optionen werden an beide Build-Scripts (`build-gx.sh` und `build-wasm.sh`) weitergegeben.

### `copy-all.sh`

Kopiert die Build-Dateien für beide Plattformen (GX-Gerät und WebAssembly) in einem Durchlauf.

**Verwendung:**
```bash
./scripts/copy-all.sh [Optionen]
```

**Optionen:**
- `-H, --host HOST` - IP(s) oder Hostname(s) des GX-Geräts für direkten Upload (kommagetrennt)
- `-h, --help` - Hilfe anzeigen

**Beispiele:**
```bash
# Beide Copies ausführen
./scripts/copy-all.sh

# Copy und direkter Upload zu einem GX-Gerät
./scripts/copy-all.sh --host venus.local

# Copy und Upload zu mehreren GX-Geräten
./scripts/copy-all.sh --host 192.168.1.10,192.168.1.11
```

**Hinweis:** Alle Optionen werden an beide Copy-Scripts (`copy-gx.sh` und `copy-wasm.sh`) weitergegeben.

## Abhängigkeiten

Diese Scripts rufen die folgenden Scripts auf:
- `build-gx.sh` / `copy-gx.sh` - Für GX-Geräte
- `build-wasm.sh` / `copy-wasm.sh` - Für WebAssembly

Stelle sicher, dass alle erforderlichen Abhängigkeiten für beide Build-Typen installiert sind:
- Für GX: Venus OS SDK
- Für WASM: Emscripten SDK, Qt für WASM

## Fehlerbehandlung

Wenn einer der Builds oder Copies fehlschlägt, wird das Script mit dem entsprechenden Fehlercode beendet. Die Ausgabe zeigt an, welcher Teil fehlgeschlagen ist.

## Siehe auch

- `build-gx.sh` - Detaillierte Informationen zum GX-Build
- `build-wasm.sh` - Detaillierte Informationen zum WASM-Build
- [How to build venus-gui-v2](https://github.com/victronenergy/gui-v2/wiki/How-to-build-venus-gui-v2)

