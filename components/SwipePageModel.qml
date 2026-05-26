import QtQuick
import QtQml.Models
import Victron.VenusOS
import Victron.Boat as Boat

ObjectModel {
	id: root

	required property SwipeView view
	readonly property list<SwipeViewPage> pages: {
		var p = []
		if (showBoatPage) p.push(boatPageLoader.item)
		p.push(briefPage, overviewPage)
		if (showHeatingPage) p.push(heatingPageLoader.item)
		if (showLevelsPage) p.push(levelsPageLoader.item)
		p.push(notificationsPage, settingsPage)
		return p
	}
	readonly property bool showLevelsPage: levelsPageLoader.active && !!levelsPageLoader.item
	readonly property bool showBoatPage: boatPageLoader.active && !!boatPageLoader.item
	readonly property bool showHeatingPage: heatingPageLoader.active && !!heatingPageLoader.item
	readonly property int tankCount: Global.tanks ? Global.tanks.totalTankCount : 0
	readonly property int environmentInputCount: Global.environmentInputs ? Global.environmentInputs.model.count : 0

	readonly property int _expectedPageCount: 4
		+ (showBoatPage ? 1 : 0)
		+ (showHeatingPage ? 1 : 0)
		+ (showLevelsPage ? 1 : 0)

	readonly property bool completed: _completed
		&& Global.dataManagerLoaded
		&& Global.systemSettings
		&& Global.tanks
		&& Global.environmentInputs
		&& pages.length === _expectedPageCount

	property bool _completed: false

	Loader {
		id: boatPageLoader

		active: showBoatPageItem.value ?? false
		sourceComponent: Boat.BoatPage {
			view: root.view
		}

		VeQuickItem {
			id: showBoatPageItem
			uid: !!Global.systemSettings ? Global.systemSettings.serviceUid + "/Settings/Gui/ElectricPropulsionUI/Enabled" : ""
		}
	}

	BriefPage {
		id: briefPage
		view: root.view

		Image {
			width: status === Image.Null ? 0 : Theme.geometry_screen_width
			fillMode: Image.PreserveAspectFit
			source: BackendConnection.demoImageFileName
			onStatusChanged: {
				if (status === Image.Ready) {
					console.info("Loaded demo image:", source)
				}
			}
		}
	}

	OverviewPage {
		id: overviewPage
		view: root.view
	}

	Loader {
		id: heatingPageLoader

		active: occServicePresent.isValid && occServicePresent.value !== undefined
		sourceComponent: HeatingPage {
			view: root.view
		}

		VeQuickItem {
			id: occServicePresent
			uid: BackendConnection.type === BackendConnection.MqttSource
				? "mqtt/heating.occ/Status"
				: "dbus/com.victronenergy.heating.occ/Status"
		}
	}

	Loader {
		id: levelsPageLoader

		active: root.tankCount > 0 || root.environmentInputCount > 0
		sourceComponent: LevelsPage {
			view: root.view
		}
	}

	NotificationsPage {
		id: notificationsPage
		view: root.view
	}

	SettingsPage {
		id: settingsPage
		view: root.view
	}

	Component.onCompleted: Qt.callLater(function() { root._completed = true })
}
