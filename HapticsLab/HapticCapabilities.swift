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
        case .attack: "Attack"
        case .decay: "Decay"
        case .release: "Release"
        case .sustained: "Sustain"
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

    func validate(_ configuration: CustomHapticConfiguration) throws {
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
            events[kind] = HapticEventCapabilities(ranges: ranges, unavailable: unavailable)
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
