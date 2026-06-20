#!/bin/bash
#
# merge-main-into-vario.sh
#
# Wiederholbarer Workflow zum Integrieren von origin/main in einen Vario-Branch,
# unter Beibehaltung branch-spezifischer Features.
#
# Basiert auf:
#   - .cursor/skills/triage-main-diff/SKILL.md
#   - docs/merge/2026-05-25_merge-main-into-vario_2026.5.md
#   - docs/merge/2026-06-09_merge-main-into-v_2026.6.md
#
# Automatisiert nur mechanische Schritte — keine blinden Commits ohne Review.
#
# Verwendung:
#   ./scripts/merge-main-into-vario.sh analyze
#   ./scripts/merge-main-into-vario.sh backup
#   ./scripts/merge-main-into-vario.sh merge [--commit]
#   ./scripts/merge-main-into-vario.sh verify
#   ./scripts/merge-main-into-vario.sh doc
#   ./scripts/merge-main-into-vario.sh all    # analyze → backup → merge → verify → doc
#

set -euo pipefail

UPSTREAM="${UPSTREAM:-origin/main}"
TS_FILE="i18n/venus-gui-v2_de.ts"
OVERRIDE_JSON="i18n/translation-overrides.json"
VEUTIL_PATH="src/veutil"
TRANSLATION_SCRIPT="scripts/translation-override.py"
BUILD_SCRIPT="scripts/build-wasm.sh"

# Branch-spezifische Hotspots — bei Konflikten Vario-Features prüfen
VARIO_HOTSPOTS=(
	"components/StatusBar_Landscape.qml"
	"components/StatusBar.qml"
	"pages/PageContact.qml"
	"pages/StandbyPage.qml"
	"pages/settings/PageSettingsGeneral.qml"
	"pages/settings/PageSettingsBackupRestore.qml"
	"pages/settings/PageSettingsStatusBar.qml"
	"pages/HeatingPage.qml"
	"pages/SettingsPage.qml"
	"src/screenblanker.cpp"
	"src/screenblanker.h"
	"themes/color/ColorDesign.json"
	"cmake/ModuleVenus_Sources.cmake"
)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${BASE_DIR}"

info()  { echo -e "${CYAN}>>>${NC} $*"; }
ok()    { echo -e "${GREEN}✓${NC} $*"; }
warn()  { echo -e "${YELLOW}!${NC} $*"; }
fail()  { echo -e "${RED}✗${NC} $*" >&2; exit 1; }

usage() {
	cat <<EOF
Usage: $(basename "$0") <command> [options]

Commands:
  analyze          Fetch ${UPSTREAM}, Divergenz + Dry-Run-Konflikte anzeigen
  backup           Sicherungsbranch erstellen (aktueller Branch + Datum)
  merge            Merge starten + bekannte Konflikte auto-lösen (DE + veutil)
  verify           WASM-Build als Gate A ausführen
  doc              Merge-Doku-Template unter docs/merge/ erzeugen
  all              analyze → backup → merge (ohne --commit; verify/doc danach manuell)

Options (für merge):
  --commit         Merge-Commit automatisch erstellen (Standard: nur stagen, kein Commit)
  --no-backup      Bei 'all': keinen Backup-Branch erstellen

Environment:
  UPSTREAM         Git-Ref für Upstream (Standard: origin/main)

Beispiele:
  ./scripts/merge-main-into-vario.sh analyze
  ./scripts/merge-main-into-vario.sh backup
  ./scripts/merge-main-into-vario.sh merge
  ./scripts/merge-main-into-vario.sh merge --commit
  ./scripts/merge-main-into-vario.sh verify
  ./scripts/merge-main-into-vario.sh doc
  ./scripts/merge-main-into-vario.sh all

Nach 'merge' (ohne --commit):
  git status
  ./scripts/merge-main-into-vario.sh verify
  git commit   # manuell, wenn alles passt
EOF
}

require_git_repo() {
	git rev-parse --git-dir >/dev/null 2>&1 || fail "Kein Git-Repository."
}

