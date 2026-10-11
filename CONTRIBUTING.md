# Contributing

Keep changes small, native, and dependency-free. Preserve iOS 26.0 and Swift 6 support.

Use MainActor for SwiftUI state and native framework adapters; use Sendable values across isolation boundaries. Keep custom playback cancellable and reject obsolete callbacks. Use semantic colors, Dynamic Type, stable accessibility identifiers, and native padding.

Run affected unit tests and a normal build through Xcode MCP. UI tests are intentionally excluded. Review light, dark, and accessibility text sizes when simulator interaction is available, and report any unexecuted checks. State explicitly whether physical haptic playback was tested; simulator checks cannot establish the tactile result.

Do not commit signing credentials, personal Xcode settings, build output, analytics, or private data. Contributions are licensed under the repository MIT license.
