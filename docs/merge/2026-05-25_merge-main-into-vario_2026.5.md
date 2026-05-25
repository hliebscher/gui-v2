# Merge-Dokumentation: origin/main → vario_2026.5

**Datum:** 2026-05-25
**Durchgeführt von:** hliebscher
**Sicherungsbranch:** `vario_2026.5-backup-pre-merge-2026-05-25`

---

## 1. Ausgangslage

| Parameter | Wert |
|-----------|------|
| Merge-Base | `e0b32672d` — "Bump version to v1.2.29" (2026-02-09) |
| origin/main HEAD | `1315aa3bd` — "Inverter: show correct state text in solar drilldowns" (2026-05-20) |
| vario_2026.5 HEAD | `b4aae1505` — "Enhance translation override script..." (2026-04-16) |
| Commits in main (nicht in vario) | 205 |
| Commits in vario (nicht in main) | 100 |

---

## 2. Konflikte — Übersicht

| # | Datei | Typ | Schwere | Lösungsstrategie |
|---|-------|-----|---------|-----------------|
| 1 | `cmake/ModuleVenus_Sources.cmake` | content | Niedrig | BEIDE: PageContact.qml + Portrait-Seiten hinzufügen |
| 2 | `components/QuantityRow.qml` | content | Mittel | MAIN: Eigene Padding-Anpassungen sind obsolet durch neues Layout-System |
| 3 | `components/SolarYieldGauge.qml` | content | Mittel | MAIN: Neues Timer-basiertes Sampling-System übernehmen |
| 4 | `components/StatusBar.qml` | content | **HOCH** | VARIO: Gesamte eigene StatusBar (Logo, Temperatur, Uhr, Kontakt) beibehalten, Portrait-Wrapper aus main integrieren |
| 5 | `components/TankItem.qml` | modify/delete | Niedrig | MAIN: Datei wurde gelöscht (in ListItem-Refactoring aufgegangen), eigene Änderungen prüfen |
| 6 | `i18n/venus-gui-v2_de.ts` | content | **HOCH** | VARIO: Eigene DE-Übersetzungen haben immer Vorrang, neue main-Einträge hinzufügen |
| 7 | `pages/settings/PageSettingsGeneral.qml` | content | Mittel | MANUELL: Eigenes Backup&Restore behalten + neues Support-Status-Layout aus main |
| 8 | `src/screenblanker.cpp` | content | Mittel | MANUELL: Eigene setBlanked(bool, bool) Signatur + main's neue Logik kombinieren |
| 9 | `src/veutil` (Submodule) | submodule | Mittel | MAIN: Auf cd3b9bb updaten (102 neue Commits, u.a. Units, MQTT, nlohmann/json) |
| 10 | `themes/color/ColorDesign.json` | content | Niedrig | VARIO: Eigene Farben (blackWater=#7C7267, diesel=#D2AA6D) behalten |

---

## 3. Konflikt-Detailanalyse

### 3.1 cmake/ModuleVenus_Sources.cmake (Zeile 371-376)

**VARIO fügt hinzu:** `pages/PageContact.qml`
**MAIN fügt hinzu:** `pages/OverviewPage_Landscape.qml`, `pages/OverviewPage_Portrait.qml`

**Lösung:** Alle drei Einträge übernehmen (alphabetisch sortiert):
```
    pages/OverviewPage_Landscape.qml
    pages/OverviewPage_Portrait.qml
    pages/PageContact.qml
```

**Risiko:** Keins — additive Änderung.

---

### 3.2 components/QuantityRow.qml (Zeilen 41-59)

**VARIO:** Eigenes `horizontalPadding` und `isFirstColumn` für Layout-Korrektur
**MAIN:** Komplett neues Padding-System mit `padLastColumn` und separator-basiertem leftPadding

**Lösung:** MAIN übernehmen. Die eigenen Anpassungen (30px Abzug für erste Spalte) wurden durch das neue allgemeine Layout-System von main obsolet. Falls UI-Probleme auftreten, post-merge anpassen.

**Risiko:** Mittel — visueller Regression-Check erforderlich.

---

### 3.3 components/SolarYieldGauge.qml (Zeilen 37-69)

**VARIO:** Einfacher `ValueRange` mit direktem `Global.system.solar.power`
**MAIN:** Neues Timer-basiertes Sampling (30s Samples → 5min Durchschnitt → Gauge-History)

**Lösung:** MAIN übernehmen. Das neue System ist funktional überlegen (Solar-Historie statt nur aktuellem Wert).

**Risiko:** Niedrig — rein additive Funktionalität.

---

### 3.4 components/StatusBar.qml (3 Konfliktzonen)

**VARIO enthält umfangreiche eigene Implementierung:**
- Logo (Victron SVG) mit Klick → PageContact
- Temperatur-Anzeige (konfigurierbarer Sensor-Index via VeQuickItem)
- Uhr mit ScreenBlanker-Klick-Funktion
- WiFi/GSM-Icons
- StatusBarButton-Komponente mit einheitlichen Icon-Größen
- NotificationButton, AlarmButton, SleepButton
- Breadcrumbs mit Key-Navigation
- backgroundColor-Property, animationEnabled

**MAIN hat grundlegenden Architekturwechsel:**
- StatusBar.qml ist jetzt nur ein Loader/Wrapper
- Eigentliche Implementierung in `StatusBar_Landscape.qml` und `StatusBar_Portrait.qml`
- Signale: controlCardsActivated, auxCardsActivated, cardsDeactivated, sidePanelToggled

**Lösung:** KOMPLEXESTE ENTSCHEIDUNG — Zwei Optionen:

**Option A (empfohlen):** Eigene StatusBar-Logik in `StatusBar_Landscape.qml` integrieren:
1. Main's Wrapper-Struktur (Loader + Landscape/Portrait) übernehmen
2. Eigene Features (Logo, Temperatur, Uhr, Kontakt) in `StatusBar_Landscape.qml` einbauen
3. Portrait-Variante vorerst ohne eigene Features (Basis-Funktionalität)

**Option B:** Eigene StatusBar komplett behalten, Portrait-Support ignorieren
→ Nicht empfohlen, da Portrait ein Major-Feature von main ist.

**Risiko:** HOCH — erfordert sorgfältige manuelle Integration.

---

### 3.5 components/TankItem.qml (modify/delete)

**VARIO:** Leichte Modifikation (5 Zeilen hinzugefügt, 3 geändert)
**MAIN:** Datei komplett gelöscht (Teil des ListItem-Refactorings)

**Lösung:** MAIN folgen und Datei löschen. Die TankItem-Funktionalität ist in das neue ListItem-System migriert. Eigene Änderungen (vermutlich Layout-Tweaks) sind durch das neue System obsolet.

**Risiko:** Niedrig — prüfen ob eigene Änderungen semantisch relevant waren.

---

### 3.6 i18n/venus-gui-v2_de.ts (~180 Konfliktzonen)

**VARIO:** Umfangreiche deutsche Übersetzungen (manuell verbessert, finalisiert)
**MAIN:** Automatische Translation-Updates (faberd/update-translations)

**Lösung:** Für jede Konfliktstelle gilt:
- Wenn VARIO eine **fertige deutsche Übersetzung** hat → VARIO behalten
- Wenn MAIN einen **neuen Translation-Key** einführt (der in VARIO fehlt) → MAIN hinzufügen
- Wenn beide den gleichen Key mit unterschiedlichem `<translation>` haben → VARIO (manuell geprüft)

**Strategie:** `git checkout --ours i18n/venus-gui-v2_de.ts` als Basis, dann neue Keys aus main selektiv hinzufügen via Script.

**Risiko:** Mittel — neue Features könnten unübersetzt bleiben, aber das ist akzeptabel (Fallback auf Englisch).

---

### 3.7 pages/settings/PageSettingsGeneral.qml (Zeile 243-260)

**VARIO:** 
- "Backup & Restore" Navigation (eigener Text + Link zu PageSettingsBackupRestore.qml)
- "Support status (modifications checks)" mit supportStateText()/supportStateColor()

**MAIN:**
- Neues `id: supportStatus` mit Layout-Component (`contentItem: Item`)
- Vereinfachter Text: "Support status" statt "Support status (modifications checks)"

**Lösung:** MANUELL kombinieren:
1. Eigene "Backup & Restore" ListNavigation behalten (da PageSettingsBackupRestore.qml Vario-spezifisch ist)
2. Main's neues Support-Status-Layout übernehmen (strukturell besser)
3. Eigenen erweiterten Text beibehalten wenn gewünscht

**Risiko:** Niedrig — isolierte Settings-Seite.

---

### 3.8 src/screenblanker.cpp (2 Konfliktzonen)

**Konflikt 1 (Zeile 28-32):**
- VARIO: `m_hwBlanked = m_blanked;` (zusätzliche Hardware-Tracking-Variable)
- MAIN: Nichts (Variable existiert dort nicht)

**Konflikt 2 (Zeile 181-198):**
- VARIO: `setBlanked(bool blanked, bool applyHardware)` — 2-Parameter-Signatur mit Gnaden-Frist-Timer
- MAIN: `setBlanked(bool blanked)` — 1-Parameter mit Desktop-Build-Guard und neuer `blanked()` const getter

**Lösung:** MANUELL kombinieren:
1. VARIO's `m_hwBlanked` und 2-Parameter-Signatur behalten (eigene Hardware-Logik)
2. MAIN's `blanked()` const getter hinzufügen
3. Desktop-Build-Guard (`#if defined(VENUS_DESKTOP_BUILD)`) aus main übernehmen
4. Eigene Timer-Logik (`m_finalOffTimer`) beibehalten

**Risiko:** Mittel — screenblanker.h muss konsistent sein.

---

### 3.9 src/veutil (Submodule)

**VARIO:** `175ba578` — "Units: add kilometre, miles and nautical miles to units"
**MAIN:** `cd3b9bb9` — "Models: add VeQItemSortTableModel::filterExcludedValue" (102 Commits neuer)

**Lösung:** Auf MAIN's Version updaten (`cd3b9bb9`). Die 102 neuen Commits enthalten:
- nlohmann/json Integration
- MQTT-Verbesserungen  
- Units-Erweiterungen (Rotation, km, Meilen)
- Model-Verbesserungen

VARIO's Version ist ein Vorfahre von MAIN's Version (linear, kein Divergenz).

**Risiko:** Niedrig — rein vorwärts-kompatibel.

---

### 3.10 themes/color/ColorDesign.json (Zeile 30-36)

**VARIO:** `color_blackWater: "#7C7267"`, `color_diesel: "#D2AA6D"` (natürliche Braun/Beige-Töne)
**MAIN:** `color_blackWater: "#A277FF"`, `color_diesel: "#FFFE76"` (Lila/Gelb — neue Farbpalette)

**Lösung:** VARIO behalten. Die eigenen Farben sind bewusst gewählt (realistische Tank-Farben für Vario-Kunden).

**Risiko:** Keins — rein visuell, isoliert.

---

## 4. Dateien ohne Konflikt (automatisch gemergt)

Folgende Dateien wurden automatisch und korrekt gemergt:
- `ApplicationContent.qml`
- `components/BriefCenterDisplay.qml`
- `components/CircularMultiGauge.qml`
- `components/QuantityLabel.qml`
- `components/widgets/InverterChargerWidget.qml`
- `data/mock/conf/setup-common.json`
- `src/enums.h`
- `src/screenblanker.h`

---

## 5. Merge-Reihenfolge (empfohlen)

1. ✅ Sicherungsbranch erstellt
2. ⬜ veutil Submodule updaten
3. ⬜ Einfache Konflikte lösen (cmake, ColorDesign, TankItem)
4. ⬜ Mittlere Konflikte lösen (QuantityRow, SolarYieldGauge, screenblanker.cpp, PageSettingsGeneral)
5. ⬜ Komplexe Konflikte lösen (StatusBar.qml, venus-gui-v2_de.ts)
6. ⬜ Build-Test
7. ⬜ Visueller Regression-Test
8. ⬜ Commit

---

## 6. Post-Merge Prüfungen

- [ ] Build kompiliert fehlerfrei
- [ ] StatusBar zeigt Logo, Temperatur, Uhr korrekt an
- [ ] Portrait-Layout funktioniert (neues Feature aus main)
- [ ] Deutsche Übersetzungen sind vollständig
- [ ] ScreenBlanker funktioniert (Hardware + Timer)
- [ ] PageContact.qml ist erreichbar
- [ ] Neue main-Features funktionieren (Switches, Generic Inputs, GUI Plugins)
- [ ] Farben in Tank-Ansicht korrekt (eigene Palette)

---

## 7. Wiederholbarer Workflow für zukünftige Updates

```bash
# 1. Sicherung
git branch vario_2026.X-backup-pre-merge-$(date +%Y-%m-%d)

# 2. Fetch
git fetch origin

# 3. Dry-Run
git merge --no-commit --no-ff origin/main
# Konflikte prüfen, dann:
git merge --abort

# 4. Echter Merge
git merge origin/main
# Konflikte lösen gemäß Prioritätsregeln:
#   - Eigene Übersetzungen > main
#   - Eigene UI-Anpassungen (Logo, Farben, Kontakt) > main
#   - Main's Architektur-Änderungen > eigene Workarounds
#   - Submodule: immer main folgen

# 5. Build & Test
# 6. Commit & Push
```
