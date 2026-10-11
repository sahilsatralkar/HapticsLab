import XCTest
@testable import HapticsLab

final class HapticNumberInputTests: XCTestCase {
    private let english = Locale(identifier: "en_US")

    func testExactValuesAndBoundariesAreNotRoundedOrClamped() throws {
        XCTAssertEqual(try HapticNumberInput.parse("0.1234567891234567", range: 0...1, locale: english),
                       0.1234567891234567)
        for value in ["0", "1", ".5", "+0.5", " 0.25\n", "1e-3"] {
            XCTAssertNoThrow(try HapticNumberInput.parse(value, range: 0...1, locale: english))
        }
        for value in ["-0.00001", "1.00001"] {
            XCTAssertThrowsError(try HapticNumberInput.parse(value, range: 0...1, locale: english)) {
                XCTAssertEqual($0 as? HapticNumberInput.InputError, .outsideRange)
            }
        }
        XCTAssertThrowsError(try HapticNumberInput.parse("0.1", range: 0.2...0.7, locale: english))
        XCTAssertEqual(try HapticNumberInput.parse("0.2", range: 0.2...0.7, locale: english), 0.2)
        XCTAssertEqual(try HapticNumberInput.parse("0.7", range: 0.2...0.7, locale: english), 0.7)
    }

    func testMalformedEmptyAndNonFiniteInputsAreRejected() {
        for value in ["", " \n", "hello", "0.5s", "NaN", "inf", "-infinity", "∞",
                      "1e309", "1e-999", "1,000", "0,5", "0.1.2", "1_000", "1 2", "--1",
                      "1e", "+", ".", "0\n.5", String(repeating: "1", count: 257)] {
            XCTAssertThrowsError(try HapticNumberInput.parse(value, range: 0...30, locale: english),
                                 "Accepted invalid input: \(value)")
        }
    }

    func testContinuousDurationRequiresPositiveValueAndHonorsMaximum() throws {
        XCTAssertThrowsError(try HapticNumberInput.parse("0", range: 0...30,
                                                        requiresPositive: true, locale: english)) {
            XCTAssertEqual($0 as? HapticNumberInput.InputError, .positiveRequired)
        }
        XCTAssertEqual(try HapticNumberInput.parse("0.000001", range: 0...30,
                                                   requiresPositive: true, locale: english), 0.000001)
        XCTAssertEqual(try HapticNumberInput.parse("30", range: 0...30,
                                                   requiresPositive: true, locale: english), 30)
        XCTAssertThrowsError(try HapticNumberInput.parse("30.0001", range: 0...30,
                                                        requiresPositive: true, locale: english))
        XCTAssertEqual(try HapticNumberInput.parse("0", range: 0...2, locale: english), 0)
    }

    func testLocaleDecimalsAndPastedSwiftNumbers() throws {
        let german = Locale(identifier: "de_DE")
        XCTAssertEqual(try HapticNumberInput.parse("0,125", range: 0...1, locale: german), 0.125)
        XCTAssertEqual(try HapticNumberInput.parse("0.125", range: 0...1, locale: german), 0.125)
        XCTAssertEqual(try HapticNumberInput.parse("1,25e-1", range: 0...1, locale: german), 0.125)
        for value in ["1.000,5", "0,1.2", "0,,5"] {
            XCTAssertThrowsError(try HapticNumberInput.parse(value, range: 0...30, locale: german))
        }
        XCTAssertEqual(try HapticNumberInput.parse("٠٫٢٥", range: 0...1,
                                                   locale: Locale(identifier: "ar_EG")), 0.25)
    }

    func testEditorTextRoundTripsTheOriginalDouble() throws {
        for locale in [english, Locale(identifier: "de_DE"), Locale(identifier: "ar_EG")] {
            for value in [0.0, 0.1234567891234567, 1.0 / 3.0, 0.000000001, 30.0] {
                let text = HapticNumberInput.text(for: value, locale: locale)
                XCTAssertEqual(try HapticNumberInput.parse(text, range: 0...30, locale: locale), value)
            }
        }
    }
}

@MainActor
final class HapticDraftTests: XCTestCase {
    func testDraftSurvivesStopAndCustomScreenRecreation() {
        let controller = HapticsController()
        var draft = controller.customConfiguration
        draft.intensity = 0.23456789
        draft.sharpness = 0.7654321
        draft.isContinuous = true
        draft.duration = 0.875
        draft.pulseCount = 3
        draft.gap = 0.25
        draft.sustained = false
        draft.decay = 0.4
        controller.customConfiguration = draft
        _ = CustomHapticsView(controller: controller)
        controller.stop()
        _ = CustomHapticsView(controller: controller)
        XCTAssertEqual(controller.customConfiguration, draft)
    }

    func testResetRestoresDeviceDefaultsAndLeavesCapturedSnapshotUnchanged() {
        let controller = HapticsController()
        let initial = controller.customConfiguration
        controller.customConfiguration.intensity = 0.1
        controller.customConfiguration.isContinuous = true
        controller.customConfiguration.duration = 2
        controller.customConfiguration.pulseCount = 5
        let snapshot = controller.customConfiguration
        controller.resetCustomConfiguration()
        XCTAssertEqual(controller.customConfiguration, initial)
        XCTAssertEqual(snapshot.intensity, 0.1)
        XCTAssertEqual(snapshot.duration, 2)
        XCTAssertTrue(snapshot.isContinuous)
        XCTAssertEqual(snapshot.pulseCount, 5)
    }
}
