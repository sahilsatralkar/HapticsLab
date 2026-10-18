import Foundation

/// A value snapshot captured by Play. Envelope values are normalized, not seconds.
nonisolated struct CustomHapticConfiguration: Equatable, Sendable {
    enum EventKind: String, CaseIterable, Sendable {
        case transient, continuous
    }

    // Core Haptics documents 30 seconds per continuous event. No device-specific
    // duration query exists. Pulse count and gap are explicitly app limits.
    static let maximumContinuousDuration = 30.0
    static let pulseRange = 1...8
    static let gapRange = 0.0...2.0
    static let defaults = Self(intensity: 0.65, sharpness: 0.35,
                               duration: 0.2, pulseCount: 1, gap: 0.12)

    var isContinuous = false
    var kind: EventKind { isContinuous ? .continuous : .transient }
    var intensity: Double
    var sharpness: Double
    var duration: Double
    var pulseCount: Int
    var gap: Double
    var attack: Double = 0
    var decay: Double = 0
    var release: Double = 0
    var sustained: Bool = true
    var variesOverTime = false
    var curvePoints: [HapticCurvePoint] = []
    var usesCurves: Bool { isContinuous && variesOverTime }

    // A testing/UI limit, not a device-reported maximum.
    static let curvePointRange = 2...16

    mutating func setVariation(_ enabled: Bool) {
        if enabled && curvePoints.isEmpty {
            curvePoints = [0.0, 0.5, 1.0].map {
                HapticCurvePoint(position: $0, intensity: intensity, sharpness: sharpness)
            }
        }
        variesOverTime = enabled
    }

    var curveBaseIntensity: Double { curvePoints.map(\.intensity).max() ?? intensity }
    var curveBaseSharpness: Double { curvePoints.first?.sharpness ?? sharpness }

    func validateCurvePoints() throws {
        guard usesCurves else { return }
        guard Self.curvePointRange.contains(curvePoints.count),
              Set(curvePoints.map(\.id)).count == curvePoints.count,
              curvePoints.first?.position == 0, curvePoints.last?.position == 1,
              duration.isFinite, duration > 0 else { throw ValidationError.invalidCurve }
        var previous = -Double.infinity
        for point in curvePoints {
            let time = point.position * duration
            guard point.position.isFinite, point.intensity.isFinite, point.sharpness.isFinite,
                  (0...1).contains(point.position), time.isFinite, time > previous else {
                throw ValidationError.invalidCurve
            }
            previous = time
        }
    }

    func pointTimeError(_ time: Double, id: UUID) -> String? {
        guard time.isFinite, duration.isFinite, duration > 0,
              let index = curvePoints.firstIndex(where: { $0.id == id }),
              index > 0, index < curvePoints.count - 1 else {
            return "Only intermediate point times can be edited."
        }
        let position = time / duration
        guard position > curvePoints[index - 1].position,
              position < curvePoints[index + 1].position else {
            return "Time must be strictly between the previous and next point."
        }
        return nil
    }

    mutating func setPointTime(_ time: Double, id: UUID) {
        guard pointTimeError(time, id: id) == nil,
              let index = curvePoints.firstIndex(where: { $0.id == id }) else { return }
        curvePoints[index].position = time / duration
    }

    var canAddCurvePoint: Bool {
        guard usesCurves, curvePoints.count >= 2, curvePoints.count < Self.curvePointRange.upperBound,
              (try? validateCurvePoints()) != nil else { return false }
        return insertionIndex != nil
    }

    private var insertionIndex: Int? {
        curvePoints.indices.dropLast().filter {
            let mid = (curvePoints[$0].position + curvePoints[$0 + 1].position) / 2
            return mid > curvePoints[$0].position && mid < curvePoints[$0 + 1].position
        }.max {
            curvePoints[$0 + 1].position - curvePoints[$0].position <
                curvePoints[$1 + 1].position - curvePoints[$1].position
        }
    }

    mutating func addCurvePoint() {
        guard canAddCurvePoint, let index = insertionIndex else { return }
        let a = curvePoints[index], b = curvePoints[index + 1]
        curvePoints.insert(HapticCurvePoint(
            position: (a.position + b.position) / 2,
            intensity: (a.intensity + b.intensity) / 2,
            sharpness: (a.sharpness + b.sharpness) / 2), at: index + 1)
    }

    mutating func removeCurvePoint(id: UUID) {
        guard let index = curvePoints.firstIndex(where: { $0.id == id }),
              index > 0, index < curvePoints.count - 1 else { return }
        curvePoints.remove(at: index)
    }

    var activeParameters: [HapticParameter] {
        [.intensity, .sharpness, .attack, .sustained, sustained ? .release : .decay]
    }

    func value(for parameter: HapticParameter) -> Double {
        switch parameter {
        case .intensity: usesCurves ? curveBaseIntensity : intensity
        case .sharpness: usesCurves ? curveBaseSharpness : sharpness
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

    mutating func setContinuous(_ enabled: Bool, using capabilities: HapticCapabilities) {
        guard enabled != isContinuous else { return }
        isContinuous = enabled
        let limits = capabilities.event(kind)
        for parameter in HapticParameter.allCases {
            let current = value(for: parameter)
            if current.isFinite, let range = limits.ranges[parameter], !range.contains(current) {
                set(range.defaultValue, for: parameter)
            }
        }
    }

    struct Event: Equatable, Sendable {
        let time: Double
        let duration: Double
    }

    enum ValidationError: LocalizedError, Equatable, Sendable {
        case invalidParameters, invalidCapabilities, unavailableParameter, outsideDeviceRange, invalidCurve, unavailableCurves
        var errorDescription: String? {
            switch self {
            case .invalidCurve:
                "Use 2 to 16 curve points with finite values and strictly increasing times from Start to End."
            case .unavailableCurves:
                "This device did not report the dynamic intensity and sharpness ranges required for curves."
            case .invalidParameters:
                "Use finite values, a continuous duration above 0 and up to 30 seconds, 1 to 8 repetitions, and a gap from 0 to 2 seconds."
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
        try validateCurvePoints()
        guard HapticParameter.allCases.allSatisfy({ value(for: $0).isFinite }),
              duration.isFinite, duration >= 0, duration <= Self.maximumContinuousDuration,
              !isContinuous || duration > 0,
              Self.pulseRange.contains(pulseCount), Self.gapRange.contains(gap), gap.isFinite else {
            throw ValidationError.invalidParameters
        }
        let eventDuration = isContinuous ? duration : 0
        return (0..<pulseCount).map {
            Event(time: Double($0) * (eventDuration + gap), duration: eventDuration)
        }
    }
}

nonisolated struct HapticCurvePoint: Identifiable, Equatable, Sendable {
    let id: UUID
    // Fraction of Duration; editing Duration intentionally rescales all point times.
    var position: Double
    var intensity: Double
    var sharpness: Double

    init(id: UUID = UUID(), position: Double, intensity: Double, sharpness: Double) {
        self.id = id
        self.position = position
        self.intensity = intensity
        self.sharpness = sharpness
    }
}
