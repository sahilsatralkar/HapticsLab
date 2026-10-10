import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var controller = HapticsController()
    @State private var canvas = CanvasHaptics()
    @State private var request: NativeHapticRequest?
    @State private var sequence: UInt64 = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    HapticsGrid(controller: controller, canvas: canvas, onRequest: requestHaptic)
                    HapticsStatus(status: controller.status)
                }
                .padding()
            }
            .navigationTitle("Haptics")
            .navigationBarTitleDisplayMode(.inline)
            .background(CanvasHapticAnchor(haptics: canvas))
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
    let canvas: CanvasHaptics
    let onRequest: (NativeHaptic) -> Void
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(NativeHaptic.allCases) { haptic in
                Button {
                    onRequest(haptic)
                } label: {
                    HapticTileLabel(title: haptic.title, symbol: haptic.symbol)
                }
                .aspectRatio(1, contentMode: .fit)
                .accessibilityIdentifier("haptics." + haptic.rawValue)
                .accessibilityValue(controller.status == "Requested: " + String(localized: haptic.title) ? "Requested" : "Ready")
            }
            NavigationLink {
                CustomHapticsView(controller: controller)
            } label: {
                HapticTileLabel(title: "Custom haptics", symbol: "slider.horizontal.3")
            }
            .aspectRatio(1, contentMode: .fit)
            .accessibilityIdentifier("haptics.custom")
            CanvasFeedbackButton(title: "Canvas alignment", alignment: true,
                                 controller: controller, canvas: canvas)
            CanvasFeedbackButton(title: "Canvas path completed", alignment: false,
                                 controller: controller, canvas: canvas)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle)
        .controlSize(.large)
    }
}

private struct HapticTileLabel: View {
    let title: LocalizedStringResource
    let symbol: String
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Image(systemName: symbol)
                    .font(.largeTitle)
                    .accessibilityHidden(true)
                Text(title)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .lineLimit(String(localized: title).contains(" ") ? 2 : 1)
                    .minimumScaleFactor(0.2)
            }
            .padding()
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

private struct CanvasFeedbackButton: View {
    let title: LocalizedStringResource
    let alignment: Bool
    let controller: HapticsController
    let canvas: CanvasHaptics

    var body: some View {
        Button {
            canvas.play(alignment: alignment)
            controller.recordNativeRequest(String(localized: title))
        } label: {
            HapticTileLabel(title: title, symbol: "pencil.tip")
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityIdentifier(alignment ? "haptics.canvasAlignment" : "haptics.canvasPath")
        .accessibilityValue(controller.status == "Requested: " + String(localized: title) ? "Requested" : "Ready")
    }
}

private struct HapticsStatus: View {
    let status: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(status)
                .accessibilityIdentifier("haptics.status")
            Text("Canvas feedback requires Apple Pencil Pro and a compatible iPad.")
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
        .padding(.top)
    }
}

#Preview("Light") { ContentView() }
#Preview("Dark") { ContentView().preferredColorScheme(.dark) }
#Preview("Accessibility") { ContentView().environment(\.dynamicTypeSize, .accessibility3) }
