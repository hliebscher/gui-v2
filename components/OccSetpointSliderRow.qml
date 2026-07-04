/*
** OpenCamperCore — Temperature setpoint row (OCC D-Bus, slider look like Schalter)
*/

import QtQuick
import Victron.VenusOS

FocusScope {
	id: root

	property string title
	property string nameUid: ""
	property string defaultTitle: ""
	property string setpointUid
	property string temperatureUid
	property string stateUid: ""
	property int stateHeatingValue: 1
	property real from: 5.0
	property real to: 30.0
	property real stepSize: 0.5
	property int writeAccessLevel: VenusOS.User_AccessType_User

	readonly property bool userHasWriteAccess: Global.systemSettings.canAccess(writeAccessLevel)
	readonly property bool dragging: slider.pressed || slider._valueChangeKeyPressed

	implicitWidth: Theme.geometry_listItem_width
	implicitHeight: header.height + slider.height + Theme.geometry_listItem_itemSeparator_height

	function _formatTemp(value, valid) {
		if (!valid || value === undefined || value === null)
			return "---"
		return (Math.round(value * 10) / 10).toFixed(1) + Units.degreesSymbol
	}

	Row {
		id: header

		width: parent.width
		leftPadding: Theme.geometry_listItem_content_horizontalMargin
		rightPadding: Theme.geometry_listItem_content_horizontalMargin
		topPadding: Theme.geometry_listItem_content_verticalMargin
		spacing: Theme.geometry_listItem_spacing

		Label {
			width: parent.width * 0.38
			text: root.nameUid.length && nameItem.valid ? nameItem.value : (root.title.length ? root.title : root.defaultTitle)
			font.pixelSize: Theme.font_size_body1
			color: Theme.color_font_primary
			elide: Text.ElideRight
			verticalAlignment: Text.AlignVCenter
		}

		Label {
			width: parent.width * 0.42
			text: _formatTemp(temperatureItem.value, temperatureItem.valid)
					+ " / "
					+ _formatTemp(setpointItem.value, setpointItem.valid)
			font.pixelSize: Theme.font_size_body2
			color: Theme.color_font_secondary
			horizontalAlignment: Text.AlignRight
			verticalAlignment: Text.AlignVCenter
		}

		Label {
			width: parent.width * 0.2 - parent.spacing
			text: {
				if (!stateUid.length || !stateItem.valid)
					return ""
				if (stateItem.value === stateHeatingValue)
					return "\u2191"
				if (stateItem.value === 2)
					return "\u2193"
				return ""
			}
			font.pixelSize: Theme.font_size_body2
			color: stateItem.value === stateHeatingValue ? Theme.color_orange : Theme.color_font_secondary
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
		}
	}

	MiniSlider {
		id: slider

		anchors {
			left: parent.left
			right: parent.right
			top: header.bottom
		}
		leftInset: Theme.geometry_listItem_content_horizontalMargin
		rightInset: Theme.geometry_listItem_content_horizontalMargin
		bottomInset: Theme.geometry_listItem_content_verticalMargin

		from: root.from
		to: root.to
		stepSize: root.stepSize
		value: setpointItem.valid ? setpointItem.value : from
		enabled: root.userHasWriteAccess && setpointItem.valid
		live: true
		snapMode: Slider.SnapAlways
		focus: true

		property bool _valueChangeKeyPressed

		onMoved: valueSync.writeValue(value)

		background: Rectangle {
			implicitWidth: Theme.geometry_controlCard_minimumWidth
			implicitHeight: Theme.geometry_iochannel_control_height
			radius: Theme.geometry_slider_groove_radius

			gradient: Gradient {
				orientation: Qt.Horizontal
				GradientStop {
					position: 0.0
					color: slider.enabled ? Theme.color_temperatureslider_gradient_min_border : Theme.color_gray3
				}
				GradientStop {
					position: 1.0
					color: slider.enabled ? Theme.color_temperatureslider_gradient_max_border : Theme.color_gray3
				}
			}

			Rectangle {
				anchors.fill: parent
				anchors.margins: Theme.geometry_button_border_width
				radius: Theme.geometry_slider_groove_radius - anchors.margins

				gradient: Gradient {
					orientation: Qt.Horizontal
					GradientStop {
						position: 0.0
						color: slider.enabled ? Theme.color_temperatureslider_gradient_min : Theme.color_background_disabled
					}
					GradientStop {
						position: 0.5
						color: slider.enabled ? Theme.color_temperatureslider_gradient_mid : Theme.color_background_disabled
					}
					GradientStop {
						position: 1.0
						color: slider.enabled ? Theme.color_temperatureslider_gradient_max : Theme.color_background_disabled
					}
				}
			}
		}

		Keys.onPressed: (event) => {
			switch (event.key) {
			case Qt.Key_Left:
			case Qt.Key_Right:
				_valueChangeKeyPressed = true
				break
			}
			event.accepted = false
		}
		Keys.onReleased: (event) => {
			if (event.key === Qt.Key_Left || event.key === Qt.Key_Right)
				_valueChangeKeyPressed = false
			event.accepted = false
		}
	}

	SliderSettingSync {
		id: valueSync
		dataItem: setpointItem
		dragging: root.dragging
		onUpdateSliderValue: slider.value = setpointItem.valid ? setpointItem.value : slider.from
	}

	VeQuickItem {
		id: setpointItem
		uid: root.setpointUid
		sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Celsius)
		displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
	}

	VeQuickItem {
		id: temperatureItem
		uid: root.temperatureUid
		sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Celsius)
		displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
	}

	VeQuickItem {
		id: stateItem
		uid: root.stateUid
	}

	VeQuickItem {
		id: nameItem
		uid: root.nameUid
	}
}
