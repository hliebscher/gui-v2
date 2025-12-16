# Übersetzungen bearbeiten

## Übersicht

Dieses Projekt verwendet Qt's Übersetzungssystem (`.ts` Dateien) für die Internationalisierung. Die Übersetzungen werden in `i18n/` gespeichert.

## Übersetzungen lokal bearbeiten

### 1. Übersetzungsdateien direkt bearbeiten

Die einfachste Methode ist, die `.ts` Dateien direkt zu bearbeiten:

- **Hauptdatei (Englisch)**: `i18n/venus-gui-v2.ts` - enthält alle Übersetzungsschlüssel
- **Deutsch**: `i18n/venus-gui-v2_de.ts`
- **Andere Sprachen**: `i18n/venus-gui-v2_<sprache>.ts`

### 2. Neue Übersetzungsschlüssel hinzufügen

Wenn Sie neue Texte im Code hinzufügen, die übersetzt werden sollen:

1. **Im QML-Code** verwenden Sie `qsTrId()`:
   ```qml
   //% "Your text here"
   text: qsTrId("your_translation_id")
   ```

2. **Neue Übersetzungsschlüssel extrahieren**:
   ```bash
   # Stellen Sie sicher, dass Sie cmake ausgeführt haben
   cd build-wasm  # oder Ihr Build-Verzeichnis
   cmake ..
   
   # Führen Sie das Update-Script aus
   ../scripts/update-translations.sh
   ```

   Dies extrahiert neue Übersetzungsschlüssel aus dem Code und aktualisiert `i18n/venus-gui-v2.ts`.

3. **Übersetzungen hinzufügen**:
   - Öffnen Sie `i18n/venus-gui-v2_de.ts` (oder die entsprechende Sprachdatei)
   - Suchen Sie nach dem neuen Eintrag (er hat `<translation type="unfinished"></translation>`)
   - Fügen Sie die Übersetzung hinzu:
     ```xml
     <translation>Ihre Übersetzung hier</translation>
     ```

### 3. Übersetzungen aktualisieren

Wenn Sie bestehende Übersetzungen ändern möchten:

1. Öffnen Sie die entsprechende `.ts` Datei (z.B. `venus-gui-v2_de.ts`)
2. Suchen Sie nach dem `message id` (z.B. `page_contact_title`)
3. Ändern Sie den `<translation>` Eintrag:
   ```xml
   <message id="page_contact_title">
       <source>Contact</source>
       <translation>Kontakt</translation>  <!-- Hier ändern -->
   </message>
   ```

## POEditor Integration (optional)

POEditor ist ein Online-Übersetzungsdienst, der von Victron Energy verwendet wird, um Übersetzungen zu verwalten.

### POEditor Token erhalten

**Wichtig**: Der POEditor Token ist ein geheimer API-Schlüssel und sollte nicht öffentlich geteilt werden.

Um einen Token zu erhalten:

1. **Kontaktieren Sie einen Victron Energy Administrator** - Der Token wird normalerweise nur an autorisierte Entwickler vergeben
2. **Falls Sie Zugriff auf das POEditor-Projekt haben**:
   - Melden Sie sich bei [POEditor.com](https://poeditor.com) an
   - Gehen Sie zu Ihrem Projekt
   - Navigieren Sie zu "Settings" → "API" → "API Token"
   - Kopieren Sie den Token

### Übersetzungen von POEditor herunterladen

Wenn Sie einen Token haben:

```bash
# Im Build-Verzeichnis
cd build-wasm  # oder Ihr Build-Verzeichnis
cmake ..

# Alle Übersetzungen herunterladen
POEDITOR_TOKEN='Ihr-Token-hier' make download_translations

# Oder eine einzelne Sprache herunterladen
POEDITOR_TOKEN='Ihr-Token-hier' make venus-gui-v2_de
```

### Neue Übersetzungsschlüssel zu POEditor hochladen

Wenn Sie neue Übersetzungsschlüssel hinzugefügt haben:

```bash
cd build-wasm
cmake ..

# Zuerst die Übersetzungen extrahieren (wie oben beschrieben)
../scripts/update-translations.sh

# Dann zu POEditor hochladen
POEDITOR_TOKEN='Ihr-Token-hier' make upload_translations
```

## Workflow ohne POEditor Token

Wenn Sie keinen POEditor Token haben (was normal ist für externe Entwickler):

1. **Übersetzungen lokal bearbeiten**:
   - Bearbeiten Sie die `.ts` Dateien direkt in `i18n/`
   - Fügen Sie Ihre Übersetzungen hinzu

2. **Neue Schlüssel extrahieren**:
   ```bash
   cd build-wasm
   cmake ..
   ../scripts/update-translations.sh
   ```

3. **Änderungen committen**:
   - Committen Sie die geänderten `.ts` Dateien
   - Die Änderungen werden dann von Victron Energy übernommen und zu POEditor hochgeladen

## Häufige Probleme

### "lupdate not found"

Qt6 muss installiert und im PATH sein:
```bash
# Beispiel für Ubuntu/Debian
sudo apt-get install qt6-tools-dev

# Oder setzen Sie QTDIR
export QTDIR=/path/to/qt6
export PATH=$QTDIR/bin:$PATH
```

### "No build directory found"

Sie müssen zuerst cmake ausführen:
```bash
mkdir build-wasm
cd build-wasm
cmake ..
```

### "translation_sources.txt not found"

Das Build-Verzeichnis wurde nicht richtig konfiguriert. Führen Sie `cmake ..` im Build-Verzeichnis aus.

## Weitere Informationen

- Qt Übersetzungssystem: https://doc.qt.io/qt-6/internationalization.html
- POEditor API: https://poeditor.com/docs/api

