import SwiftUI

struct CustomHapticsView: View {
    @Bindable var controller: HapticsController
    @State private var configuration = CustomHapticConfiguration.defaults

    var body: some View {
        Form {
            Section {
                Picker("Event", selection: $configuration.kind) {
                    ForEach(CustomHapticConfiguration.EventKind.allCases) { kind in
                        Text(kind.title).tag(kind)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("custom.kind")
                parameter("Intensity", value: $configuration.intensity, range: 0...1, step: 0.05)
                parameter("Sharpness", value: $configuration.sharpness, range: 0...1, step: 0.05)
            }
            Section("Timing") {
                if configuration.kind == .continuous {
                    parameter("Duration", value: $configuration.duration, range: 0.05...3, step: 0.05, seconds: true)
                }
                Stepper("Pulses: \(configuration.pulseCount)", value: $configuration.pulseCount, in: 1...8)
                    .accessibilityIdentifier("custom.pulses")
                parameter("Gap", value: $configuration.gap, range: 0.05...2, step: 0.05, seconds: true)
            }
            Section {
                Button {
                    controller.playCustom(configuration)
                } label: {
                    Label(controller.isPlaying ? "Playing" : "Play custom haptic", systemImage: "waveform")
                        .font(.title3)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                }
                .buttonStyle(.borderedProminent)
                .disabled(controller.isPlaying || validationMessage != nil)
                .accessibilityIdentifier("custom.play")
                if controller.isPlaying {
                    Button("Stop", systemImage: "stop.fill", action: controller.stop)
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                        .accessibilityIdentifier("custom.stop")
                }
                Text(validationMessage ?? controller.status)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("custom.status")
            } footer: {
                Text("Sharpness changes the feel from rounded to crisp. A gap is silence between pulses. Maximum pattern length: 10 seconds.")
            }
            Section {
                Button("Reset parameters") { configuration = .defaults }
                    .accessibilityIdentifier("custom.reset")
            }
        }
        .navigationTitle("Custom")
        .onDisappear { controller.stop() }
    }

    private var validationMessage: String? {
        do { _ = try configuration.events(); return nil }
        catch { return error.localizedDescription }
    }

    private func parameter(_ title: String, value: Binding<Double>, range: ClosedRange<Double>,
                           step: Double, seconds: Bool = false) -> some View {
        VStack(alignment: .leading) {
            LabeledContent(title) {
                HStack {
                    Text(value.wrappedValue, format: .number.precision(.fractionLength(2)))
                        .monospacedDigit()
                    if seconds { Text("s") }
                }
            }
            Slider(value: value, in: range, step: step) { Text(title) }
                .accessibilityIdentifier("custom." + title.lowercased())
        }
    }
}
