#!/bin/bash

# Update the German translation file (venus-gui-v2_de.ts) with lupdate
# and normalize the location paths to match the expected "../../../" form.
#
# Usage:
#   ./scripts/update-translations-de.sh
# Optional:
#   Set LUPDATE_CMD to force a specific lupdate binary.
#
# Prerequisites:
#   - A configured build directory containing i18n/translation_sources.txt
#     (typically build-wasm/ or build/; the script will auto-detect)
#   - Qt6 lupdate available (PATH or known locations)

set -euo pipefail

# Go to repo root
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )"
cd "${BASE_DIR}"

# Find build directory (prefer build-wasm, then build, else first build-*)
BUILD_DIR=""
if [ -d "build-wasm" ]; then
    BUILD_DIR="build-wasm"
elif [ -d "build" ]; then
    BUILD_DIR="build"
else
    BUILD_DIR=$(find . -maxdepth 1 -type d -name "build-*" | head -n 1)
    if [ -z "$BUILD_DIR" ]; then
        echo "Error: No build directory found. Please run cmake first."
        exit 1
    fi
    BUILD_DIR=$(basename "$BUILD_DIR")
fi
echo "Using build directory: ${BUILD_DIR}"

# Check translation_sources.txt
if [ ! -f "${BUILD_DIR}/i18n/translation_sources.txt" ]; then
    echo "Error: ${BUILD_DIR}/i18n/translation_sources.txt not found. Run cmake in ${BUILD_DIR} first."
    exit 1
fi

# Find lupdate
if [ -z "${LUPDATE_CMD:-}" ]; then
    if command -v lupdate &> /dev/null; then
        LUPDATE_CMD="lupdate"
    else
        QT6_PATHS=(
            "/opt/venus/build-gx-hostedtoolcache/Qt/6.8.3/gcc_64/bin/lupdate"
            "$HOME/Qt/6.*/gcc_64/bin/lupdate"
            "/opt/Qt/6.*/gcc_64/bin/lupdate"
            "/usr/lib/qt6/bin/lupdate"
            "/usr/bin/lupdate-qt6"
        )
        for path in "${QT6_PATHS[@]}"; do
            for expanded_path in $path; do
                if [ -f "$expanded_path" ] && [ -x "$expanded_path" ]; then
                    LUPDATE_CMD="$expanded_path"
                    echo "Found lupdate at: $LUPDATE_CMD"
                    break 2
                fi
            done
        done
    fi
fi

if [ -z "${LUPDATE_CMD:-}" ]; then
    echo "Error: lupdate not found. Set LUPDATE_CMD or add Qt6 to PATH."
    exit 1
fi

echo "=== Updating german TS (venus-gui-v2_de.ts) ==="
"${LUPDATE_CMD}" -no-obsolete "@${BUILD_DIR}/i18n/translation_sources.txt" \
    -ts "${BASE_DIR}/i18n/venus-gui-v2_de.ts" \
    -I "${BASE_DIR}/src/veutil/inc"

echo "Normalizing location paths to ../../../..."
perl -pi -e 's@filename="\.\./@filename="../../../@g' "${BASE_DIR}/i18n/venus-gui-v2_de.ts"

echo "✓ Updated i18n/venus-gui-v2_de.ts"

