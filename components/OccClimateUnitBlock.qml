/*
** OpenCamperCore — Climate unit block (setpoint slider + mode)
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	required property string serviceUid
	required property int climateId
	property real from: 16.0
	property real to: 30.0
	property string defaultTitle: "Klima"

	readonly property string climatePrefix: serviceUid + "/Climate/" + climateId

	implicitWidth: sliderRow.implicitWidth
	implicitHeight: sliderRow.implicitHeight + modeGroup.height

	OccSetpointSliderRow {
		id: sliderRow

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
		id: modeGroup

		anchors.top: sliderRow.bottom
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
