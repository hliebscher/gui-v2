/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {
		model: VisibleItemModel {
			SettingsListHeader {
				//% "Kontakt"
				text: qsTrId("page_contact_contact")
			}

			ListItem {
				id: addressItem
				//% "Anschrift"
				text: qsTrId("page_contact_address")
				interactive: false
				content.children: [
					SecondaryListLabel {
						text: "VARIOmobil Fahrzeugbau GmbH\nAn Teckners Tannen 1\n49163 Bohmte | Germany"
						width: Math.min(implicitWidth, addressItem.maximumContentWidth)
						anchors.verticalCenter: parent.verticalCenter
					}
				]
			}

			ListItem {
				id: phoneItem
				//% "Telefon"
				text: qsTrId("page_contact_phone")
				interactive: false
				content.children: [
					SecondaryListLabel {
						text: "05471 - 9511 0"
						width: Math.min(implicitWidth, phoneItem.maximumContentWidth)
						anchors.verticalCenter: parent.verticalCenter
					}
				]
			}

			ListItem {
				id: faxItem
				//% "Fax"
				text: qsTrId("page_contact_fax")
				interactive: false
				content.children: [
					SecondaryListLabel {
						text: "05471 - 9511 59"
						width: Math.min(implicitWidth, faxItem.maximumContentWidth)
						anchors.verticalCenter: parent.verticalCenter
					}
				]
			}

			ListItem {
				id: emailItem
				//% "E-Mail"
				text: qsTrId("page_contact_email")
				interactive: false
				content.children: [
					SecondaryListLabel {
						text: "info@vario-mobil.com"
						width: Math.min(implicitWidth, emailItem.maximumContentWidth)
						anchors.verticalCenter: parent.verticalCenter
					}
				]
			}

			ListItem {
				id: hoursItem
				//% "Öffnungszeiten"
				text: qsTrId("page_contact_opening_hours")
				interactive: false
				content.children: [
					SecondaryListLabel {
						text: qsTrId("page_contact_opening_hours_text")
						width: Math.min(implicitWidth, hoursItem.maximumContentWidth)
						anchors.verticalCenter: parent.verticalCenter
					}
				]
			}
		}
	}
}

