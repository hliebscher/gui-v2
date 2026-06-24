# Analyse: Scheer Selection Heizungssteuerung über Victron Cerbo

Stand: 2026-05-26  
Quelle: `docs/Steuerung Scheer Selection über Victron Cerbo.pdf` (VARIOmobil, 04.05.26, DM)

---

## Schaltplan-Zusammenfassung

### Identifizierte Systeme

| System | Beschreibung | Anschluss |
|---|---|---|
| Scheer Selection | Heizgerät (Zentralheizung) | Platine Scheer → Relais |
| Frischwasser Warm Plus | Warmwasserbereitung | Eigenes Power Supply 24V |
| Auto-Tank-Control | Tankumschaltung (Zusatztank ↔ Fahrzeugtank) | NC-Kontakt + Endschalter |
| Cerbo GX | Zentrale Steuereinheit | HDMI, VE.CAN×2, VE.BUS, VE.direct, USB, Ethernet |
| 2× GX IO-Extender 150 | I/O-Erweiterung (je 4DI + 4DO + 3R) | USB zum Cerbo |
| DC/DC Wandler Stellantriebe | 24V-Versorgung für Ventilantriebe | 4.7kΩ, QV/24V |

### Heizungszonen (3 Zonen)

| Zone | Raum | Thermostat steuert | Ventile | Pumpen |
|---|---|---|---|---|
| 1 | Wohnraum | Wohnraum-Thermostat | V20, V24, V25 | P1 + P2 |
| 2 | Bad | Bad-Thermostat | V18 | P1 |
| 3 | Schlafraum | Schlafraum-Thermostat | V17 | P1 |

### Pumpen

| Bezeichnung | Funktion | Steuerung |
|---|---|---|
| P1 | Hauptumwälzpumpe (gemeinsam) | Alle Thermostate (wenn mind. 1 Zone aktiv) |
| P2 | Zusatzpumpe Wohnraum | Nur Wohnraum-Thermostat |
| Pumpe Fußboden | Fußbodenheizungs-Umwälzung | Via Relais |
| Pumpe Konvektor | Konvektor-Umwälzung | Via Relais |

### Ventile (motorisiert, 24V Stellantriebe)

| Ventil | Zone | Heizkreis | Beschreibung |
|---|---|---|---|
| V17 | Schlafraum | 1 Kreis | Schlafraum-Zonenventil |
| V18 | Bad | 1 Kreis | Bad-Zonenventil |
| V20 | Wohnraum | Kreis 1 | Wohnraum-Zonenventil 1 |
| V24 | Wohnraum | Kreis 2 | Wohnraum-Zonenventil 2 |
| V25 | Wohnraum | Kreis 3 | Wohnraum-Zonenventil 3 |

### Power Supplies (4 Stück)

| # | Eingang | Ausgang | Verbraucher |
|---|---|---|---|
| 1 | 9–36V (8-pol) | 12V | Raumthermostat 1 |
| 2 | 9–36V (10-pol) | 12V | Pumpe Heizkreis 1 |
| 3 | 9–36V (24V) | 24V | Frischwasser Warm Plus |
| 4 | 9–36V (9-pol) | 12V | Strömungsschalter |
| 5 | 9–36V (10-pol) | 12V | Auto-Tank-Control |

### Cerbo GX Anschlüsse (lt. Schaltplan)

| Port | Belegung |
|---|---|
| Relay 1 | WR (Wechselrichter) |
| Relay 2 | Bad |
| Power N | — |
| Temp | Temperatursensor |
| USB (×2) | IO-Extender 150 (×2) |
| Ethernet | Netzwerk |
| VE.CAN 1 | — |
| VE.CAN 2 | — |
| VE.BUS | — |
| VE.direct | — |
| HDMI | Display |

### IO-Extender 150 — Belegung (aus Schaltplan)

**IO-Extender 1:**

| Kanal | Belegung | Typ |
|---|---|---|
| Eingang | SR (Strömungsrelais?) | Digital In |
| Eingang | USB | — |
| Ausgänge | → V17, V18 Steuerung | Relais/DO |

**IO-Extender 2:**

| Kanal | Belegung | Typ |
|---|---|---|
| Eingang | WR | Digital In |
| Eingang | Bad | Digital In |
| Ausgänge | → V20, V24, V25 Steuerung | Relais/DO |

### Wichtige Hinweise aus dem Schaltplan

