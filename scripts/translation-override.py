#!/usr/bin/env python3
"""
Übersetzungs-Override-Script für venus-gui-v2_de.ts

Vergleicht die lokale de.ts mit der main-Branch-Version und erstellt eine JSON-Datei
mit deinen eigenen Übersetzungsänderungen. Diese JSON kann später auf jede neue de.ts
angewendet werden, um deine Übersetzungen zu erhalten.

Typischer Workflow bei neuem de.ts vom Upstream:
  1. Neue de.ts vom Upstream übernehmen (z.B. nach Merge/Rebase)
  2. python3 scripts/translation-override.py apply
  3. Deine Overrides sind wieder angewendet ✓

Verwendung:
  # Deine Änderungen vs. main extrahieren und in JSON speichern:
  python3 scripts/translation-override.py extract

  # JSON auf die aktuelle de.ts anwenden:
  python3 scripts/translation-override.py apply

  # Optional: andere JSON-Datei oder TS-Datei angeben:
  python3 scripts/translation-override.py extract -o meine-uebersetzungen.json
  python3 scripts/translation-override.py apply -i meine-uebersetzungen.json -t i18n/venus-gui-v2_de.ts
"""

import argparse
import json
import re
import subprocess
import sys
import tempfile
from pathlib import Path
from xml.etree import ElementTree as ET

# Standardpfade
SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent
DEFAULT_TS_FILE = REPO_ROOT / "i18n" / "venus-gui-v2_de.ts"
DEFAULT_JSON_FILE = REPO_ROOT / "i18n" / "translation-overrides.json"

def _default_compare_branch() -> str:
    """
    Prefer comparing against the remote-tracking branch if available.

    Note: This script uses `git show <ref>:<path>`, so both `origin/main` and `main`
    are valid refs if they exist locally.
    """
    for ref in ("origin/main", "main"):
        r = subprocess.run(
            ["git", "rev-parse", "--verify", "--quiet", ref],
            cwd=REPO_ROOT,
            capture_output=True,
            text=True,
        )
        if r.returncode == 0:
            return ref
    return "main"


def parse_ts_file(filepath: Path) -> dict[str, tuple[str, str]]:
    """
    Parst eine .ts-Datei und gibt ein Dict zurück: key -> (source, translation)
    Key ist: message id wenn vorhanden, sonst "context::source"
    """
    tree = ET.parse(filepath)
    root = tree.getroot()

    result = {}
    for context in root.findall(".//context"):
        context_name = context.find("name")
        ctx_name = context_name.text or "" if context_name is not None else ""

        for msg in context.findall("message"):
            msg_id = msg.get("id")
            source_elem = msg.find("source")
            trans_elem = msg.find("translation")

            if source_elem is None or trans_elem is None:
                continue

            source = source_elem.text or ""
            translation = trans_elem.text or ""

            # type="unfinished" oder leere Übersetzung ignorieren wir beim Extrahieren nicht,
            # aber wir speichern den unformatierten Text
            if msg_id:
                key = msg_id
            else:
                key = f"{ctx_name}::{source}" if ctx_name else source

            result[key] = (source, translation)

    return result


