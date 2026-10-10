import Foundation

/// Edit these defaults to quickly experiment from code; the Custom screen exposes
/// the same parameters. Values are copied at Play, so edits cannot change playback.
nonisolated struct CustomHapticConfiguration: Equatable, Sendable {
    enum EventKind: String, CaseIterable, Identifiable, Sendable {
        case transient, continuous
        var id: Self { self }
        var title: LocalizedStringResource { self == .transient ? "Tap" : "Continuous" }
    }

    static let defaults = Self(
        kind: .transient,
        intensity: 0.65,
        sharpness: 0.35,
        duration: 0.20,
        pulseCount: 2,
        gap: 0.12
    )

    var kind: EventKind
    var intensity: Double
    var sharpness: Double
    /// Seconds per continuous pulse; transient taps have no duration.
    var duration: Double
    var pulseCount: Int
    /// Silence between pulses, in seconds.
    var gap: Double

    struct Event: Equatable, Sendable {
        let time: Double
        let duration: Double
    }

    enum ValidationError: LocalizedError, Equatable, Sendable {
        case invalidParameters, tooLong
        var errorDescription: String? {
            switch self {
            case .invalidParameters:
                "Use intensity and sharpness from 0 to 1, duration from 0.05 to 3 seconds, 1 to 8 pulses, and a gap from 0.05 to 2 seconds."
            case .tooLong:
                "Keep the complete pattern within 10 seconds."
            }
        }
    }

    func events() throws -> [Event] {
        guard intensity.isFinite, sharpness.isFinite, duration.isFinite, gap.isFinite,
              (0...1).contains(intensity), (0...1).contains(sharpness),
              (0.05...3).contains(duration), (1...8).contains(pulseCount),
              (0.05...2).contains(gap) else {
            throw ValidationError.invalidParameters
        }
        let pulseDuration = kind == .continuous ? duration : 0
        let lastEnd = Double(pulseCount - 1) * (pulseDuration + gap) + pulseDuration
        guard lastEnd <= 10 else { throw ValidationError.tooLong }
        return (0..<pulseCount).map {
            Event(time: Double($0) * (pulseDuration + gap), duration: pulseDuration)
        }
    }
}
