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
		// Immer dunkler Hintergrund, unabhängig vom UI-Theme.
		color: "#000000"
	}

	Column {
		anchors.centerIn: parent
		spacing: 20

		Label {
			id: timeLabel
			anchors.horizontalCenter: parent.horizontalCenter
			text: ClockTime.currentTime
			font.family: Global.fontFamily
			font.pixelSize: 160
			color: Theme.color_font_primary
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
		}

		Label {
			id: dateLabel
			anchors.horizontalCenter: parent.horizontalCenter
 			// Locale-basiert, Wochentag gemäß Systemsprache.
			text: {
				// Nutze die eingestellte GUI-Sprache (Language.currentLocaleName),
				// nicht die System-Locale, damit Wochentag/Monat übersetzt werden.
				const localeName = Language.currentLocaleName
				const effectiveLocale = localeName && localeName.length ? Qt.locale(localeName) : Qt.locale()
				return Qt.formatDate(new Date(), effectiveLocale, "dddd, dd.MM.yyyy")
			}
			font.family: Global.fontFamily
			font.pixelSize: 42
			color: Theme.color_font_secondary
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
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

