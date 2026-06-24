#!/bin/bash
# uninstall.sh — Remove dbus-mqtt-occ from Venus OS GX device

set -e

APP_NAME="dbus-mqtt-occ"
INSTALL_DIR="/data/apps/${APP_NAME}"
SERVICE_DIR="/service/${APP_NAME}"

echo "=== Uninstalling ${APP_NAME} ==="

# Stop service
if [ -L "${SERVICE_DIR}" ]; then
    svc -d "${SERVICE_DIR}" 2>/dev/null || true
    sleep 2
    rm -f "${SERVICE_DIR}"
    echo "Service stopped and symlink removed"
fi

# Remove install directory
if [ -d "${INSTALL_DIR}" ]; then
    rm -rf "${INSTALL_DIR}"
    echo "Install directory removed: ${INSTALL_DIR}"
fi

# Remove logs
rm -rf "/var/log/${APP_NAME}"

echo ""
echo "=== Uninstallation complete ==="
