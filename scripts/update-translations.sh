#!/bin/bash

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

# Check if Qt6 lupdate is available
if ! command -v lupdate &> /dev/null; then
    echo "Error: lupdate not found. Please ensure Qt6 is in your PATH."
    echo "You may need to source the Qt environment or set QTDIR."
    exit 1
fi

echo ""
echo "=== Step 1: Extracting translation strings from source code ==="
echo "Running lupdate to extract new translation strings..."

# Run lupdate to update the TS file
lupdate -no-obsolete "@${BUILD_DIR}/i18n/translation_sources.txt" \
    -ts "${BUILD_DIR}/i18n/venus-gui-v2_en.ts" \
    -I "${BASE_DIR}/src/veutil/inc"

if [ $? -ne 0 ]; then
    echo "Error: lupdate failed"
    exit 1
fi

echo "✓ Translation strings extracted successfully"

echo ""
echo "=== Step 2: Copying updated TS file back to source directory ==="
cp "${BUILD_DIR}/i18n/venus-gui-v2_en.ts" "${BASE_DIR}/i18n/venus-gui-v2.ts"

if [ $? -ne 0 ]; then
    echo "Error: Failed to copy TS file"
    exit 1
fi

echo "✓ Updated venus-gui-v2.ts copied to i18n/"

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

