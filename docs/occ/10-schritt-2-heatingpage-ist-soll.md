# Schritt 2 — HeatingPage: Ist/Soll-Anzeige, Temperaturgrenzen, Seiten-Fix

**Stand:** 2026-07-04  
**Branch:** `v_2026.6.2`  
**Vorgänger:** [09-implementierung-steuerseite-2026-06-24.md](09-implementierung-steuerseite-2026-06-24.md) (Schritt 1)  
**Index:** [00-wissensspeicher.md](00-wissensspeicher.md)

---

## Zusammenfassung

Schritt 2 stabilisiert die Steuerseite **Heating & Climate** (Heizung & Klima): Temperaturbereich Heizung auf **5–30 °C**, Anzeige **Ist / Soll** pro Zone und Klima-Einheit, Rückfall von instabilen Custom-Komponenten auf Standard-Victron-QML (`ListText`, `ListSlider`, `ListRadioButtonGroup`).

---

## Geänderte Dateien (Commit-Kandidaten)

| Datei | Änderung |
|-------|----------|
| `pages/HeatingPage.qml` | Ist/Soll in `ListText`, Slider 5–30 °C, Klima-Modus, kein `OccSetpointSliderRow` |
| `pages/HeatingZonePage.qml` | Max. Sollwert 30 °C |
| `components/OccSetpointSliderRow.qml` | Default `to: 30.0` |
| `services/dbus-mqtt-occ/config.ini` | `MaxSetpoint = 30.0` |

**Nicht committen:** `analysis/build-all_2026-07-03.log`, `services/dbus-mqtt-occ/__pycache__/`

---

## Übersetzungen (EN → DE)

Alle Begriffe der Steuerseite und Modusnamen:

| Key / Begriff (EN) | Deutsch (DE) | Verwendung |
|--------------------|--------------|------------|
| Heating & Climate | Heizung & Klima | Menüeintrag Einstellungen |
| Zones, setpoints, valves, climate control | Zonen, Sollwerte, Ventile, Klimasteuerung | Menü-Untertitel |
| System status | Systemstatus | Kopfzeile Steuerseite |
| Offline | Offline | Systemstatus |
| Standby | Standby | Systemstatus |
| Active | Aktiv | Systemstatus |
| Heating zones | Heizungszonen | Abschnittsüberschrift |
| Setpoint | Soll-Temperatur | Slider Heizzone |
| Target temperature | Ziel-Temperatur | Slider Klima |
| Climate | Klimaanlage | Abschnittsüberschrift |
| Climate mode | Klima-Modus | Modus-Auswahl |
| Off | Aus | Klima-Modus (CommonWords.off) |
| Cooling | Kühlen | Klima-Modus |
| Heating | Heizen | Klima-Modus |
| Automatic | Automatik | Klima-Modus |
| Current temperature | Ist-Temperatur | Detailseiten / Anzeigeformat |
| Mode | Modus | Zonen-Detail |
| Manual | Manuell | Zonen-Modus |
| State | Status | Zonen-Detail |
| Relay | Relais | Zonen-Detail |
| Valves | Ventile | Zonen-Detail |
| Open | Offen | Ventilstatus |
| Closed | Geschlossen | Ventilstatus |
| Idle | Bereit | Klima-Status |

**Anzeigeformat Ist/Soll (ohne eigene Übersetzungs-ID):**  
`21,5 °C / 20,0 °C` — links Ist-Temperatur, rechts Soll-Temperatur, getrennt durch ` / `.

---

## Commit (Schritt 2)

```bash
cd /home/hliebscher/github/gui-v2

git add pages/HeatingPage.qml \
        pages/HeatingZonePage.qml \
        components/OccSetpointSliderRow.qml \
        services/dbus-mqtt-occ/config.ini \
        docs/occ/10-schritt-2-heatingpage-ist-soll.md

git commit -m "$(cat <<'EOF'
fix(heating): Schritt 2 — Ist/Soll-Anzeige und Heiz-Max 30 °C

HeatingPage zeigt Ist/Soll pro Zone und Klima, nutzt stabile
Standard-Slider statt OccSetpointSliderRow. Backend-MaxSetpoint 30 °C.
EOF
)"
```

---

## Deploy & Test

```bash
# Browser (WASM)
./scripts/build-wasm.sh -H 100.65.95.55

# GX-Display (native)
./scripts/build-gx.sh -H 100.65.95.55

# Backend config.ini auf dem GX (nicht im GUI-Deploy enthalten)
ssh root@100.65.95.55 'grep MaxSetpoint /data/apps/dbus-mqtt-occ/config.ini'
ssh root@100.65.95.55 'svc -t /service/dbus-mqtt-occ'
```

**Test:** Einstellungen → **Heizung & Klima** — Seite öffnet, pro Zeile Ist/Soll, Slider 5–30 °C (Heizung) bzw. 16–30 °C (Klima).

---

## Bekannte Einschränkungen

- `OccSetpointSliderRow` / `OccClimateUnitBlock` brechen `pushPage` in `VisibleItemModel` — nicht in `HeatingPage` verwenden.
- Browser: Ist-Werte oft `---` ohne MQTT-Temperaturen von `dbus-mqtt-occ`.
- Übersetzungs-Keys `settings_heating_climate*` ggf. noch in `i18n/venus-gui-v2_de.ts` ergänzen (lupdate/lrelease).
