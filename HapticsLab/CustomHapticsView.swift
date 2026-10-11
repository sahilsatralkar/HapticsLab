import SwiftUI

struct CustomHapticsView: View {
    @Bindable var controller: HapticsController
    @State private var configuration: CustomHapticConfiguration
    @State private var presentedHelp: HapticHelpTopic?

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
                HapticParameterControl(parameter: .intensity, configuration: $configuration, limits: limits)
                HapticParameterControl(parameter: .sharpness, configuration: $configuration, limits: limits)
                Toggle("Continuous", isOn: Binding(
                    get: { configuration.isContinuous },
                    set: { configuration.setContinuous($0, using: controller.capabilities) }
                ))
                .accessibilityIdentifier("custom.continuous")
                if configuration.isContinuous {
                    HapticValueSlider(title: "Duration", value: $configuration.duration,
                                      range: 0...CustomHapticConfiguration.maximumContinuousDuration,
                                      identifier: "custom.duration", seconds: true)
                    if configuration.duration == 0 {
                        Text("Duration must be greater than 0.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                HapticSectionHeader(topic: .haptics, presentedHelp: $presentedHelp)
            }
            HapticRepetitionSection(configuration: $configuration, presentedHelp: $presentedHelp)
            HapticEnvelopeSection(configuration: $configuration, limits: limits, presentedHelp: $presentedHelp)
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
                    if controller.isPlaying {
                        controller.stop()
                    } else {
                        controller.playCustom(configuration)
                    }
                } label: {
                    if controller.isPlaying {
                        Label("Stop custom haptic", systemImage: "stop.fill")
                    } else {
                        Label("Play custom haptic", systemImage: "play.fill")
                    }
                }
                .labelStyle(.iconOnly)
                .foregroundStyle(playbackButtonDisabled ? Color.secondary : Color.primary)
                .disabled(playbackButtonDisabled)
                .accessibilityIdentifier(controller.isPlaying ? "custom.stop" : "custom.play")
                .accessibilityHint(controller.isPlaying ? "" : (validationMessage ?? ""))
            }
        }
        .sheet(item: $presentedHelp) { topic in
            HapticHelpSheet(topic: topic)
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

    private var playbackButtonDisabled: Bool {
        !controller.isPlaying && controller.supportsCustomHaptics && validationMessage != nil
    }

    private var validationMessage: String? {
        do {
            _ = try configuration.events()
            try limits.validate(configuration)
            return nil
        } catch { return error.localizedDescription }
    }
}

private enum HapticHelpTopic: String, Identifiable {
    case haptics, repetition, envelope

    var id: Self { self }

    var title: LocalizedStringResource {
        switch self {
        case .haptics: "Haptics"
        case .repetition: "Repetition"
        case .envelope: "Envelope"
        }
    }

    var informationLabel: LocalizedStringResource {
        switch self {
        case .haptics: "About Haptics"
        case .repetition: "About Repetition"
        case .envelope: "About Envelope"
        }
    }

    var explanation: LocalizedStringResource {
        switch self {
        case .haptics:
            "Intensity controls the strength. Sharpness changes the feel from soft and rounded to crisp. Turn on Continuous to set how long each vibration lasts; leave it off for brief taps."
        case .repetition:
            "Choose how many times the haptic plays. For a single vibration, leave Repetitions at 1. Increase it to test a repeating pattern, then adjust Gap to change the spacing between vibrations."
        case .envelope:
            "Shape how each vibration builds and fades. Attack time controls how gradually it reaches the selected intensity. With Sustained on, the vibration holds its strength before fading with Release time. With Sustained off, it fades with Decay time. Higher values make the rise or fade longer. These values are relative, not seconds. Change one control at a time and press Play to compare."
        }
    }
}

private struct HapticSectionHeader: View {
    let topic: HapticHelpTopic
    @Binding var presentedHelp: HapticHelpTopic?

    var body: some View {
        HStack {
            Text(topic.title)
            Spacer()
            Button {
                presentedHelp = topic
            } label: {
                Image(systemName: "info.circle")
                    .font(.body)
                    .padding()
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(.primary)
            .accessibilityLabel(Text(topic.informationLabel))
            .accessibilityIdentifier("custom.info." + topic.rawValue)
        }
        .textCase(nil)
    }
}

private struct HapticHelpSheet: View {
    let topic: HapticHelpTopic
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        NavigationStack {
            ScrollView {
                Text(topic.explanation)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .navigationTitle(Text(topic.title))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .accessibilityIdentifier("custom.info.done")
                }
            }
        }
        .presentationDetents(dynamicTypeSize.isAccessibilitySize ? [.large] : [.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

private struct HapticEnvelopeSection: View {
    @Binding var configuration: CustomHapticConfiguration
    let limits: HapticEventCapabilities
    @Binding var presentedHelp: HapticHelpTopic?

    var body: some View {
        Section {
            if let sustain = limits.ranges[.sustained],
               sustain.contains(0), sustain.contains(1) {
                Toggle("Sustained", isOn: $configuration.sustained)
                    .accessibilityIdentifier("custom.sustained")
            } else {
                LabeledContent("Sustained", value: limits.ranges[.sustained] == nil ? "Unavailable" : "Fixed by device")
            }
            HapticParameterControl(parameter: .attack, configuration: $configuration, limits: limits)
            if configuration.sustained {
                HapticParameterControl(parameter: .release, configuration: $configuration, limits: limits)
            } else {
                HapticParameterControl(parameter: .decay, configuration: $configuration, limits: limits)
            }
        } header: {
            HapticSectionHeader(topic: .envelope, presentedHelp: $presentedHelp)
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

private struct HapticRepetitionSection: View {
    @Binding var configuration: CustomHapticConfiguration
    @Binding var presentedHelp: HapticHelpTopic?

    var body: some View {
        Section {
            Stepper("Repetitions: \(configuration.pulseCount)", value: $configuration.pulseCount,
                    in: CustomHapticConfiguration.pulseRange)
                .accessibilityIdentifier("custom.repetitions")
            if configuration.pulseCount > 1 {
                HapticValueSlider(title: "Gap", value: $configuration.gap,
                                  range: CustomHapticConfiguration.gapRange,
                                  identifier: "custom.gap", seconds: true)
            }
        } header: {
            HapticSectionHeader(topic: .repetition, presentedHelp: $presentedHelp)
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
