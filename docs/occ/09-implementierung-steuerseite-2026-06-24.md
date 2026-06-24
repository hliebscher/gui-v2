# Implementierungslog — Steuerseite 3 Heizung + 2 Klima

**Stand:** 2026-06-24  
**Branch:** `v_2026.6.2`  
**Design:** [08-steuerseite-3heizung-2klima-design.md](08-steuerseite-3heizung-2klima-design.md)  
**Index:** [00-wissensspeicher.md](00-wissensspeicher.md)

---

## Zusammenfassung

Steuerseite mit 3 Heizungs-Slidern und 2 Klima-Einheiten (jeweils Slider + Modus-Chips), Control Card im Hauptmenü, Backend-Erweiterung für `/Climate/1/` und `/Climate/2/`. Deploy von `dbus-mqtt-occ` auf GX `100.65.95.55` inkl. zwei Produktions-Bugfixes.

---

## Commits

| Hash | Message |
|------|---------|
| `02cd95ea` | `feat(heating): OCC Steuerseite mit 3 Heiz- und 2 Klima-Zonen` |
| `cf90d590` | `fix(dbus-mqtt-occ): Deploy auf Venus OS (ve_utils, paho-mqtt v2)` |

Vorgänger auf Branch: `f07845aa` — NavBar-Tab entfernt, Settings-Seite wiederhergestellt.

---

## Geänderte / neue Dateien

### Backend (`services/dbus-mqtt-occ/`)

| Datei | Änderung |
|-------|----------|
| `dbus-mqtt-occ.py` | `/Climate/{id}/…`, `/NumberOfClimateUnits`, Legacy-Alias Unit 1, MQTT `occ/climate/{id}/…`, paho-mqtt v2 Kompatibilität |
| `config.ini` | `Units = 2`, `UnitNames = Klima Wohnen,Klima Schlafen` |
| `install.sh` | Kopiert `ve_utils.py` (Deploy-Fix) |

### GUI (Fork)

| Datei | Änderung |
|-------|----------|
| `components/OccSetpointSliderRow.qml` | **Neu** — Slider-Zeile (Temperatur-Look) |
| `components/OccClimateUnitBlock.qml` | **Neu** — Slider + Modus-Chips pro Klima |
| `pages/HeatingPage.qml` | Steuerseite: 3 Heiz + 2 Klima |
| `pages/HeatingClimatePage.qml` | `climateId` Property, Pfade `/Climate/{id}/…` |
| `pages/HeatingZonePage.qml` | `ListTextItem` → `ListText` |
| `components/HeatingCard.qml` | 3 Zonen + 2 Klima Kurzübersicht, Button zur Steuerseite |
| `pages/ControlCardsPage.qml` | HeatingCard als Footer |
| `cmake/ModuleVenus_Sources.cmake` | Neue QML-Dateien registriert |

### Dokumentation

| Datei | Änderung |
|-------|----------|
| `docs/occ/08-steuerseite-3heizung-2klima-design.md` | Design freigegeben |
| `docs/occ/00-wissensspeicher.md` | Wissensspeicher-Index |
| `docs/occ/09-implementierung-steuerseite-2026-06-24.md` | Dieses Log |

---

## Deploy dbus-mqtt-occ (2026-06-24)

**Ziel:** `root@100.65.95.55`

```bash
rsync -avc --exclude '__pycache__' services/dbus-mqtt-occ/ root@100.65.95.55:/tmp/dbus-mqtt-occ/
ssh root@100.65.95.55 "cd /tmp/dbus-mqtt-occ && bash install.sh && svc -t /service/dbus-mqtt-occ"
```

### Aufgetretene Probleme

| # | Symptom | Ursache | Fix |
|---|---------|---------|-----|
| 1 | Service startet neu alle ~2 s | `ModuleNotFoundError: ve_utils` | `install.sh`: `cp ve_utils.py` |
| 2 | Crash nach D-Bus-Registrierung | paho-mqtt 2.x: `callback_api_version` fehlt | `mqtt.Client(CallbackAPIVersion.VERSION1, …)` |

### Verifikation (erfolgreich)

```
/service/dbus-mqtt-occ: up (pid 25153) 5 seconds
dbus … /NumberOfClimateUnits GetValue  → 2
dbus … /Climate/2/Name GetValue        → 'Klima Schlafen'
```

---

## GUI-Deploy

Die QML-Änderungen erfordern einen GUI-Build:

```bash
./scripts/build-all.sh -H 100.65.95.55
```

**Status zum Log-Zeitpunkt:** Bridge deployed und verifiziert; GUI-Build vom Auftraggeber separat auszuführen.

---

## Abnahme-Kriterien (Design 08)

| Kriterium | Status |
|-----------|--------|
| 5 Slider-Zeilen auf Steuerseite | Implementiert (GUI-Build ausstehend) |
| Slider schreiben Sollwert | Implementiert (MQTT/D-Bus) |
| Klima-Modus pro Einheit | Implementiert |
| Tap → Zonen-/Klima-Detail | Implementiert |
| Kein NavBar-Tab / kein Schwarzbild | Eingehalten |
| D-Bus `/Climate/2/Setpoint` schreibbar | Backend OK, manuell testbar |

---

## Offene Punkte

- [ ] GUI-Build auf GX und visuelle Abnahme
- [ ] Übersetzungen (`i18n/translation-overrides.json`) für neue Keys prüfen
- [ ] Live-MQTT-Daten von OCC-Hardware gegen echte Slider testen
- [ ] Hardware-Mapping Relais/Topic pro Klima-Unit in Bridge-Config finalisieren
