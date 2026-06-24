---
name: occ-wissensspeicher
description: Pflegt den OpenCamperCore-Wissensspeicher — dokumentiert Features, Deploys, Bugfixes und aktualisiert docs/occ/00-wissensspeicher.md.
---

## Zweck

Reproduzierbarer Workflow, damit **jede OCC-relevante Arbeit** dokumentiert wird und im Wissensspeicher auffindbar bleibt.

## Wann benutzen?

- Implementierung, Deploy oder Bugfix an Heating/Climate, `dbus-mqtt-occ`, OCC-QML
- User fordert Dokumentation oder „Wissensspeicher“
- Vor Abschluss einer größeren Aufgabe im Fork `v_2026.6.2` / OCC-Bereich

## Ablauf

### 1. Index lesen

`docs/occ/00-wissensspeicher.md` — Quick Facts, bestehende Logs, Fallstricke.

### 2. Log anlegen oder erweitern

| Art | Datei |
|-----|-------|
| Feature / Implementierung | `docs/occ/NN-implementierung-YYYY-MM-DD.md` |
| Design / Spezifikation | `docs/occ/NN-<thema>.md` |
| Merge / Triage | `docs/merge/` oder `docs/triage/` |

Log-Inhalt mindestens:

- Zusammenfassung (1 Absatz)
- Commits (Hash + Message)
- Geänderte Dateien (Tabelle)
- Deploy (Befehle, Host, Verifikation)
- Probleme + Fixes
- Offene Punkte / Abnahme-Status

### 3. Index aktualisieren

In `docs/occ/00-wissensspeicher.md`:

- Zeile im **Dokumenten-Index**
- Eintrag im **Ereignislog**
- Neue **Fallstricke** falls relevant
- **Quick Facts** bei Host/Branch/Service-Änderung

### 4. Neben-Docs

- API/Deploy-Änderung → `services/dbus-mqtt-occ/README.md`
- Design umgesetzt → Abnahme-Kriterien in Design-Doc abhaken

## Checkliste (Abschluss)

- [ ] Log-Datei geschrieben/aktualisiert
- [ ] `00-wissensspeicher.md` Ereignislog + Index
- [ ] Fallstricke ergänzt (wenn neuer Lerneffekt)
- [ ] Service-README (wenn Backend betroffen)

Ohne diese Schritte gilt die Aufgabe als **nicht dokumentiert abgeschlossen**.
