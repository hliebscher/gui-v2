/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

FocusScope {
	id: root

	required property PageStack pageStack

	signal controlCardsActivated()
	signal auxCardsActivated()
	signal cardsDeactivated()
	signal sidePanelToggled()

	function updateBreadcrumbsFocusHint() {
		// When breadcrumbs list is focused: if focus is arriving from the left side, focus the
		// the left-most breadcrumb, or if from the right side, focus the right-most breadcrumb.
		if (leftButton.activeFocus || auxButton.activeFocus) {
			breadcrumbs.focusEdgeHint = Qt.LeftEdge
		} else if (rightButton.activeFocus || sleepButton.activeFocus) {
			breadcrumbs.focusEdgeHint = Qt.RightEdge
		} else {
			// Focus is coming elsewhere, so do not change the current index
			breadcrumbs.focusEdgeHint = -1
		}
	}

	implicitWidth: Theme.geometry_screen_width
	implicitHeight: Theme.geometry_statusBar_height

	component NotificationButton : Button {
		readonly property bool animating: animator.running

		opacity: enabled ? 1 : 0
		font.family: Global.fontFamily
		font.pixelSize: Theme.font_size_caption
		Behavior on opacity {
			enabled: Global.animationEnabled
			OpacityAnimator {
				id: animator
				duration: Theme.animation_toastNotification_fade_duration
			}
		}
	}

	StatusBarButton {
		id: leftButton

		readonly property int buttonType: {
			const customButton = Global.mainView.currentPage?.topLeftButton ?? VenusOS.StatusBar_LeftButton_None
			if (customButton === VenusOS.StatusBar_LeftButton_None && pageStack.opened) {
				return VenusOS.StatusBar_LeftButton_Back
			}
			return customButton
		}

		// Expand clickable area on left and bottom edges.
		leftInset: Theme.geometry_statusBar_horizontalMargin
		bottomInset: Theme.geometry_statusBar_spacing

		icon.source: buttonType === VenusOS.StatusBar_LeftButton_ControlsInactive ? "qrc:/images/icon_controls_off_32.svg"
			: buttonType === VenusOS.StatusBar_LeftButton_ControlsActive ? "qrc:/images/icon_controls_on_32.svg"
			: buttonType === VenusOS.StatusBar_LeftButton_Back ? "qrc:/images/icon_back_32.svg"
			: ""
		enabled: buttonType !== VenusOS.StatusBar_LeftButton_None
		KeyNavigation.right: auxButton

		onClicked: {
			switch (buttonType) {
			case VenusOS.StatusBar_LeftButton_ControlsInactive:
				root.controlCardsActivated()
				break
			case VenusOS.StatusBar_LeftButton_ControlsActive:
				root.cardsDeactivated()
				break;
			case VenusOS.StatusBar_LeftButton_Back:
				Global.pageManager.popPage()
				break
			default:
				break
			}
		}

		onActiveFocusChanged: {
			if (activeFocus) {
				root.updateBreadcrumbsFocusHint()
			}
		}
	}

	StatusBarButton {
		id: auxButton

		readonly property bool auxCardsOpened: Global.mainView.cardsActive
				&& leftButton.buttonType !== VenusOS.StatusBar_LeftButton_ControlsActive

		// Expand clickable area on right and bottom edges, and on left if leftButton is hidden.
		anchors {
			left: leftButton.right
			leftMargin: -leftInset
		}
		leftInset: leftButton.enabled ? 0 : Theme.geometry_statusBar_spacing
		rightInset: Theme.geometry_statusBar_spacing
		bottomInset: Theme.geometry_statusBar_spacing

		visible: (!root.pageStack.opened && Global.switches.groups.count > 0)
				|| auxCardsOpened // allow cards to be closed if all switches are disconnected while opened
		icon.source: leftButton.buttonType === VenusOS.StatusBar_LeftButton_ControlsActive ? ""
				: auxCardsOpened ? "qrc:/images/icon_smartswitch_on_32.svg"
				: "qrc:/images/icon_smartswitch_off_32.svg"
		enabled: leftButton.buttonType !== VenusOS.StatusBar_LeftButton_ControlsActive
		KeyNavigation.right: breadcrumbs

		contentItem: Item {
			Image {
				id: auxIcon
				source: auxButton.icon.source
				width: auxButton.icon.width
				height: auxButton.icon.height
				sourceSize: Qt.size(width, height)
				fillMode: Image.PreserveAspectFit
				visible: !!auxButton.icon.source
				anchors.verticalCenter: parent.verticalCenter
			}
			Label {
				text: CommonWords.switch_mode
				color: Theme.color_ok
				visible: auxButton.auxCardsOpened
				font.pixelSize: Theme.font_size_body
				anchors.verticalCenter: parent.verticalCenter
				anchors.left: auxIcon.right
				anchors.leftMargin: 4
			}
		}

		onClicked: {
			if (auxCardsOpened) {
				root.cardsDeactivated()
			} else {
				root.auxCardsActivated()
			}
		}

		onActiveFocusChanged: {
			if (activeFocus) {
				root.updateBreadcrumbsFocusHint()
			}
		}
	}

	Breadcrumbs {
		id: breadcrumbs

		anchors {
			top: parent.top
			topMargin: Theme.geometry_settings_breadcrumb_topMargin
			left: leftButton.right
			leftMargin: Theme.geometry_settings_breadcrumb_horizontalMargin
			right: rightButtonRow.left
		}
		pageStack: root.pageStack

		KeyNavigation.right: wifiButton

		Rectangle { // fade out the breadcrumbs RHS when overflowing
			width: parent.width
			height: Theme.geometry_settings_breadcrumb_height
			visible: !parent.atXEnd

			gradient: Gradient {
				orientation: Gradient.Horizontal

				GradientStop {
					position: 1 - Theme.geometry_breadcrumbs_viewGradient_width
					color: Theme.color_viewGradient_color1
				}
				GradientStop {
					position: 1 - Theme.geometry_breadcrumbs_viewGradient_width / 2
					color: Theme.color_viewGradient_color2
				}
				GradientStop {
					position: 1
					color: Theme.color_viewGradient_color3
				}
			}
		}
	}

	Item {
		id: timeDateConnectivityRow
		anchors.fill: parent
		visible: !breadcrumbs.visible

		VeQuickItem {
			id: statusBarTemperatureSensorIndex
			uid: Global.systemSettings.serviceUid + "/Settings/Gui2/StatusBar/TemperatureSensorIndex"
			onValueChanged: updateTemperatureSensorIndex()
			Component.onCompleted: updateTemperatureSensorIndex()

			property int temperatureSensorIndex: 0

			function updateTemperatureSensorIndex() {
				if (valid) {
					const idx = (value !== undefined && value !== null) ? parseInt(value) : 0
					temperatureSensorIndex = idx
				} else {
					temperatureSensorIndex = 0
				}
			}
		}

		Row {
			id: temperatureRow
			spacing: 8
			anchors {
				right: logoContainer.left
				rightMargin: 16
				verticalCenter: parent.verticalCenter
			}

			CP.ColorImage {
				source: "qrc:/images/icon_temp_32.svg"
				color: Theme.color_font_primary
				height: 20
				width: 20
				visible: temperatureItem.valid
				anchors.verticalCenter: parent.verticalCenter
			}

			QuantityLabel {
				id: temperatureLabel
				font.pixelSize: 22
				unit: Global.systemSettings.temperatureUnit
				value: temperatureItem.value
				visible: temperatureItem.valid && !isNaN(temperatureItem.value)
			}

			VeQuickItem {
				id: temperatureItem
				uid: {
					if (Global.environmentInputs?.model?.count > 0) {
						const idx = Math.min(Math.max(statusBarTemperatureSensorIndex.temperatureSensorIndex, 0), Global.environmentInputs.model.count - 1)
						const dev = Global.environmentInputs.model.deviceAt ? Global.environmentInputs.model.deviceAt(idx) : Global.environmentInputs.model.get(idx)
						return dev && dev.serviceUid ? dev.serviceUid + "/Temperature" : ""
					}
					return ""
				}
				sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Celsius)
				displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
			}
		}

		Item {
			id: logoContainer
			anchors {
				horizontalCenter: parent.horizontalCenter
				verticalCenter: parent.verticalCenter
			}
			width: Math.max(victronLogo.width, 100)
			height: Math.max(victronLogo.height, 32)

			Image {
				id: victronLogo
				source: "qrc:/images/victronenergy.svg"
				height: 32
				fillMode: Image.PreserveAspectFit
				anchors.centerIn: parent
			}

			PressArea {
				id: logoPressArea
				anchors.fill: parent
				enabled: true

				onClicked: {
					Global.pageManager.pushPage("/pages/PageContact.qml", {
						//% "Kontakt"
						"title": qsTrId("page_contact_title")
					})
				}
			}
		}

		PressArea {
			id: clockPressArea
			anchors {
				left: logoContainer.right
				leftMargin: 16
				verticalCenter: parent.verticalCenter
			}
			width: clockLabel.implicitWidth
			height: clockLabel.implicitHeight

			onClicked: {
				if (ScreenBlanker.supported && ScreenBlanker.enabled) {
					ScreenBlanker.setDisplayOff()
				}
			}

			Label {
				id: clockLabel
				font.pixelSize: 22
				text: ClockTime.currentTime
			}
		}

		Row {
			id: connectivityRow

			spacing: Theme.geometry_statusBar_rightSideRow_horizontalMargin
			anchors {
				left: clockPressArea.right
				leftMargin: 8
				verticalCenter: parent.verticalCenter
			}

			StatusBarButton {
				id: wifiButton

				opacity: enabled ? 1.0 : 0.0
				color: Theme.color_font_primary
				enabled: signalStrength.valid

				icon.source: !signalStrength.valid ? ""
					: signalStrength.value > 75 ? "qrc:/images/icon_WiFi_4_32.svg"
					: signalStrength.value > 50 ? "qrc:/images/icon_WiFi_3_32.svg"
					: signalStrength.value > 25 ? "qrc:/images/icon_WiFi_2_32.svg"
					: signalStrength.value > 0 ? "qrc:/images/icon_WiFi_1_32.svg"
					: "qrc:/images/icon_WiFi_noconnection_32.svg"

				KeyNavigation.right: mobileButton

				onClicked: Global.mainView.goToConnectivityPage("wifi")

				VeQuickItem {
					id: signalStrength
					uid: Global.venusPlatform.serviceUid + "/Network/Wifi/SignalStrength"
				}
			}

			StatusBarButton {
				id: mobileButton

				opacity: enabled ? 1.0 : 0.0
				visible: mobileIcon.valid

				KeyNavigation.right: notificationButton

				onClicked: Global.mainView.goToConnectivityPage("mobile")

				GsmStatusIcon {
					id: mobileIcon
					height: Theme.geometry_status_bar_gsmModem_icon_height
					anchors.centerIn: parent
				}
			}
		}
	}

	StatusBarButton {
		id: notificationButton

		anchors {
			left: timeDateConnectivityRow.right
			verticalCenter: parent.verticalCenter
		}
		// Expand clickable area on vertical and bottom edges.
		rightInset: Theme.geometry_statusBar_spacing / 2
		topInset: Theme.geometry_statusBar_spacing
		bottomInset: Theme.geometry_statusBar_spacing

		// The notificationButton should always be shown, even when the page is not interactive
		opacity: 1
		visible: !breadcrumbs.visible && (Global.notifications?.statusBarNotificationIconVisible ?? false)

		color: Global.notifications?.statusBarNotificationIconColor ?? "transparent"
		icon.source: Global.notifications?.statusBarNotificationIconSource ?? ""

		onClicked: Global.mainView.goToNotificationsPage()
		onActiveFocusChanged: {
			if (activeFocus) {
				root.updateBreadcrumbsFocusHint()
			}
		}

		KeyNavigation.right: alarmButton
	}

	SilenceAlarmButton {
		id: alarmButton

		anchors {
			left: notificationButton.right
			verticalCenter: parent.verticalCenter
		}
		width: Math.min(parent.width - x - rightButtonRow.width, implicitWidth)
		// Expand clickable area on horizontal and bottom edges.
		leftInset: Theme.geometry_statusBar_spacing / 2
		rightInset: Theme.geometry_statusBar_spacing / 2
		topInset: Theme.geometry_statusBar_spacing
		bottomInset: Theme.geometry_statusBar_spacing
		enabled: Global.mainView?.notificationButtonsEnabled
		visible: enabled

		onClicked: NotificationModel.acknowledgeAll()
	}

	Row {
		id: rightButtonRow

		height: parent.height
		anchors.right: parent.right

		StatusBarButton {
			id: rightButton

			readonly property int buttonType: Global.mainView?.currentPage?.topRightButton ?? VenusOS.StatusBar_RightButton_None

			// Expand clickable area on left and bottom edges.
			leftInset: Theme.geometry_statusBar_spacing
			bottomInset: Theme.geometry_statusBar_spacing

			enabled: buttonType != VenusOS.StatusBar_RightButton_None
			visible: enabled
			icon.source: buttonType === VenusOS.StatusBar_RightButton_SidePanelActive
						 ? "qrc:/images/icon_sidepanel_on_32.svg"
						 : buttonType === VenusOS.StatusBar_RightButton_SidePanelInactive
						   ? "qrc:/images/icon_sidepanel_off_32.svg"
						   : buttonType === VenusOS.StatusBar_RightButton_Add
							 ? "qrc:/images/icon_plus.svg"
							 : buttonType === VenusOS.StatusBar_RightButton_Refresh
							   ? "qrc:/images/icon_refresh_32.svg"
							   : ""
			KeyNavigation.left: alarmButton
			KeyNavigation.right: sleepButton

			onClicked: root.sidePanelToggled()
			onActiveFocusChanged: {
				if (activeFocus) {
					root.updateBreadcrumbsFocusHint()
				}
			}
		}

		StatusBarButton {
			id: sleepButton

			// Expand clickable area on right and bottom edges, and on left edge if right button is
			// hidden. This is the right-most button in the row, so on the right edge, use
			// Theme.geometry_statusBar_horizontalMargin instead of Theme.geometry_statusBar_spacing.
			leftInset: rightButton.visible ? 0 : Theme.geometry_statusBar_spacing
			rightInset: Theme.geometry_statusBar_horizontalMargin
			bottomInset: Theme.geometry_statusBar_spacing

			icon.source: "qrc:/images/icon_screen_sleep_32.svg"
			visible: ScreenBlanker.supported && ScreenBlanker.enabled

			onClicked: ScreenBlanker.setDisplayOff()
			onActiveFocusChanged: {
				if (activeFocus) {
					root.updateBreadcrumbsFocusHint()
				}
			}
		}
	}

	// The status bar should never become the focused item; if it does, it means there was no
	// previously focused button in the status bar, or the last focused button is now disabled and
	// not focusable. So, find the first available button and focus that instead.
	Connections {
		target: Global.main
		enabled: Global.keyNavigationEnabled
		function onActiveFocusItemChanged() {
			if (Global.main.activeFocusItem === root) {
				for (const button of [leftButton, auxButton, breadcrumbs, notificationButton, alarmButton, rightButton, sleepButton]) {
					if (button.enabled) {
						button.focus = true
						break
					}
				}
			}
		}
	}
}
