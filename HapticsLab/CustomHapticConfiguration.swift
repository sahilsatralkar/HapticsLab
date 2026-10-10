import Foundation

/// A value snapshot captured by Play. Envelope values are normalized, not seconds.
nonisolated struct CustomHapticConfiguration: Equatable, Sendable {
    enum EventKind: String, CaseIterable, Identifiable, Sendable {
        case transient, continuous
        var id: Self { self }
        var title: LocalizedStringResource { self == .transient ? "Tap" : "Continuous" }
    }

    // Core Haptics documents 30 seconds per continuous event. No device-specific
    // duration query exists. Pulse count and gap are explicitly app limits.
    static let maximumContinuousDuration = 30.0
    static let pulseRange = 1...8
    static let gapRange = 0.0...2.0
    static let defaults = Self(kind: .transient, intensity: 0.65, sharpness: 0.35,
                               duration: 0.20, pulseCount: 2, gap: 0.12)

    var kind: EventKind
    var intensity: Double
    var sharpness: Double
    var duration: Double
    var pulseCount: Int
    var gap: Double
    var attack: Double = 0
    var decay: Double = 0
    var release: Double = 0
    var sustained: Bool = true

    var activeParameters: [HapticParameter] {
        [.intensity, .sharpness, .attack, .sustained, sustained ? .release : .decay]
    }

    func value(for parameter: HapticParameter) -> Double {
        switch parameter {
        case .intensity: intensity
        case .sharpness: sharpness
        case .attack: attack
        case .decay: decay
        case .release: release
        case .sustained: sustained ? 1 : 0
        }
    }

    mutating func set(_ value: Double, for parameter: HapticParameter) {
        switch parameter {
        case .intensity: intensity = value
        case .sharpness: sharpness = value
        case .attack: attack = value
        case .decay: decay = value
        case .release: release = value
        case .sustained: sustained = value != 0
        }
    }

    mutating func resetParameters(using capabilities: HapticEventCapabilities) {
        for parameter in HapticParameter.allCases {
            if let range = capabilities.ranges[parameter] {
                set(range.defaultValue, for: parameter)
            }
        }
    }

    struct Event: Equatable, Sendable {
        let time: Double
        let duration: Double
    }

    enum ValidationError: LocalizedError, Equatable, Sendable {
        case invalidParameters, invalidCapabilities, unavailableParameter, outsideDeviceRange
        var errorDescription: String? {
            switch self {
            case .invalidParameters:
                "Use finite values, a duration above 0 and up to 30 seconds, 1 to 8 pulses, and a gap from 0 to 2 seconds."
            case .invalidCapabilities:
                "The device returned invalid parameter limits."
            case .unavailableParameter:
                "Required haptic parameter ranges are unavailable on this device."
            case .outsideDeviceRange:
                "A parameter is outside the range reported by this device. Reset parameters or adjust the value."
            }
        }
    }

    func events() throws -> [Event] {
        guard HapticParameter.allCases.allSatisfy({ value(for: $0).isFinite }),
              duration.isFinite, duration > 0, duration <= Self.maximumContinuousDuration,
              Self.pulseRange.contains(pulseCount), Self.gapRange.contains(gap), gap.isFinite else {
            throw ValidationError.invalidParameters
        }
        let pulseDuration = kind == .continuous ? duration : 0
        return (0..<pulseCount).map {
            Event(time: Double($0) * (pulseDuration + gap), duration: pulseDuration)
        }
    }
}
