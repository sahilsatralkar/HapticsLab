import XCTest

@MainActor
final class HapticsLabUITests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }

    func testEveryNativeButtonDispatchesAndRepeatedTapsWork() {
        let app = launch()
        defer { app.terminate() }
        let left = app.buttons["haptics.light"]
        let right = app.buttons["haptics.medium"]
        XCTAssertTrue(left.waitForExistence(timeout: 10))
        XCTAssertTrue(right.isHittable)
        XCTAssertEqual(left.frame.midY, right.frame.midY, accuracy: 2)
        XCTAssertGreaterThan(left.frame.width, left.frame.height)
        XCTAssertGreaterThan(right.frame.width, right.frame.height)
        XCTAssertGreaterThan(right.frame.minX, left.frame.maxX)
        XCTAssertFalse(app.staticTexts["Tap a pattern to feel it."].exists)
        for id in ["light", "medium", "heavy", "soft", "solid", "rigid", "impact",
                   "selection", "success", "warning", "error"] {
            let button = app.buttons["haptics." + id]
            reveal(button, in: app)
            XCTAssertGreaterThanOrEqual(button.frame.height, 44)
            button.tap()
            XCTAssertEqual(button.value as? String, "Requested")
            button.tap()
            XCTAssertEqual(button.value as? String, "Requested")
        }
    }

    func testCustomControlsAndSimulatorHardwareMessage() {
        let app = launch()
        defer { app.terminate() }
        reveal(app.buttons["haptics.custom"], in: app)
        app.buttons["haptics.custom"].tap()
        XCTAssertTrue(app.navigationBars["Custom"].waitForExistence(timeout: 5))
        for name in ["intensity", "sharpness"] {
            let slider = app.sliders["custom." + name]
            if slider.exists {
                slider.adjust(toNormalizedSliderPosition: 0.237)
            } else {
                XCTAssertTrue(app.otherElements["custom.unavailable." + name].exists ||
                              app.staticTexts["custom.unavailable." + name].exists)
            }
        }
        app.segmentedControls["custom.kind"].buttons["Continuous"].tap()
        let duration = app.sliders["custom.duration"]
        reveal(duration, in: app)
        let initialDuration = duration.value as? String
        duration.adjust(toNormalizedSliderPosition: 1)
        XCTAssertNotEqual(duration.value as? String, initialDuration)
        reveal(app.buttons["custom.play"], in: app)
        app.buttons["custom.play"].tap()
        #if targetEnvironment(simulator)
        reveal(app.staticTexts["custom.status"], in: app)
        XCTAssertEqual(app.staticTexts["custom.status"].label, "Custom haptics require supported physical hardware.")
        #endif
        reveal(app.buttons["custom.reset"], in: app)
        app.buttons["custom.reset"].tap()
        XCTAssertFalse(app.sliders["custom.duration"].exists)
        attach(app, "Custom parameters")
    }

    func testLightDarkAndAccessibilityLayout() {
        for (appearance, size) in [("light", "UICTContentSizeCategoryL"),
                                   ("dark", "UICTContentSizeCategoryL"),
                                   ("dark", "UICTContentSizeCategoryAccessibilityXXXL")] {
            let app = launch(appearance: appearance, size: size)
            XCTAssertTrue(app.buttons["haptics.light"].waitForExistence(timeout: 10))
            XCTAssertTrue(app.navigationBars["Haptics Lab"].exists)
            attach(app, "Haptics-" + appearance + "-" + size)
            let custom = app.buttons["haptics.custom"]
            reveal(custom, in: app)
            XCTAssertEqual(custom.label, "Custom haptics testing")
            XCTAssertTrue(app.cells.containing(.button, identifier: "haptics.custom").firstMatch.exists)
            let reference = app.buttons["haptics.error"]
            XCTAssertGreaterThan(custom.frame.width, reference.frame.width)
            let hapticButtons = app.buttons.matching(NSPredicate(
                format: "identifier BEGINSWITH %@ AND identifier != %@", "haptics.", "haptics.custom")).allElementsBoundByIndex
            XCTAssertEqual(hapticButtons.count, 11)
            for button in hapticButtons {
                XCTAssertEqual(button.frame.height, reference.frame.height, accuracy: 1, button.identifier)
            }
            XCTAssertTrue(app.windows.firstMatch.frame.contains(custom.frame))
            XCTAssertFalse(app.buttons["haptics.alignment"].exists)
            XCTAssertFalse(app.buttons["haptics.canvasAlignment"].exists)
            XCTAssertFalse(app.buttons["haptics.canvasPath"].exists)
            XCTAssertFalse(app.staticTexts["haptics.status"].exists)
            XCTAssertFalse(app.staticTexts["Canvas feedback requires Apple Pencil Pro and a compatible iPad."].exists)
            let device = app.descendants(matching: .any)["haptics.device"].firstMatch
            reveal(device, in: app)
            XCTAssertTrue(device.label.contains("iPhone model:"))
            XCTAssertTrue(device.label.contains("iOS version:"))
            XCTAssertFalse(device.label.contains("Detected:"))
            XCTAssertFalse(device.label.contains("Model identifier:"))
            #if targetEnvironment(simulator)
            XCTAssertTrue(device.label.contains("Custom haptics unavailable."))
            #endif
            attach(app, "Haptics-bottom-" + appearance + "-" + size)
            reveal(custom, in: app)
            custom.tap()
            reveal(app.buttons["custom.play"], in: app)
            XCTAssertTrue(app.buttons["custom.play"].isHittable)
            attach(app, "Custom-" + appearance + "-" + size)
            app.terminate()
        }
    }

    private func launch(appearance: String = "light", size: String = "UICTContentSizeCategoryL") -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US",
                               "-uiTestAppearance", appearance,
                               "-UIPreferredContentSizeCategoryName", size]
        app.launch()
        return app
    }

    private func reveal(_ element: XCUIElement, in app: XCUIApplication) {
        let window = app.windows.firstMatch
        for _ in 0..<12 {
            if element.exists && element.isHittable && window.frame.contains(element.frame) { return }
            if element.exists && element.frame.midY < window.frame.midY {
                app.swipeDown()
            } else {
                app.swipeUp()
            }
        }
        XCTAssertTrue(element.exists && element.isHittable && window.frame.contains(element.frame))
    }

    private func attach(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
