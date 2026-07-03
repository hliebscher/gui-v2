# Tätigkeitsnachweis / Rechnungsgrundlage

**Projekt:** Victron GUI v2 Fork — Vario Mobil / OpenCamperCore  
**Repository:** hliebscher/gui-v2  
**Branch:** v_2026.6.2  
**Zeitraum:** August 2025 — Juli 2026  
**Erstellt:** 2026-07-03

---

## Auftraggeber / Entwickler

| | |
|---|---|
| **Entwickler** | Heiko Liebscher |
| **E-Mail** | hliebscher@gmail.com |
| **Repository** | Fork von victronenergy/gui-v2 |

---

## Projektziel

Anpassung und Erweiterung der Victron Venus OS GUI v2 für **Vario Mobil** Fahrzeuge mit Integration einer **OpenCamperCore (OCC)** Heizungs- und Klima-Steuerung über MQTT/D-Bus-Anbindung an externe Hardware (Scheer Selection).

---

## Durchgeführte Leistungen

### 1. Entwicklung neuer Funktionen

- **OpenCamperCore Heizungs-/Klima-Steuerung**
  - Neue GUI-Steuerseite „Heating & Climate" (3 Heizungszonen + 2 Klimaanlagen)
  - Control Card in der Schalter-Ansicht
  - Einstieg über Einstellungen → Heating & Climate
  - Detailseiten für Zonen und Klima-Einheiten

- **MQTT↔D-Bus Bridge (`dbus-mqtt-occ`)**
  - Python-Service für Venus OS GX-Geräte
  - D-Bus-Service `com.victronenergy.heating.occ` (DeviceInstance 100)
  - Bidirektionale MQTT-Anbindung für externe Steuerung
  - Installations- und Deinstallations-Scripts für Produktivbetrieb

- **GUI-Plugin (occ-heating)**
  - Victron-kompatibles Plugin mit 4 QML-Seiten
  - Deutsche und englische Übersetzungen
  - Kompilierungs-Workflow (lupdate, lrelease, rcc)

- **Vario Mobil GUI-Anpassungen**
  - Individuelle StatusBar (Datum, Uhrzeit, Schalter mit Text)
  - Standby-Seite mit Uhr-Anzeige
  - Kontaktseite mit Öffnungszeiten
  - Vario-/VM-Branding (Logos, Splash-Screen, Icons)

### 2. Erweiterung bestehender Module

- Integration von Victron-Upstream-Features:
  - Tank-Backup/Restore (mr-manuel)
  - Dynamische Customisations (Victron)
  - DC-Load-Drilldowns, Breadcrumb-Navigation, DVCC-Fixes
- Backup/Restore-Einstellungsseite konsolidiert
- ScreenBlanker-API vereinheitlicht (Standby-Uhr vor Display-Blank)

### 3. Fehlerbehebungen

- HeatingPage QML-Ladefehler (`ListTextItem` → `ListText`, SettingsColumn-Wrapper)
- WASM-Build-Fix (Emscripten WrapRt-Workaround)
- dbus-mqtt-occ Deploy auf Venus OS (paho-mqtt v2, ve_utils.py)
- GX-Deploy: venus-gui-v2 Prozess vor Upload beenden
- StatusBar auxButton Opacity/Icon-Fix
- ScreenBlanker: Standby-Uhr vor Hardware-Blank wiederherstellen
- Falsche MQTT-UID für Browser-GUI korrigiert (`serviceUidFromName`)

### 4. Refactoring

- HeatingPage mehrfach überarbeitet (NavBar → Settings → Standard-Slider)
- ScreenBlanker-Referenzen in QML vereinheitlicht
- StatusBar Icon-Größen standardisiert
- Copy-Settings-Seite entfernt, Backup/Restore konsolidiert

### 5. Architekturverbesserungen

- OpenCamperCore Architekturentscheidung dokumentiert (Fork-Layer vs. Plugin)
- Feature-Matrix und Kollisionsanalyse erstellt
- Wissensspeicher mit Runbooks für Deploy und Fehlerbehebung
- Cursor IDE Regeln und Skills für OCC-Dokumentationspflicht

### 6. Dokumentation

- 10 OCC-Spezifikationsdokumente (~3.200 Zeilen Markdown)
- 4 Merge-Protokolle (main → vario Branches)
- README_de.md, TRANSLATIONS.md
- Schaltplan-Analyse (Scheer Selection über Victron Cerbo)
- IO-Extender-Mapping, MQTT-Bridge-Spezifikation