1. **"S* = Motorwärme Only — Nur wenn das Heizgerät defekt!"**
   → Fallback-Modus: Bei Defekt des Scheer-Heizgeräts wird Motorabwärme genutzt

2. **"Thermostate steuern direkt die Pumpen"**
   → Direkte Hardware-Verbindung — die Thermostate schalten eigenständig

3. **Tankumschaltung:** Beim Umschalten des Ventils auf "Fahrzeugtank" wird ein Endschalter betätigt und unterbricht den Heizkreis

4. **"Optional mit Kontrolle"** (gestrichelter roter Bereich)
   → Optionale Überwachungs-/Kontrollschaltung (noch nicht implementiert)

---

## Abgleich mit OCC-Architekturplanung

### Abweichungen: Plan vs. realer Schaltplan

| Aspekt | OCC-Plan (docs/occ/06) | Realer Schaltplan | Anpassung nötig |
|---|---|---|---|
| **Anzahl IO-Extender** | 1× IO-Extender 150 | **2× IO-Extender 150** | JA — Erweiterung |
| **Heizungszonen** | 2 Zonen | **3 Zonen** (Wohnraum, Bad, Schlafraum) | JA — Zone 3 hinzufügen |
| **Ventile** | Nicht geplant | **5 Motorventile** (V17–V25) | JA — Ventilsteuerung ergänzen |
| **Pumpen** | 1 Umwälzpumpe | **4 Pumpen** (P1, P2, Fußboden, Konvektor) | JA — Pumpenlogik erweitern |
| **Thermostat-Steuerung** | OCC steuert alles | **Thermostate steuern direkt** | KRITISCH — Hybride Steuerung |
| **Klimaanlage** | 1 Relais | Nicht im Schaltplan | Prüfen — ggf. separates System |
| **Cerbo Relay 1+2** | Nicht genutzt | WR + Bad | Beachten — bereits belegt |
| **Tank-System** | Nicht geplant | Auto-Tank-Control mit Umschaltventil | Optional — spätere Phase |
| **Warmwasser** | Nicht geplant | Frischwasser Warm Plus | Optional — spätere Phase |

### Kritische Erkenntnis: Hybrid-Steuerungskonzept

Der Schaltplan zeigt, dass die **Thermostate direkt die Pumpen steuern** — das bedeutet:

```
┌──────────────────────────────────────────────────────────────────┐
│                   STEUERUNGS-HIERARCHIE                           │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Ebene 1: THERMOSTATE (autonom, direkte Hardware-Verdrahtung)    │
│  ──────────────────────────────────────────────────────────────  │
│  • Schalten Pumpen P1/P2 direkt                                  │
│  • Funktionieren OHNE Cerbo/OCC (Fail-Safe!)                    │
│  • Keine Software-Abhängigkeit                                   │
│                                                                  │
│  Ebene 2: IO-EXTENDER (Ventilsteuerung via Cerbo)                │
│  ──────────────────────────────────────────────────────────────  │
│  • Schalten Zonenventile V17–V25                                 │
│  • Bestimmen welche Heizkreise aktiv sind                        │
│  • Cerbo/OCC steuert WELCHE Zonen beheizt werden                │
│                                                                  │
│  Ebene 3: OCC/GUI (Monitoring + Sollwert-Vorgabe)               │
│  ──────────────────────────────────────────────────────────────  │
│  • Temperaturen anzeigen (Ist/Soll)                              │
│  • Zeitprogramme für Ventilöffnung                               │
│  • Modus-Umschaltung (Auto/Manuell/Aus)                         │
│  • Fernüberwachung via MQTT                                      │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

**Das bedeutet für die Software:**
- OCC steuert nicht die Pumpen (die laufen autonom per Thermostat)
- OCC steuert die **Ventile** (welche Zonen offen/geschlossen sind)
- OCC **überwacht** (Temperaturen, Durchfluss, Ventilstatus)
- Die Heizung funktioniert auch bei Software-Ausfall (Fail-Safe)

---

## Korrigiertes Datenmodell

### 3 Zonen (statt 2)

```
com.victronenergy.heating.occ/Zone/1/Name           → "Wohnraum"
com.victronenergy.heating.occ/Zone/1/Temperature    → Ist-Wert
com.victronenergy.heating.occ/Zone/1/Setpoint       → Soll-Wert
com.victronenergy.heating.occ/Zone/1/State          → 0=Aus, 1=Heizen
com.victronenergy.heating.occ/Zone/1/ValveState     → Bitmaske: V20|V24|V25
com.victronenergy.heating.occ/Zone/1/PumpState      → P1+P2 aktiv

