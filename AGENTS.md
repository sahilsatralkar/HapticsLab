# HapticsLab

## Workflow

- Read [README.md](README.md) and [VERIFICATION.md](VERIFICATION.md) before implementation. Keep responses concise.
- Use Xcode MCP for source/resource inspection and edits, project changes, Apple documentation, builds, tests, and simulator verification. If a required MCP operation is unavailable or fails, stop the affected code work and report the blocker; do not silently substitute shell-based Xcode operations.
- Shell/file tools may handle repository documentation and Git inspection. Documentation-only edits require link/content and diff checks, not app tests or builds.
- Review SwiftUI changes using relevant available Xcode skill guidance. State whether guidance came from a locally exposed built-in skill or an external exported copy; never claim an unavailable skill was invoked.

## Implementation

- Preserve the iOS 26.0 deployment target, Swift 6, SwiftUI, native Apple frameworks, and zero third-party dependencies.
- Keep native UI/framework objects and observable state on `MainActor`. Use immutable `Sendable` configuration snapshots for playback requests. Preserve task cancellation, playback-generation and engine-identity checks against stale asynchronous callbacks. Do not suppress isolation checking or introduce unchecked `Sendable` wrappers.
- Stop custom playback when leaving its screen or backgrounding the app. Preserve parameter validation and the ten-second pattern limit; reject invalid/nonfinite values rather than silently clamping them.
- Keep the UI native and minimal: two columns of rounded square haptic buttons, compact navigation title, semantic colors, Dynamic Type, and native padding without numeric margins.

## Verification and repository hygiene

- After app changes, run affected unit and/or UI tests through Xcode MCP, then finish with a normal build. For layout changes, check compact screens, light/dark appearance, and accessibility text sizes.
- Simulator tests verify requests, pattern construction, and UI; they cannot verify physical vibration. Report the tested simulator/runtime and unexecuted hardware and iOS 26.0 minimum-runtime checks. Do not present historical results in VERIFICATION.md as checks run for the current change.
- Update README.md when behavior or setup changes, and VERIFICATION.md when recording new checks or limitations. Record failed or unavailable checks honestly.
- Do not install on physical devices or change repository visibility without an explicit request. Keep personal signing settings, credentials, build output, and Xcode user state out of Git. Preserve unrelated user changes.
