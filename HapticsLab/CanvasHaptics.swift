import SwiftUI
import UIKit

/// UIKit canvas feedback needs an associated native view and compatible
/// Apple Pencil Pro hardware. It is separate from iPhone Taptic Engine tests.
@MainActor
final class CanvasHaptics {
    private weak var view: UIView?
    private var generator: UICanvasFeedbackGenerator?

    func attach(to view: UIView) {
        self.view = view
        generator = UICanvasFeedbackGenerator(view: view)
    }

    func play(alignment: Bool) {
        guard let view, let generator else { return }
        let point = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        generator.prepare()
        if alignment { generator.alignmentOccurred(at: point) }
        else { generator.pathCompleted(at: point) }
    }
}

struct CanvasHapticAnchor: UIViewRepresentable {
    let haptics: CanvasHaptics
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = false
        haptics.attach(to: view)
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}
