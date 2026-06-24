#!/bin/bash
# compile.sh — Compile OCC Heating Plugin for gui-v2
#
# Voraussetzungen:
#   - Qt6 SDK im PATH (lupdate, lrelease, rcc)
#   - ODER: Ausführung direkt auf dem GX-Gerät (Venus OS Large)
#
# Ergebnis: occ-heating.json (deploybar nach /data/apps/available/occ-heating/gui-v2/)

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

COMPILER="../../tools/gui-v2-plugin-compiler.py"

if [ ! -f "$COMPILER" ]; then
    # Fallback: auf GX-Gerät
    COMPILER="/opt/victronenergy/gui-v2/gui-v2-plugin-compiler.py"
fi

if [ ! -f "$COMPILER" ]; then
    echo "ERROR: gui-v2-plugin-compiler.py nicht gefunden!"
    echo "Erwartet: ../../tools/gui-v2-plugin-compiler.py"
    echo "     oder: /opt/victronenergy/gui-v2/gui-v2-plugin-compiler.py"
    exit 1
fi

echo "=== Compiling OCC Heating Plugin ==="
echo "Compiler: $COMPILER"
echo ""

python3 "$COMPILER" \
    --name occ-heating \
    --version 1.0 \
    --min-required-version v1.3 \
    --settings OccHeatingMain.qml \
    --filter-empty-sources

echo ""
echo "=== Done ==="
echo "Output: occ-heating.json"
echo ""
echo "Deploy auf GX:"
echo "  scp occ-heating.json root@<gx-ip>:/tmp/"
echo "  ssh root@<gx-ip> 'mkdir -p /data/apps/available/occ-heating/gui-v2 && mv /tmp/occ-heating.json /data/apps/available/occ-heating/gui-v2/ && ln -sf /data/apps/available/occ-heating /data/apps/enabled/occ-heating'"
echo "  ssh root@<gx-ip> 'svc -t /service/gui'"
