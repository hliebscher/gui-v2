# Victron MQTT, Auth/Token & Virtual Heating Controls (ESP32 / ALDE)

**Stand:** 2026-07-26  
**Zielgruppe:** Weiterentwicklung ESP32 (CI-/LIN-Bus → Cerbo) + GUI-Integration  
**Quellen (verifizierbar):**
- [victronenergy/dbus-flashmq](https://github.com/victronenergy/dbus-flashmq) (offizielles MQTT↔D-Bus)
- GUI-v2 `src/veutil/src/qt/ve_qitems_mqtt.cpp` (Keepalive, Credentials, `W/`-Writes)
- [freakent/dbus-mqtt-devices](https://github.com/freakent/dbus-mqtt-devices) (ESP32 Self-Registration)
- [node-red-contrib-victron](https://github.com/victronenergy/node-red-contrib-victron) Virtual Devices
- Fork-Eigenentwicklung: `services/dbus-mqtt-occ/` + `docs/occ/`

---

## 1. Overview — Was „Token“ bei Victron wirklich bedeutet

Es gibt **kein** lokales JWT/Session-Token, das der ESP32 vom Cerbo holt, um danach „Virtual Devices anzulegen“. Das ist der häufigste Missverständnispunkt.

| Begriff | Was es ist | Wofür | Lokal Cerbo? | Remote VRM? |
|---|---|---|---|---|
| **VRM Access Token** | Geheimnis aus [VRM Access Tokens](https://vrm.victronenergy.com/access-tokens) | MQTT-Passwort am **Cloud**-Broker (`mqttN.victronenergy.com:8883`) | Nein (nicht nötig) | **Ja — das „geschützte Token“** |
| **VRM Portal ID** | Hex-ID des GX (öffentlich auf dem Gerät) | Teil jedes Topic-Pfads `N\|R\|W/<portalId>/…` | Ja | Ja |
| **Keepalive** | Publish auf `R/<portalId>/keepalive` | Ohne Retain: Topics erscheinen erst nach Keepalive | Ja | Ja |
| **MQTT User/Pass (lokal)** | Optional Netzwerk-Passwort (neuere Venus) | Broker-Login lokal | Optional | — |
| **Device Registration** | JSON auf `device/<clientId>/Status` | Nur mit Treiber `dbus-mqtt-devices` | Ja | — |

### Zwei Verbindungsmodi

```
A) LOKAL (empfohlen für ESP32 im Fahrzeug)
   ESP32 ──MQTT :1883/8883──► Cerbo FlashMQ (dbus-flashmq)
                              │
                              ▼
                           D-Bus Venus OS ──► GUI v2

B) REMOTE (VRM Cloud — hier braucht ihr das Access Token)
   Client ──TLS :8883──► mqtt<N>.victronenergy.com
   Username = VRM-E-Mail
   Password = Token <ACCESS_TOKEN>
```

**Für den ESP32 an der Heizung:** immer **Modus A (lokal)**. Token-Austausch ist nur relevant, wenn ihr **über Internet/VRM** steuern wollt.

---

## 2. Token Exchange (nur VRM / Remote)

### 2.1 Token beschaffen

1. VRM → Access Tokens → Token erzeugen (Scopes: mind. Full Control für Writes).
2. Token **nie** im Klartext committen; auf ESP32 in NVS / verschlüsseltem Partition-Slot ablegen.
3. Bei Reconnect: Token ggf. neu setzen (GUI-Code kommentiert: *„VRM token may change“* — siehe `VeQItemMqttProducer::setCredentials`).

### 2.2 MQTT-Login am Cloud-Broker

```text
Host:     mqtt<broker_index>.victronenergy.com   # oder aus VRM API mqtt_host
Port:     8883 (TLS)
Username: <vrm-email>
Password: Token <access_token>                   # Literal "Token " + Token
ClientId: unique, z.B. esp32_alde_<mac>
CA:       venus-ca.crt / ccgx-ca.pem
```

Broker-Index (offizieller Algorithmus aus dbus-flashmq):

```python
def vrm_broker_url(portal_id: str) -> str:
    s = sum(ord(c) for c in portal_id.lower().strip())
    return f"mqtt{s % 128}.victronenergy.com"
```

### 2.3 Keepalive (kein Auth, aber Pflicht)

```bash
# Volles Republish aller Topics
mosquitto_pub -h <broker> -t 'R/<portalId>/keepalive' -m ''

# Danach periodisch (alle ~30s), ohne erneutes Full-Publish:
mosquitto_pub -t 'R/<portalId>/keepalive' \
  -m '{ "keepalive-options" : ["suppress-republish"] }'
```

GUI macht dasselbe (`doKeepAlive` in `ve_qitems_mqtt.cpp`).

### 2.4 Was lokal **nicht** existiert

- Kein `{"action":"request_token"}` am Cerbo-Broker
- Kein MQTT-RPC „create virtual slider“
- Schreiben = Publish auf `W/…` mit `{"value": …}` — **nur wenn der D-Bus-Pfad schon existiert**

---

## 3. MQTT Topic Design (offiziell dbus-flashmq)

```text
N/<portalId>/<serviceType>/<deviceInstance>/<DBusPath>   # Notify (lesen)
R/<portalId>/<serviceType>/<deviceInstance>/<DBusPath>   # Read anfordern
W/<portalId>/<serviceType>/<deviceInstance>/<DBusPath>   # Write (setzen)
R/<portalId>/keepalive                                   # Keepalive
```

Payload (immer):

```json
{"value": 22.5}
```

Ungültig / verschwunden: `{"value": null}` bzw. leerer Payload.

Beispiel Write (Solltemperatur einer OCC-Zone, wenn Bridge läuft):

```text
W/<portalId>/heating/100/Zone/1/Setpoint
{"value": 22.0}
```

---

## 4. Drei Wege zu „virtuellen“ Bedienelementen

### Vergleich

| Kriterium | A: OCC Bridge (empfohlen) | B: dbus-mqtt-devices | C: Node-RED Virtual Devices |
|---|---|---|---|
| ESP32 legt Devices selbst an | Indirekt (publisht `occ/…`) | Ja (`device/*/Status`) | Nein (Node-RED legt an) |
| Temperatursensor in DeviceList | Ja (über Temp-Bridge) | Ja (`temperature`) | Ja |
| **Sollwert-Slider wie HeatingPage** | **Ja (eigene GUI)** | Nein (nur Sensor) | Nur eingeschränkt (Temp-Sensor / Switch; Venus 3.70+ ggf. SwitchableOutput TemperatureSetpoint) |
| Gas-/Leistungs-Schalter | Als D-Bus-Pfade + QML | Nur Standard-Services | Virtual **Switch** |
| ALDE 3030 (Zonen, Stufen, Priorität) | **Passt** | Unpassend | Teilarbeit |
| Extra-Software auf Cerbo | `dbus-mqtt-occ` | `dbus-mqtt-devices` | Node-RED Large |
| Offline / ohne Cloud | Ja | Ja | Ja |

### Empfehlung

1. **Primär: Ansatz A** — ESP32 publisht auf `occ/…`, Cerbo-Service `dbus-mqtt-occ` mappt auf `com.victronenergy.heating.occ`, Fork-GUI zeigt Slider (bereits vorhanden).
2. **Sensoren optional B** — Außentemperatur / Zone-Ist als `temperature`-Services via `dbus-mqtt-devices`, falls ihr sie auch in der normalen DeviceList/VRM sehen wollt.
3. **Fallback C** — Node-RED Virtual Switch/Temperature, wenn kein Custom-Service gewünscht; **kein** vollwertiger ALDE-Thermostat ohne weitere Arbeit.

> **Klartext:** Einen „virtuellen Temperaturslider“ erzeugt **kein** MQTT-Topic allein. Entweder existiert ein D-Bus-Service mit Setpoint-Pfad + GUI, die ihn bindet (OCC), oder ihr nutzt Standard-Widgets (Temp-Sensor = Anzeige; Switch = Schalter; ab Venus 3.70 ggf. SwitchableOutput-Typen).

---

## 5. Device Definition Table (ALDE 3030 Zielbild)

| Funktion | UI | Empfohlener D-Bus-Pfad (OCC) | ESP32 MQTT (OCC) | Typ |
|---|---|---|---|---|
| Soll Wohnen | Slider | `/Zone/1/Setpoint` | `occ/heating/zone/1/setpoint` (+ `/set` zurück) | float °C |
| Soll Schlafen (opt.) | Slider | `/Zone/2/Setpoint` | `occ/heating/zone/2/setpoint` | float °C |
| Ist Wohnen | Wert | `/Zone/1/Temperature` | `occ/heating/zone/1/temperature` | float °C |
| Ist Schlafen | Wert | `/Zone/2/Temperature` | `occ/heating/zone/2/temperature` | float °C |
| Außen | Wert | `/Outdoor/Temperature` *(erweitern)* oder Temp-Service | `occ/heating/outdoor/temperature` | float °C |
| El. Leistung | 0/1/2/3 kW | `/Electric/PowerLevel` | `occ/heating/electric/power_level` | int 0–3 |
| Gas Ein/Aus | Schalter | `/Gas/Enabled` | `occ/heating/gas/enabled` | 0/1 |
| Priorität Gas/Elek. | Schalter/Enum | `/Energy/Priority` | `occ/heating/energy/priority` | 0=Gas,1=Elek |

Instanz OCC (aktuell): **DeviceInstance 100**, Service-Typ MQTT: `heating`, Portal-Pfad:  
`mqtt/heating.occ/...` (WASM) bzw. `dbus/com.victronenergy.heating.occ/...` (GX).

---

## 6. ESP32 Implementation

### 6.1 Lokal verbinden (ohne Token)

```cpp
// Pseudocode / Arduino PubSubClient oder esp-idf mqtt
const char* BROKER = "192.168.4.145";   // oder Tailscale-IP des Cerbo
const int   PORT   = 1883;
const char* CLIENT = "esp32_alde_01";

// Optional, falls Netzwerk-Passwort gesetzt:
// mqtt.setUsername("..."); mqtt.setPassword("...");

void onConnect() {
  // Last Will: Bridge kann Connected=0 setzen
  // topic: occ/system/status  payload: {"value":0}   — oder OCC-eigenes LWT

  // Periodische Telemetrie
  publishFloat("occ/heating/zone/1/temperature", livingTemp);
  publishFloat("occ/heating/zone/1/setpoint", livingSet); // Ist vom LIN lesen
  publishInt  ("occ/heating/electric/power_level", powerLevel);
  publishInt  ("occ/heating/gas/enabled", gasOn);
  publishInt  ("occ/heating/energy/priority", priority);
}

void publishFloat(const char* topic, float v) {
  char buf[32];
  snprintf(buf, sizeof(buf), "{\"value\":%.2f}", v);
  mqtt.publish(topic, buf, false); // retain=false empfohlen
}
```

> Die Bridge `dbus-mqtt-occ` erwartet die OCC-Topics (siehe `docs/occ/05-mqtt-bridge-spezifikation.md`) und schreibt D-Bus. GUI schreibt Setpoints → Bridge → `…/set` Topics zurück an den ESP32.

### 6.2 Steuerung empfangen (ESP32 subscriber)

```cpp
mqtt.subscribe("occ/heating/zone/1/setpoint/set");
mqtt.subscribe("occ/heating/electric/power_level/set");
mqtt.subscribe("occ/heating/gas/enabled/set");
mqtt.subscribe("occ/heating/energy/priority/set");

// onMessage: JSON {"value":...} parsen → LIN/CI-Bus Befehl an ALDE
```

### 6.3 Optional: dbus-mqtt-devices Self-Registration (Sensoren)

Nur wenn Treiber auf dem Cerbo installiert ist:

```json
// Publish device/esp32alde/Status  (connected=1 bei jedem Connect)
{
  "clientId": "esp32alde",
  "connected": 1,
  "version": "alde-1.0",
  "services": {
    "out": "temperature",
    "z1": "temperature",
    "z2": "temperature"
  }
}
```

Antwort auf `device/esp32alde/DBus`:

```json
{
  "portalId": "c0619ab12e1a",
  "deviceInstance": { "out": 21, "z1": 22, "z2": 23 },
  "topicPath": {
    "out": {
      "N": "N/c0619ab12e1a/temperature/21",
      "W": "W/c0619ab12e1a/temperature/21"
    }
  }
}
```

Dann Werte schreiben:

```text
W/<portalId>/temperature/21/Temperature
{"value": 4.2}
```

**Das erzeugt Temperatursensoren in der DeviceList — keine Heating-Sollwert-Slider.**

### 6.4 Remote (VRM) — Token sicher speichern

```cpp
// NVS namespace "vrm"
preferences.begin("vrm", false);
preferences.putString("email", email);
preferences.putString("token", token);  // nicht loggen!

String pass = String("Token ") + preferences.getString("token");
mqtt.setUsername(preferences.getString("email").c_str());
mqtt.setPassword(pass.c_str());
// TLS + CA Pflicht
```

Token-Renewal: bei Auth-Fehler Token als ungültig markieren, Fallback lokal, UI/Provisioning für neues Token.

### 6.5 Reconnect / Error-Handling

1. On disconnect → reconnect mit Backoff (1s, 2s, 5s, 30s max).
2. On connect → Status `connected=1` + volle Telemetrie-Snapshot publishen.
3. LWT: `connected=0` / `occ/system/status=0`.
4. Bei VRM: Credentials vor jedem Connect aktualisieren.
5. Keine großen Static-Buffer; JSON mit kleinen `snprintf`-Buffers (≤ 128 B pro Message).

---

## 7. Node-RED Alternative

### 7.1 Virtual Devices (offiziell)

Unterstützte Typen u.a.: **temperature, tank, battery, switch, grid, pvinverter, …**  
→ Ideal für: Außentemperatur, Ist-Werte, Gas-Schalter, ggf. Stufen als mehrere Switches.

**Nicht** ideal für: ALDE-Zonen-Sollwert-Slider in HeatingPage.

### 7.2 Flow-Idee (Fallback)

```text
ESP32 --MQTT occ/*--> MQTT-In (Node-RED)
                         │
         ┌───────────────┼────────────────┐
         ▼               ▼                ▼
   Virtual Temp     Virtual Switch   Function → D-Bus
   (Außen/Zone)     (Gas, Prio)      Custom Control
                         │
                         ▼
              Victron GUI DeviceList / Switch Pane
```

Virtual Switch Input (Konzept):

```json
{
  "/State": 1,
  "/Name": "ALDE Gas"
}
```

(Exakte Pfade je nach Virtual-Switch-Dokumentation der installierten `node-red-contrib-victron`-Version.)

### 7.3 Venus 3.70+ Hinweis

Community: SwitchableOutput-Typ **TemperatureSetpoint** kann native Temp-Slider im Switch-Pane nutzen. Das ist ein möglicher dritter UI-Pfad **ohne** OCC-HeatingPage — aber Hardware/IO-Modell muss passen; ALDE-Stufen/Priorität bleiben Custom.

Es gibt **keine** stabile öffentliche REST-API `POST /api/virtual_devices` als offiziellen Victron-Standard; Virtual Devices werden über Node-RED-Nodes (Deploy) erzeugt, nicht über ein generisches HTTP-Create vom ESP32.

---

## 8. Example Payloads

### Keepalive

```json
{ "keepalive-options": ["suppress-republish"] }
```

### OCC Telemetrie

```json
{"value": 21.5}
```

Topic: `occ/heating/zone/1/temperature`

### OCC Write vom Cerbo an ESP32

Topic: `occ/heating/zone/1/setpoint/set`  
Payload: `{"value": 22.0}`

### dbus-mqtt Write (nach Registration)

```text
W/c0619ab12e1a/temperature/21/Temperature
{"value": 3.8}
```

### VRM Auth (Konzept, nicht committen)

```text
user: user@example.com
password: Token eyJhbGciOi...
```

---

## 9. Empfohlene Gesamarchitektur (ALDE + ESP32)

```text
ALDE 3030
   │ CI/LIN
   ▼
ESP32 Firmware
   │ publish occ/heating/...
   │ subscribe occ/heating/.../set
   ▼
Cerbo FlashMQ :1883
   │
   ├─► dbus-mqtt-occ  → com.victronenergy.heating.occ
   │                      └─► GUI HeatingPage / HeatingCard (Fork)
   │
   └─► (optional) dbus-mqtt-devices → temperature.* (Außen/Ist in DeviceList)
```

**Automatisches Anlegen:**
- OCC-Pfade: vom Bridge-Service beim Start registriert (nicht vom ESP32 per Token).
- ESP32 muss **nur** Topics bedienen; Geräte-„Anlage“ = Bridge + ggf. Registration-Protokoll.

---

## 10. Troubleshooting

| Symptom | Ursache | Fix |
|---|---|---|
| Subscribe `N/…/#` leer | Kein Keepalive / keine Retains | `R/<portalId>/keepalive` senden |
| Write ohne Wirkung | Falsche Instance / Service / kein D-Bus-Pfad | Mit MQTT Explorer `N/+/+/+/ProductId` + Keepalive prüfen |
| „Token“ lokal erwartet | Verwechslung mit VRM | Lokal ohne Token; nur Cloud braucht `Token …` |
| Temp sichtbar, kein Slider | temperature-Service ≠ Setpoint-UI | OCC Bridge + HeatingPage oder SwitchableOutput |
| Auth fail remote | Token falsch / Monitor-Only | Neues Access Token, Full Control |
| ESP32 reconnect Loop | Broker-IP/WLAN | Statische IP / mDNS / Tailscale; LWT prüfen |
| GUI zeigt OCC nicht | Bridge down | `svstat /service/dbus-mqtt-occ`, Logs |

Portal-ID finden: GX → Settings → VRM → Portal ID (oder `N/<id>/system/0/Serial` nach Keepalive).

---

## 11. Workflow-Kurzfassung für Weiterentwicklung

1. **Lokal** MQTT zum Cerbo (1883), Portal-ID notieren.  
2. **OCC-Bridge** auf Cerbo deployen (`services/dbus-mqtt-occ`).  
3. ESP32: LIN lesen → `occ/heating/…` publishen; `…/set` abonnieren → LIN schreiben.  
4. GUI Fork: HeatingPage bereits an `heating.occ` gebunden.  
5. Optional: Außentemp zusätzlich über `dbus-mqtt-devices` als `temperature`.  
6. Remote nur bei Bedarf: VRM Access Token als MQTT-Password `Token …`.  
7. Node-RED nur als Fallback für Standard-Virtual-Switches/Temps.

---

## 12. Offene Erweiterungen (Bridge)

Für die gewünschte ALDE-Matrix fehlen ggf. noch D-Bus/MQTT-Felder in `dbus-mqtt-occ` (je nach aktuellem Stand prüfen):

- `/Outdoor/Temperature`
- `/Electric/PowerLevel` (0–3)
- `/Gas/Enabled`
- `/Energy/Priority`

GUI-Widgets dafür in `HeatingPage.qml` ergänzen (Slider/Segmented/Switches).

---

## Referenzen im Repo

| Doc | Inhalt |
|---|---|
| `docs/occ/05-mqtt-bridge-spezifikation.md` | OCC Topic↔D-Bus |
| `docs/occ/07-architektur-entscheidung.md` | Hybrid Bridge+Fork |
| `docs/occ/00-wissensspeicher.md` | Deploy/Runbooks |
| `services/dbus-mqtt-occ/` | Laufende Bridge |
