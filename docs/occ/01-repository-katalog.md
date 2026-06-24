# OpenCamperCore — Repository-Katalog

Stand: 2026-05-26

---

## Offizielle Victron-Repositories

| Repository | URL | Beschreibung | Letzter Commit | Lizenz | Relevanz |
|---|---|---|---|---|---|
| victronenergy/gui-v2 | https://github.com/victronenergy/gui-v2 | Haupt-GUI, Plugin-System, IOChannel | 2026-05-20 | MIT | Basis |
| victronenergy/dbus-switch | https://github.com/victronenergy/dbus-switch | Relais-Steuerung I/O Extender | aktiv | MIT | I/O |
| victronenergy/dbus-digitalinputs | https://github.com/victronenergy/dbus-digitalinputs | Digital-Eingänge I/O Extender | aktiv | MIT | I/O |
| victronenergy/venus-platform | https://github.com/victronenergy/venus-platform | System-Services, localsettings | aktiv | MIT | Backend |
| victronenergy/dbus-mqtt | https://github.com/victronenergy/dbus-mqtt | Offizieller D-Bus↔MQTT Proxy | aktiv | MIT | MQTT |

---

## MQTT-Bridge-Treiber (mr-manuel)

Alle MIT-lizenziert, Python-basiert, als daemontools-Service lauffähig.

| Repository | URL | Funktion | Stars | Status |
|---|---|---|---|---|
| venus-os_dbus-mqtt-temperature | https://github.com/mr-manuel/venus-os_dbus-mqtt-temperature | Temperatursensoren → D-Bus | ~30 | Aktiv |
| venus-os_dbus-mqtt-grid | https://github.com/mr-manuel/venus-os_dbus-mqtt-grid | Grid/Genset/AC Load → D-Bus | 101 | Aktiv |
| venus-os_dbus-mqtt-pv | https://github.com/mr-manuel/venus-os_dbus-mqtt-pv | PV Inverter → D-Bus | 90 | Aktiv |
| venus-os_dbus-mqtt-battery | https://github.com/mr-manuel/venus-os_dbus-mqtt-battery | Batterie → D-Bus | 58 | Aktiv |
| venus-os_dbus-mqtt-ev-charger | https://github.com/mr-manuel/venus-os_dbus-mqtt-ev-charger | EV Charger → D-Bus | ~20 | Aktiv |
| venus-os_dbus-mqtt-solar-charger | https://github.com/mr-manuel/venus-os_dbus-mqtt-solar-charger | Solar Charger → D-Bus | ~15 | Aktiv |
| venus-os_dbus-mqtt-tank | https://github.com/mr-manuel/venus-os_dbus-mqtt-tank | Tank Levels → D-Bus | ~10 | Aktiv |
| venus-os_dbus-serialbattery | https://github.com/mr-manuel/venus-os_dbus-serialbattery | Referenz GUI-v2-Plugin | 227 | Aktiv |

### Treiber-Architektur (gemeinsames Muster)

```
/data/apps/dbus-mqtt-<type>/
├── dbus-mqtt-<type>.py        # Hauptscript
├── config.ini                 # MQTT-Broker, Topics, Mapping
├── service/run                # daemontools Service-Script
└── install.sh                 # Installations-Script
```

Jeder Treiber:
1. Verbindet sich zum lokalen MQTT-Broker (mosquitto auf GX)
2. Subscribt auf konfigurierte Topics
3. Erstellt einen D-Bus Service (`com.victronenergy.<type>.<instance>`)
4. Mapped MQTT-Werte auf D-Bus-Pfade
5. Propagiert Änderungen bidirektional

---

## Heating/Climate-Projekte (Community)

| Repository | URL | Ansatz | Plattform | Einschätzung |
|---|---|---|---|---|
| FNewel/PV-Water-Heating-Manager | https://github.com/FNewel/PV-Water-Heating-Manager | ESPHome + HA + Venus | Venus OS + HA | Komplex, HA-Abhängigkeit |
| asderferjerkel/node-red-webasto-victron | https://github.com/asderferjerkel/node-red-webasto-victron | Node-RED + Webasto CAN | Venus OS Large | Niedrig, aber Node-RED nötig |

---

## GUI-v2-Plugin-Referenzen

| Quelle | Beschreibung | URL |
|---|---|---|
| gui-v2 Issue #1071 | Plugin-System Tracking | https://github.com/victronenergy/gui-v2/issues/1071 |
| gui-v2 Issue #2623 | MQTT Plugin Loading | https://github.com/victronenergy/gui-v2/issues/2623 |
| gui-v2 examples/ | 3 Beispiel-Plugins | `gui-v2/examples/DeviceListExample/` |
| gui-v2-plugin-compiler | Integriert im Repo | `gui-v2/tools/gui-v2-plugin-compiler.py` |

---

## Eigene Repositories

| Repository | URL | Beschreibung |
|---|---|---|
| hliebscher/gui-v2 | https://github.com/hliebscher/gui-v2 | Fork mit vario_2026.5 Branch |

---

## Integrationsaufwand-Bewertung

| Kategorie | Aufwand | Beschreibung |
|---|---|---|
| dbus-mqtt-temperature direkt nutzen | **Niedrig** | Nur config.ini anpassen |
| Eigenen dbus-mqtt-occ schreiben | **Mittel** | ~200 Zeilen Python nach Vorlage |
| GUI-Plugin (Typ 1: Settings Page) | **Mittel** | QML + JSON Manifest + RCC |
| GUI-Plugin (Typ 2: Device Page) | **Mittel** | Wie Typ 1, plus productId-Filter |
| Fork-Integration (NavBar, Cards) | **Hoch** | QML + Merge-Pflege bei Updates |
| Node-RED Integration | **Niedrig** | Flows importieren, Venus OS Large nötig |

---

## Risiken

| Risiko | Wahrscheinlichkeit | Auswirkung | Mitigation |
|---|---|---|---|
| Plugin-Typen 3-5 bleiben TODO | Mittel | NavBar/Cards nur per Fork | Fork-Layer beibehalten |
| Main ändert StatusBar-Architektur erneut | Hoch | Merge-Konflikte | Wrapper-Pattern, Tests |
| MQTT-Broker nicht verfügbar auf GX | Niedrig | Keine Heizungssteuerung | mosquitto ist Standard |
| dbus-mqtt-* API-Änderung | Niedrig | Bridge-Update nötig | Version pinnen |
| Qt-Version-Sprung (6.8 → 6.9+) | Mittel | Build-Probleme | CI testen |
