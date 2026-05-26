/*
** OpenCamperCore — Climate Control (Fork-Layer)
** Pushed from HeatingPage NavBar page
*/

import QtQuick
import Victron.VenusOS

Page {
    id: root

    required property string serviceUid

    readonly property string climatePrefix: serviceUid + "/Climate"

    GradientListView {
        model: VisibleItemModel {

            ListRadioButtonGroup {
                //% "Climate mode"
                text: qsTrId("occ_climate_mode")
                dataItem.uid: root.climatePrefix + "/Mode"
                writeAccessLevel: VenusOS.User_AccessType_User
                optionModel: [
                    { display: CommonWords.off, value: 0 },
                    { display: qsTrId("occ_climate_cool"), value: 1 },
                    { display: qsTrId("occ_climate_heat"), value: 2 },
                    { display: qsTrId("occ_climate_auto"), value: 3 }
                ]
            }

            ListTemperature {
                //% "Current temperature"
                text: qsTrId("occ_temperature_current")
                dataItem.uid: root.climatePrefix + "/Temperature"
            }

            ListSlider {
                //% "Target temperature"
                text: qsTrId("occ_climate_setpoint")
                dataItem.uid: root.climatePrefix + "/Setpoint"
                writeAccessLevel: VenusOS.User_AccessType_User
                from: 16.0
                to: 30.0
                stepSize: 0.5
            }

            ListTextItem {
                //% "Climate state"
                text: qsTrId("occ_climate_state")
                dataItem.uid: root.climatePrefix + "/State"
                secondaryText: dataItem.value === 1
                    ? qsTrId("occ_climate_active")
                    : qsTrId("occ_climate_idle")
            }
        }
    }
}
