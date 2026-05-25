/*
** OpenCamperCore Heating Plugin — Main Page
** Einstiegsseite: Systemstatus + Zonenübersicht + Navigation
*/

import QtQuick
import Victron.VenusOS

Page {
    id: root

    readonly property string serviceUid: BackendConnection.type === BackendConnection.MqttSource
        ? "mqtt/heating.occ"
        : "dbus/com.victronenergy.heating.occ"

    GradientListView {
        model: VisibleItemModel {

            ListTextItem {
                //% "System status"
                text: qsTrId("occ_heating_system_status")
                secondaryText: {
                    switch (statusItem.value) {
                    case 0: return qsTrId("occ_status_offline")
                    case 1: return qsTrId("occ_status_standby")
                    case 2: return qsTrId("occ_status_active")
                    default: return "---"
                    }
                }
            }

            ListTextItem {
                //% "Heater"
                text: qsTrId("occ_heater")
                secondaryText: {
                    switch (heaterState.value) {
                    case 0: return CommonWords.off
                    case 1: return qsTrId("occ_heater_ready")
                    case 2: return qsTrId("occ_heater_heating")
                    case 3: return qsTrId("occ_heater_fault")
                    default: return "---"
                    }
                }
                preferredVisible: heaterState.isValid
            }

            ListTextItem {
                //% "Flow"
                text: qsTrId("occ_flow")
                secondaryText: flowState.value === 1
                    ? qsTrId("occ_flow_active")
                    : qsTrId("occ_flow_none")
                preferredVisible: flowState.isValid
            }

            PrimaryListLabel {
                //% "Heating zones"
                text: qsTrId("occ_heating_zones_header")
            }

            ListNavigation {
                text: zone1Name.isValid ? zone1Name.value : qsTrId("occ_zone") + " 1"
                secondaryText: _zoneSecondaryText(zone1Temp.value, zone1Setpoint.value, zone1State.value)
                onClicked: Global.pageManager.pushPage(zonePageComponent, {
                    "title": text,
                    "zoneId": 1,
                    "serviceUid": root.serviceUid
                })
            }

            ListNavigation {
                text: zone2Name.isValid ? zone2Name.value : qsTrId("occ_zone") + " 2"
                secondaryText: _zoneSecondaryText(zone2Temp.value, zone2Setpoint.value, zone2State.value)
                onClicked: Global.pageManager.pushPage(zonePageComponent, {
                    "title": text,
                    "zoneId": 2,
                    "serviceUid": root.serviceUid
                })
            }

            ListNavigation {
                text: zone3Name.isValid ? zone3Name.value : qsTrId("occ_zone") + " 3"
                secondaryText: _zoneSecondaryText(zone3Temp.value, zone3Setpoint.value, zone3State.value)
                onClicked: Global.pageManager.pushPage(zonePageComponent, {
                    "title": text,
                    "zoneId": 3,
                    "serviceUid": root.serviceUid
                })
            }

            PrimaryListLabel {
                text: ""
            }

            ListNavigation {
                //% "Climate"
                text: qsTrId("occ_climate")
                secondaryText: {
                    if (!climateMode.isValid) return "---"
                    switch (climateMode.value) {
                    case 0: return CommonWords.off
                    case 1: return qsTrId("occ_climate_cool")
                    case 2: return qsTrId("occ_climate_heat")
                    case 3: return qsTrId("occ_climate_auto")
                    default: return "---"
                    }
                }
                onClicked: Global.pageManager.pushPage(climatePageComponent, {
                    "title": text,
                    "serviceUid": root.serviceUid
                })
            }

            ListNavigation {
                //% "Settings"
                text: qsTrId("occ_settings")
                onClicked: Global.pageManager.pushPage(settingsPageComponent, {
                    "title": text,
                    "serviceUid": root.serviceUid
                })
            }
        }
    }

    function _zoneSecondaryText(temp, setpoint, state) {
        if (temp === undefined || temp === null) return "---"
        var stateText = ""
        if (state === 1) stateText = " \u2022 " + qsTrId("occ_state_heating")
        else if (state === 2) stateText = " \u2022 " + qsTrId("occ_state_cooling")
        return Units.getCelsiusQuantity(temp).number + " \u2192 " +
               Units.getCelsiusQuantity(setpoint).number + stateText
    }

    // D-Bus bindings
    VeQuickItem { id: statusItem; uid: root.serviceUid + "/Status" }
    VeQuickItem { id: heaterState; uid: root.serviceUid + "/Heater/State" }
    VeQuickItem { id: flowState; uid: root.serviceUid + "/Flow/State" }
    VeQuickItem { id: climateMode; uid: root.serviceUid + "/Climate/Mode" }

    VeQuickItem { id: zone1Name; uid: root.serviceUid + "/Zone/1/Name" }
    VeQuickItem { id: zone1Temp; uid: root.serviceUid + "/Zone/1/Temperature" }
    VeQuickItem { id: zone1Setpoint; uid: root.serviceUid + "/Zone/1/Setpoint" }
    VeQuickItem { id: zone1State; uid: root.serviceUid + "/Zone/1/State" }

    VeQuickItem { id: zone2Name; uid: root.serviceUid + "/Zone/2/Name" }
    VeQuickItem { id: zone2Temp; uid: root.serviceUid + "/Zone/2/Temperature" }
    VeQuickItem { id: zone2Setpoint; uid: root.serviceUid + "/Zone/2/Setpoint" }
    VeQuickItem { id: zone2State; uid: root.serviceUid + "/Zone/2/State" }

    VeQuickItem { id: zone3Name; uid: root.serviceUid + "/Zone/3/Name" }
    VeQuickItem { id: zone3Temp; uid: root.serviceUid + "/Zone/3/Temperature" }
    VeQuickItem { id: zone3Setpoint; uid: root.serviceUid + "/Zone/3/Setpoint" }
    VeQuickItem { id: zone3State; uid: root.serviceUid + "/Zone/3/State" }

    // Sub-page components
    Component { id: zonePageComponent; OccHeatingZone {} }
    Component { id: climatePageComponent; OccHeatingClimate {} }
    Component { id: settingsPageComponent; OccHeatingSettings {} }
}
