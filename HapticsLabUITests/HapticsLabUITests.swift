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
        XCTAssertEqual(left.frame.width, left.frame.height, accuracy: 2)
        XCTAssertEqual(right.frame.width, right.frame.height, accuracy: 2)
        XCTAssertGreaterThan(right.frame.minX, left.frame.maxX)
        XCTAssertFalse(app.staticTexts["Tap a pattern to feel it."].exists)
        for id in ["light", "medium", "heavy", "soft", "solid", "rigid", "impact",
                   "selection", "success", "warning", "error", "alignment",
                   "canvasAlignment", "canvasPath"] {
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
        XCTAssertTrue(app.sliders["custom.intensity"].exists)
        XCTAssertTrue(app.sliders["custom.sharpness"].exists)
        app.segmentedControls["custom.kind"].buttons["Continuous"].tap()
        XCTAssertTrue(app.sliders["custom.duration"].waitForExistence(timeout: 5))
        app.sliders["custom.intensity"].adjust(toNormalizedSliderPosition: 0.2)
        app.sliders["custom.sharpness"].adjust(toNormalizedSliderPosition: 0.8)
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
            attach(app, "Haptics-" + appearance + "-" + size)
            reveal(app.buttons["haptics.custom"], in: app)
            app.buttons["haptics.custom"].tap()
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
        for _ in 0..<12 {
            if element.exists && element.isHittable { return }
            app.swipeUp()
        }
        XCTAssertTrue(element.exists && element.isHittable)
    }

    private func attach(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