com.victronenergy.heating.occ/Zone/2/Name           → "Bad"
com.victronenergy.heating.occ/Zone/2/Temperature    → Ist-Wert
com.victronenergy.heating.occ/Zone/2/Setpoint       → Soll-Wert
com.victronenergy.heating.occ/Zone/2/State          → 0=Aus, 1=Heizen
com.victronenergy.heating.occ/Zone/2/ValveState     → V18

com.victronenergy.heating.occ/Zone/3/Name           → "Schlafraum"
com.victronenergy.heating.occ/Zone/3/Temperature    → Ist-Wert
com.victronenergy.heating.occ/Zone/3/Setpoint       → Soll-Wert
com.victronenergy.heating.occ/Zone/3/State          → 0=Aus, 1=Heizen
com.victronenergy.heating.occ/Zone/3/ValveState     → V17
```

### Ventil-Mapping (NEU)

```
com.victronenergy.heating.occ/Valve/V17/State       → 0=Zu, 1=Offen
com.victronenergy.heating.occ/Valve/V17/Zone        → 3 (Schlafraum)
com.victronenergy.heating.occ/Valve/V18/State       → 0=Zu, 1=Offen
com.victronenergy.heating.occ/Valve/V18/Zone        → 2 (Bad)
com.victronenergy.heating.occ/Valve/V20/State       → 0=Zu, 1=Offen
com.victronenergy.heating.occ/Valve/V20/Zone        → 1 (Wohnraum)
com.victronenergy.heating.occ/Valve/V24/State       → 0=Zu, 1=Offen
com.victronenergy.heating.occ/Valve/V24/Zone        → 1 (Wohnraum)
com.victronenergy.heating.occ/Valve/V25/State       → 0=Zu, 1=Offen
com.victronenergy.heating.occ/Valve/V25/Zone        → 1 (Wohnraum)
```

### Pumpen-Status (NEU)

```
com.victronenergy.heating.occ/Pump/P1/State         → 0=Aus, 1=Läuft (von Thermostat)
com.victronenergy.heating.occ/Pump/P2/State         → 0=Aus, 1=Läuft (von Thermostat)
com.victronenergy.heating.occ/Pump/Floor/State      → 0=Aus, 1=Läuft
com.victronenergy.heating.occ/Pump/Convector/State  → 0=Aus, 1=Läuft
```

### System-Status (NEU)

```
com.victronenergy.heating.occ/Heater/State          → 0=Aus, 1=Bereit, 2=Heizt, 3=Störung
com.victronenergy.heating.occ/Heater/Mode           → 0=Normal, 1=MotorwärmeOnly(S*)
com.victronenergy.heating.occ/Flow/State            → 0=Kein Durchfluss, 1=Durchfluss
com.victronenergy.heating.occ/HotWater/State        → 0=Aus, 1=Heizen, 2=Bereit
```

---

## Korrigierte IO-Extender Zuordnung

### IO-Extender 1 (USB-Port 1 am Cerbo)

| Kanal | Funktion lt. Schaltplan | OCC D-Bus Pfad |
|---|---|---|
| R1 | Ventil V17 (Schlafraum) | `/SwitchableOutput/relay1/State` |
| R2 | Ventil V18 (Bad) | `/SwitchableOutput/relay2/State` |
| R3 | Reserve / SR | `/SwitchableOutput/relay3/State` |
| DO1 | Pumpe Fußboden | `/SwitchableOutput/do1/State` |
| DO2 | Pumpe Konvektor | `/SwitchableOutput/do2/State` |
| DO3 | Reserve | — |
| DO4 | Reserve | — |
| DI1 | Strömungsschalter (SR) | `/DigitalInput/.../State` |
| DI2 | Thermostat Schlafraum | `/DigitalInput/.../State` |
| DI3 | Thermostat Bad | `/DigitalInput/.../State` |
| DI4 | Reserve | — |

### IO-Extender 2 (USB-Port 2 am Cerbo)

| Kanal | Funktion lt. Schaltplan | OCC D-Bus Pfad |
|---|---|---|
| R1 | Ventil V20 (Wohnraum Kreis 1) | `/SwitchableOutput/relay1/State` |
| R2 | Ventil V24 (Wohnraum Kreis 2) | `/SwitchableOutput/relay2/State` |
| R3 | Ventil V25 (Wohnraum Kreis 3) | `/SwitchableOutput/relay3/State` |
| DO1 | Reserve (Warmwasser?) | — |
| DO2 | Reserve | — |
| DO3 | Reserve | — |
| DO4 | Reserve | — |
| DI1 | Thermostat Wohnraum | `/DigitalInput/.../State` |
| DI2 | WR-Signal (Wechselrichter) | `/DigitalInput/.../State` |
| DI3 | Tank-Endschalter | `/DigitalInput/.../State` |
| DI4 | Reserve | — |

### Cerbo GX eigene Relais

| Relais | Belegung lt. Schaltplan | Hinweis |
|---|---|---|
| Relay 1 | WR (Wechselrichter-Steuerung) | NICHT für OCC verfügbar |
| Relay 2 | Bad (Zusatzfunktion) | NICHT für OCC verfügbar |

---

## Empfohlene Änderungen an der OCC-Architektur

### 1. Zonen-Anzahl: 2 → 3

```diff
- [HEATING]
- Zones = 2
- ZoneNames = Wohnbereich,Schlafbereich
+ [HEATING]
+ Zones = 3
+ ZoneNames = Wohnraum,Bad,Schlafraum
```

### 2. Ventil-Konzept ergänzen

Die OCC-Architektur muss um ein Ventil-Management erweitert werden:
- Zone 1 (Wohnraum) hat **3 Ventile** (V20, V24, V25) — Heizkreise Fußboden, Konvektor, etc.
- Zone 2 (Bad) hat **1 Ventil** (V18)
- Zone 3 (Schlafraum) hat **1 Ventil** (V17)

### 3. Steuerungslogik anpassen

```
Bisheriger Plan:  OCC → Relais → Heizung EIN/AUS
Reale Logik:      Thermostat → Pumpe (direkt, autonom)
                  OCC → Ventile (Zonensteuerung)
                  OCC → Überwachung (Temperaturen, Durchfluss)
