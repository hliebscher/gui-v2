# Standby-Uhr Blank-Timeout Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Konfigurierbare Dauer der Standby-Uhr nach Idle; danach Hardware-Blank (Victron-Original). Default bleibt 8 h.

**Architecture:** `ScreenBlanker` bekommt eine konfigurierbare `standbyClockDuration` (ms) statt der hardcodierten 8‑h-Gnadenfrist sowie `standbyClockActive` für die UI. `ApplicationContent` bindet `/Settings/Gui2/StandbyClockDuration` (Sekunden). Setting-UI unter Display-off in `PageSettingsDisplayAndAppearance.qml`. `StandbyPage`-Loader nur bei aktiver Uhr-Phase.

**Tech Stack:** Qt/QML (gui-v2), C++ `ScreenBlanker` Singleton, VeQuickItem/D-Bus Settings, QtTest (`tests/screenblanker`), DE via `i18n/translation-overrides.json`.

## Global Constraints

- Default ohne/invalid Setting: **28800 s / 28800000 ms** (8 h), Verhalten wie bisher.
- Setting-Wert **0** = keine Uhr, sofort Hardware-Blank.
- D-Bus-Pfad: `/Settings/Gui2/StandbyClockDuration` (Sekunden, Integer).
- Setting nur GX sichtbar (`preferredVisible: Qt.platform.os != "wasm"`).
- Access: `VenusOS.User_AccessType_User`.
- Kein Nachtfenster in v1.
- Branch: `feature/standby-clock-blank-timeout`.
- Spec: `docs/superpowers/specs/2026-08-16-standby-clock-blank-timeout-design.md`.

## File Map

| File | Responsibility |
|------|----------------|
| `src/screenblanker.h` / `.cpp` | Duration-Property, `standbyClockActive`, Timer-Logik |
| `ApplicationContent.qml` | Setting-Binding; Loader nur bei `standbyClockActive` |
| `pages/settings/PageSettingsDisplayAndAppearance.qml` | Radio-Group Setting |
| `pages/StandbyPage.qml` | optional: `visible` härten (Loader reicht meist) |
| `tests/screenblanker/tst_screenblanker.qml` | Duration 0 / >0 Tests |
| `i18n/translation-overrides.json` | DE-Strings für neues Setting |

---

### Task 1: ScreenBlanker — Duration + standbyClockActive (TDD)

**Files:**
- Modify: `src/screenblanker.h`
- Modify: `src/screenblanker.cpp`
- Modify: `tests/screenblanker/tst_screenblanker.qml`

**Interfaces:**
- Produces:
  - `Q_PROPERTY(int standbyClockDuration READ standbyClockDuration WRITE setStandbyClockDuration NOTIFY standbyClockDurationChanged FINAL)` — **Millisekunden**
  - `Q_PROPERTY(bool standbyClockActive READ standbyClockActive NOTIFY standbyClockActiveChanged FINAL)` — `true` nur in Uhr-Phase (blanked, HW noch nicht blank, duration > 0)
  - Default `standbyClockDuration` = `28800000`

- [ ] **Step 1: Extend unit test with failing cases for duration**

Am Ende von `test_blanker()` (oder neue `test_standby_clock_duration()`), **nach** dem bestehenden Flow, ergänzen:

```qml
function test_standby_clock_duration() {
	if (!blanker.supported) {
		return
	}

	// Default / restore
	blanker.enabled = true
	blanker.standbyClockDuration = 28800000
	blanker.setDisplayOn()
	compare(blanker.blanked, false)
	compare(blanker.standbyClockActive, false)

	// Duration 0 → sofort blanked, keine Clock-Phase
	blanker.standbyClockDuration = 0
	blanker.setDisplayOff()
	compare(blanker.blanked, true)
	compare(blanker.standbyClockActive, false)

	blanker.setDisplayOn()
	compare(blanker.blanked, false)

	// Duration 200 ms → zuerst Clock-Phase, dann Ende der Phase
	blanker.standbyClockDuration = 200
	blanker.setDisplayOff()
	compare(blanker.blanked, true)
	compare(blanker.standbyClockActive, true)
	tryCompare(blanker, "standbyClockActive", false, 500)
	compare(blanker.blanked, true)

	blanker.setDisplayOn()
	blanker.standbyClockDuration = 28800000
}
```

- [ ] **Step 2: Run test — expect FAIL (property missing)**

```bash
# Aus Repo-Root, Desktop/Unit-Test-Build wie üblich für gui-v2 Tests:
# Falls CTest-Target existiert:
ctest --test-dir build-desktop -R screenblanker --output-on-failure
# Alternativ das vorhandene Single-File-Test-Binary starten, z.B.:
# ./build-desktop/tests/screenblanker/tst_screenblanker
```

Expected: FAIL — `standbyClockDuration` / `standbyClockActive` unknown property (oder Compile-Fehler im QML-Test).

- [ ] **Step 3: Implement properties + logic in ScreenBlanker**

In `screenblanker.h`:

