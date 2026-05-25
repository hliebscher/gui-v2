"""
vedbus.py — Victron Energy D-Bus Service Helper

This is a minimal stub for development/testing. On a real GX device, this file
is replaced with the full version from victronenergy/velib_python.

To get the real implementation:
    git clone https://github.com/victronenergy/velib_python.git
    cp velib_python/vedbus.py .
    cp velib_python/ve_utils.py .
"""

import dbus
import dbus.service
import logging

log = logging.getLogger(__name__)


class VeDbusService:
    """Minimal VeDbusService implementation for development."""

    def __init__(self, service_name, bus=None, register=True):
        self._service_name = service_name
        self._bus = bus or dbus.SystemBus()
        self._paths = {}
        self._callbacks = {}
        self._registered = False

        if register:
            self.register()

    def register(self):
        """Claim the bus name."""
        if not self._registered:
            self._bus_name = dbus.service.BusName(self._service_name, self._bus)
            self._registered = True
            log.info("Registered D-Bus service: %s", self._service_name)

    def add_path(self, path, initial_value, writeable=False, onchangecallback=None,
                 gettextcallback=None, description=None):
        """Add a D-Bus path with an initial value."""
        self._paths[path] = initial_value
        if onchangecallback:
            self._callbacks[path] = onchangecallback

    def __getitem__(self, path):
        return self._paths.get(path)

    def __setitem__(self, path, value):
        old = self._paths.get(path)
        self._paths[path] = value
        if old != value:
            log.debug("Path %s: %s -> %s", path, old, value)

    def __contains__(self, path):
        return path in self._paths

    def get_value(self, path):
        return self._paths.get(path)

    def set_value(self, path, value):
        if path in self._callbacks:
            accepted = self._callbacks[path](path, value)
            if accepted:
                self._paths[path] = value
        else:
            self._paths[path] = value
