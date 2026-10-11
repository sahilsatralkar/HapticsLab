import CoreHaptics
import XCTest
@testable import HapticsLab

@MainActor
final class HapticsLabTests: XCTestCase {
    private func referenceCapabilities(envelope: Bool = true) throws -> HapticEventCapabilities {
        let range = try HapticParameterRange(minimum: 0, maximum: 1, defaultValue: 0.5)
        let keys: [HapticParameter] = envelope ? HapticParameter.allCases : [.intensity, .sharpness]
        return HapticEventCapabilities(ranges: Dictionary(uniqueKeysWithValues: keys.map { ($0, range) }),
                                       unavailable: [:])
    }

    func testDefaultTransientTiming() throws {
        let events = try CustomHapticConfiguration.defaults.events()
        XCTAssertEqual(events.count, 2)
        XCTAssertEqual(events[0].time, 0)
        XCTAssertEqual(events[1].time, 0.12, accuracy: 0.0001)
        XCTAssertTrue(events.allSatisfy { $0.duration == 0 })
    }

    func testContinuousToggleSelectsEventTypeAndRemembersDuration() throws {
        var configuration = CustomHapticConfiguration.defaults
        let limits = try referenceCapabilities()
        let capabilities = HapticCapabilities(supportsHaptics: true,
                                             events: [.transient: limits, .continuous: limits])
        XCTAssertFalse(configuration.isContinuous)
        XCTAssertEqual(configuration.duration, 0.2)
        configuration.intensity = 0.237
        configuration.sharpness = 0.713
        for duration in [0.000001, 0.123456, 30.0] {
            configuration.duration = duration
            for enabled in [true, false, true] {
                configuration.setContinuous(enabled, using: capabilities)
                let events = try HapticsController.hapticEvents(configuration, capabilities: limits)
                let expectedType: CHHapticEvent.EventType = enabled ? .hapticContinuous : .hapticTransient
                let expectedDuration = enabled ? duration : 0
                XCTAssertTrue(events.allSatisfy { $0.type == expectedType })
                XCTAssertTrue(events.allSatisfy { $0.duration == expectedDuration })
                XCTAssertEqual(events[1].relativeTime, expectedDuration + configuration.gap, accuracy: 0.0000001)
                XCTAssertEqual(configuration.duration, duration)
                XCTAssertEqual(configuration.intensity, 0.237)
                XCTAssertEqual(configuration.sharpness, 0.713)
                _ = try HapticsController.pattern(configuration, capabilities: limits)
            }
        }
        configuration.duration = 0
        XCTAssertThrowsError(try configuration.events())
        configuration.setContinuous(false, using: capabilities)
        XCTAssertNoThrow(try configuration.events())
    }

    func testModeSwitchUsesDefaultsOnlyOutsideNewDeviceRanges() throws {
        let transient = try referenceCapabilities()
        var ranges = transient.ranges
        ranges[.intensity] = try HapticParameterRange(minimum: 0.2, maximum: 0.8, defaultValue: 0.4)
        let continuous = HapticEventCapabilities(ranges: ranges, unavailable: [:])
        let capabilities = HapticCapabilities(supportsHaptics: true,
                                             events: [.transient: transient, .continuous: continuous])
        var configuration = CustomHapticConfiguration.defaults
        configuration.intensity = 0.9
        configuration.sharpness = 0.237
        configuration.attack = 0.123
        configuration.setContinuous(true, using: capabilities)
        XCTAssertEqual(configuration.intensity, 0.4)
        XCTAssertEqual(configuration.sharpness, 0.237)
        XCTAssertEqual(configuration.attack, 0.123)
        XCTAssertNoThrow(try continuous.validate(configuration))

        configuration.setContinuous(false, using: capabilities)
        configuration.intensity = .nan
        configuration.setContinuous(true, using: capabilities)
        XCTAssertTrue(configuration.intensity.isNaN)
        XCTAssertThrowsError(try configuration.events())
    }

    func testContinuousPulsesIncludeDurationAndGap() throws {
        var configuration = CustomHapticConfiguration.defaults
        configuration.isContinuous = true
        configuration.duration = 0.4
        configuration.gap = 0.15
        configuration.pulseCount = 3
        let events = try configuration.events()
        XCTAssertEqual(events[1].time, 0.55, accuracy: 0.0001)
        XCTAssertEqual(events[2].time, 1.10, accuracy: 0.0001)
        let encoded = try HapticsController.hapticEvents(configuration, capabilities: referenceCapabilities())
        XCTAssertEqual(encoded.last!.relativeTime + encoded.last!.duration, 1.5, accuracy: 0.0001)
        // Pattern.duration may account for the native envelope; scheduled inputs must remain exact.
        _ = try HapticsController.pattern(configuration, capabilities: referenceCapabilities())
    }

    func testInvalidAndNonfiniteParametersAreRejected() throws {
        let limits = try referenceCapabilities()
        for parameter in HapticParameter.allCases where parameter != .sustained {
            for badValue in [-0.1, 1.1, Double.nan, Double.infinity] {
                var configuration = CustomHapticConfiguration.defaults
                configuration.set(badValue, for: parameter)
                XCTAssertThrowsError(try HapticsController.pattern(configuration, capabilities: limits))
            }
        }
        for count in [0, 9] {
            var configuration = CustomHapticConfiguration.defaults
            configuration.pulseCount = count
            XCTAssertThrowsError(try configuration.events())
        }
        for value in [-1, 30.001, Double.nan, Double.infinity] {
            var configuration = CustomHapticConfiguration.defaults
            configuration.duration = value
            XCTAssertThrowsError(try configuration.events())
        }
        for value in [-0.001, 2.001, Double.nan, Double.infinity] {
            var configuration = CustomHapticConfiguration.defaults
            configuration.gap = value
            XCTAssertThrowsError(try configuration.events())
        }
    }

