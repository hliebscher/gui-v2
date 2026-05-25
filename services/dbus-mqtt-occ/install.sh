#!/bin/bash
# install.sh — Install dbus-mqtt-occ on Venus OS GX device
# Usage: ssh root@<gx-ip> "bash /tmp/dbus-mqtt-occ/install.sh"
#   or:  rsync -avc . root@<gx-ip>:/tmp/dbus-mqtt-occ/ && ssh root@<gx-ip> "bash /tmp/dbus-mqtt-occ/install.sh"

set -e

APP_NAME="dbus-mqtt-occ"
INSTALL_DIR="/data/apps/${APP_NAME}"
SERVICE_DIR="/service/${APP_NAME}"

echo "=== Installing ${APP_NAME} ==="

# Create install directory
mkdir -p "${INSTALL_DIR}"
mkdir -p "${INSTALL_DIR}/service"
mkdir -p "${INSTALL_DIR}/log"

# Copy files
cp dbus-mqtt-occ.py "${INSTALL_DIR}/"
cp config.ini "${INSTALL_DIR}/"
cp version.py "${INSTALL_DIR}/"
cp vedbus.py "${INSTALL_DIR}/"
cp service/run "${INSTALL_DIR}/service/run"
cp log/run "${INSTALL_DIR}/log/run"

# Make scripts executable
chmod +x "${INSTALL_DIR}/service/run"
chmod +x "${INSTALL_DIR}/log/run"
chmod +x "${INSTALL_DIR}/dbus-mqtt-occ.py"

# Install paho-mqtt if not present
if ! python3 -c "import paho.mqtt.client" 2>/dev/null; then
    echo "Installing paho-mqtt..."
    pip3 install paho-mqtt 2>/dev/null || opkg install python3-paho-mqtt 2>/dev/null || \
        echo "WARNING: Could not install paho-mqtt automatically. Install manually."
fi

# Create daemontools service symlink
if [ ! -L "${SERVICE_DIR}" ]; then
    ln -s "${INSTALL_DIR}/service" "${SERVICE_DIR}"
    echo "Service symlink created: ${SERVICE_DIR}"
else
    echo "Service symlink already exists"
fi

# Create log directory
mkdir -p /var/log/${APP_NAME}

echo ""
echo "=== Installation complete ==="
echo ""
echo "Service will start automatically via daemontools."
echo "Check status:  svstat ${SERVICE_DIR}"
echo "View logs:     tail -f /var/log/${APP_NAME}/current"
echo "Restart:       svc -t ${SERVICE_DIR}"
echo "Stop:          svc -d ${SERVICE_DIR}"
echo ""
echo "Edit config:   vi ${INSTALL_DIR}/config.ini"
echo "After config change: svc -t ${SERVICE_DIR}"
