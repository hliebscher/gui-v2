# Design: Standby-Uhr mit konfigurierbarem Blank-Timeout

**Datum:** 2026-08-16  
**Branch:** `feature/standby-clock-blank-timeout`  
**Status:** Freigabe Design (User) — Spec zur Review  
**Basis:** Brainstorm ScreenBlanker / Kundenbeschwerde „Uhr zu lange hell nachts“

---

## 1. Problem

Nach Idle zeigt der Vario-Fork die **StandbyPage** (große Datum/Uhrzeit) bei eingeschaltetem Backlight. Der echte Hardware-Blank startet erst nach einer **hardcodierten Gnadenfrist von 8 Stunden** (`m_finalDisplayOffDelayMs = 28800000` in `src/screenblanker.cpp`).

Folge: Nachts bleibt die Uhr lange hell — Kundenbeschwerden.

Victron-Stock: nach Display-off-Timeout typischerweise **sofort** Hardware-Blank (kein dauerhaftes Uhr-Overlay).

---

## 2. Ziel (v1)

1. Konfigurierbare Dauer der Standby-Uhr, danach **Original-Blank** (HW aus).  
2. Setting an geeigneter Stelle (analog Display-off / StatusBar-Temperatur).  
3. **Default unverändert 8 h** — schonende Migration für Bestand.  
4. Option **0** = keine Uhr, sofort Blank.

**Nicht in v1:** Nachtfenster 00:00–06:00, Dimmen der Uhr, Änderung der Display-off-Stufen selbst.

---

## 3. Entschiedene Parameter

| Parameter | Wert |
|-----------|------|
| Ansatz | Timer „Uhr → Blank“ (Ansatz A) |
| Default | **28800 s (8 h)** |
| Nachtfenster | nein (v1) |
| Setting-Ort | `PageSettingsDisplayAndAppearance.qml`, direkt unter „Display off time“ |
| D-Bus-Pfad | `/Settings/Gui2/StandbyClockDuration` (Sekunden) |
| Access | `User` |
| Sichtbarkeit | nur GX (`preferredVisible: Qt.platform.os != "wasm"`), analog Display-off |

### Optionsmodell (UI)

| Anzeige (Konzept) | value (s) |
|-------------------|----------:|
| Aus (sofort Blank) | 0 |
| 1 min | 60 |
| 5 min | 300 |
| 15 min | 900 |
| 30 min | 1800 |
| 1 h | 3600 |
| 8 h (Standard) | 28800 |

Exact qsTrId-Strings bei Implementierung; DE über `translation-overrides.json` falls nötig.

---

## 4. Verhalten

```
[UI aktiv]
    │ Display-off-Timeout (/Settings/Gui/DisplayOff) — unverändert
    ▼
[Standby-Uhr]  blanked=true, HW-Backlight=an, StandbyPage sichtbar
    │ Dauer = StandbyClockDuration (N Sekunden)
    │ wenn N == 0: diesen Schritt überspringen
    ▼
[Hardware-Blank]  Backlight aus (write blank_display_device)
    │
Touch/Key/Scroll  →  Display on, Idle-Timer neu starten
```

Manuelles „Display aus“ (StatusBar) nutzt denselben Pfad (`ScreenBlanker.setDisplayOff()`): gleiche Uhr-Dauer, dann Blank.

---

## 5. Technik

### 5.1 ScreenBlanker (`src/screenblanker.{h,cpp}`)

- `m_finalDisplayOffDelayMs` nicht mehr `const` / Compile-Zeit-Konstante.  
- Neue Property z. B. `standbyClockDuration` (ms oder s — **Empfehlung: ms intern wie `displayOffTime`**, Setting in Sekunden × 1000 im Binding).  
- `setDisplayOff()`:  
  - wenn Duration `== 0`: `setBlanked(true, true)` sofort (kein `m_finalOffTimer`).  
  - sonst: `setBlanked(true, false)` + `m_finalOffTimer.start(duration)`.  
- Default der Property ohne gültiges Setting: **28800000 ms** (Rückwärtskompatibilität).

### 5.2 Binding (`ApplicationContent.qml`)

Analog zu DisplayOff:

```qml
VeQuickItem { id: standbyClockDurationItem
  uid: … + "/Settings/Gui2/StandbyClockDuration" }
// ScreenBlanker.standbyClockDuration = valid ? value * 1000 : 28800000
```

(Fehlendes/ungültiges Setting → 8 h Default.)

### 5.3 StandbyPage (`pages/StandbyPage.qml`)

