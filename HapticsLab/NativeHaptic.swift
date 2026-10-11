import SwiftUI

/// Native system feedback requests, including canvas feedback for Apple Pencil Pro.
/// A successful request does not guarantee tactile output on the current hardware.
nonisolated enum NativeHaptic: String, CaseIterable, Identifiable, Sendable {
    case light, medium, heavy, soft, solid, rigid, impact
    case selection, success, warning, error
    case alignment, pathComplete

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
        case .alignment: "Alignment*"
        case .pathComplete: "Path complete*"
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
        case .alignment: .alignment
        case .pathComplete: .pathComplete
        }
    }
}

nonisolated struct NativeHapticRequest: Equatable, Sendable {
    let sequence: UInt64
    let haptic: NativeHaptic
}
