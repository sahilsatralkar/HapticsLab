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

- After app changes, run affected unit tests through Xcode MCP, then finish with a normal build. UI tests are intentionally excluded at the user's request. For layout changes, review compact screens, light/dark appearance, and accessibility text sizes when simulator interaction is available; report any unexecuted checks.
- Simulator unit tests verify requests and pattern construction; they cannot verify physical vibration. Report the tested simulator/runtime and unexecuted hardware and iOS 26.0 minimum-runtime checks. Do not present historical results in VERIFICATION.md as checks run for the current change.
- Update README.md when behavior or setup changes, and VERIFICATION.md when recording new checks or limitations. Record failed or unavailable checks honestly.
- Do not install on physical devices or change repository visibility without an explicit request. Keep personal signing settings, credentials, build output, and Xcode user state out of Git. Preserve unrelated user changes.

## Development team and signing: never commit

- Never commit actual Apple development team IDs, team/account names or emails, personal signing identities, provisioning-profile identifiers, or signing credentials in any file, including project settings, configuration files, scripts, documentation, and logs. Empty team settings and generic placeholders are allowed.
- Treat signing changes made by Xcode as local-only. Before every commit, inspect the complete staged diff and staged signing configuration for these details, including `DEVELOPMENT_TEAM`, `DevelopmentTeam`, `CODE_SIGN_IDENTITY`, `PROVISIONING_PROFILE`, and `PROVISIONING_PROFILE_SPECIFIER`. Generic SDK signing defaults are allowed; personal values are not.
- If prohibited details are staged, stop the commit. Exclude those changes from staging while preserving the user's local signing setup and unrelated edits, then inspect the staged result again. Do not commit or push until it is clean. `.gitignore` does not protect settings inside already tracked files.
- If details are already committed, report the affected files without repeating the values. Do not push them or rewrite published history without explicit authorization.
