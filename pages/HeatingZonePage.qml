/*
** OpenCamperCore — Heating Zone Detail (Fork-Layer)
** Pushed from HeatingPage NavBar page
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
                    { display: qsTrId("occ_mode_manual"), value: 0 },
                    { display: qsTrId("occ_mode_auto"), value: 1 },
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

            ListTextItem {
                //% "Valve"
                text: qsTrId("occ_valves_header")
                dataItem.uid: root.zonePrefix + "/ValveState"
                secondaryText: dataItem.value === 1
                    ? qsTrId("occ_valve_open") : qsTrId("occ_valve_closed")
            }
        }
    }
}