- Property `standbyClockDuration` (int, ms) + getter/setter + notify.
- Property `standbyClockActive` (bool, read-only) + notify.
- Member `int m_standbyClockDurationMs = 28800000;` statt `const int m_finalDisplayOffDelayMs`.
- Private helper optional: `void updateStandbyClockActive();` oder inline in `setBlanked`.

In `screenblanker.cpp`:

```cpp
bool ScreenBlanker::standbyClockActive() const
{
	return m_blanked && !m_hwBlanked && m_standbyClockDurationMs > 0;
}

int ScreenBlanker::standbyClockDuration() const
{
	return m_standbyClockDurationMs;
}

void ScreenBlanker::setStandbyClockDuration(int timeMs)
{
	if (timeMs < 0 || timeMs == m_standbyClockDurationMs) {
		return;
	}
	m_standbyClockDurationMs = timeMs;
	// Wenn bereits in Clock-Phase: Timer neu setzen
	if (m_blanked && !m_hwBlanked) {
		m_finalOffTimer.stop();
		if (m_standbyClockDurationMs == 0) {
			setBlanked(true, true);
		} else {
			m_finalOffTimer.start(m_standbyClockDurationMs);
		}
	}
	emit standbyClockDurationChanged();
	emit standbyClockActiveChanged(); // falls sichtbarkeitsrelevant
}

void ScreenBlanker::setDisplayOff()
{
	if (!m_enabled) {
		return;
	}
	m_blankingTimer.stop();
	if (m_standbyClockDurationMs == 0) {
		setBlanked(true, true);
		m_finalOffTimer.stop();
	} else {
		setBlanked(true, false);
		m_finalOffTimer.start(m_standbyClockDurationMs);
	}
}
```

In `setBlanked`: nach Zustandswechsel `emit standbyClockActiveChanged()` wenn sich `standbyClockActive()` gegenüber vorherigem Wert geändert hat (vorherigen bool cachen oder vor/nach vergleichen).

Constructor: `m_finalOffTimer`-Connect unverändert (`setBlanked(true, true)`).

- [ ] **Step 4: Re-run screenblanker tests — expect PASS**

Same command as Step 2. Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add src/screenblanker.h src/screenblanker.cpp tests/screenblanker/tst_screenblanker.qml
git commit -m "$(cat <<'EOF'
feat(screenblanker): konfigurierbare Standby-Uhr-Dauer vor Hardware-Blank

Ersetzt die hardcodierte 8h-Gnadenfrist durch standbyClockDuration (Default 8h)
und exponiert standbyClockActive für die UI.
EOF
)"
```

---

### Task 2: Setting-Binding + StandbyPage-Loader

**Files:**
- Modify: `ApplicationContent.qml`

**Interfaces:**
- Consumes: `ScreenBlanker.standbyClockDuration` (ms), `ScreenBlanker.standbyClockActive`
- Produces: Binding von `/Settings/Gui2/StandbyClockDuration` (Sekunden → ×1000); invalid → 28800000

- [ ] **Step 1: Update Loader + VeQuickItem binding**

`standbyPageLoader.active` ändern:

```qml
active: ScreenBlanker.supported && ScreenBlanker.standbyClockActive
```

Im `QtObject { id: screenBlanker }` ergänzen:

```qml
property VeQuickItem standbyClockDurationItem: VeQuickItem {
	uid: !!Global.systemSettings
		? Global.systemSettings.serviceUid + "/Settings/Gui2/StandbyClockDuration"
		: ""
}
```

In `Component.onCompleted` Binding hinzufügen (neben displayOffTime):

```qml
ScreenBlanker.standbyClockDuration = Qt.binding(function() {
	return screenBlanker.standbyClockDurationItem.valid
		? 1000 * screenBlanker.standbyClockDurationItem.value
		: 28800000
})
```

Wichtig: bei `valid === false` **nicht** 0 verwenden (sonst sofort Blank).

- [ ] **Step 2: Smoke-check (optional Desktop/Mock)**

App starten oder QML-Syntax prüfen. Expected: keine Bindings-Fehler; ohne Setting-Key Default 8 h.

- [ ] **Step 3: Commit**

```bash
git add ApplicationContent.qml
git commit -m "$(cat <<'EOF'
feat(gui): StandbyClockDuration aus Settings binden und Loader steuern

