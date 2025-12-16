#!/bin/bash

# This script is used to update the translations for the GUIv2.
# It is used to extract the translation strings from the source code
# and update the venus-gui-v2.ts file with the new strings.
# It also optionally downloads the updated translations for all languages from POEditor.
# It is typically called from the GitHub action, via the cmake build system, and only running on tagged releases.
#
# you find more information in the readme.md file.

# example usage: cmake /path/to/CMakeLists.txt; make update_translations
# example usage: update_translations.sh
# This script updates all translations:
# 1. Extracts new translation strings from source code using lupdate
# 2. Updates venus-gui-v2.ts with new strings
# 3. Optionally downloads updated translations for all languages from POEditor

# Go to the parent directory of the script
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )"
cd "${BASE_DIR}"
echo "Changed to parent directory: $(pwd)"

# Find build directory (prefer build-wasm, otherwise use first build-* directory)
BUILD_DIR=""
if [ -d "build-wasm" ]; then
    BUILD_DIR="build-wasm"
elif [ -d "build" ]; then
    BUILD_DIR="build"
else
    # Find first build-* directory
    BUILD_DIR=$(find . -maxdepth 1 -type d -name "build-*" | head -n 1)
    if [ -z "$BUILD_DIR" ]; then
        echo "Error: No build directory found. Please run cmake first."
        exit 1
    fi
    BUILD_DIR=$(basename "$BUILD_DIR")
fi

echo "Using build directory: ${BUILD_DIR}"

# Check if build directory exists and has been configured
if [ ! -f "${BUILD_DIR}/i18n/translation_sources.txt" ]; then
    echo "Error: Build directory not configured. Please run cmake first:"
    echo "  cd ${BUILD_DIR}"
    echo "  cmake .."
    exit 1
fi

# Find lupdate - check PATH first, then common Qt6 locations
LUPDATE_CMD=""
if command -v lupdate &> /dev/null; then
    LUPDATE_CMD="lupdate"
else
    # Try to find lupdate in common Qt6 installation paths
    QT6_PATHS=(
        "/opt/venus/build-gx-hostedtoolcache/Qt/6.8.3/gcc_64/bin/lupdate"
        "$HOME/Qt/6.*/gcc_64/bin/lupdate"
        "/opt/Qt/6.*/gcc_64/bin/lupdate"
        "/usr/lib/qt6/bin/lupdate"
        "/usr/bin/lupdate-qt6"
    )
    
    for path in "${QT6_PATHS[@]}"; do
        # Expand glob patterns
        for expanded_path in $path; do
            if [ -f "$expanded_path" ] && [ -x "$expanded_path" ]; then
                LUPDATE_CMD="$expanded_path"
                echo "Found lupdate at: $LUPDATE_CMD"
                break 2
            fi
        done
    done
    
    if [ -z "$LUPDATE_CMD" ]; then
        echo "Error: lupdate not found. Please ensure Qt6 is installed."
        echo "You can either:"
        echo "  1. Add Qt6 bin directory to your PATH"
        echo "  2. Set QTDIR environment variable"
        echo "  3. Install Qt6 tools: sudo apt install qt6-tools-dev"
        exit 1
    fi
fi

echo ""
echo "=== Step 1: Extracting translation strings from source code ==="
echo "Running lupdate to extract new translation strings..."

# Run lupdate to update the TS file
# Note: write directly to the source TS to keep relative paths correct (../pages, ../components, ...)
"${LUPDATE_CMD}" -no-obsolete "@${BUILD_DIR}/i18n/translation_sources.txt" \
    -ts "${BASE_DIR}/i18n/venus-gui-v2.ts" \
    -I "${BASE_DIR}/src/veutil/inc"

if [ $? -ne 0 ]; then
    echo "Error: lupdate failed"
    exit 1
fi

# Normalize location paths to the previous form (../../../...)
perl -pi -e 's@filename="\.\./@filename="../../../@g' "${BASE_DIR}/i18n/venus-gui-v2.ts"

echo "✓ Translation strings extracted successfully"

echo ""
echo "=== Step 2: TS updated in-place at i18n/venus-gui-v2.ts ==="

# Check if POEDITOR_TOKEN is set for downloading translations
if [ -n "${POEDITOR_TOKEN}" ]; then
    echo ""
    echo "=== Step 3: Downloading updated translations from POEditor ==="
    echo "POEDITOR_TOKEN is set, downloading translations for all languages..."
    
    cd "${BUILD_DIR}"
    if [ -f "Makefile" ]; then
        make download_translations
        if [ $? -eq 0 ]; then
            echo "✓ Translations downloaded from POEditor"
        else
            echo "Warning: Failed to download translations from POEditor"
        fi
    else
        echo "Warning: Makefile not found in build directory. Skipping POEditor download."
        echo "You can manually download translations with:"
        echo "  cd ${BUILD_DIR}"
        echo "  cmake .."
        echo "  POEDITOR_TOKEN='...' make download_translations"
    fi
    cd "${BASE_DIR}"
else
    echo ""
    echo "=== Step 3: Skipping POEditor download ==="
    echo "POEDITOR_TOKEN not set. To download updated translations, run:"
    echo "  POEDITOR_TOKEN='...' $0"
fi

echo ""
echo "=== Translation update complete ==="
echo "Updated files:"
echo "  - i18n/venus-gui-v2.ts (source strings)"
if [ -n "${POEDITOR_TOKEN}" ]; then
    echo "  - i18n/venus-gui-v2_*.ts (translated files)"
fi

