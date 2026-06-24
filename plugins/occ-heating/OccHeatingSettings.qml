/*
** OpenCamperCore Heating Plugin — Settings Page
** Thermostat-Parameter, MQTT-Status, Firmware-Version
*/

import QtQuick
import Victron.VenusOS

Page {
    id: root

    required property string serviceUid

    GradientListView {
        model: VisibleItemModel {

            PrimaryListLabel {
                //% "Thermostat parameters"
                text: qsTrId("occ_settings_thermostat_parameters")
            }

            ListSpinBox {
                //% "Hysteresis"
                text: qsTrId("occ_settings_hysteresis")
                dataItem.uid: root.serviceUid + "/Settings/Hysteresis"
                from: 2
                to: 50
                stepSize: 1
                suffix: " \u00d710\u207B\u00B9 \u00B0C"
            }

            ListSpinBox {
                //% "Min. setpoint"
                text: qsTrId("occ_settings_min_setpoint")
                dataItem.uid: root.serviceUid + "/Settings/MinSetpoint"
                from: 0
                to: 150
                stepSize: 5
                suffix: " \u00d710\u207B\u00B9 \u00B0C"
            }

            ListSpinBox {
                //% "Max. setpoint"
                text: qsTrId("occ_settings_max_setpoint")
                dataItem.uid: root.serviceUid + "/Settings/MaxSetpoint"
                from: 250
                to: 400
                stepSize: 5
                suffix: " \u00d710\u207B\u00B9 \u00B0C"
            }

            ListSpinBox {
                //% "Sensor timeout (min)"
                text: qsTrId("occ_settings_sensor_timeout")
                dataItem.uid: root.serviceUid + "/Settings/SensorTimeout"
                from: 1
                to: 30
                stepSize: 1
                suffix: " min"
            }

            ListSwitch {
                //% "Frost protection"
                text: qsTrId("occ_settings_frost_protection")
                dataItem.uid: root.serviceUid + "/Settings/FrostProtection"
            }

            ListSpinBox {
                //% "Frost threshold"
                text: qsTrId("occ_settings_frost_threshold")
                dataItem.uid: root.serviceUid + "/Settings/FrostThreshold"
                from: 0
                to: 100
                stepSize: 5
                suffix: " \u00d710\u207B\u00B9 \u00B0C"
                preferredVisible: frostProtection.value === 1
            }

            PrimaryListLabel {
                //% "System information"
                text: qsTrId("occ_settings_system_info")
            }

            ListTextItem {
                //% "MQTT status"
                text: qsTrId("occ_mqtt_status")
                dataItem.uid: root.serviceUid + "/Status"
                secondaryText: {
                    switch (dataItem.value) {
                    case 0: return qsTrId("occ_status_offline")
                    case 1: return qsTrId("occ_status_standby")
                    case 2: return qsTrId("occ_status_active")
                    default: return "---"
                    }
                }
            }

            ListTextItem {
                //% "Firmware version"
                text: qsTrId("occ_firmware_version")
                dataItem.uid: root.serviceUid + "/FirmwareVersion"
            }

            ListTextItem {
                //% "Product name"
                text: qsTrId("occ_product_name")
                dataItem.uid: root.serviceUid + "/ProductName"
            }

            ListSpinBox {
                //% "StatusBar temperature sensor"
                text: qsTrId("occ_settings_statusbar_sensor")
                dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Gui2/StatusBar/TemperatureSensorIndex"
                from: 0
                to: 10
                stepSize: 1
            }
        }
    }

    VeQuickItem {
        id: frostProtection
        uid: root.serviceUid + "/Settings/FrostProtection"
    }
}
