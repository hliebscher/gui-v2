# Final whole-branch review fixes — 2026-08-16

- C1: `/Settings/Gui2/StandbyClockDuration` auf GX `100.65.95.55` mit Default
  `28800`, Typ `i`, Min `0`, Max `28800` registriert. `GetValue` lieferte `28800`.
- C1: Native D-Bus-Initialisierung registriert das Setting bei jedem Start idempotent
  über `com.victronenergy.Settings.AddSettings`; WASM bleibt unverändert.
- I5: Mock-Wert `28800` in `data/mock/conf/setup-common.json` ergänzt.
- I2: `m_hwBlanked` wird nur noch nach erfolgreichem `writeToFile()` aktualisiert.
- I3: Das QML-Binding akzeptiert nur endliche numerische Werte, sonst gilt
  `28800000 ms`.
- M3: `StandbyPage.visible` verwendet `ScreenBlanker.standbyClockActive`.
- Spec §5.4 korrigiert und Registrierung samt manuellem Einzeiler dokumentiert.

## Verifikation

- Inkrementeller GX-Build: `cmake --build build-gx --parallel 2` — Exit 0.
- GX-Deploy: Binary und geänderte QML-Dateien nach
  `/opt/victronenergy/gui-v2` kopiert, GUI-Service neu gestartet.
- GX nach Neustart: `GetValue` → `28800`; `/service/start-gui` → `up`.
- IDE-Lints der geänderten C++-/QML-Dateien: keine Fehler.
- `git diff --check`: Exit 0.
- Desktop-ScreenBlanker-Test nicht ausführbar: `build-desktop` ist nicht
  konfiguriert (`Makefile: No such file or directory`).
