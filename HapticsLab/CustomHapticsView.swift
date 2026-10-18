import SwiftUI

struct CustomHapticsView: View {
    @Bindable var controller: HapticsController
    @Binding private var configuration: CustomHapticConfiguration
    @State private var presentedHelp: HapticHelpTopic?
    @State private var shareFile: HapticShareFile?
    @State private var retainedShareFile: HapticShareFile?
    @State private var shareCompletionError: String?
    @State private var exportError: String?

    init(controller: HapticsController) {
        self.controller = controller
        _configuration = Binding(
            get: { controller.customConfiguration },
            set: { controller.customConfiguration = $0 }
        )
    }

    private var limits: HapticEventCapabilities { controller.capabilities.event(configuration.kind) }

    var body: some View {
        Form {
            Section {
                if !configuration.usesCurves {
                    HapticParameterControl(parameter: .intensity, configuration: $configuration, limits: limits)
                    HapticParameterControl(parameter: .sharpness, configuration: $configuration, limits: limits)
                }
                Toggle("Continuous", isOn: Binding(
                    get: { configuration.isContinuous },
                    set: { configuration.setContinuous($0, using: controller.capabilities) }
                ))
                .accessibilityIdentifier("custom.continuous")
                if configuration.isContinuous {
                    HapticValueSlider(title: "Duration", value: $configuration.duration,
                                      range: 0...CustomHapticConfiguration.maximumContinuousDuration,
                                      identifier: "custom.duration", seconds: true, requiresPositive: true)
                    Toggle("Vary over time", isOn: Binding(
                        get: { configuration.variesOverTime },
                        set: { configuration.setVariation($0) }
                    ))
                    .disabled(!limits.supportsCurves && !configuration.variesOverTime)
                    .accessibilityIdentifier("custom.curves.enabled")
                    if !limits.supportsCurves {
                        Text("Dynamic intensity and sharpness controls are unavailable on this device.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    if configuration.usesCurves && configuration.duration > 0 {
                        HapticCurveControls(configuration: $configuration, limits: limits)
                    }
                    if configuration.duration == 0 {
                        Text("Duration must be greater than 0.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                HapticSectionHeader(topic: .haptics, presentedHelp: $presentedHelp)
            }
            if let validationMessage {
                Section {
                    Text(validationMessage)
                        .foregroundStyle(.red)
                        .accessibilityIdentifier("custom.validation")
                }
            }
            HapticRepetitionSection(configuration: $configuration, presentedHelp: $presentedHelp)
            HapticEnvelopeSection(configuration: $configuration, limits: limits, presentedHelp: $presentedHelp)
            Section {
                Button("Reset to defaults", action: controller.resetCustomConfiguration)
                    .accessibilityIdentifier("custom.reset")
            }
        }
        .buttonBorderShape(.roundedRectangle(radius: 12))
        .navigationTitle("Custom")
        .navigationBarTitleDisplayMode(.inline)
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
            ToolbarSpacer(.fixed, placement: .topBarTrailing)
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    do {
                        exportError = nil
                        shareCompletionError = nil
                        let file = try HapticShareFile(
                            source: HapticSwiftExport.source(for: configuration, capabilities: limits))
                        retainedShareFile = file
                        shareFile = file
                    } catch {
                        exportError = error.localizedDescription
                    }
                } label: {
                    Label("Share Swift code", systemImage: "square.and.arrow.up")
                        .labelStyle(.iconOnly)
                }
                .foregroundStyle(validationMessage == nil ? Color.primary : Color.secondary)
                .disabled(validationMessage != nil)
                .accessibilityIdentifier("custom.export")
                .accessibilityHint(validationMessage ?? "")
            }
        }
        .sheet(item: $presentedHelp) { topic in
            HapticHelpSheet(topic: topic)
        }
        .sheet(item: $shareFile, onDismiss: {
            // Retain the attachment through child presentations such as Save to Files.
            try? retainedShareFile?.remove()
            retainedShareFile = nil
            exportError = shareCompletionError
            shareCompletionError = nil
        }) { file in
            HapticShareSheet(file: file) { message in
                shareCompletionError = message
                shareFile = nil
            }
        }
        .alert("Sharing unavailable", isPresented: Binding(
            get: { exportError != nil },
            set: { if !$0 { exportError = nil } }
        )) {
            Button("OK", role: .cancel) { exportError = nil }
        } message: {
            Text(exportError ?? "")
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
            "Intensity controls the strength. Sharpness changes the feel from soft and rounded to crisp. Turn on Continuous to set how long each vibration lasts; leave it off for brief taps. Vary over time lets you edit intensity and sharpness at 2 to 16 points. Expand a point to edit it. Start and End follow Duration; intermediate times must remain in order. Changing Duration scales every point time. Add point preserves the current curve; deleting a point connects its neighbours directly. The same shape repeats for each repetition. Envelope settings still affect the result."
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
            Button {
                presentedHelp = topic
            } label: {
                Image(systemName: "info.circle")
                    .font(.body)
                    .padding(.vertical)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(.primary)
            .accessibilityLabel(Text(topic.informationLabel))
            .accessibilityIdentifier("custom.info." + topic.rawValue)
            Spacer()
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
    var requiresPositive = false
    var additionalValidation: ((Double) -> String?)? = nil
    @State private var isEditing = false
    @Environment(\.locale) private var locale

    var body: some View {
        VStack(alignment: .leading) {
            LabeledContent {
                Button {
                    isEditing = true
                } label: {
                    HStack {
                        Text(value, format: .number.precision(.significantDigits(1...8)))
                            .monospacedDigit()
                        if seconds { Text("s") }
                    }
                }
                .buttonStyle(.borderless)
                .foregroundStyle(.primary)
                .disabled(range.lowerBound == range.upperBound)
                .accessibilityLabel(Text("Edit \(String(localized: title))"))
                .accessibilityIdentifier(identifier + ".edit")
                .sheet(isPresented: $isEditing) {
                    HapticValueEditor(title: title, value: $value, range: range,
                                      requiresPositive: requiresPositive, seconds: seconds, locale: locale,
                                      additionalValidation: additionalValidation)
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

private struct HapticCurveControls: View {
    @Binding var configuration: CustomHapticConfiguration
    let limits: HapticEventCapabilities

    var body: some View {
        LabeledContent("Points", value: "\(configuration.curvePoints.count)")
        ForEach(configuration.curvePoints) { point in
            HapticCurvePointEditor(configuration: $configuration, point: point, limits: limits)
        }
        Button("Add point") { configuration.addCurvePoint() }
            .disabled(!configuration.canAddCurvePoint)
            .accessibilityIdentifier("custom.curves.add")
    }
}

private struct HapticCurvePointEditor: View {
    @Binding var configuration: CustomHapticConfiguration
    let point: HapticCurvePoint
    let limits: HapticEventCapabilities
    @State private var isExpanded = false

    private var index: Int { configuration.curvePoints.firstIndex(where: { $0.id == point.id }) ?? 0 }
    private var isEndpoint: Bool { index == 0 || index == configuration.curvePoints.count - 1 }
    private var title: LocalizedStringResource {
        if index == 0 { return "Start" }
        if index == configuration.curvePoints.count - 1 { return "End" }
        return "Point \(index + 1)"
    }
    private var time: Double { point.position * configuration.duration }

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            if isEndpoint {
                LabeledContent("Time") {
                    Text("\(time, format: .number.precision(.significantDigits(1...8))) s")
                }
            } else {
                HapticValueSlider(title: "Time", value: Binding(
                    get: { time },
                    set: { configuration.setPointTime($0, id: point.id) }
                ), range: 0...configuration.duration,
                   identifier: "custom.curves.point.\(point.id).time", seconds: true,
                   additionalValidation: { configuration.pointTimeError($0, id: point.id) })
            }
            if let range = limits.ranges[.intensity] {
                HapticValueSlider(title: "Intensity", value: value(\.intensity),
                                 range: range.bounds, identifier: "custom.curves.point.\(point.id).intensity")
            }
            if let range = limits.ranges[.sharpness] {
                HapticValueSlider(title: "Sharpness", value: value(\.sharpness),
                                 range: range.bounds, identifier: "custom.curves.point.\(point.id).sharpness")
            }
            if !isEndpoint {
                Button("Delete point", role: .destructive) { configuration.removeCurvePoint(id: point.id) }
                    .buttonStyle(.borderless)
                    .accessibilityIdentifier("custom.curves.point.\(point.id).delete")
            }
        } label: {
            VStack(alignment: .leading) {
                HStack {
                    Text(title)
                    Spacer()
                    Text("\(time, format: .number.precision(.significantDigits(1...6))) s")
                }
                Text("Intensity \(point.intensity, format: .number.precision(.significantDigits(1...4))) · Sharpness \(point.sharpness, format: .number.precision(.significantDigits(1...4)))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityIdentifier("custom.curves.point.\(point.id)")
    }

    private func value(_ keyPath: WritableKeyPath<HapticCurvePoint, Double>) -> Binding<Double> {
        Binding(
            get: { configuration.curvePoints.first(where: { $0.id == point.id })?[keyPath: keyPath] ?? point[keyPath: keyPath] },
            set: { newValue in
                guard let index = configuration.curvePoints.firstIndex(where: { $0.id == point.id }) else { return }
                configuration.curvePoints[index][keyPath: keyPath] = newValue
            })
    }
}
