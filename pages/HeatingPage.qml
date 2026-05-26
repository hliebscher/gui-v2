/*
** OpenCamperCore — Heating & Climate Overview
** SwipeView page in NavBar + accessible via Settings
*/

import QtQuick
import Victron.VenusOS

SwipeViewPage {
    id: root

    //% "Heating"
    title: qsTrId("nav_heating")
    iconSource: "qrc:/images/heating.svg"
    url: "qrc:/qt/qml/Victron/VenusOS/pages/HeatingPage.qml"

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

            ListNavigation {
                text: zone1Name.valid ? zone1Name.value : "Wohnraum"
                secondaryText: _zoneText(zone1Temp.value, zone1Setpoint.value, zone1State.value)
                onClicked: Global.pageManager.pushPage("/pages/HeatingZonePage.qml", {
                    "title": text, "zoneId": 1, "serviceUid": root.serviceUid
                })
            }

            ListNavigation {
                text: zone2Name.valid ? zone2Name.value : "Bad"
                secondaryText: _zoneText(zone2Temp.value, zone2Setpoint.value, zone2State.value)
                onClicked: Global.pageManager.pushPage("/pages/HeatingZonePage.qml", {
                    "title": text, "zoneId": 2, "serviceUid": root.serviceUid
                })
            }

            ListNavigation {
                text: zone3Name.valid ? zone3Name.value : "Schlafraum"
                secondaryText: _zoneText(zone3Temp.value, zone3Setpoint.value, zone3State.value)
                onClicked: Global.pageManager.pushPage("/pages/HeatingZonePage.qml", {
                    "title": text, "zoneId": 3, "serviceUid": root.serviceUid
                })
            }

            ListNavigation {
                //% "Climate"
                text: qsTrId("occ_climate")
                secondaryText: {
                    if (!climateMode.valid) return "---"
                    var modes = ["", qsTrId("occ_climate_cool"), qsTrId("occ_climate_heat"), qsTrId("occ_climate_auto")]
                    return climateMode.value === 0 ? CommonWords.off : (modes[climateMode.value] || "---")
                }
                onClicked: Global.pageManager.pushPage("/pages/HeatingClimatePage.qml", {
                    "title": text, "serviceUid": root.serviceUid
                })
            }
        }
    }

    function _zoneText(temp, setpoint, state) {
        if (temp === undefined || temp === null) return "---"
        var t = Math.round(temp * 10) / 10 + "°C"
        var s = Math.round(setpoint * 10) / 10 + "°C"
        var suffix = state === 1 ? " \u2022 \u2191" : state === 2 ? " \u2022 \u2193" : ""
        return t + " \u2192 " + s + suffix
    }

    VeQuickItem { id: statusItem; uid: root.serviceUid + "/Status" }
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
}