- Sichtbar nur wenn `ScreenBlanker.blanked` **und** Uhr-Phase aktiv (Duration > 0 und HW noch nicht blank **oder** äquivalente Property).  
- Bei Duration `0`: **kein** kurzes Aufblitzen der Uhr vor Blank.

Konkrete API (eine davon bei Implementierung wählen):

- Option A: Property `ScreenBlanker.hardwareBlanked` / `standbyClockVisible`  
- Option B: QML prüft `standbyClockDuration > 0 && blanked && !…`

Empfehlung: explizite Property `standbyClockActive` vom C++ Blanker (klar, testbar).

### 5.4 Settings-UI

`ListRadioButtonGroup` in `PageSettingsDisplayAndAppearance.qml` unter Display-off:

- `dataItem.uid: …/Settings/Gui2/StandbyClockDuration`  
- `optionModel` wie Abschnitt 3  

Local Settings / GUI2-Pfad: wie bei `StatusBar/TemperatureSensorIndex` — Venus legt fehlende Keys typischerweise bei erstem Write an; falls Fork eigene Defaults braucht, in bestehendem Settings-Bootstrap nur dokumentieren/ergänzen falls vorhanden.

### 5.5 Tests

`tests/screenblanker/tst_screenblanker.qml` erweitern:

- Duration > 0: nach Idle zuerst blanked ohne HW, nach Delay HW (soweit in Desktop-Mock testbar).  
- Duration 0: sofort HW-blank / keine Clock-Phase.

---

## 6. Abnahme-Kriterien

- [ ] Default ohne Setting-Änderung: Verhalten wie vor dem Feature (Uhr bis ~8 h, dann Blank).  
- [ ] Setting „Aus (0)“: nach Display-off **kein** Uhr-Overlay, Display dunkel.  
- [ ] Setting z. B. 5 min: Uhr ~5 min sichtbar, danach dunkel; Touch weckt.  
- [x] Setting erscheint unter Display-off, User-Level, nicht auf WASM.  
- [ ] Manuelles Display-aus (StatusBar) respektiert dieselbe Duration.  
- [x] DE-Strings verständlich; Overrides gepflegt falls nötig.  
- [ ] ScreenBlanker-Unit-Test grün für Duration 0 und > 0.

### Verifikation Task 4 (2026-08-16)

| Kriterium | Methode | Ergebnis |
|-----------|---------|----------|
| Default 8 h | Code-Review: `m_standbyClockDurationMs = 28800000`, Binding invalid → 28800000 | Laufzeit/GX-Smoke offen |
| Setting 0 | Code-Review + `test_standby_clock_duration()` vorhanden | Unit-Test blockiert (Qt6Mqtt); GX-Smoke offen |
| Setting 5 min | — | GX-Smoke offen (manuell) |
| Setting-UI | Code-Review `PageSettingsDisplayAndAppearance.qml` | ✓ abgehakt |
| Manuelles Display-aus | Code-Review: `StatusBar` → `ScreenBlanker.setDisplayOff()` | Laufzeit offen |
| DE-Strings | `translation-overrides.json`, `venus-gui-v2_de.ts` | ✓ abgehakt |
| Unit-Test | Desktop-Build `cmake -B build-desktop` | Blockiert: Qt6Mqtt fehlt in gcc_64 |
| GX-Compile | Incremental `cmake --build …/build-gx --target venus-gui-v2` | ✓ Exit 0 |
| GX-Smoke | Host `100.65.95.55`: Ping fail, SSH ok | Nicht durchgeführt (interaktiv) |

---

## 7. Risiken / Fallstricke

| Risiko | Mitigation |
|--------|------------|
| Setting-Key fehlt → 0 gelesen → plötzlich kein Uhr | Binding: invalid → Default 28800 s |
| Kurzes Aufblitzen der Uhr bei 0 | `standbyClockActive` / Duration-Check vor StandbyPage |
| WASM ohne Blank-Device | Setting ohnehin `preferredVisible` aus; Property-Default harmlos |
| Verwechslung Display-off vs. Standby-Uhr | UI-Hilfetext klar: erst Idle-Zeit, dann Uhr-Dauer |

---

## 8. Später (Out of Scope v1)

- Nachtfenster (z. B. 00–06 sofort Blank).  
- Dimmen / reduzierte Uhr-Helligkeit.  
- „Unbegrenzt“ ohne 8‑h-Cap.

---

## 9. Referenzen

- `src/screenblanker.cpp` / `.h`  
- `pages/StandbyPage.qml`  
- `ApplicationContent.qml` (DisplayOff-Binding)  
- `pages/settings/PageSettingsDisplayAndAppearance.qml`  
- `pages/settings/PageSettingsStatusBar.qml` (Muster Gui2-Setting)
