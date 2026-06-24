/*
** OpenCamperCore — Heating (minimal test)
*/

import QtQuick
import Victron.VenusOS

SwipeViewPage {
    id: root

    //% "Heating"
    title: qsTrId("nav_heating")
    iconSource: "qrc:/images/icon_temp_32.svg"
    url: "qrc:/qt/qml/Victron/VenusOS/pages/HeatingPage.qml"

    GradientListView {
        model: VisibleItemModel {
            ListTextItem {
                text: "Heating"
                secondaryText: "---"
            }
        }
    }
}
