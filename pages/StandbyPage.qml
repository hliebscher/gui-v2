/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	anchors.fill: parent
	visible: !!Global.screenBlanker && Global.screenBlanker.blanked

	Rectangle {
		anchors.fill: parent
		color: Theme.color_background
	}

	Column {
		anchors.centerIn: parent
		spacing: 20

		Label {
			id: timeLabel
			anchors.horizontalCenter: parent.horizontalCenter
			text: ClockTime.currentTime
			font.family: Global.fontFamily
			font.pixelSize: 120
			color: Theme.color_font_primary
		}

		Label {
			id: dateLabel
			anchors.horizontalCenter: parent.horizontalCenter
			text: Qt.formatDate(new Date(), "dddd, dd.MM.yyyy")
			font.family: Global.fontFamily
			font.pixelSize: 32
			color: Theme.color_font_secondary
		}
	}

	Timer {
		interval: 1000
		running: root.visible
		repeat: true
		onTriggered: {
			// Force update of the time label
			timeLabel.text = ClockTime.currentTime
		}
	}
}

