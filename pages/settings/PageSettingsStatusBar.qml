/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	VeQuickItem {
		id: statusBarTemperatureSensorIndex
		uid: Global.systemSettings.serviceUid + "/Settings/Gui2/StatusBar/TemperatureSensorIndex"
	}

	function _summaryText(deviceName, deviceInstance) {
		return deviceName ? `${deviceName} [${deviceInstance}]` : ""
	}

	Timer {
		id: popTimer
		interval: Theme.animation_settings_radioButtonPage_autoClose_duration
		onTriggered: Global.pageManager.popPage()
	}

	GradientListView {
		model: VisibleItemModel {
			SettingsColumn {
				width: parent ? parent.width : 0

				Repeater {
					model: Global.environmentInputs?.model
					delegate: ListRadioButton {
						required property Device device
						required property int index
						
						checked: statusBarTemperatureSensorIndex.valid
							? parseInt(statusBarTemperatureSensorIndex.value ?? 0) === index
							: index === 0
						text: root._summaryText(device?.name, device?.deviceInstance)
						writeAccessLevel: VenusOS.User_AccessType_User
						onClicked: {
							popTimer.stop()
							statusBarTemperatureSensorIndex.setValue(index)
							popTimer.start()
						}
					}
				}
			}
		}
	}
}