```

### 4. Zwei IO-Extender berücksichtigen

```diff
- IO_SERVICE=$(dbus -y | grep "com.victronenergy.ioextender" | head -1)
+ IO_SERVICE_1=$(dbus -y | grep "com.victronenergy.ioextender" | sed -n '1p')
+ IO_SERVICE_2=$(dbus -y | grep "com.victronenergy.ioextender" | sed -n '2p')
```

### 5. Fail-Safe Prinzip dokumentieren

Das System ist so konzipiert, dass bei Ausfall von Cerbo/OCC die Grundheizung weiterläuft (Thermostate schalten Pumpen direkt). OCC fügt nur Komfort-Features hinzu:
- Zonensteuerung per Ventil
- Zeitprogramme
- Fernüberwachung
- Temperatur-Logging

---

## Offene Fragen (zur Klärung mit Elektrik-Team)

1. **Welche Kanäle genau** sind an welchem IO-Extender belegt? (Schaltplan zeigt Verbindungen, aber exakte Pin-Zuordnung ist teilweise unklar)
2. **"Optional mit Kontrolle"** (roter gestrichelter Bereich): Was genau ist dort vorgesehen?
3. **Klimaanlage:** Im Schaltplan nicht ersichtlich — separates System oder noch nicht geplant?
4. **Temperatursensoren:** Welche Sensoren liefern die Ist-Werte? (Cerbo "Temp"-Anschluss = 1 Sensor, aber 3 Zonen?)
5. **Strömungsschalter (SR):** Welche Aktion soll bei "kein Durchfluss" ausgelöst werden?
6. **DC/DC Wandler 4.7kΩ:** Ist das ein Feedback-Signal für Ventilposition?

---

## Zusammenfassung: Auswirkungen auf OCC-Implementierung

| Bereich | Änderung | Aufwand |
|---|---|---|
| dbus-mqtt-occ config.ini | 3 Zonen, Ventil-Pfade, Pumpen-Status | Niedrig |
| PageHeating.qml | 3 Zonen statt 2, Ventil-Anzeige pro Zone | Niedrig |
| PageHeatingZone.qml | Ventil-Liste pro Zone, Pumpen-Status | Mittel |
| IO-Setup-Script | 2× IO-Extender, korrekte Kanal-Zuordnung | Mittel |
| Bridge-Logik | Ventil-Steuerung statt Relais-EIN/AUS | Mittel |
| Architektur-Doc | Fail-Safe-Konzept dokumentieren | Niedrig |
| Klimaanlage | Ggf. separates System → eigene Phase | Klärung nötig |
