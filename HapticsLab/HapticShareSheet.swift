import SwiftUI
import UIKit

/// Each share gets its own immutable file, so another export cannot overwrite it.
nonisolated struct HapticShareFile: Identifiable, Sendable {
    var id: URL { url }
    let url: URL
    private let directory: URL

    init(source: String, temporaryDirectory: URL = FileManager.default.temporaryDirectory) throws {
        let directory = temporaryDirectory.appendingPathComponent("HapticsLab-Share-" + UUID().uuidString,
                                                                   isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appendingPathComponent("CustomHaptic.swift")
        do {
            try Data(source.utf8).write(to: url, options: .atomic)
        } catch {
            try? FileManager.default.removeItem(at: directory)
            throw error
        }
        self.directory = directory
        self.url = url
    }

    func remove() throws {
        if FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.removeItem(at: directory)
        }
    }
}

/// UIKit's system activity sheet shares an actual .swift attachment.
@MainActor
struct HapticShareSheet: UIViewControllerRepresentable {
    let file: HapticShareFile
    let onCompletion: @MainActor (String?) -> Void

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: [file.url], applicationActivities: nil)
        controller.completionWithItemsHandler = { _, _, _, error in
            let message = error?.localizedDescription
            Task { @MainActor in onCompletion(message) }
        }
        return controller
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