def get_branch_version(ts_path: Path, branch: str) -> str:
    """Holt die de.ts vom angegebenen Git-Ref (z.B. origin/main oder main)."""
    resolved = (REPO_ROOT / ts_path).resolve()
    git_path = resolved.relative_to(REPO_ROOT)
    result = subprocess.run(
        ["git", "show", f"{branch}:{git_path}"],
        cwd=REPO_ROOT,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        sys.stderr.write(
            f"Fehler: Konnte Branch-Version nicht laden. "
            f"Stelle sicher, dass der Branch '{branch}' existiert.\n{result.stderr}\n"
        )
        sys.exit(1)
    return result.stdout


def extract_overrides(ts_file: Path, json_file: Path, compare_branch: str) -> None:
    """Extrahiert Übersetzungsänderungen gegenüber dem angegebenen Ref in eine JSON-Datei."""
    if not ts_file.exists():
        sys.stderr.write(f"Fehler: {ts_file} nicht gefunden.\n")
        sys.exit(1)

    # Branch-Version holen
    main_content = get_branch_version(ts_file, compare_branch)
    with tempfile.NamedTemporaryFile(mode="w", suffix=".ts", delete=False) as f:
        f.write(main_content)
        main_path = Path(f.name)

    try:
        main_translations = parse_ts_file(main_path)
    finally:
        main_path.unlink()

    current_translations = parse_ts_file(ts_file)

    # Nur Einträge, die sich von main unterscheiden (deine Overrides)
    overrides = {}
    for key, (source, translation) in current_translations.items():
        if key not in main_translations:
            # Nur in current: neue Übersetzung
            overrides[key] = {"source": source, "translation": translation}
        else:
            main_source, main_trans = main_translations[key]
            if main_trans != translation:
                overrides[key] = {"source": source, "translation": translation}

    output = {
        "meta": {
            "description": "Externe Übersetzungs-Overrides für venus-gui-v2_de.ts",
            "compare_branch": compare_branch,
            "ts_file": str(ts_file.relative_to(REPO_ROOT)),
        },
        "translations": {k: v["translation"] for k, v in overrides.items()},
    }

    json_file.parent.mkdir(parents=True, exist_ok=True)
    with open(json_file, "w", encoding="utf-8") as f:
        json.dump(output, f, ensure_ascii=False, indent=2)

    print(f"✓ {len(overrides)} Override(s) nach {json_file} geschrieben.")


def _escape_xml_text(text: str) -> str:
    """Escaped Text für XML-Textinhalt (nur & und < müssen escaped werden)."""
    return text.replace("&", "&amp;").replace("<", "&lt;")


def apply_overrides(ts_file: Path, json_file: Path) -> None:
    """Wendet die JSON-Overrides auf die de.ts an (formatierungserhaltend)."""
    if not ts_file.exists():
        sys.stderr.write(f"Fehler: {ts_file} nicht gefunden.\n")
        sys.exit(1)
    if not json_file.exists():
        sys.stderr.write(f"Fehler: {json_file} nicht gefunden.\n")
        sys.exit(1)

    with open(json_file, encoding="utf-8") as f:
        data = json.load(f)

    overrides = data.get("translations", {})
    if not isinstance(overrides, dict):
        overrides = {}

    # Zeilenbasiert: Kontext und aktueller Key tracken, bei <translation> ersetzen
    with open(ts_file, encoding="utf-8") as f:
        lines = f.readlines()

    ctx_name = ""
    current_id = None
    current_source = None
    applied = 0
    out_lines = []

    i = 0
    while i < len(lines):
        line = lines[i]

        if "<context>" in line:
            ctx_name = ""
        elif "<name>" in line:
            match = re.search(r"<name>(.*?)</name>", line, re.DOTALL)
            if match:
                ctx_name = (match.group(1) or "").strip()
        elif "<message " in line:
            mid = re.search(r'id="([^"]+)"', line)
            current_id = mid.group(1) if mid else None
            current_source = None
        elif "<message>" in line:
            current_id = None
            current_source = None
        elif "<source>" in line:
            match = re.search(r"<source>(.*?)</source>", line, re.DOTALL)
            if match:
                current_source = (match.group(1) or "").replace("&amp;", "&").replace("&lt;", "<").replace("&gt;", ">").replace("&quot;", '"')
        elif "<translation" in line:
            key = current_id if current_id else (f"{ctx_name}::{current_source}" if ctx_name and current_source is not None else (current_source or ""))
            if key in overrides:
                new_val = overrides[key]
                # Zeile ersetzen: <translation>alt</translation> oder <translation type="unfinished">alt</translation>
                repl = re.sub(
                    r"(<translation(?:\s+[^>]*)?>).*?(</translation>)",
                    lambda m: m.group(1) + _escape_xml_text(new_val) + m.group(2),
                    line,
                    count=1,
                    flags=re.DOTALL,
                )
                # type="unfinished" entfernen
                repl = repl.replace(' type="unfinished"', "")
                line = repl
                applied += 1
        out_lines.append(line)
        i += 1

    with open(ts_file, "w", encoding="utf-8") as f:
        f.writelines(out_lines)

    print(f"✓ {applied} Override(s) auf {ts_file} angewendet.")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Übersetzungs-Overrides: extrahieren (vs. origin/main oder main) oder anwenden."
    )
    sub = parser.add_subparsers(dest="command", required=True)

    ext = sub.add_parser("extract", help="Änderungen vs. main extrahieren und in JSON speichern")
    ext.add_argument("-t", "--ts-file", type=Path, default=DEFAULT_TS_FILE, help="Pfad zur de.ts")
    ext.add_argument("-o", "--output", type=Path, default=DEFAULT_JSON_FILE, help="Ausgabe-JSON")
    ext.add_argument(
        "-b",
        "--branch",
        default=_default_compare_branch(),
        help="Vergleichs-Ref (default: origin/main falls vorhanden, sonst main)",
    )

    app = sub.add_parser("apply", help="JSON-Overrides auf de.ts anwenden")
    app.add_argument("-t", "--ts-file", type=Path, default=DEFAULT_TS_FILE, help="Pfad zur de.ts")
    app.add_argument("-i", "--input", type=Path, default=DEFAULT_JSON_FILE, help="Eingabe-JSON")

    args = parser.parse_args()

    if args.command == "extract":
        extract_overrides(args.ts_file, args.output, args.branch)
    elif args.command == "apply":
        apply_overrides(args.ts_file, args.input)


if __name__ == "__main__":
    main()
