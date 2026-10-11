import SwiftUI

struct CustomHapticsView: View {
    @Bindable var controller: HapticsController
    @State private var configuration: CustomHapticConfiguration

    init(controller: HapticsController) {
        self.controller = controller
        var initial = CustomHapticConfiguration.defaults
        initial.resetParameters(using: controller.capabilities.event(initial.kind))
        _configuration = State(initialValue: initial)
    }

    private var limits: HapticEventCapabilities { controller.capabilities.event(configuration.kind) }

    var body: some View {
        Form {
            Section {
                HapticValueSlider(title: "Duration", value: $configuration.duration,
                                  range: 0...CustomHapticConfiguration.maximumContinuousDuration,
                                  identifier: "custom.duration", seconds: true)
                HapticParameterControl(parameter: .intensity, configuration: $configuration, limits: limits)
                HapticParameterControl(parameter: .sharpness, configuration: $configuration, limits: limits)
            } footer: {
                Text("A duration of 0 plays a tap; above 0 plays a continuous haptic. Switching between them resets parameters to this device’s defaults.")
            }
            HapticEnvelopeSection(configuration: $configuration, limits: limits)
            HapticTimingSection(configuration: $configuration)
            if controller.isPlaying {
                Section {
                    Button("Stop", action: controller.stop)
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                        .accessibilityIdentifier("custom.stop")
                }
            }
            Section {
                Button("Reset parameters") {
                    configuration = .defaults
                    configuration.resetParameters(using: controller.capabilities.event(configuration.kind))
                }
                .accessibilityIdentifier("custom.reset")
            }
        }
        .buttonBorderShape(.roundedRectangle(radius: 12))
        .navigationTitle("Custom haptics")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    controller.playCustom(configuration)
                } label: {
                    Label("Play custom haptic", systemImage: "play.fill")
                        .labelStyle(.iconOnly)
                }
                .foregroundStyle(playDisabled ? Color.secondary : Color.primary)
                .disabled(playDisabled)
                .accessibilityIdentifier("custom.play")
                .accessibilityHint(validationMessage ?? "")
            }
        }
        .onChange(of: configuration.kind) { _, kind in
            configuration.resetParameters(using: controller.capabilities.event(kind))
        }
        .onDisappear { controller.stop() }
        .alert("Playback unavailable", isPresented: Binding(
            get: { controller.errorMessage != nil },
            set: { if !$0 { controller.clearError() } }
        )) {
            Button("OK", role: .cancel, action: controller.clearError)
        } message: {
            Text(controller.errorMessage ?? "")
        }
    }

    private var playDisabled: Bool {
        controller.isPlaying || (controller.supportsCustomHaptics && validationMessage != nil)
    }

    private var validationMessage: String? {
        do {
            _ = try configuration.events()
            try limits.validate(configuration)
            return nil
        } catch { return error.localizedDescription }
    }
}

private struct HapticEnvelopeSection: View {
    @Binding var configuration: CustomHapticConfiguration
    let limits: HapticEventCapabilities

    var body: some View {
        Section {
            HapticParameterControl(parameter: .attack, configuration: $configuration, limits: limits)
            if let sustain = limits.ranges[.sustained],
               sustain.contains(0), sustain.contains(1) {
                Toggle("Sustain", isOn: $configuration.sustained)
                    .accessibilityIdentifier("custom.sustained")
            } else {
                LabeledContent("Sustain", value: limits.ranges[.sustained] == nil ? "Unavailable" : "Fixed by device")
            }
            if configuration.sustained {
                HapticParameterControl(parameter: .release, configuration: $configuration, limits: limits)
            } else {
                HapticParameterControl(parameter: .decay, configuration: $configuration, limits: limits)
            }
        } header: {
            Text("Envelope")
        } footer: {
            Text("Attack controls the rise. With Sustain off, Decay controls the fall; with Sustain on, Release controls the fade after the event. These values are normalized, not seconds.")
        }
    }
}

private struct HapticParameterControl: View {
    let parameter: HapticParameter
    @Binding var configuration: CustomHapticConfiguration
    let limits: HapticEventCapabilities

    var body: some View {
        if let range = limits.ranges[parameter] {
            HapticValueSlider(title: parameter.title,
                              value: Binding(get: { configuration.value(for: parameter) },
                                             set: { configuration.set($0, for: parameter) }),
                              range: range.bounds, identifier: "custom." + parameter.rawValue)
        } else {
            LabeledContent {
                Text("Unavailable for this event")
            } label: {
                Text(parameter.title)
            }
            .accessibilityIdentifier("custom.unavailable." + parameter.rawValue)
        }
    }
}

private struct HapticTimingSection: View {
    @Binding var configuration: CustomHapticConfiguration

    var body: some View {
        Section {
            Stepper("Pulses: \(configuration.pulseCount)", value: $configuration.pulseCount,
                    in: CustomHapticConfiguration.pulseRange)
                .accessibilityIdentifier("custom.pulses")
            HapticValueSlider(title: "Gap", value: $configuration.gap,
                              range: CustomHapticConfiguration.gapRange,
                              identifier: "custom.gap", seconds: true)
        } header: {
            Text("Timing")
        } footer: {
            Text("Core Haptics allows up to 30 seconds per continuous event. This app allows 1–8 pulses and 0–2 seconds between scheduled events. A release tail can overlap that gap.")
        }
    }
}

private struct HapticValueSlider: View {
    let title: LocalizedStringResource
    @Binding var value: Double
    let range: ClosedRange<Double>
    let identifier: String
    var seconds = false

    var body: some View {
        VStack(alignment: .leading) {
            LabeledContent {
                HStack {
                    Text(value, format: .number.precision(.fractionLength(3)))
                        .monospacedDigit()
                    if seconds { Text("s") }
                }
            } label: {
                Text(title)
            }
            if range.lowerBound < range.upperBound {
                Slider(value: $value, in: range) { Text(title) }
                    .accessibilityIdentifier(identifier)
            }
            HStack {
                Text(range.lowerBound, format: .number.precision(.fractionLength(0...3)))
                Spacer()
                Text(range.upperBound, format: .number.precision(.fractionLength(0...3)))
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Range \(range.lowerBound) to \(range.upperBound)")
        }
    }
}
