import CoreHaptics
import UIKit
import Darwin

nonisolated enum HapticParameter: String, CaseIterable, Identifiable, Sendable {
    case intensity, sharpness, attack, decay, release, sustained
    var id: Self { self }
    var title: LocalizedStringResource {
        switch self {
        case .intensity: "Intensity"
        case .sharpness: "Sharpness"
        case .attack: "Attack time"
        case .decay: "Decay time"
        case .release: "Release time"
        case .sustained: "Sustained"
        }
    }
    var parameterID: CHHapticEvent.ParameterID {
        switch self {
        case .intensity: .hapticIntensity
        case .sharpness: .hapticSharpness
        case .attack: .attackTime
        case .decay: .decayTime
        case .release: .releaseTime
        case .sustained: .sustained
        }
    }
}

nonisolated struct HapticParameterRange: Equatable, Sendable {
    let minimum: Double
    let maximum: Double
    let defaultValue: Double
    var bounds: ClosedRange<Double> { minimum...maximum }

    init(minimum: Double, maximum: Double, defaultValue: Double) throws {
        guard minimum.isFinite, maximum.isFinite, defaultValue.isFinite,
              minimum <= maximum, (minimum...maximum).contains(defaultValue) else {
            throw CustomHapticConfiguration.ValidationError.invalidCapabilities
        }
        self.minimum = minimum
        self.maximum = maximum
        self.defaultValue = defaultValue
    }

    func contains(_ value: Double) -> Bool { value.isFinite && bounds.contains(value) }
}

nonisolated struct HapticEventCapabilities: Equatable, Sendable {
    let ranges: [HapticParameter: HapticParameterRange]
    let unavailable: [HapticParameter: String]
    var dynamicRanges: [HapticCurveParameter: HapticParameterRange] = [:]
    var supportsCurves: Bool { HapticCurveParameter.allCases.allSatisfy { dynamicRanges[$0] != nil } }

    func validate(_ configuration: CustomHapticConfiguration) throws {
        try configuration.validateCurvePoints()
        for parameter in [HapticParameter.intensity, .sharpness] {
            guard ranges[parameter] != nil else {
                throw CustomHapticConfiguration.ValidationError.unavailableParameter
            }
        }
        for parameter in HapticParameter.allCases {
            guard let range = ranges[parameter] else {
                // Optional envelope parameters are omitted, never assigned invented ranges.
                continue
            }
            guard range.contains(configuration.value(for: parameter)) else {
                throw CustomHapticConfiguration.ValidationError.outsideDeviceRange
            }
        }
        if configuration.usesCurves {
            guard supportsCurves else { throw CustomHapticConfiguration.ValidationError.unavailableCurves }
            for point in configuration.curvePoints {
                guard ranges[.intensity]?.contains(point.intensity) == true,
                      ranges[.sharpness]?.contains(point.sharpness) == true else {
                    throw CustomHapticConfiguration.ValidationError.outsideDeviceRange
                }
                for parameter in HapticCurveParameter.allCases {
                    let value = parameter.value(at: point, configuration: configuration)
                    let base = Float(parameter == .intensity ? configuration.curveBaseIntensity : configuration.curveBaseSharpness)
                    let effective = parameter == .intensity ? base * Float(value) : base + Float(value)
                    let eventRange = ranges[parameter == .intensity ? .intensity : .sharpness]
                    guard effective.isFinite,
                          eventRange?.contains(Double(effective)) == true,
                          dynamicRanges[parameter]?.contains(Double(Float(value))) == true else {
                        throw CustomHapticConfiguration.ValidationError.outsideDeviceRange
                    }
                }
            }
        }
    }
}

nonisolated struct HapticCapabilities: Equatable, Sendable {
    let supportsHaptics: Bool
    let events: [CustomHapticConfiguration.EventKind: HapticEventCapabilities]

    func event(_ kind: CustomHapticConfiguration.EventKind) -> HapticEventCapabilities {
        events[kind] ?? HapticEventCapabilities(ranges: [:], unavailable: [:])
    }

    @MainActor static func detect() -> Self {
        let hardware = CHHapticEngine.capabilitiesForHardware()
        var events: [CustomHapticConfiguration.EventKind: HapticEventCapabilities] = [:]
        var dynamicRanges: [HapticCurveParameter: HapticParameterRange] = [:]
        for parameter in HapticCurveParameter.allCases {
            if let attributes = try? hardware.attributes(forDynamicParameter: parameter.parameterID),
               let range = try? HapticParameterRange(minimum: Double(attributes.minValue),
                                                     maximum: Double(attributes.maxValue),
                                                     defaultValue: Double(attributes.defaultValue)) {
                dynamicRanges[parameter] = range
            }
        }
        for kind in CustomHapticConfiguration.EventKind.allCases {
            var ranges: [HapticParameter: HapticParameterRange] = [:]
            var unavailable: [HapticParameter: String] = [:]
            for parameter in HapticParameter.allCases {
                do {
                    let attributes = try hardware.attributes(
                        forEventParameter: parameter.parameterID,
                        eventType: kind == .transient ? .hapticTransient : .hapticContinuous)
                    ranges[parameter] = try HapticParameterRange(
                        minimum: Double(attributes.minValue),
                        maximum: Double(attributes.maxValue),
                        defaultValue: Double(attributes.defaultValue))
                } catch {
                    unavailable[parameter] = error.localizedDescription
                }
            }
            events[kind] = HapticEventCapabilities(ranges: ranges, unavailable: unavailable, dynamicRanges: dynamicRanges)
        }
        return Self(supportsHaptics: hardware.supportsHaptics, events: events)
    }
}

nonisolated struct HapticDeviceInfo: Equatable, Sendable {
    let model: String
    let systemVersion: String
    let hardwareIdentifier: String
    let isSimulator: Bool

    @MainActor static func detect() -> Self {
        let device = UIDevice.current
        #if targetEnvironment(simulator)
        let model = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "Simulator"
        return Self(model: device.model, systemVersion: device.systemVersion,
                    hardwareIdentifier: model, isSimulator: true)
        #else
        var size = 0
        var identifier = "Unavailable"
        if sysctlbyname("hw.machine", nil, &size, nil, 0) == 0, size > 0 {
            var buffer = [CChar](repeating: 0, count: size)
            if sysctlbyname("hw.machine", &buffer, &size, nil, 0) == 0 {
                identifier = String(decoding: buffer.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) }, as: UTF8.self)
            }
        }
        return Self(model: device.model, systemVersion: device.systemVersion,
                    hardwareIdentifier: identifier, isSimulator: false)
        #endif
    }
}

nonisolated enum HapticCurveParameter: String, CaseIterable, Sendable {
    case intensity, sharpness
    var parameterID: CHHapticDynamicParameter.ID {
        switch self {
        case .intensity: .hapticIntensityControl
        case .sharpness: .hapticSharpnessControl
        }
    }

    func value(at point: HapticCurvePoint, configuration: CustomHapticConfiguration) -> Double {
        switch self {
        case .intensity:
            configuration.curveBaseIntensity == 0 ? 1 : point.intensity / configuration.curveBaseIntensity
        case .sharpness:
            point.sharpness - configuration.curveBaseSharpness
        }
    }
}
