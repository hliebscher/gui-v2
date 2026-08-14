# Entscheidung: OCC-Bridge (A) vs. dbus-mqtt-devices (B) + Phasenplan

**Stand:** 2026-07-27 (Umlabel nach Grill-Me)  
**Methode (A/B):** Superpowers `dispatching-parallel-agents` — 2026-07-26  
**Agents:**
- [OCC Bridge Ansatz A](23638cab-c44b-496c-ac71-5d3ded07315d)
- [dbus-mqtt-devices Ansatz B](23508acb-f7e6-432c-91d6-1836a5eba71a)  
**Basis-Doku:** [11-victron-mqtt-token-virtual-devices-esp32.md](11-victron-mqtt-token-virtual-devices-esp32.md)

---

## Status (verbindlich)

| Phase | Rolle | Status |
|---|---|---|
| **Phase 1** | Board-Demo: Stock-Venus + **Node-RED** Virtual Devices, Topics `occ/heating/…` | **Aktiv** (≤ 2 Wochen) |
| **Phase 2** | Produkt-UX: **OCC-Bridge + HeatingPage** (Ansatz A) | **Eingefroren** bis Board durch; danach Primärpfad |
| Ansatz B | `dbus-mqtt-devices` Sensor-PoC | **Nicht** in Phase 1 |

OCC/HeatingPage-Featurearbeit pausiert bis Phase‑1‑Board; Fork-Cerbo nur intern/Regression, **nicht** Board-Narrativ.

---

## Phasenplan (Grill-Me 2026-07-26/27)

| Thema | Entscheidung |
|---|---|
| Phase‑1‑Erfolg | Board-Demo: Heizung sichtbar + bedienbar in **Stock-Victron-UI** |
| Geräte | Stock = Board-Wahrheit; Fork nur intern |
| Stock-UX | Mehrere Switch-/DeviceList-Einträge ok; eine Heizungsseite = Phase 2 |
| Controls Ziel | Volles ALDE-Set (2 Zonen + Gas + kW + Priorität) |
| Hard-Cut ≤ 2 Wochen | **Must:** 2 Zonen Soll/Ist + Gas; **Nice:** kW + Priorität |
| Hardware | Hybrid: echte Ist vom Gateway; Write zuerst MQTT `…/set` (ALDE-Write optional Stub) |
| Modell | Generisches Heizungsprofil; ALDE = erstes Mapping |
| MQTT | `occ/heating/…`, Payload **`{"value": …}`** |
| Schreibpfad | GUI → Virtual Device → Node-RED → `occ/heating/…/set` |
| Node-RED-Artefakt | Eigenes kleines Repo (nicht gui-v2) |
| Node-RED langfristig | Nur PoC/Board; **Produkt ohne** Node-RED-Abhängigkeit |
| Produkt Phase 2 | OCC-Bridge (+ HeatingPage) bzw. später Victron-Plugin |

### Phase‑1‑Architektur

```text
ALDE ──LIN──► ESP32 ──occ/heating/… {"value":…}──► mosquitto (Cerbo Stock)
                                                      │
                                                      ▼
                                              Node-RED Large
                                              Virtual Devices
                                                      │
                                                      ▼
                                              Stock GUI (Switch Pane / DeviceList)
                                                      │
                                              (Write) ▼
                                              Node-RED ──► occ/heating/…/set
                                                      │
                                                      ▼
                                                    ESP32
```

### Phase‑2‑Architektur (OCC = Primärpfad)

```text
ALDE ──LIN──► ESP32 ──occ/heating/…──► dbus-mqtt-occ ──► heating.occ
                                                      └──► HeatingPage
```

Gleiches Gateway-Topic-Schema; Cerbo-Seite wechselt von Node-RED → OCC-Bridge.

---

## Kurzentscheidung A vs B (technisch, Phase 2)

| Frage | Antwort |
|---|---|
| Primärpfad **Produkt-UX / ALDE-Steuerung** (nach Board)? | **Ansatz A — OCC-Bridge + HeatingPage** |
| dbus-mqtt-devices für Produktziel? | **Nein** |
| Phase‑1‑Board-Pfad? | **Node-RED (C)**, nicht A und nicht B |

---

## Scorecard (1–10, aus Subagenten)

| Kriterium | A: OCC-Bridge | B: dbus-mqtt-devices | Gewinner |
|---|---:|---:|---|
| ALDE-Fit | **9** | 2 | A |
| UX (Heizungsbedieneinheit) | **8** | 3 | A |
| Wartbarkeit | **8** | 5 | A |
| ESP32-Einfachheit | 8 | **8** | Unentschieden |
| Time-to-Demo (passend zum Ziel) | **8** (Steuerung) | 7 (nur Sensoren) | A für Ziel / B für Sensor-Smoke |
| **Gesamt als ALDE-Steuerung** | **~8** | **~3** | **A** |

---

## Capability-Matrix (ALDE-Controls)