    func testFullContinuousDurationAndZeroGapAreAccepted() throws {
        var configuration = CustomHapticConfiguration.defaults
        configuration.isContinuous = true
        configuration.duration = 30
        configuration.gap = 0
        configuration.pulseCount = 1
        let encoded = try HapticsController.hapticEvents(configuration, capabilities: referenceCapabilities())
        XCTAssertEqual(encoded.first!.duration, 30)
        _ = try HapticsController.pattern(configuration, capabilities: referenceCapabilities())
        configuration.pulseCount = 8
        configuration.gap = 2
        let events = try configuration.events()
        XCTAssertEqual(events.last!.time + events.last!.duration, 254)
    }

    func testSmoothValuesAndSilentIntensityArePreserved() throws {
        var configuration = CustomHapticConfiguration.defaults
        configuration.intensity = 0
        configuration.sharpness = 0.123456
        configuration.gap = 0.123456
        let events = try HapticsController.hapticEvents(configuration, capabilities: referenceCapabilities())
        XCTAssertEqual(events[1].relativeTime, 0.123456, accuracy: 0.0000001)
        XCTAssertEqual(events[0].eventParameters.first { $0.parameterID == .hapticIntensity }?.value, 0)
        let sharpness = try XCTUnwrap(events[0].eventParameters.first { $0.parameterID == .hapticSharpness })
        XCTAssertEqual(sharpness.value, Float(0.123456), accuracy: 0.000001)
    }

    func testEnvelopeMapsAttackDecayReleaseAndSustain() throws {
        var configuration = CustomHapticConfiguration.defaults
        configuration.isContinuous = true
        configuration.duration = 0.2
        configuration.attack = 0.234
        configuration.decay = 0.456
        configuration.release = 0.678
        let limits = try referenceCapabilities()
        for sustain in [true, false] {
            configuration.sustained = sustain
            let event = try XCTUnwrap(HapticsController.hapticEvents(configuration, capabilities: limits).first)
            let values = Dictionary(uniqueKeysWithValues: event.eventParameters.map { ($0.parameterID, $0.value) })
            XCTAssertEqual(values[.attackTime], Float(0.234))
            XCTAssertEqual(values[.sustained], sustain ? 1 : 0)
            XCTAssertEqual(values[sustain ? .releaseTime : .decayTime], sustain ? Float(0.678) : Float(0.456))
            XCTAssertNil(values[sustain ? .decayTime : .releaseTime])
            _ = try HapticsController.pattern(configuration, capabilities: limits)
        }
    }

    func testDeviceRangesAreEnforcedWithoutClamping() throws {
        var ranges = try referenceCapabilities().ranges
        ranges[.intensity] = try HapticParameterRange(minimum: 0.2, maximum: 0.8, defaultValue: 0.4)
        let limits = HapticEventCapabilities(ranges: ranges, unavailable: [:])
        var configuration = CustomHapticConfiguration.defaults
        configuration.resetParameters(using: limits)
        XCTAssertEqual(configuration.intensity, 0.4)
        for value in [0.2, 0.8] {
            configuration.intensity = value
            XCTAssertNoThrow(try limits.validate(configuration))
        }
        configuration.intensity = 0.81
        XCTAssertThrowsError(try HapticsController.pattern(configuration, capabilities: limits))
        XCTAssertEqual(configuration.intensity, 0.81)
    }

    func testUnavailableParametersAreOmittedAndMissingBasicsRejected() throws {
        let limits = try referenceCapabilities(envelope: false)
        let event = try XCTUnwrap(HapticsController.hapticEvents(.defaults, capabilities: limits).first)
        XCTAssertEqual(Set(event.eventParameters.map(\.parameterID)), [.hapticIntensity, .hapticSharpness])
        let missing = HapticEventCapabilities(ranges: [:], unavailable: [:])
        XCTAssertThrowsError(try HapticsController.pattern(.defaults, capabilities: missing))
    }

    func testInvalidCapabilityAttributesAreRejected() {
        for (minimum, maximum, value) in [(1.0, 0.0, 0.5), (0, 1, 2), (.nan, 1, 0), (0, .infinity, 0)] {
            XCTAssertThrowsError(try HapticParameterRange(minimum: minimum, maximum: maximum, defaultValue: value))
        }
    }

    func testConfigurationIsAnImmutablePlaybackSnapshot() throws {
        var draft = CustomHapticConfiguration.defaults
        let accepted = draft
        draft.intensity = 0.1
        draft.attack = 0.9
        draft.pulseCount = 6
        XCTAssertEqual(accepted.intensity, 0.65)
        XCTAssertEqual(accepted.attack, 0)
        XCTAssertEqual(try accepted.events().count, 2)
    }

    func testRepeatedNativeRequestsRemainDistinct() {
        XCTAssertNotEqual(NativeHapticRequest(sequence: 1, haptic: .soft),
                          NativeHapticRequest(sequence: 2, haptic: .soft))
        XCTAssertEqual(Set(NativeHaptic.allCases.map(\.id)).count, 11)
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
