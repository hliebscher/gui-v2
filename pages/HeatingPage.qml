/*
** OpenCamperCore — Heating & Climate control page
** Settings → Heating & Climate
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	readonly property string serviceUid: BackendConnection.type === BackendConnection.MqttSource
			? "mqtt/heating.occ"
			: "dbus/com.victronenergy.heating.occ"

	readonly property real heatingMin: 5.0
	readonly property real heatingMax: 35.0
	readonly property real climateMin: 16.0
	readonly property real climateMax: 30.0

	readonly property var defaultZoneNames: ["Wohnraum", "Bad", "Schlafraum"]
	readonly property var defaultClimateNames: ["Klima Wohnen", "Klima Schlafen"]

	GradientListView {
		model: VisibleItemModel {

			ListText {
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

			PrimaryListLabel {
				//% "Heating zones"
				text: qsTrId("occ_heating_zones_header")
			}

			Repeater {
				model: zoneCount.valid ? zoneCount.value : 3

				OccSetpointSliderRow {
					required property int index
					readonly property int zoneId: index + 1
					readonly property string zonePrefix: root.serviceUid + "/Zone/" + zoneId

					width: ListView.view ? ListView.view.width : implicitWidth
					nameUid: zonePrefix + "/Name"
					defaultTitle: index < root.defaultZoneNames.length
							? root.defaultZoneNames[index]
							: ("Zone " + zoneId)
					setpointUid: zonePrefix + "/Setpoint"
					temperatureUid: zonePrefix + "/Temperature"
					stateUid: zonePrefix + "/State"
					stateHeatingValue: 1
					from: root.heatingMin
					to: root.heatingMax
					stepSize: 0.5
				}
			}

			PrimaryListLabel {
				//% "Climate"
				text: qsTrId("occ_climate")
				preferredVisible: climateCount.valid ? climateCount.value > 0 : true
			}

			Repeater {
				model: climateCount.valid ? climateCount.value : 2

				OccClimateUnitBlock {
					required property int index
					readonly property int climateId: index + 1

					width: ListView.view ? ListView.view.width : implicitWidth
					serviceUid: root.serviceUid
					climateId: climateId
					from: root.climateMin
					to: root.climateMax
					defaultTitle: index < root.defaultClimateNames.length
							? root.defaultClimateNames[index]
							: ("Klima " + climateId)
				}
			}
		}
	}

	VeQuickItem { id: statusItem; uid: root.serviceUid + "/Status" }
	VeQuickItem { id: zoneCount; uid: root.serviceUid + "/NumberOfZones" }
	VeQuickItem { id: climateCount; uid: root.serviceUid + "/NumberOfClimateUnits" }
}
