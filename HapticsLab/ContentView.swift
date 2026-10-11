import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var controller = HapticsController()
    @State private var request: NativeHapticRequest?
    @State private var sequence: UInt64 = 0

    var body: some View {
        NavigationStack {
            List {
                Section("System haptics") {
                    HapticsGrid(controller: controller, onRequest: requestHaptic)
                        .buttonStyle(HapticButtonStyle())
                        .controlSize(.large)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
                Section {
                    NavigationLink {
                        CustomHapticsView(controller: controller)
                    } label: {
                        Text("Custom haptics testing")
                            .foregroundStyle(.primary)
                    }
                    .accessibilityIdentifier("haptics.custom")
                } footer: {
                    HapticDeviceFooter(info: controller.deviceInfo, supportsHaptics: controller.supportsCustomHaptics)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Haptics lab")
            .navigationBarTitleDisplayMode(.inline)
            .sensoryFeedback(trigger: request) { _, new in new?.haptic.feedback }
            .onChange(of: scenePhase) { _, phase in
                if phase != .active { controller.stop() }
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
    @Environment(\.layoutDirection) private var layoutDirection

    var body: some View {
        EqualHeightHapticLayout(layoutDirection: layoutDirection) {
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

/// Two equal columns, with every haptic button sized to the tallest padded label.
private struct EqualHeightHapticLayout: Layout {
    let layoutDirection: LayoutDirection

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        guard !subviews.isEmpty else { return .zero }
        let sizes = measurements(width: proposal.width, subviews: subviews)
        let rows = (subviews.count + 1) / 2
        return CGSize(width: sizes.width,
                      height: CGFloat(rows) * sizes.height + CGFloat(rows - 1) * sizes.vertical)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        guard !subviews.isEmpty else { return }
        let sizes = measurements(width: bounds.width, subviews: subviews)
        for index in subviews.indices {
            let row = index / 2
            let column = layoutDirection == .rightToLeft ? 1 - index % 2 : index % 2
            let x = bounds.minX + CGFloat(column) * (sizes.column + sizes.horizontal)
            subviews[index].place(
                at: CGPoint(x: x, y: bounds.minY + CGFloat(row) * (sizes.height + sizes.vertical)),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: sizes.column, height: sizes.height))
        }
    }

    private func measurements(width: CGFloat?, subviews: Subviews)
        -> (width: CGFloat, column: CGFloat, height: CGFloat, horizontal: CGFloat, vertical: CGFloat) {
        var spacing = ViewSpacing()
        for subview in subviews { spacing.formUnion(subview.spacing) }
        let horizontal = spacing.distance(to: spacing, along: .horizontal)
        let vertical = spacing.distance(to: spacing, along: .vertical)
        let idealWidth = subviews.map { $0.sizeThatFits(.unspecified).width }.max() ?? 0
        let width = width.flatMap { $0.isFinite ? $0 : nil } ?? (idealWidth * 2 + horizontal)
        let column = max(0, (width - horizontal) / 2)
        let height = subviews.map {
            $0.sizeThatFits(ProposedViewSize(width: column, height: nil)).height
        }.max() ?? 0
        return (width, column, height, horizontal, vertical)
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            Text("Device model: \(info.hardwareIdentifier)")
            Text("OS version: \(info.systemVersion)")
            Text(supportsHaptics && !info.isSimulator ? "Custom haptics supported." : "Custom haptics unavailable.")
            Text("* Requires Apple Pencil Pro with a compatible iPad. Feedback is felt in the Pencil.")
                .padding(.top)
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
