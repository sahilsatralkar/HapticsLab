# Contributing

Keep changes small, native, and dependency-free. Preserve iOS 26.0 and Swift 6 support.

Use MainActor for SwiftUI state and native framework adapters; use Sendable values across isolation boundaries. Keep custom playback cancellable and reject obsolete callbacks. Use semantic colors, Dynamic Type, stable accessibility identifiers, and native padding.

Run unit and UI tests and a normal build. Review light, dark, and accessibility text sizes. State explicitly whether physical haptic playback was tested; simulator checks cannot establish the tactile result.

Do not commit signing credentials, personal Xcode settings, build output, analytics, or private data. Contributions are licensed under the repository MIT license.
