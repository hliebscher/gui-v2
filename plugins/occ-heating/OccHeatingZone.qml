/*
** OpenCamperCore Heating Plugin — Zone Detail Page
** Zeigt Ist/Soll-Temperatur, Modus, Ventilstatus einer Zone
*/

import QtQuick
import Victron.VenusOS

Page {
    id: root

    required property int zoneId
    required property string serviceUid

    readonly property string zonePrefix: serviceUid + "/Zone/" + zoneId

    GradientListView {
        model: VisibleItemModel {

            ListQuantityItem {
                //% "Current temperature"
                text: qsTrId("occ_temperature_current")
                dataItem.uid: root.zonePrefix + "/Temperature"
                unit: VenusOS.Units_Temperature_Celsius
            }

            ListSlider {
                //% "Setpoint"
                text: qsTrId("occ_temperature_setpoint")
                dataItem.uid: root.zonePrefix + "/Setpoint"
                writeAccessLevel: VenusOS.User_AccessType_User
                from: 5.0
                to: 35.0
                stepSize: 0.5
            }

            ListRadioButtonGroup {
                //% "Mode"
                text: qsTrId("occ_mode")
                dataItem.uid: root.zonePrefix + "/Mode"
                writeAccessLevel: VenusOS.User_AccessType_User
                optionModel: [
                    //% "Manual"
                    { display: qsTrId("occ_mode_manual"), value: 0 },
                    //% "Automatic"
                    { display: qsTrId("occ_mode_auto"), value: 1 },
                    //% "Off"
                    { display: qsTrId("occ_mode_off"), value: 2 }
                ]
            }

            ListTextItem {
                //% "State"
                text: qsTrId("occ_state")
                dataItem.uid: root.zonePrefix + "/State"
                secondaryText: {
                    switch (dataItem.value) {
                    case 0: return CommonWords.off
                    case 1: return qsTrId("occ_state_heating")
                    case 2: return qsTrId("occ_state_cooling")
                    default: return "---"
                    }
                }
            }

            ListTextItem {
                //% "Relay"
                text: qsTrId("occ_relay_state")
                dataItem.uid: root.zonePrefix + "/RelayState"
                secondaryText: dataItem.value === 1 ? CommonWords.on : CommonWords.off
            }

            PrimaryListLabel {
                //% "Valves"
                text: qsTrId("occ_valves_header")
            }

            Repeater {
                model: valveModel

                ListTextItem {
                    required property var modelData
                    text: modelData.id
                    secondaryText: modelData.item.value === 1
                        //% "Open"
                        ? qsTrId("occ_valve_open")
                        //% "Closed"
                        : qsTrId("occ_valve_closed")

                    VeQuickItem {
                        id: valveItem
                    }

                    Component.onCompleted: {
                        modelData.item = valveItem
                        valveItem.uid = root.serviceUid + "/Valve/" + modelData.id + "/State"
                    }
                }
            }

            PrimaryListLabel {
                //% "Pumps"
                text: qsTrId("occ_pumps_header")
                preferredVisible: root.zoneId === 1
            }

            ListTextItem {
                //% "Main pump (P1)"
                text: qsTrId("occ_pump_p1")
                dataItem.uid: root.serviceUid + "/Pump/P1/State"
                secondaryText: dataItem.value === 1 ? CommonWords.on : CommonWords.off
            }

            ListTextItem {
                //% "Zone pump (P2)"
                text: qsTrId("occ_pump_p2")
                dataItem.uid: root.serviceUid + "/Pump/P2/State"
                secondaryText: dataItem.value === 1 ? CommonWords.on : CommonWords.off
                preferredVisible: root.zoneId === 1
            }
        }
    }

    // Build valve model for this zone
    readonly property var valveModel: {
        var valves = []
        var mapping = { "V17": 3, "V18": 2, "V20": 1, "V24": 1, "V25": 1 }
        for (var id in mapping) {
            if (mapping[id] === root.zoneId) {
                valves.push({ "id": id, "item": null })
            }
        }
        return valves
    }
}
