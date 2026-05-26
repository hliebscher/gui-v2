/*
** OpenCamperCore — Heating Control Card
** Shows zone summary with quick-access temperature control
*/

import QtQuick
import Victron.VenusOS

ControlCard {
    id: root

    property string serviceUid: BackendConnection.type === BackendConnection.MqttSource
        ? "mqtt/heating.occ"
        : "dbus/com.victronenergy.heating.occ"

    icon.source: "qrc:/images/heating.svg"
    //% "Heating"
    title.text: qsTrId("occ_heating_card_title")
    status.text: _statusText()
    status.color: statusItem.value === 2 ? Theme.color_green : Theme.color_font_secondary

    function _statusText() {
        if (!statusItem.isValid) return "---"
        switch (statusItem.value) {
        case 0: return qsTrId("occ_status_offline")
        case 1: return qsTrId("occ_status_standby")
        case 2: return qsTrId("occ_status_active")
        default: return "---"
        }
    }

    Column {
        anchors {
            top: root.status.bottom
            topMargin: Theme.geometry_controlCard_contentMargins
            left: parent.left
            leftMargin: Theme.geometry_controlCard_contentMargins
            right: parent.right
            rightMargin: Theme.geometry_controlCard_contentMargins
        }
        spacing: 4

        Repeater {
            model: 3
            delegate: Row {
                required property int index
                readonly property int zoneId: index + 1
                width: parent.width
                spacing: 8

                Label {
                    width: parent.width * 0.35
                    text: zoneName.isValid ? zoneName.value : ["Wohnraum", "Bad", "Schlafraum"][index]
                    font.pixelSize: Theme.font_size_body2
                    color: Theme.color_font_primary
                    elide: Text.ElideRight
                }

                Label {
                    width: parent.width * 0.25
                    text: zoneTemp.isValid ? (Math.round(zoneTemp.value * 10) / 10) + "°C" : "---"
                    font.pixelSize: Theme.font_size_body2
                    color: Theme.color_font_secondary
                    horizontalAlignment: Text.AlignRight
                }

                Label {
                    width: parent.width * 0.1
                    text: "\u2192"
                    font.pixelSize: Theme.font_size_body2
                    color: Theme.color_font_secondary
                    horizontalAlignment: Text.AlignHCenter
                }

                Label {
                    width: parent.width * 0.25
                    text: zoneSetpoint.isValid ? (Math.round(zoneSetpoint.value * 10) / 10) + "°C" : "---"
                    font.pixelSize: Theme.font_size_body2
                    color: zoneState.value === 1 ? Theme.color_orange : Theme.color_font_primary
                    horizontalAlignment: Text.AlignRight
                }

                VeQuickItem { id: zoneName; uid: root.serviceUid + "/Zone/" + zoneId + "/Name" }
                VeQuickItem { id: zoneTemp; uid: root.serviceUid + "/Zone/" + zoneId + "/Temperature" }
                VeQuickItem { id: zoneSetpoint; uid: root.serviceUid + "/Zone/" + zoneId + "/Setpoint" }
                VeQuickItem { id: zoneState; uid: root.serviceUid + "/Zone/" + zoneId + "/State" }
            }
        }
    }

    VeQuickItem { id: statusItem; uid: root.serviceUid + "/Status" }
}
