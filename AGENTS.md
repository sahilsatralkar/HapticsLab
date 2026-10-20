# Haptics lab — guidance for AI agents

These instructions apply to coding agents working in this repository. Human contributors should start with [README.md](README.md) and [CONTRIBUTING.md](CONTRIBUTING.md).

## Workflow and tools

- Read README and [VERIFICATION.md](VERIFICATION.md) before implementation. README describes current features; verification entries are dated evidence, not checks already run for your task. Keep responses concise and report material blockers.
- Inspect Git status before editing and preserve unrelated user changes. Follow the user's current scope and explicit preferences; do not expand a documentation task into app changes or a repository publication.
- Use **Xcode MCP** for app source/resource inspection and edits, project changes, Apple documentation, builds, tests, and simulator verification. Discover the active workspace and relevant project paths rather than assuming a previous session's identifiers still apply.
- If a required MCP operation is unavailable or fails, stop the affected work and report the blocker. Continue independent work that remains possible. Do not silently substitute shell-based Xcode operations. An approved exception applies only to the files and operation the user authorized.
- Shell/file tools may handle repository documentation, including documentation screenshots, and Git operations within the authorized task. Do not use this allowance to edit app assets or project settings.
- Review SwiftUI changes using relevant available Xcode skill guidance. State whether guidance came from a locally exposed built-in skill or an external exported copy; never claim an unavailable skill was invoked.

## Implementation safeguards

- Preserve the iOS/iPadOS 26.0 deployment target, Swift 6, SwiftUI, native Apple frameworks, and zero third-party dependencies. Keep strict concurrency checking and MainActor isolation.
- Keep native UI/framework objects and observable state on `MainActor`. Capture immutable `Sendable` configuration snapshots for playback requests. Preserve task cancellation, playback-generation and engine-identity checks against stale asynchronous callbacks. Do not suppress isolation checking or introduce unchecked `Sendable` wrappers.
- Stop custom playback when leaving its screen or when the scene becomes inactive, including backgrounding. Preserve the controller-owned draft across navigation within the app session. Do not introduce persistence across launches without a requested feature change.
- Derive event-parameter ranges and defaults from Core Haptics separately for transient and continuous events. Never infer support from a hardware model string. Missing required intensity/sharpness attributes must prevent validation; unavailable optional envelope parameters must be omitted rather than assigned invented ranges.
- Preserve the limits in [CustomHapticConfiguration.swift](HapticsLab/CustomHapticConfiguration.swift): continuous duration greater than zero and at most 30 seconds per event, 1–8 repetitions, and a 0–2-second gap. Repetition and gap are app limits. **There is no ten-second total-pattern cap.** Do not restore it from historical documentation.
- Keep sliders smooth and numeric entry precise. Reject invalid, nonfinite, and out-of-range input rather than silently clamping it. Invalid editor text must not mutate the draft; cancellation must discard it. Mode changes retain values valid for the new event type and use reported defaults only where the new range requires it.
- Treat Attack time, Decay time, and Release time as relative envelope parameters, not seconds. Encode the active Release/Decay branch according to Sustained. Keep UI controls, validation, event construction, Swift export, and related tests consistent when changing parameters.
- Curves apply only to continuous events. Preserve 2–16 points (an app limit), stable UUID identities, strictly ordered positions from 0 to 1, proportional timing when Duration changes, interpolation-preserving insertion, and nondeletable endpoints. Switching Constant/Vary over time must retain independent constant values and curve points; initialize the curve from constant values only when no curve exists. Retain hidden curves across event-type changes; Reset clears them. Query dynamic ranges separately, validate effective and encoded values, restart curves for each repetition, and keep export scheduling identical.
- Preserve export parity with playback: capture the current draft as a standalone UTF-8 `CustomHaptic.swift` attachment, validate using the same values and timing, retain the file through sharing, and clean up only its own temporary directory. Generated playback must retain destination-device validation and lifecycle safeguards.

## UI and product scope

- Keep the interface native and minimal: two columns of equal-height rounded rectangle system buttons, a native System haptics section, compact navigation titles, semantic colors, and native `.padding()` without numeric margins. Do not force the buttons to be square or capsule-shaped.
- Preserve native Dynamic Type and accessibility labels/identifiers. Dedicated accessibility audits and accessibility-size test passes are optional unless requested; do not remove native support.
- Custom uses Haptics, Repetition, and Envelope sections with inline information buttons. Continuous reveals Duration and a native Intensity and sharpness segmented control with Constant and Vary over time choices. Show only the selected mode's controls: constant intensity/sharpness sliders or native expandable point rows. With Continuous off, show only constant controls. Multiple repetitions reveal Gap. Keep the unified Play/Stop toolbar action and separate Share action, with Stop available during startup and playback.
- Keep default system feedback requests unchanged as a comparison baseline. The shared catalog has thirteen choices, including `Alignment*` and `Path complete*` on both iPhone and iPad, without device-specific filtering. Preserve their footer explanation requiring Apple Pencil Pro with a compatible iPad; neither button visibility nor Core Haptics support detects a connected Pencil. API availability alone is not evidence of physical iPhone feedback. Do not add audio, custom accessory patterns, or advanced playback features without a request.

