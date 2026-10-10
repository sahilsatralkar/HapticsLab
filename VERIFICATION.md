# Verification

Date: 10 October 2026. Source, tests, project settings, builds, and simulator test execution were handled through Xcode MCP.

## API and skill review

Apple documentation searches covered SwiftUI SensoryFeedback platform support, native impact variants, Core Haptics intensity/sharpness and engine lifecycle, asynchronous start/stop, off-main callbacks, and Pencil canvas feedback. The sample excludes feedback documented only on other platforms.

Reviewed with the exported `swiftui-specialist` skill from the user-supplied [xcode27-skills repository](https://github.com/superagents-lab/xcode27-skills/tree/6f9ff8d5ad6000491cb0f483a776b7062e41cd97/swiftui-specialist). Applied separate View boundaries, private state ownership, MainActor observable state, stable enum identities, native modifiers, and LocalizedStringResource for pattern names. This was an external exported skill review; a built-in Xcode skill invocation is not exposed and was not performed. No copied skill content is distributed with this project.

## Explicit rounded button corners — 10 October 2026

Home buttons now use a continuous RoundedRectangle with a 12-point corner radius for background, border, and hit shape. Custom Play/Stop controls use the native rounded-rectangle border shape with the same explicit radius. Native padding, semantic colors, and existing sizing remain intact. README was not edited. Review continued with the external SwiftUI guidance identified above.

- Xcode MCP, iPhone 13 mini simulator, iOS 26.5: all 3 UI tests passed, including native requests, Custom controls/navigation, and compact light/dark/largest-accessibility layout assertions.
- Final normal build succeeded with no reported errors. Git diff whitespace check passed.
- Screenshots were not visually inspected because the previously reported MCP attachment/interaction limitation remains unresolved. Physical vibration and iOS 26.0 minimum-runtime execution were not tested. No physical device installation was performed. Unit tests were not rerun for this shape-only change.

Artifacts: `Test-HapticsLab-2026.10.10_19-04-29-+0530.xcresult`, `BuildProject-Log-20261010-190615.txt` (temporary, not distributed).

## Device capabilities and envelopes — 10 October 2026

Implemented the detected-device footer (generic device family, OS, hardware identifier, simulator/support state), per-event Core Haptics parameter-range/default queries, smooth native sliders, positive continuous durations through Apple's 30-second event limit, and supported attack/sustain/decay/release controls. The prior ten-second total restriction was superseded by the user's full-duration request. Pulse count (1–8) and gap (0–2 seconds) remain labeled app limits. No audio features were added. README was left unchanged.

The complete API-family study and remaining vibration features are in [Docs/HAPTICS_STUDY.md](Docs/HAPTICS_STUDY.md). SwiftUI review continued with the external exported guidance referenced above; no locally exposed built-in skill was invoked.

Checks through Xcode MCP on iPhone 13 mini simulator, iOS 26.5:

- Initial full suite: 12 passed, 3 failed (15 total: 12 unit and 3 UI). The failures were two incorrect assumptions about framework-reported pattern duration with explicit envelopes, and a UI assertion expecting a value to be independently exposed inside LabeledContent.
- Corrected checks assert actual encoded event duration and successful pattern construction separately; the UI assertion checks slider adjustment. Targeted rerun: all 3 passed. All 15 checks have passing results across the initial and targeted runs; the full suite was not repeated after these test-only corrections.
- Passing coverage includes queried-range/default validation, invalid/nonfinite values, missing parameters, exact envelope encoding, arbitrary intermediate values, 30-second continuous event inputs, zero gap/intensity, finite sequence timing, snapshots, repeated requests/Stop, detected-device copy, Custom navigation/controls, compact light/dark and largest accessibility layout assertions.
- Final normal build passed with no reported errors. Test build log had no warnings. Git diff whitespace checks passed.
- Editor diagnostics succeeded for the capability model, Custom view and unit tests. Controller editor diagnostics failed with SourceEditorCallableDiagnosticError error 5; the subsequent test builds and final normal build succeeded.
- Screenshot inspection remains unverified. An iPhone 17 Pro/iOS 27 simulator interaction session was requested, but the tool required a device-interaction skill not exposed locally; the external skill URL could not be retrieved. No interactions were performed. The session was already gone when cleanup was requested. No shell-based simulator or Xcode fallback was used.

Artifacts: `Test-HapticsLab-2026.10.10_18-47-18-+0530.xcresult` (initial), `Test-HapticsLab-2026.10.10_18-50-56-+0530.xcresult` (targeted), `BuildProject-Log-20261010-185259.txt` (normal build). Temporary artifacts are not distributed.

Physical vibration, device-specific perceptual envelope behavior, hardware interruption/Stop during long playback, and iOS 26.0 minimum-runtime execution were not checked. No physical device installation was performed. The research distinguishes API limits and successful request construction from actual tactile output.

## Button appearance and copy update — 10 October 2026

Changed the home controls to text-only rounded rectangles using SwiftUI's native `ButtonBorderShape.roundedRectangle`, semantic background and primary foreground, and a one-point secondary border. Button heights follow their text and native padding; the Custom CTA remains full-width and taller. All padding uses system defaults without numeric margins. Updated the CTA to “Custom haptics testing” and navigation title to “Haptics Lab”. README was intentionally left unchanged at the user's request.

Review continued with the external exported SwiftUI guidance identified above; no locally exposed built-in Xcode skill was invoked.

- Xcode MCP requested the two affected UI tests on iPhone 13 mini, iOS 26.5, covering repeated requests, rectangular controls, renamed title/CTA, full-width navigation, and light/dark/largest-accessibility layouts. The tool returned an incomplete-result-bundle error, so this run's test outcomes are unconfirmed. No shell-based Xcode fallback was used.
- Final normal build through Xcode MCP succeeded with no reported errors (`BuildProject-Log-20261010-183040.txt`).
- Git diff whitespace check passed.
- Current screenshots were not inspected. Compact/light/dark/accessibility checks remain unconfirmed for this update. Physical haptics and iOS 26.0 minimum-runtime checks were not run; no physical device installation was performed.

## Home layout update — 10 October 2026

Removed the two canvas buttons and their unused UIKit adapter, removed the home footer/status copy, and made Custom haptics a large full-width button below the native grid. README screenshots are explicitly marked historical.

Reviewed using the external exported `swiftui-specialist` skill linked above (view structure, data flow, and modifier guidance); no built-in Xcode skill was exposed or invoked. Retained private state ownership, separate grid view, semantic native controls, and existing playback lifecycle handling.

Current-change checks through Xcode MCP:

- iPhone 13 mini simulator, iOS 26.5: all 3 affected UI tests passed. Covered repeated native requests, Custom navigation/controls, full-width button boundaries and size, removed canvas/footer elements, light/dark appearance, and largest accessibility text size.
- Final normal build: succeeded with no reported errors. Test build log also reported no warnings.
- README local links and Git whitespace/diff checks: passed.
- Screenshot inspection remains unverified: DeviceInteractionStartWorkspaceSession could not select iPhone 13 mini even though it was available as a test destination. UI-test screenshots were retained in the result bundle, but no MCP attachment-reading tool was exposed; no shell-based Xcode fallback was used.
- Initial headless workspace had no active scheme; tests were run successfully through the open Xcode window workspace instead.

Result bundle: `Test-HapticsLab-2026.10.10_18-20-05-+0530.xcresult`. Final build log: `BuildProject-Log-20261010-182312.txt`. These temporary artifacts are not distributed.

Physical vibration and iOS 26.0 minimum-runtime checks were not run. No physical device installation was performed. Unit tests were not rerun for this UI-only change; prior results below are historical.

## Earlier executed checks

| Check | Result |
| --- | --- |
| Full suite, iPhone 17 Pro, iOS 26.5 (23F77) | 11 passed: 8 unit, 3 UI |
| Full suite, iPhone 17 Pro, iOS 27.0 (24A434) | 11 passed before final layout refinements |
| Final compact layout, iPhone 13 mini, iOS 26.5 | Full suite: 11 passed |
| Refined square sizing and repeated taps, iOS 27.0 | 2 affected UI tests passed |
| Final label fitting, light/dark/largest accessibility text, iOS 27.0 | Visual UI test passed |
| Final controller cleanup change, iPhone 13 mini, iOS 26.5 | 8 unit tests passed |
| Normal build and debugger-attached simulator launch | Passed; no compiler warnings |

Coverage includes finite/range validation, transient/continuous timing, silent intensity, the ten-second boundary, immutable playback configuration, distinct repeated requests, repeatable Stop, all native button targets, square dimensions and paired alignment, Custom controls/reset, unsupported simulator feedback, and light/dark/accessibility layouts. Native framework playback and interruptions still need hardware testing.

Review corrected an offscreen Form-status test assertion, a ten-point mismatch caused by native button insets, large-text label clipping, and completed playback being misreported as interrupted during idle engine cleanup. No tests were disabled or failures suppressed.

Xcode MCP initially timed out on one test request and twice attempted to read result bundles before completion. Completed bundles were inspected using xcresulttool; the affected follow-up runs passed. A standalone launch without a debugger timed out; the normal debugger-attached launch then succeeded. Preview rendering did not complete successfully; delivered screenshots come from actual simulator UI tests.

Local result artifacts (not distributed; temporary locations may expire):

- Final compact suite: Test-HapticsLab-2026.10.10_17-33-09-+0530.xcresult
- Final iOS 27 visual check: Test-HapticsLab-2026.10.10_17-37-04-+0530.xcresult
- Final controller units: Test-HapticsLab-2026.10.10_17-42-22-+0530.xcresult
- Normal launch: RunProject-Log-20261010-174443.txt
- Committed screenshots: Docs/Screenshots


## Limitations

Physical vibration, custom engine playback/interruption on hardware, and Apple Pencil Pro feedback remain unverified. No physical device installation was performed. iOS 26.0 minimum-runtime execution is unverified; the deployment target is 26.0. iOS 27.1 beta is excluded. iPad UI and a VoiceOver session have not been exercised. The sample currently provides English copy with localization-ready native labels; it does not claim translated language coverage. Sanitizers were not run.

## Reproduce

Open HapticsLab.xcodeproj, select HapticsLab and an installed iOS simulator, and choose Product → Test. Physical testing requires your own signing team and compatible hardware. Use the Custom screen or change defaults in HapticsLab/CustomHapticConfiguration.swift.