require_clean_tree() {
	if ! git diff --quiet || ! git diff --cached --quiet; then
		fail "Working tree ist nicht clean. Bitte erst committen oder stashen."
	fi
	if [ -n "$(git ls-files -u 2>/dev/null)" ]; then
		fail "Merge/Rebase läuft bereits (unmerged files). Bitte erst abschließen oder 'git merge --abort'."
	fi
}

current_branch() {
	git rev-parse --abbrev-ref HEAD
}

fetch_upstream() {
	info "Fetch ${UPSTREAM}..."
	git fetch origin main --prune
	git rev-parse --verify "${UPSTREAM}" >/dev/null 2>&1 || fail "Ref '${UPSTREAM}' nicht gefunden."
	ok "Upstream: ${UPSTREAM} @ $(git rev-parse --short "${UPSTREAM}")"
}

cmd_analyze() {
	require_git_repo
	fetch_upstream

	local branch merge_base main_ahead branch_ahead
	branch="$(current_branch)"
	merge_base="$(git merge-base "${UPSTREAM}" HEAD)"
	main_ahead="$(git rev-list --count HEAD.."${UPSTREAM}")"
	branch_ahead="$(git rev-list --count "${UPSTREAM}"..HEAD)"

	echo
	echo "=== Analyse: ${branch} ← ${UPSTREAM} ==="
	echo "Branch:           ${branch} @ $(git rev-parse --short HEAD)"
	echo "Merge-Base:       $(git rev-parse --short "${merge_base}")"
	echo "Main voraus:      ${main_ahead} Commit(s)"
	echo "Branch voraus:    ${branch_ahead} Commit(s)"
	echo

	info "Neue Commits in ${UPSTREAM}:"
	git log --oneline --decorate -15 HEAD.."${UPSTREAM}" || true
	if [ "${main_ahead}" -gt 15 ]; then
		echo "... (${main_ahead} total)"
	fi
	echo

	info "Vario-Hotspots (geändert vs. ${UPSTREAM}):"
	local hotspot_found=0
	for f in "${VARIO_HOTSPOTS[@]}"; do
		if git diff --name-only "${UPSTREAM}"...HEAD | grep -qx "${f}"; then
			echo "  • ${f}"
			hotspot_found=1
		fi
	done
	if [ "${hotspot_found}" -eq 0 ]; then
		echo "  (keine Hotspot-Dateien im Branch-Diff)"
	fi
	echo

	info "Dry-Run Merge (Konflikt-Vorschau)..."
	if ! git diff --quiet || ! git diff --cached --quiet || [ -n "$(git ls-files -u 2>/dev/null)" ]; then
		warn "Working tree nicht clean — Dry-Run übersprungen."
		warn "Für Konflikt-Vorschau: Änderungen committen/stashen, dann erneut 'analyze'."
	else
		git merge --no-commit --no-ff "${UPSTREAM}" 2>&1 || true
		local conflicts
		conflicts="$(git diff --name-only --diff-filter=U 2>/dev/null || true)"

		if [ -n "${conflicts}" ]; then
			warn "Erwartete/aktuelle Konflikte:"
			echo "${conflicts}" | sed 's/^/  • /'
		else
			ok "Keine Konflikte im Dry-Run."
		fi

		git merge --abort 2>/dev/null || true
		ok "Dry-Run abgebrochen (Working tree wiederhergestellt)."
	fi

	echo
	info "Bekannte Auto-Lösungen bei merge:"
	echo "  • ${TS_FILE}  → checkout --theirs + translation-override.py apply"
	echo "  • ${VEUTIL_PATH} → Pointer von ${UPSTREAM} übernehmen"
	echo
	info "Override-JSON: ${OVERRIDE_JSON}"
	if [ -f "${OVERRIDE_JSON}" ]; then
		local count
		count="$(python3 -c "import json; d=json.load(open('${OVERRIDE_JSON}')); print(len(d.get('translations',{})))" 2>/dev/null || echo '?')"
		echo "  ${count} Override(s) registriert"
	else
		warn "  ${OVERRIDE_JSON} nicht gefunden — vor merge prüfen!"
	fi
}

cmd_backup() {
	require_git_repo
	require_clean_tree

	local branch backup_name
	branch="$(current_branch)"
	backup_name="${branch}-backup-pre-merge-$(date +%Y-%m-%d)"

	if git show-ref --verify --quiet "refs/heads/${backup_name}"; then
		fail "Backup-Branch '${backup_name}' existiert bereits."
	fi

	git branch "${backup_name}"
	ok "Backup erstellt: ${backup_name} @ $(git rev-parse --short HEAD)"
}

