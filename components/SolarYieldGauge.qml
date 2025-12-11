/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property int direction
	property real startAngle
	property real endAngle
	property int horizontalAlignment
	property real arcVerticalCenterOffset
	property bool animationEnabled

	width: parent.width
	height: parent.height

	// Ein einzelner Kreisbalken für die aktuelle Solar-Summenleistung.
	SideGauge {
		id: gauge
		animationEnabled: root.animationEnabled
		width: Theme.geometry_briefPage_edgeGauge_width
		height: root.height
		direction: root.direction
		startAngle: root.startAngle
		endAngle: root.endAngle
		horizontalAlignment: root.horizontalAlignment
		arcVerticalCenterOffset: root.arcVerticalCenterOffset
		valueType: VenusOS.Gauges_ValueType_NeutralPercentage
		value: valueRange.valueAsRatio * 100
	}

	ValueRange {
		id: valueRange
		value: Global.system.solar.power
		maximumValue: Global.system.solar.maximumPower
		minimumValue: 0
	}
}