### 7. Buildsystem-Anpassungen

- `build-all.sh` — GX + WASM kombinierter Build
- `copy-gx.sh` / `copy-wasm.sh` — Automatisierter Deploy auf GX-Geräte
- `merge-main-into-vario.sh` — Wiederholbares Upstream-Merge-Script (438 Zeilen)
- `translation-override.py` — Externe DE-Übersetzungen verwalten
- `update-translations.sh` / `-de.sh` — TS-Datei-Aktualisierung

### 8. Integration neuer Geräte / Schnittstellen

- Scheer Selection Heizungssteuerung über MQTT
- 3 Heizungszonen (Wohnraum, Bad, Schlafraum)
- 2 Klimaanlagen (Klima Wohnen, Klima Schlafen)
- D-Bus-Pfade für Victron GUI v2 und WASM-Browser

### 9. Lokalisierung (i18n)

- Umfangreiche deutsche Übersetzungen (venus-gui-v2_de.ts)
- Translation-Override-System mit JSON-Konfiguration
- 25+ Übersetzungs-Commits über den Projektzeitraum
- Fahrzeugspezifische Begriffe (WC/Abwasser, Schalter, Kontakt)

### 10. Test und Deployment

- Mehrfache Build-/Deploy-Zyklen auf GX-Gerät (Cerbo, 100.65.95.55)
- Native GUI (venus-gui-v2) und WASM-Browser-GUI deployed
- dbus-mqtt-occ Service installiert und verifiziert
- Funktionstest Heating & Climate auf GX-Display bestätigt (2026-07-03)

---

## Quantitative Übersicht

| Kennzahl | Wert |
|----------|------|
| Commits (eigene Entwicklung) | 88 Feature/Fix-Commits |
| Commits gesamt (inkl. Merges) | 126 |
| Geänderte Dateien | 114 |
| Neue Zeilen Code/Docs | +14.718 |
| Projektzeitraum | 10,5 Monate |

---

## Aufwandsschätzung

| | Stunden | Arbeitstage (8 h) |
|---|---------|-------------------|
| **Minimal** | 114 | ~14 |
| **Realistisch (empfohlen)** | **142** | **~18** |
| **Maximal** | 172 | ~22 |

### Aufwand nach Bereichen (realistisch)

| Bereich | Stunden |
|---------|---------|
| OpenCamperCore / Heating / Climate | 34 |
| GUI — Vario Mobil Anpassungen | 27 |
| i18n / Deutsche Übersetzungen | 23 |
| Buildsystem / Deploy / Upstream-Merges | 31 |
| Test / Deploy / Debugging | 18 |
| Dokumentation / Projektmanagement | 5 |
| Upstream-Integration | 4 |
| **Gesamt** | **142** |

---

## Liefergegenstände

1. Fork-Branch `v_2026.6.2` mit allen Anpassungen
2. Funktionsfähige Heating & Climate Steuerseite auf GX-Display
3. `dbus-mqtt-occ` Backend-Service (installierbar auf Venus OS)
4. Build- und Deploy-Scripts für GX und WASM
5. Umfassende Projektdokumentation unter `docs/occ/`
6. Deutsche GUI-Übersetzungen mit Override-Workflow

---

## Status

| Komponente | Status |
|------------|--------|
| GUI Steuerseite (GX-Display) | ✅ Funktionsfähig (bestätigt 2026-07-03) |
| dbus-mqtt-occ Backend | ✅ Installiert und läuft |
| WASM Browser-GUI | ✅ Deployed (Live-Daten ohne MQTT-Publishing eingeschränkt) |
| Dokumentation | ✅ Vollständig |
| Git Commit | ✅ Letzter Fix committed (`66839d50`) |

---

## Anmerkungen für Rechnungsstellung

- Die Schätzung von **142 Stunden** ist konservativ und basiert auf Codeumfang, Commit-Anzahl und dokumentierten Deploy-/Debug-Zyklen.
- Upstream-Code von Victron-Mitarbeitern und mr-manuel ist **nicht** als Eigenentwicklung enthalten — nur der Integrationsaufwand.
- Offene optionale Folgearbeit: MQTT-Publishing für Browser-Livedaten, Wiedereinbau Custom-Slider-Komponenten.
- Keine uncommitteten Code-Änderungen (Stand 2026-07-03).

---

*Erstellt automatisch aus Git-Historie. Keine Repository-Änderungen vorgenommen.*
