# Verification

Date: 10 October 2026. Source, tests, project settings, builds, and simulator test execution were handled through Xcode MCP.

## API and skill review

Apple documentation searches covered SwiftUI SensoryFeedback platform support, native impact variants, Core Haptics intensity/sharpness and engine lifecycle, asynchronous start/stop, off-main callbacks, and Pencil canvas feedback. The sample excludes feedback documented only on other platforms.

Reviewed with the exported `swiftui-specialist` skill from the user-supplied [xcode27-skills repository](https://github.com/superagents-lab/xcode27-skills/tree/6f9ff8d5ad6000491cb0f483a776b7062e41cd97/swiftui-specialist). Applied separate View boundaries, private state ownership, MainActor observable state, stable enum identities, native modifiers, and LocalizedStringResource for pattern names. This was an external exported skill review; a built-in Xcode skill invocation is not exposed and was not performed. No copied skill content is distributed with this project.

## Executed checks

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
