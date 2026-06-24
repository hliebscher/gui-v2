/*
** OpenCamperCore Heating Plugin — Climate Page
** Klimaanlage: Modus, Ist/Soll-Temperatur, Status
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
                    //% "Cooling"
                    { display: qsTrId("occ_climate_cool"), value: 1 },
                    //% "Heating"
                    { display: qsTrId("occ_climate_heat"), value: 2 },
                    //% "Automatic"
                    { display: qsTrId("occ_climate_auto"), value: 3 }
                ]
            }

            ListQuantityItem {
                //% "Current temperature"
                text: qsTrId("occ_temperature_current")
                dataItem.uid: root.climatePrefix + "/Temperature"
                unit: VenusOS.Units_Temperature_Celsius
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
                    //% "Active"
                    ? qsTrId("occ_climate_active")
                    //% "Idle"
                    : qsTrId("occ_climate_idle")
            }
        }
    }
}
