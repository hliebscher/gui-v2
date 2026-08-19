/*
 * Copyright (C) 2024 Victron Energy B.V.
 * See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtTest

TestCase {
	name: "ScreenBlanker"

	property ScreenBlanker blanker: ScreenBlanker

	SignalSpy {
		id: spy
		target: blanker
		signalName: "clicked"
	}

	function test_blanker() {
		if (!blanker.supported) {
			return
		}

		blanker.displayOffTime = 100
		compare(blanker.enabled, true)
		compare(blanker.displayOffTime, 100)

		// Reset display off timeout
		blanker.setDisplayOn()

		// Wait for the display off timeout to blank the screen
		let startTime = new Date()
		wait(80)
		tryCompare(blanker, "blanked", false)

		// Wait a bit more
		tryCompare(blanker, "blanked", true)
		let endTime = new Date();

		// Check the timeout roughly follows the display off time
		fuzzyCompare(endTime - startTime, blanker.displayOffTime, 50)
		console.log("timeout", endTime - startTime)

		// Manually turn the display on
		blanker.setDisplayOn()
		compare(blanker.blanked, false)

		// Simulate input events happening every 10 milliseconds
		for (var i = 0; i < 20; i++) {
			// During the interaction the display should stay unblanked
			compare(blanker.blanked, false)
			blanker.setDisplayOn()
			wait(20)
		}

		// Turn the display off manually
		blanker.setDisplayOff()
		compare(blanker.blanked, true)

		// Disallow blanking (e.g. during alarms)
		blanker.enabled = false

		// Disallowing blanking should turn the display back on
		compare(blanker.blanked, false)

		// Display off timeout should no longer apply
		wait(200)
		compare(blanker.blanked, false)

		// Allow display off timeout again
		blanker.enabled = true
		compare(blanker.blanked, false)

		// This time try different display off time
		blanker.displayOffTime = 50
		wait(80)
		compare(blanker.blanked, true)

		// Check that the display off timer is disabled with 0 timeout
		blanker.setDisplayOn()
		compare(blanker.blanked, false)
		blanker.displayOffTime = 0
		wait(160)
		compare(blanker.blanked, false)
	}

	function test_standby_clock_duration() {
		if (!blanker.supported) {
			return
		}

		// Default / restore
		blanker.enabled = true
		compare(blanker.standbyClockDuration, 28800000)
		blanker.setDisplayOn()
		compare(blanker.blanked, false)
		compare(blanker.standbyClockActive, false)

		// Duration 0 → sofort blanked, keine Clock-Phase
		blanker.standbyClockDuration = 0
		blanker.setDisplayOff()
		compare(blanker.blanked, true)
		compare(blanker.standbyClockActive, false)

		blanker.setDisplayOn()
		compare(blanker.blanked, false)

		// Duration 200 ms → zuerst Clock-Phase, dann Ende der Phase
		blanker.standbyClockDuration = 200
		blanker.setDisplayOff()
		compare(blanker.blanked, true)
		compare(blanker.standbyClockActive, true)
		wait(300)
		// Desktop has no hardware blank device. A failed write must keep the clock active.
		compare(blanker.standbyClockActive, true)
		compare(blanker.blanked, true)

		blanker.setDisplayOn()
		blanker.standbyClockDuration = 28800000
	}
}