StandbyPage nur während standbyClockActive; invalid Setting → 8h Default.
EOF
)"
```

---

### Task 3: Settings-UI + i18n

**Files:**
- Modify: `pages/settings/PageSettingsDisplayAndAppearance.qml` (nach dem Display-off-`ListRadioButtonGroup`, ca. Zeile 55)
- Modify: `i18n/translation-overrides.json`

**Interfaces:**
- Consumes: D-Bus `/Settings/Gui2/StandbyClockDuration`
- Produces: User-wählbare Stufen 0, 60, 300, 900, 1800, 3600, 28800

- [ ] **Step 1: Add ListRadioButtonGroup**

Direkt unter dem bestehenden Display-off-Block einfügen:

```qml
ListRadioButtonGroup {
	//% "Standby clock"
	text: qsTrId("settings_standby_clock_duration")
	dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Gui2/StandbyClockDuration"
	writeAccessLevel: VenusOS.User_AccessType_User
	optionModel: [
		//% "Off (blank immediately)"
		{ display: qsTrId("settings_standby_clock_off"), value: 0 },
		//% "1 min"
		{ display: qsTrId("settings_standby_clock_1min"), value: 60 },
		//% "5 min"
		{ display: qsTrId("settings_standby_clock_5min"), value: 300 },
		//% "15 min"
		{ display: qsTrId("settings_standby_clock_15min"), value: 900 },
		//% "30 min"
		{ display: qsTrId("settings_standby_clock_30min"), value: 1800 },
		//% "1 hour"
		{ display: qsTrId("settings_standby_clock_1hour"), value: 3600 },
		//% "8 hours"
		{ display: qsTrId("settings_standby_clock_8hours"), value: 28800 },
	]
	preferredVisible: Qt.platform.os != "wasm"
}
```

- [ ] **Step 2: DE Overrides**

In `i18n/translation-overrides.json` unter `translations` ergänzen:

```json
"settings_standby_clock_duration": "Standby-Uhr",
"settings_standby_clock_off": "Aus (sofort dunkel)",
"settings_standby_clock_1min": "1 Min.",
"settings_standby_clock_5min": "5 Min.",
"settings_standby_clock_15min": "15 Min.",
"settings_standby_clock_30min": "30 Min.",
"settings_standby_clock_1hour": "1 Std.",
"settings_standby_clock_8hours": "8 Std."
```

Dann Overrides anwenden:

```bash
python3 scripts/translation-override.py apply -t i18n/venus-gui-v2_de.ts -i i18n/translation-overrides.json
```

- [ ] **Step 3: Manual UI check on GX (or note for later)**

Settings → Display & appearance → „Standby-Uhr“ sichtbar; Wert speichern; Idle testen.

- [ ] **Step 4: Commit**

```bash
git add pages/settings/PageSettingsDisplayAndAppearance.qml i18n/translation-overrides.json i18n/venus-gui-v2_de.ts
git commit -m "$(cat <<'EOF'
feat(settings): Standby-Uhr-Dauer unter Display-off konfigurierbar

Gui2/StandbyClockDuration inkl. DE-Overrides; Default-Option 8 Std.
EOF
)"
```

---

### Task 4: Verifikation + Spec-Abnahme abhaken

**Files:**
- Modify: `docs/superpowers/specs/2026-08-16-standby-clock-blank-timeout-design.md` (Abnahme-Checkboxen)
- Optional: kurzer Eintrag in Merge-/Feature-Notiz nur wenn gewünscht — **nicht** nötig für OCC

- [ ] **Step 1: Run screenblanker unit tests again**

Same as Task 1 Step 4. Expected: PASS.

- [ ] **Step 2: GX smoke (wenn Gerät erreichbar)**

```bash
./scripts/build-all.sh -H <gx-ip>
```

Checks:
1. Ohne Setting-Änderung / Wert 28800: Uhr lange an (wie bisher).
2. Wert 0: nach Display-off sofort dunkel, keine Uhr.
3. Wert 300: Uhr ~5 min, dann dunkel; Touch weckt.
4. StatusBar manuelles Display-aus: gleiche Duration.
5. Setting nicht auf WASM-Remote-Console-Pfad kritisch (preferredVisible aus).

- [ ] **Step 3: Mark acceptance criteria in spec**

Checkboxen in Abschnitt 6 der Spec auf `[x]` setzen wo verifiziert.

- [ ] **Step 4: Commit**

```bash
git add docs/superpowers/specs/2026-08-16-standby-clock-blank-timeout-design.md
git commit -m "$(cat <<'EOF'
docs: Abnahme Standby-Uhr-Blank-Timeout nach Verifikation
EOF
)"
```

---

## Spec coverage (self-review)

| Spec-Anforderung | Task |
|------------------|------|
| Konfigurierbare Uhr-Dauer → HW-Blank | 1, 2 |
| Default 8 h / invalid → 8 h | 1 Default, 2 Binding |
| Wert 0 = sofort Blank, keine Uhr | 1, 2 Loader |
| Setting unter Display-off | 3 |
| D-Bus Gui2/StandbyClockDuration | 2, 3 |
| Nur GX / User access | 3 |
| Manuelles Display-aus gleicher Pfad | 1 (`setDisplayOff`) |
| Unit-Test Duration 0 / >0 | 1 |
| Kein Nachtfenster | — (bewusst nicht) |
| i18n DE | 3 |

## Placeholder scan

Keine TBD/TODO-Schritte; konkrete Code-Blöcke und Commit-Messages vorhanden.

## Type consistency

- Setting: **Sekunden**; C++ Property: **Millisekunden** (`× 1000` nur im Binding).
- Property-Namen: `standbyClockDuration`, `standbyClockActive` durchgängig.
