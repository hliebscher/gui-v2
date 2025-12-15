#!/bin/bash

# This script builds GUIv2 for both GX device and WebAssembly
# It calls build-gx.sh and build-wasm.sh with the same parameters

# Save all arguments
ALL_ARGS=("$@")

# Parse command-line arguments for help
while [[ $# -gt 0 ]]; do
    case "${1}" in
        -h|--help)
            echo "Usage: ${0} [options]"
            echo "This script builds GUIv2 for both GX device and WebAssembly."
            echo "It passes all options to both build-gx.sh and build-wasm.sh."
            echo ""
            echo "Options:"
            echo "  -P, --preserve   Do not delete build files"
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
echo "Building GUIv2 for GX and WASM"
echo "=========================================="
echo

# Build GX version
echo "=========================================="
echo "Building GX version..."
echo "=========================================="
"${SCRIPT_DIR}/build-gx.sh" "${ALL_ARGS[@]}"
GX_EXIT_CODE=$?

if [ $GX_EXIT_CODE -ne 0 ]; then
    echo
    echo -e "\e[31m*** GX build failed ***\e[0m"
    exit $GX_EXIT_CODE
fi

echo
echo "=========================================="
echo "Building WASM version..."
echo "=========================================="
"${SCRIPT_DIR}/build-wasm.sh" "${ALL_ARGS[@]}"
WASM_EXIT_CODE=$?

if [ $WASM_EXIT_CODE -ne 0 ]; then
    echo
    echo -e "\e[31m*** WASM build failed ***\e[0m"
    exit $WASM_EXIT_CODE
fi

echo
echo "=========================================="
echo -e "\e[32m*** All builds successful ***\e[0m"
echo "=========================================="

