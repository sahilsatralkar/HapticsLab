import SwiftUI

/// Native impact, selection, and notification patterns for iPhone testing.
/// Canvas feedback is excluded; iOS availability does not guarantee iPhone vibration.
nonisolated enum NativeHaptic: String, CaseIterable, Identifiable, Sendable {
    case light, medium, heavy, soft, solid, rigid, impact
    case selection, success, warning, error

    var id: String { rawValue }
    var title: LocalizedStringResource {
        switch self {
        case .light: "Light"
        case .medium: "Medium"
        case .heavy: "Heavy"
        case .soft: "Soft"
        case .solid: "Solid"
        case .rigid: "Rigid"
        case .impact: "Default impact"
        case .selection: "Selection"
        case .success: "Success"
        case .warning: "Warning"
        case .error: "Error"
        }
    }
    var symbol: String {
        switch self {
        case .success: "checkmark.circle"
        case .warning: "exclamationmark.triangle"
        case .error: "xmark.circle"
        case .selection: "switch.2"
        default: "waveform"
        }
    }

    /// Keep the native system patterns unchanged so the sample is a useful baseline.
    var feedback: SensoryFeedback {
        switch self {
        case .light: .impact(weight: .light)
        case .medium: .impact(weight: .medium)
        case .heavy: .impact(weight: .heavy)
        case .soft: .impact(flexibility: .soft)
        case .solid: .impact(flexibility: .solid)
        case .rigid: .impact(flexibility: .rigid)
        case .impact: .impact
        case .selection: .selection
        case .success: .success
        case .warning: .warning
        case .error: .error
        }
    }
}

nonisolated struct NativeHapticRequest: Equatable, Sendable {
    let sequence: UInt64
    let haptic: NativeHaptic
}
