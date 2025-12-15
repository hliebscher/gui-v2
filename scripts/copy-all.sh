#!/bin/bash

# This script copies GUIv2 files for both GX device and WebAssembly
# It calls copy-gx.sh and copy-wasm.sh with the same parameters

# Save all arguments
ALL_ARGS=("$@")

# Parse command-line arguments for help
while [[ $# -gt 0 ]]; do
    case "${1}" in
        -h|--help)
            echo "Usage: ${0} [options]"
            echo "This script copies GUIv2 files for both GX device and WebAssembly."
            echo "It passes all options to both copy-gx.sh and copy-wasm.sh."
            echo ""
            echo "Options:"
            echo "  -H, --host       IP(s) or hostname(s) of the GX device for direct upload, comma separated"
            echo "                   Example:"
            echo "                       -H venus.local"
            echo "                       -H 192.168.1.10"
            echo "                       -H 192.168.1.10,192.168.1.11"
            echo "                       -H einstein,ekrano"
            echo "  -h, --help       Show this help message"
            exit 0
            ;;
    esac
    shift
done

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo "=========================================="
echo "Copying GUIv2 files for GX and WASM"
echo "=========================================="
echo

# Copy GX version
echo "=========================================="
echo "Copying GX version..."
echo "=========================================="
"${SCRIPT_DIR}/copy-gx.sh" "${ALL_ARGS[@]}"
GX_EXIT_CODE=$?

if [ $GX_EXIT_CODE -ne 0 ]; then
    echo
    echo -e "\e[31m*** GX copy failed ***\e[0m"
    exit $GX_EXIT_CODE
fi

echo
echo "=========================================="
echo "Copying WASM version..."
echo "=========================================="
"${SCRIPT_DIR}/copy-wasm.sh" "${ALL_ARGS[@]}"
WASM_EXIT_CODE=$?

if [ $WASM_EXIT_CODE -ne 0 ]; then
    echo
    echo -e "\e[31m*** WASM copy failed ***\e[0m"
    exit $WASM_EXIT_CODE
fi

echo
echo "=========================================="
echo -e "\e[32m*** All copies successful ***\e[0m"
echo "=========================================="