## Verification and documentation

- Verification is intentionally initiated locally by contributors and the maintainer, as documented in [CONTRIBUTING.md](CONTRIBUTING.md). GitHub Actions is not required. Do not add Actions workflows or required CI status checks unless the maintainer explicitly requests a workflow change; absence of CI is not a readiness blocker. Human contributors may use Xcode directly; coding agents still use Xcode MCP.
- For app changes, run affected unit tests through Xcode MCP, then finish with a normal build. Do not add unrelated tests for copy-only edits. **UI tests are intentionally excluded; do not reintroduce them.**
- In PRs and handoffs, report tests and build results, the Xcode version and actual destination/runtime, relevant manual flows, and skipped or failed checks. The maintainer reviews and locally verifies the final revision before merging; repeat checks affected by subsequent changes. Documentation-only changes use documentation checks rather than app tests/builds.
- Check the actual run destination before tests or installation. Use a simulator unless physical-device installation is explicitly requested. Record the destination/runtime reported by the operation; preview rendering may use a different destination from the active scheme.
- For layout changes, review a compact screen and light/dark appearance when supported MCP operations are available. Identify preview-only evidence and any unexecuted checks. Do not imply that screenshots establish successful interactions or physical vibration.
- Simulator unit tests verify requests, validation, pattern construction, and export logic; they cannot verify tactile output. Report relevant unexecuted physical-device and iOS 26.0 minimum-runtime checks. Keep historical results clearly distinguished from checks run for the current change.
- Keep the app marketing/build versions, README version status, [CHANGELOG.md](CHANGELOG.md), and release notes consistent when a version change is requested. Identify development versions as unreleased until actually published; preserve historical verification dates. Do not infer authorization to create tags or publish releases from a version/documentation change alone.
- Update README when behavior or setup changes, and VERIFICATION when recording new checks or limitations. Record failed or unavailable checks honestly. The dated [capability study](Docs/HAPTICS_STUDY.md) is research context and may predate later UI/export changes; confirm current behavior against source.
- Documentation-only changes require content, relative-link/image-reference, and diff checks, not app tests or builds. Use supplied or actual captured screenshots, identify their provenance, and do not present old screens or generated mockups as the current app. Remove any temporary preview source used for captures through Xcode MCP.

## Git and repository access

- Keep changes focused and preserve local signing settings, Xcode user state, credentials, and build output outside commits. Stage only files belonging to the authorized task and inspect the complete staged diff before every commit.
- Contributions should use a branch and pull request. **Only the repository owner, `sahilsatralkar`, may authorize updates or merges into upstream `main`.** Agents acting for other contributors must submit a PR rather than update upstream `main`. Honor the owner's explicit branch, commit, and push instructions.
- This file documents maintainer policy; it does not enforce GitHub permissions. Owner-only merging is independent of GitHub Actions. Verify actual branch protections separately and never claim owner-only merging is enforced without evidence from GitHub.
- Do not change repository visibility, access permissions, or branch protections without an explicit request. Do not rewrite published history without explicit authorization.

## Development team and signing: never commit

- Never commit actual Apple development team IDs, team/account names or emails, personal signing identities, provisioning-profile identifiers, or signing credentials in any file, including project settings, configuration files, scripts, documentation, and logs. Empty team settings and generic placeholders are allowed.
- Treat signing changes made by Xcode as local-only. Before every commit, inspect the complete staged diff and staged signing configuration for these details, including `DEVELOPMENT_TEAM`, `DevelopmentTeam`, `CODE_SIGN_IDENTITY`, `PROVISIONING_PROFILE`, and `PROVISIONING_PROFILE_SPECIFIER`. Generic SDK signing defaults are allowed; personal values are not.
- If prohibited details are staged, stop the commit. Exclude those changes from staging while preserving the user's local signing setup and unrelated edits, then inspect the staged result again. Do not commit or push until it is clean. `.gitignore` does not protect settings inside already tracked files.
- If details are already committed, report the affected files without repeating the values. Do not push them or rewrite published history without explicit authorization.