| Control | A: OCC + HeatingPage | B: dbus-mqtt-devices | Phase 1: Node-RED |
|---|---|---|---|
| Soll Wohnen (Slider) | Ja (Zone-Slider) | **Nein** (kein Setpoint) | Ja (Virtual / SwitchableOutput) |
| Soll Schlafen (Slider) | Ja | **Nein** | Ja |
| Ist Zone Wohnen/Schlafen | Ja | Ja (Temp-Sensor) | Ja |
| Außentemperatur | Ja (nach Bridge-Erweiterung) | Ja (Temp-Sensor) | Ja |
| Elektro 0 / 1 / 2 / 3 kW | Ja (nach Erweiterung) | **Nein** | Ja (Stepped/Switch) — Nice |
| Gas Ein/Aus | Ja (nach Erweiterung) | **Nein** | Ja — Must |
| Priorität Gas/Elektro | Ja (nach Erweiterung) | **Nein** | Ja — Nice |
| HeatingPage | Nutzt genau diesen Service | leer | unberührt |
| DeviceList / Switch Pane | Custom heating.* | temperature.* | Standard Virtual Devices |

---

## Architektur-Gegenüberstellung (A/B historisch)

```text
ANSATZ A (Phase-2-Primärpfad)
ALDE ──LIN──► ESP32 ──occ/heating/…──► dbus-mqtt-occ ──► heating.occ
                                                      └──► HeatingPage

ANSATZ B (nicht Phase 1)
ALDE ──LIN──► ESP32 ──device/*/Status──► dbus-mqtt-devices
                                        └──► DeviceList Temp-Sensoren
                                        └──► HeatingPage: nichts
```

---

## Aufwand (grob)

| Scope | A (Phase 2) | B | Phase 1 Node-RED |
|---|---|---|---|
| Cerbo-Seite | Bridge+GUI 8–12 h | Treiber 4–8 h | Flow + Virtual Devices (eigenes Repo) |
| Demo Steuerung | ~12–16 h | nur Anzeige | Board-Hard-Cut ~Must in ≤ 2 Wochen |
| Vollständige ALDE-Steuerung | erreichbar | **nicht** ohne A/C | Must zuerst, Nice nachziehen |

---

## Risiken

### Phase 1 (Node-RED)
1. Stock-UX fragmentiert (viele Controls) — Board-Message klar halten.  
2. Venus-/node-red-contrib-Version für Setpoint-Slider prüfen.  
3. Payload `{"value":…}` muss ESP + Flow + spätere Bridge einheitlich nutzen.  
4. Scope-Creep gegen 2-Wochen-Deadline — Hard-Cut einhalten.

### A (Phase 2)
1. Bridge `_parse_value` vs. Doc-`{"value":…}` vor OCC-Wiederaufnahme angleichen.  
2. QML-Fallen (`ListText`, `VeQuickItem.valid`).  
3. 3-Zonen-Config vs. ALDE 2 Panel.

### B
1. Kein Thermostat/Soll — für Board und Produkt ungeeignet.  
2. Community-Treiber / Update-Risiko.

---

## Roadmap (aktuell)

1. **Jetzt Phase 1:** Eigenes Node-RED-Repo; Stock-Cerbo; `occ/heating/…` + `{"value":…}`; Must = 2 Zonen + Gas.  
2. **OCC/HeatingPage einfrieren** bis Board.  
3. **Nicht:** dbus-mqtt-devices parallel.  
4. **Nach Board Phase 2:** Payload in Bridge/Spec angleichen → Bridge Outdoor/Electric/Gas/Priority → HeatingPage; Node-RED nur noch Referenz/Migration.

---

## Nächste Schritte Phase 1 (Must)

1. Node-RED-Repo anlegen: Flow-Export + README (Import, MQTT, Virtual Devices).  
2. Gateway publisht Ist auf `occ/heating/…` mit `{"value":…}`; subscribed `…/set`.  
3. Flow: Topics → Virtual Devices; Writes → `…/set`.  
4. Board-Demo auf Stock verifizieren (Hard-Cut).

## Nächste Schritte Phase 2 (nach Board, Ansatz A)

1. MQTT-Payload-Vertrag in Bridge + Spec `05` + Doc 11 auf `{"value":…}` angleichen.  
2. `dbus-mqtt-occ` um `/Outdoor/Temperature`, `/Electric/PowerLevel`, `/Gas/Enabled`, `/Energy/Priority` erweitern.  
3. `HeatingPage.qml`: Outdoor, Power, Gas, Priorität; Zone-Namen Wohnen/Schlafen.

---

## Quellen

- Grill-Me-Session 2026-07-26/27 (gemeinsames Verständnis bestätigt)
- `docs/occ/05-mqtt-bridge-spezifikation.md`, `07-architektur-entscheidung.md`, `11-…esp32.md`
- `services/dbus-mqtt-occ/dbus-mqtt-occ.py`, `pages/HeatingPage.qml`
- [freakent/dbus-mqtt-devices](https://github.com/freakent/dbus-mqtt-devices)
- Victron GUI: `PageTemperatureSensor.qml` = Anzeige ohne Setpoint-Slider
- [node-red-contrib-victron](https://github.com/victronenergy/node-red-contrib-victron) Virtual Devices
