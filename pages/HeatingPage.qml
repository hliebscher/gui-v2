/*
** OpenCamperCore — Heating & Climate control page
** Settings → Heating & Climate
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	// DeviceInstance 100 — must match services/dbus-mqtt-occ/config.ini
	readonly property string serviceUid: BackendConnection.serviceUidFromName(
			"com.victronenergy.heating.occ", 100)

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

			SettingsColumn {
				width: parent ? parent.width : 0

				Repeater {
					model: zoneCount.valid ? zoneCount.value : 3

					ListSlider {
						required property int index
						readonly property int zoneId: index + 1
						readonly property string zonePrefix: root.serviceUid + "/Zone/" + zoneId

						width: parent.width
						text: index < root.defaultZoneNames.length
								? root.defaultZoneNames[index]
								: ("Zone " + zoneId)
						dataItem.uid: zonePrefix + "/Setpoint"
						writeAccessLevel: VenusOS.User_AccessType_User
						from: root.heatingMin
						to: root.heatingMax
						stepSize: 0.5
					}
				}
			}

			PrimaryListLabel {
				//% "Climate"
				text: qsTrId("occ_climate")
				preferredVisible: climateCount.valid ? climateCount.value > 0 : true
			}

			SettingsColumn {
				width: parent ? parent.width : 0
				preferredVisible: climateCount.valid ? climateCount.value > 0 : true

				Repeater {
					model: climateCount.valid ? climateCount.value : 2

					SettingsColumn {
						required property int index
						readonly property int climateId: index + 1
						readonly property string climatePrefix: root.serviceUid + "/Climate/" + climateId

						width: parent.width

						ListSlider {
							width: parent.width
							text: index < root.defaultClimateNames.length
									? root.defaultClimateNames[index]
									: ("Klima " + climateId)
							dataItem.uid: climatePrefix + "/Setpoint"
							writeAccessLevel: VenusOS.User_AccessType_User
							from: root.climateMin
							to: root.climateMax
							stepSize: 0.5
						}

						ListRadioButtonGroup {
							width: parent.width
							//% "Climate mode"
							text: qsTrId("occ_climate_mode")
							dataItem.uid: climatePrefix + "/Mode"
							writeAccessLevel: VenusOS.User_AccessType_User
							optionModel: [
								{ display: CommonWords.off, value: 0 },
								{ display: qsTrId("occ_climate_cool"), value: 1 },
								{ display: qsTrId("occ_climate_heat"), value: 2 },
								{ display: qsTrId("occ_climate_auto"), value: 3 }
							]
						}
					}
				}
			}
		}
	}

	VeQuickItem { id: statusItem; uid: root.serviceUid + "/Status" }
	VeQuickItem { id: zoneCount; uid: root.serviceUid + "/NumberOfZones" }
	VeQuickItem { id: climateCount; uid: root.serviceUid + "/NumberOfClimateUnits" }
}