resolve_de_ts_conflict() {
	if git diff --name-only --diff-filter=U | grep -qx "${TS_FILE}"; then
		info "Löse Konflikt: ${TS_FILE} (main + Overrides)..."
		git checkout --theirs "${TS_FILE}"
		[ -f "${TRANSLATION_SCRIPT}" ] || fail "${TRANSLATION_SCRIPT} nicht gefunden."
		[ -f "${OVERRIDE_JSON}" ] || fail "${OVERRIDE_JSON} nicht gefunden."
		python3 "${TRANSLATION_SCRIPT}" apply -t "${TS_FILE}" -i "${OVERRIDE_JSON}"
		git add "${TS_FILE}"
		ok "${TS_FILE}: main-Basis + Overrides angewendet."
	fi
}

sync_veutil_submodule() {
	local main_veutil_sha
	main_veutil_sha="$(git ls-tree "${UPSTREAM}" "${VEUTIL_PATH}" | awk '{print $3}')"
	[ -n "${main_veutil_sha}" ] || fail "Kein ${VEUTIL_PATH} in ${UPSTREAM} gefunden."

	info "Setze ${VEUTIL_PATH} auf ${UPSTREAM} @ ${main_veutil_sha:0:7}..."
	git checkout "${main_veutil_sha}" -- "${VEUTIL_PATH}"
	git submodule update --init "${VEUTIL_PATH}"
	git add "${VEUTIL_PATH}"
	ok "${VEUTIL_PATH} synchronisiert."
}

cmd_merge() {
	local do_commit=0
	while [ $# -gt 0 ]; do
		case "$1" in
			--commit) do_commit=1; shift ;;
			*) fail "Unbekannte Option für merge: $1" ;;
		esac
	done

	require_git_repo
	require_clean_tree
	fetch_upstream

	local branch
	branch="$(current_branch)"
	info "Starte Merge: ${UPSTREAM} → ${branch}..."

	if ! git merge --no-commit --no-ff "${UPSTREAM}"; then
		warn "Merge hat Konflikte — löse bekannte Konflikte..."
	fi

	# Bekannte Auto-Lösungen
	resolve_de_ts_conflict
	sync_veutil_submodule

	# Verbleibende Konflikte?
	local remaining
	remaining="$(git diff --name-only --diff-filter=U 2>/dev/null || true)"
	if [ -n "${remaining}" ]; then
		echo
		fail "Unaufgelöste Konflikte — manuelle Bearbeitung nötig:\n${remaining}\n\nHotspot-Regeln: docs/merge/2026-05-25_merge-main-into-vario_2026.5.md"
	fi

	# Prüfe ob Vario-Hotspots durch Merge verändert wurden (nur Hinweis)
	echo
	info "Vario-Hotspot-Check (staged changes vs. HEAD):"
	local changed_hotspots=0
	for f in "${VARIO_HOTSPOTS[@]}"; do
		if git diff --cached --name-only | grep -qx "${f}"; then
			warn "  Geändert: ${f} — bitte manuell prüfen!"
			changed_hotspots=1
		fi
	done
	if [ "${changed_hotspots}" -eq 0 ]; then
		ok "  Keine Vario-Hotspots im Merge-Staging."
	fi

	echo
	if [ "${do_commit}" -eq 1 ]; then
		local msg
		msg="Merge ${UPSTREAM} into ${branch}

Integrate upstream changes while preserving Vario custom features.
Conflict resolution: ${TS_FILE} (main + overrides), ${VEUTIL_PATH} (main pointer).
Backup branch recommended before merge."
		git commit -m "${msg}"
		ok "Merge-Commit erstellt."
	else
		ok "Merge vorbereitet (gestaged). Kein Commit — bitte prüfen:"
		echo "  git status"
		echo "  ./scripts/merge-main-into-vario.sh verify"
		echo "  git commit -m \"Merge ${UPSTREAM} into ${branch}\""
	fi
}

