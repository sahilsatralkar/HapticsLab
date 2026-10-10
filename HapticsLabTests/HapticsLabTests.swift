import CoreHaptics
import XCTest
@testable import HapticsLab

@MainActor
final class HapticsLabTests: XCTestCase {
    func testDefaultTransientTiming() throws {
        let events = try CustomHapticConfiguration.defaults.events()
        XCTAssertEqual(events.count, 2)
        XCTAssertEqual(events[0].time, 0)
        XCTAssertEqual(events[1].time, 0.12, accuracy: 0.0001)
        XCTAssertTrue(events.allSatisfy { $0.duration == 0 })
    }

    func testContinuousPulsesIncludeDurationAndGap() throws {
        var configuration = CustomHapticConfiguration.defaults
        configuration.kind = .continuous
        configuration.duration = 0.4
        configuration.gap = 0.15
        configuration.pulseCount = 3
        let events = try configuration.events()
        XCTAssertEqual(events[1].time, 0.55, accuracy: 0.0001)
        XCTAssertEqual(events[2].time, 1.10, accuracy: 0.0001)
        XCTAssertTrue(events.allSatisfy { $0.duration == 0.4 })
        let pattern = try HapticsController.pattern(configuration, events: events)
        XCTAssertEqual(pattern.duration, 1.5, accuracy: 0.0001)
    }

    func testInvalidAndNonfiniteParametersAreRejected() {
        for badValue in [-0.1, 1.1, Double.nan, Double.infinity] {
            var configuration = CustomHapticConfiguration.defaults
            configuration.intensity = badValue
            XCTAssertThrowsError(try configuration.events())
            configuration = .defaults
            configuration.sharpness = badValue
            XCTAssertThrowsError(try configuration.events())
        }
        for count in [0, 9] {
            var configuration = CustomHapticConfiguration.defaults
            configuration.pulseCount = count
            XCTAssertThrowsError(try configuration.events())
        }
        for badValue in [0.0, 3.1, Double.nan, Double.infinity] {
            var configuration = CustomHapticConfiguration.defaults
            configuration.duration = badValue
            XCTAssertThrowsError(try configuration.events())
        }
        for badValue in [0.0, 2.1, Double.nan, Double.infinity] {
            var configuration = CustomHapticConfiguration.defaults
            configuration.gap = badValue
            XCTAssertThrowsError(try configuration.events())
        }
    }

    func testLongPatternIsRejected() {
        var configuration = CustomHapticConfiguration.defaults
        configuration.kind = .continuous
        configuration.duration = 3
        configuration.gap = 2
        configuration.pulseCount = 8
        XCTAssertThrowsError(try configuration.events()) {
            XCTAssertEqual($0 as? CustomHapticConfiguration.ValidationError, .tooLong)
        }
    }

    func testBoundaryValuesAndSilentIntensityAreAccepted() throws {
        var configuration = CustomHapticConfiguration.defaults
        configuration.kind = .continuous
        configuration.intensity = 0
        configuration.sharpness = 1
        configuration.duration = 3
        configuration.gap = 0.5
        configuration.pulseCount = 3
        XCTAssertEqual(try configuration.events().last!.time + configuration.duration, 10)
        _ = try HapticsController.pattern(configuration, events: configuration.events())
    }

    func testConfigurationIsAnImmutablePlaybackSnapshot() throws {
        var draft = CustomHapticConfiguration.defaults
        let accepted = draft
        draft.intensity = 0.1
        draft.pulseCount = 6
        XCTAssertEqual(accepted.intensity, 0.65)
        XCTAssertEqual(try accepted.events().count, 2)
    }

    func testRepeatedNativeRequestsRemainDistinct() {
        let first = NativeHapticRequest(sequence: 1, haptic: .soft)
        let second = NativeHapticRequest(sequence: 2, haptic: .soft)
        XCTAssertNotEqual(first, second)
        XCTAssertEqual(Set(NativeHaptic.allCases.map(\.id)).count, 12)
    }

    func testStopIsSafeAndRepeatableWithoutHardware() {
        let controller = HapticsController()
        controller.stop()
        controller.stop()
        XCTAssertFalse(controller.isPlaying)
        XCTAssertEqual(controller.status, "Stopped")
        XCTAssertNil(controller.errorMessage)
    }
}
