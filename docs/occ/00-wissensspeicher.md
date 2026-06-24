# OpenCamperCore — Wissensspeicher (Index)

**Stand:** 2026-06-24  
**Branch:** `v_2026.6.2`  
**Fork:** [hliebscher/gui-v2](https://github.com/hliebscher/gui-v2)

Dieser Wissensspeicher ist die **zentrale Einstiegsseite** für OCC-Arbeit am Victron-GUI-v2-Fork. Jede größere Änderung (Feature, Deploy, Bugfix, Architektur) wird hier **verlinkt** und in einem datierten Log festgehalten.

---

## Dokumentationspflicht

| Wann | Was | Ablage |
|------|-----|--------|
| Neues Feature / Design | Spezifikation + Wireframe | `docs/occ/NN-<thema>.md` |
| Implementierung abgeschlossen | Changelog, Commits, Deploy, Tests | `docs/occ/NN-implementierung-<datum>.md` |
| Merge / Triage | Entscheidungslog | `docs/merge/` oder `docs/triage/` |
| Deploy / Betrieb | Runbook + Fallstricke | Dieses Dokument (Abschnitt Runbooks) + Service-README |
| Bugfix mit Lerneffekt | Eintrag unter Fallstricke + ggf. Log | Hier + betroffenes Log |

**Regel:** Ohne Log-Eintrag gilt die Arbeit als nicht abgeschlossen dokumentiert.

---

## Dokumenten-Index

| Nr. | Datei | Inhalt |
|-----|-------|--------|
| 00 | [00-wissensspeicher.md](00-wissensspeicher.md) | **Dieser Index** — Quick Facts, Runbooks, Fallstricke |
| 01 | [01-repository-katalog.md](01-repository-katalog.md) | Externe Repos, Treiber-Muster, Risiken |
| 02 | [02-feature-matrix-kollisionen.md](02-feature-matrix-kollisionen.md) | Fork vs. main — Feature-Kollisionen |
| 03 | [03-scheer-selection-schaltplan-analyse.md](03-scheer-selection-schaltplan-analyse.md) | Hardware-Schaltplan |
| 04 | [04-heating-climate-ui-spezifikation.md](04-heating-climate-ui-spezifikation.md) | UI-Spezifikation Heating/Climate |
| 05 | [05-mqtt-bridge-spezifikation.md](05-mqtt-bridge-spezifikation.md) | MQTT ↔ D-Bus Bridge |
| 06 | [06-io-extender-mapping.md](06-io-extender-mapping.md) | I/O Extender Kanal-Zuordnung |
| 07 | [07-architektur-entscheidung.md](07-architektur-entscheidung.md) | Hybrid-Architektur (Fork + Plugin + Bridge) |
| 08 | [08-steuerseite-3heizung-2klima-design.md](08-steuerseite-3heizung-2klima-design.md) | Design Steuerseite 3+2 |
| 09 | [09-implementierung-steuerseite-2026-06-24.md](09-implementierung-steuerseite-2026-06-24.md) | **Implementierungslog** Steuerseite + Deploy |

---

## Quick Facts

| Thema | Wert |
|-------|------|
| Aktiver Branch | `v_2026.6.2` |
| GX-Gerät (Tailscale) | `100.65.95.55` |
| GUI deployen | `./scripts/build-all.sh -H 100.65.95.55` |
| Bridge deployen | `rsync` → `install.sh` → `svc -t /service/dbus-mqtt-occ` |
| D-Bus Service | `com.victronenergy.heating.occ` (Instanz 100) |
| GUI UID (GX) | `dbus/com.victronenergy.heating.occ` |
| GUI UID (WASM) | `mqtt/heating.occ` |
| Bridge-Pfad auf GX | `/data/apps/dbus-mqtt-occ/` |
| Service-Symlink | `/service/dbus-mqtt-occ` |
| Logs | `tail -f /var/log/dbus-mqtt-occ/current` |

---

## Architektur (Kurz)

```
OCC-Hardware / ESP32
    ↓ MQTT (occ/…)
mosquitto (GX)
    ↓ dbus-mqtt-occ
com.victronenergy.heating.occ
    ↓ VeQuickItem
GUI v2 Fork (HeatingPage, HeatingCard, …)
```

**Schichten:** Bridge (Python, GUI-unabhängig) → Fork-QML (Steuerseite, Control Card) → optional Plugin (`plugins/occ-heating/`, derzeit nicht aktiv genutzt).

---

## Runbooks

### dbus-mqtt-occ deployen

```bash
cd services/dbus-mqtt-occ
rsync -avc --exclude '__pycache__' . root@100.65.95.55:/tmp/dbus-mqtt-occ/
ssh root@100.65.95.55 "cd /tmp/dbus-mqtt-occ && bash install.sh && svc -t /service/dbus-mqtt-occ"
```

**Verifikation:**

```bash
ssh root@100.65.95.55 "svstat /service/dbus-mqtt-occ"
ssh root@100.65.95.55 "dbus -y com.victronenergy.heating.occ /NumberOfClimateUnits GetValue"
ssh root@100.65.95.55 "dbus -y com.victronenergy.heating.occ /Climate/2/Name GetValue"
```

Erwartung: Service `up`, `NumberOfClimateUnits` = `2`, Name = `'Klima Schlafen'`.

### GUI deployen

```bash
./scripts/build-all.sh -H 100.65.95.55
```

Enthält GX-Build + WASM-Upload. Nach Deploy: GUI auf GX neu laden (vmrlogger-Restart erfolgt automatisch).

### GUI testen (manuell)

1. Schalter-Icon → **Controls** → Heating Card sichtbar
2. Button **Heating & Climate** → Steuerseite mit 3 Heiz- + 2 Klima-Slidern
3. Einstellungen → **Heating & Climate** (alternative Route)
4. Ohne laufenden Bridge-Service: Werte zeigen `---`

---

## Bekannte Fallstricke

| Problem | Ursache | Lösung |
|---------|---------|--------|
| Schwarzer Bildschirm | NavBar-Tab für Heating | **Kein** NavBar-Tab; nur Settings + Control Card |
| QML-Fehler „ListTextItem“ | Komponente existiert nicht | `ListText` verwenden |
| VeQuickItem leer trotz Service | `.isValid` statt `.valid` | Property `.valid` nutzen |
| Control Card → schwarze Seite | `cardsLoader` blockiert Navigation | `Global.mainView.cardsLoader.hide()` vor `pushPage` |
| Bridge startet nicht | `ve_utils.py` fehlt auf GX | `install.sh` muss `ve_utils.py` kopieren |
| Bridge crasht sofort | paho-mqtt 2.x auf Venus OS | `mqtt.Client(CallbackAPIVersion.VERSION1, …)` |
| D-Bus „no such name“ | Service startet neu (Crash-Loop) | Logs / manuell `python3 dbus-mqtt-occ.py` |
| Nur `---` in UI | Bridge nicht installiert oder MQTT offline | Deploy + `svstat`, MQTT prüfen |

---

## Ereignislog (Changelog)

| Datum | Ereignis | Commits / Log |
|-------|----------|---------------|
| 2026-06-24 | Steuerseite 3 Heiz + 2 Klima implementiert | `02cd95ea` |
| 2026-06-24 | dbus-mqtt-occ Deploy-Fixes (ve_utils, paho v2) | `cf90d590` |
| 2026-06-24 | dbus-mqtt-occ auf GX `100.65.95.55` deployed | [09-implementierung…](09-implementierung-steuerseite-2026-06-24.md) |
| 2026-06-24 | Design Steuerseite freigegeben | [08-steuerseite…](08-steuerseite-3heizung-2klima-design.md) |
| 2026-06-24 | Merge main → `v_2026.6.2` | `docs/merge/2026-06-24_merge-main-into-v_2026.6.2.md` |

---

## D-Bus-Pfade (Mehrfach-Klima)

```
/NumberOfClimateUnits          → 2
/Climate/1/Name                → "Klima Wohnen"
/Climate/1/Setpoint            → R/W
/Climate/1/Mode                → R/W (0=Off, 1=Cool, 2=Heat, 3=Auto)
/Climate/2/…                   → zweite Einheit
/Climate/Setpoint, /Climate/Mode → Legacy-Alias für Unit 1
```

Details: [services/dbus-mqtt-occ/README.md](../../services/dbus-mqtt-occ/README.md)

---

## Cursor / Agent

| Ressource | Pfad |
|-----------|------|
| Dokumentations-Regel | `.cursor/rules/occ-dokumentation.mdc` |
| Wissensspeicher-Skill | `.cursor/skills/occ-wissensspeicher/SKILL.md` |
| Main-Triage-Skill | `.cursor/skills/triage-main-diff/SKILL.md` |
