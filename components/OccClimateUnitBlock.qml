/*
** OpenCamperCore — Climate unit block (setpoint slider + mode)
*/

import QtQuick
import Victron.VenusOS

SettingsColumn {
	id: root

	required property string serviceUid
	required property int climateId
	property real from: 16.0
	property real to: 30.0
	property string defaultTitle: "Klima"

	readonly property string climatePrefix: serviceUid + "/Climate/" + climateId

	width: parent ? parent.width : 0

	OccSetpointSliderRow {
		width: parent.width
		nameUid: root.climatePrefix + "/Name"
		defaultTitle: root.defaultTitle
		setpointUid: root.climatePrefix + "/Setpoint"
		temperatureUid: root.climatePrefix + "/Temperature"
		stateUid: root.climatePrefix + "/State"
		stateHeatingValue: 1
		from: root.from
		to: root.to
		stepSize: 0.5
	}

	ListRadioButtonGroup {
		width: parent.width
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
}