cmd_verify() {
	require_git_repo
	[ -x "${BUILD_SCRIPT}" ] || fail "${BUILD_SCRIPT} nicht ausführbar."

	info "Gate A: WASM-Build..."
	if "${BUILD_SCRIPT}"; then
		ok "Build erfolgreich."
	else
		fail "Build fehlgeschlagen."
	fi
}

cmd_doc() {
	require_git_repo

	local branch date_str doc_path merge_base upstream_sha branch_sha main_ahead
	branch="$(current_branch)"
	date_str="$(date +%Y-%m-%d)"
	doc_path="docs/merge/${date_str}_merge-main-into-${branch}.md"

	if git rev-parse --verify "${UPSTREAM}" >/dev/null 2>&1; then
		merge_base="$(git merge-base "${UPSTREAM}" HEAD 2>/dev/null || echo 'unknown')"
		upstream_sha="$(git rev-parse --short "${UPSTREAM}")"
		main_ahead="$(git rev-list --count HEAD.."${UPSTREAM}" 2>/dev/null || echo '?')"
	else
		merge_base="unknown"
		upstream_sha="unknown"
		main_ahead="?"
	fi
	branch_sha="$(git rev-parse --short HEAD)"

	mkdir -p docs/merge

	cat > "${doc_path}" <<EOF
# Merge-Dokumentation: ${UPSTREAM} → ${branch}

**Datum:** ${date_str}
**Branch:** \`${branch}\`
**Sicherungsbranch:** \`${branch}-backup-pre-merge-${date_str}\`

---

## 1. Ausgangslage

| Parameter | Wert |
|-----------|------|
| Merge-Base | \`${merge_base}\` |
| ${UPSTREAM} HEAD | \`${upstream_sha}\` |
| ${branch} HEAD | \`${branch_sha}\` |
| Commits in main (nicht in Branch) | ${main_ahead} |

---

## 2. Konflikte — Übersicht

| # | Datei | Lösung |
|---|-------|--------|
| 1 | \`${TS_FILE}\` | main als Basis + \`translation-override.py apply\` |
| — | \`${VEUTIL_PATH}\` (Submodule) | Pointer von ${UPSTREAM} |

---

## 3. Vario-Features — Verifikation

- [ ] StatusBar: Logo, Temperatur, Uhr, Schalter-Text
- [ ] ScreenBlanker: Uhr antippen → Standby mit Uhr/Datum
- [ ] ScreenBlanker: Auto-Timeout nach DisplayOff-Einstellung
- [ ] PageContact erreichbar (Logo-Klick)
- [ ] Backup & Restore in Settings
- [ ] Tank-Farben korrekt (\`#7C7267\`, \`#D2AA6D\`)
- [ ] Settings → Heating & Climate (falls aktiv)

---

## 4. Gates

| Gate | Ergebnis |
|------|----------|
| Build (WASM) | ⬜ |
| Konflikte | ⬜ |
| Vario-Regression (GX) | ⬜ |

---

## 5. Notizen

<!-- Konflikt-Details, unerwartete Änderungen, manuelle Eingriffe -->

EOF

	ok "Doku-Template: ${doc_path}"
}

cmd_all() {
	local no_backup=0
	while [ $# -gt 0 ]; do
		case "$1" in
			--no-backup) no_backup=1; shift ;;
			*) fail "Unbekannte Option für all: $1" ;;
		esac
	done

	cmd_analyze
	echo
	if [ "${no_backup}" -eq 0 ]; then
		cmd_backup
		echo
	fi
	cmd_merge
	echo
	warn "'all' führt keinen Commit aus. Nach Review:"
	echo "  ./scripts/merge-main-into-vario.sh verify"
	echo "  ./scripts/merge-main-into-vario.sh doc"
}

# --- main ---

COMMAND="${1:-}"
shift || true

case "${COMMAND}" in
	analyze) cmd_analyze "$@" ;;
	backup)  cmd_backup "$@" ;;
	merge)   cmd_merge "$@" ;;
	verify)  cmd_verify "$@" ;;
	doc)     cmd_doc "$@" ;;
	all)     cmd_all "$@" ;;
	-h|--help|help|"")
		usage
		;;
	*)
		fail "Unbekannter Befehl: ${COMMAND}\n\n$(usage)"
		;;
esac
