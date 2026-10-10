import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var controller = HapticsController()
    @State private var request: NativeHapticRequest?
    @State private var sequence: UInt64 = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    HapticsGrid(controller: controller, onRequest: requestHaptic)
                    NavigationLink {
                        CustomHapticsView(controller: controller)
                    } label: {
                        HapticTileLabel(title: "Custom haptics testing")
                            .padding(.vertical)
                    }
                    .accessibilityIdentifier("haptics.custom")
                    HapticDeviceFooter(info: controller.deviceInfo, supportsHaptics: controller.supportsCustomHaptics)
                }
                .buttonStyle(HapticButtonStyle())
                .controlSize(.large)
                .padding()
            }
            .navigationTitle("Haptics Lab")
            .navigationBarTitleDisplayMode(.inline)
            .sensoryFeedback(trigger: request) { _, new in new?.haptic.feedback }
            .onChange(of: scenePhase) { _, phase in
                if phase != .active { controller.stop() }
            }
            .alert("Playback unavailable", isPresented: Binding(
                get: { controller.errorMessage != nil },
                set: { if !$0 { controller.clearError() } }
            )) {
                Button("OK", role: .cancel, action: controller.clearError)
            } message: {
                Text(controller.errorMessage ?? "")
            }
        }
    }

    private func requestHaptic(_ haptic: NativeHaptic) {
        sequence &+= 1
        request = NativeHapticRequest(sequence: sequence, haptic: haptic)
        controller.recordNativeRequest(String(localized: haptic.title))
    }
}

private struct HapticsGrid: View {
    let controller: HapticsController
    let onRequest: (NativeHaptic) -> Void
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(NativeHaptic.allCases) { haptic in
                Button {
                    onRequest(haptic)
                } label: {
                    HapticTileLabel(title: haptic.title)
                }
                .accessibilityIdentifier("haptics." + haptic.rawValue)
                .accessibilityValue(controller.status == "Requested: " + String(localized: haptic.title) ? "Requested" : "Ready")
            }
        }
    }
}

private struct HapticTileLabel: View {
    let title: LocalizedStringResource

    var body: some View {
        Text(title)
            .font(.title3)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }
}

private struct HapticButtonStyle: ButtonStyle {
    private let shape = RoundedRectangle(cornerRadius: 12, style: .continuous)

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.primary)
            .padding()
            .frame(maxWidth: .infinity)
            .background(.background, in: shape)
            .overlay {
                shape
                    .strokeBorder(.secondary, lineWidth: 1)
            }
            .contentShape(shape)
            .opacity(configuration.isPressed ? 0.65 : 1)
    }
}

private struct HapticDeviceFooter: View {
    let info: HapticDeviceInfo
    let supportsHaptics: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text("Detected: \(info.model) • \(info.system)")
            Text("Model identifier: \(info.hardwareIdentifier)")
            if info.isSimulator {
                Text("Simulator — physical vibration is unavailable.")
            } else {
                Text(supportsHaptics ? "Custom haptics supported." : "Custom haptics unavailable.")
            }
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("haptics.device")
    }
}

#Preview("Light") { ContentView() }
#Preview("Dark") { ContentView().preferredColorScheme(.dark) }
#Preview("Accessibility") { ContentView().environment(\.dynamicTypeSize, .accessibility3) }
