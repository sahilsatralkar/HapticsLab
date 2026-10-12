# Verification

## v1.1 — Export device metadata — 12 October 2026

Added exporting-device comments beside the existing Swift file header: device type and hardware identifier, iOS/iPadOS version, and Simulator or Physical device. The exporter uses `HapticDeviceInfo.detect()` by default, matching Home's detection, and accepts an immutable device snapshot for deterministic tests. Metadata is descriptive only; generated playback code, validation, and destination-device capability checks are unchanged. App version is 1.1, build 2, updated through Xcode MCP. README, the capability study, and the security policy were updated for this release.

- Added regression coverage for iPhone, iPad, simulator, and unavailable hardware identifiers; asserted metadata is in the comment header, generated playback code is identical across device snapshots, and UTF-8 share attachments preserve the complete source. A separate test verifies the default runtime detection path.
- Xcode MCP: discovered the workspace, switched from the selected physical iPhone to iPhone 13 mini simulator / iOS 26.5, and ran all 29 unit tests: 29 passed, 0 failed, 0 skipped. Finished with a successful normal build and no reported errors. The destination reported the iOS 27.0 simulator SDK; the exact Xcode application version was not reported.
- No UI layout changed. No UI tests, physical-device installation, tactile checks, manual sharing into other apps, independent generated-file compilation, or minimum iOS/iPadOS 26.0 execution was performed. iPad metadata was tested with a fixture, not an iPad runtime.
- The cleanup shutdown request reported that the test simulator was already shut down. Quit Simulator and confirmed no booted devices remained. Documentation references and Git whitespace checks passed. Version-only project changes were selected for staging, preserving local personal signing settings outside the commit.

Artifacts: `Test-HapticsLab-2026.10.12_11-56-29-+0530.xcresult` (29 passed), `BuildProject-Log-20261012-115725.txt` (normal build). Temporary artifacts are not distributed.

## Screenshot URL refresh — 11 October 2026

After the maintainer reported seeing older README screenshots, GitHub's contents API confirmed that the published image blob hashes and README references matched the latest supplied captures. Caching is a likely explanation, not a confirmed diagnosis. Renamed the current images to `home-3239.png` and `custom-3240.png` and updated README to give each capture a fresh URL. Image contents are unchanged. Historical verification entries retain the filenames used at the time.

Checked the README image paths, byte-for-byte equality with the supplied originals, and Git whitespace. No app changes, builds, tests, or signing changes were made.

## Latest supplied screenshots — 11 October 2026

Replaced the README Home and Custom images with the maintainer-supplied `IMG_3239.PNG` and `IMG_3240.PNG`, respectively. Both are unchanged 1206 × 2622 PNGs, verified byte-for-byte against the supplied files. Reviewed the attached images: Home shows the medium-weight body labels, all thirteen system choices, Custom navigation, device information, and Pencil footnote; Custom shows the top of the form. Updated README alt text and caption and removed the obsolete typography warning.

README local links, anchors, image references, and Git whitespace checks passed. No app source changes, builds, tests, or device interactions were needed for this documentation-only update. Screenshots are visual evidence only, not verification of physical feedback. Existing local signing changes were preserved.

## System button typography — 11 October 2026

Changed the shared System haptics button label from `.title3` to `.body.weight(.medium)` through Xcode MCP. All thirteen labels use the new style. Dynamic Type, natural wrapping, equal-height layout, and native padding are preserved. README now describes the style and identifies the supplied Home screenshot as predating this typography change.

- Reviewed modifier usage with the external exported `swiftui-specialist` guidance referenced below, not a locally exposed built-in Xcode skill.
- Xcode MCP confirmed the active HapticsLab destination as iPhone 13 mini simulator / iOS 26.5, using the iOS 27.0 simulator SDK. The exact Xcode application version was not reported.
- Light and dark previews rendered on Xcode's selected preview device, iPhone Duo / iOS 27.1. All thirteen labels fit on one line in both captures. This is preview-only visual evidence; compact-device layout remains unverified because the preview renderer used a different destination.
- Final normal build passed with no reported errors: `BuildProject-Log-20261011-164332.txt`. No unit-tested behavior changed, so unit tests were not rerun; no UI tests were added or run. Physical-device, iPad, accessibility-size, interaction, and minimum-runtime checks were not performed.
- Documentation references and Git whitespace checks passed. Existing local signing changes remain untouched and uncommitted.

## Community documentation, security, and release — 11 October 2026

Implemented the four approved readiness follow-ups:

- Refreshed the capability study against app source inspected through Xcode MCP, covering thirteen system choices, current Custom controls, mode-switch retention, exact numeric entry, Swift export, lifecycle handling, and intentionally unimplemented APIs. Rechecked Apple's continuous-event limit, normalized envelope semantics, and Pencil canvas guidance through Xcode MCP.
- Enabled repository-level secret scanning and push protection. GitHub's repository API returned `enabled` for both. This confirms configuration, not completion of a scan or absence of secrets.
- Enabled private vulnerability reporting; its status endpoint returned `enabled: true`. Added SECURITY.md with supported-version scope and private reporting instructions, plus reporting links in README, CONTRIBUTING, and the issue template.
- Published [Haptics lab v1.0](https://github.com/sahilsatralkar/HapticsLab/releases/tag/v1.0) against the existing tag at `4c76086`. The remote annotated tag object remained unchanged. Release notes describe features, source setup, prior verification evidence, and limitations. No tag move, app binary upload, or app changes were made.

Documentation content, 66 local links/image references/anchors across seven documents, and Git whitespace checks passed. The committed app source, tests, and project configuration were identical between the existing tag and the reviewed main revision. No new app builds, unit tests, UI interactions, or physical-device checks were run for these documentation/settings changes; the earlier readiness review below records the 27-test pass and normal build. Existing local signing changes were preserved.

## Community readiness review — 11 October 2026

Reviewed the public repository, README/contribution workflow, community templates, release metadata, and active main-branch rules. GitHub confirmed the MIT license, enabled issues, recognized community issue template and PR template, and owner-only ruleset with only `sahilsatralkar` allowed to bypass restrictions on `main`. All 52 local references checked across README, CONTRIBUTING, AGENTS, and the templates resolved.

- Xcode MCP: explicitly switched from the selected physical device to iPhone 13 mini simulator / iOS 26.5 before execution. All 27 unit tests passed, followed by a successful normal build with no reported errors. Test discovery initially included two stale example-test entries absent from source; the executed suite contained the expected 27 tests. The exact Xcode application version was not reported; build settings confirmed Swift 6, complete concurrency checking, MainActor default isolation, and iOS/iPadOS 26.0 deployment.
- No physical-device installation, UI tests, clean-checkout build, iPad layout check, physical vibration/Pencil check, independent compilation of an exported Swift file, or minimum-runtime execution was performed. Existing hardware and sharing limitations remain.
- Follow-ups found: outdated current-behavior claims in the capability study; a `v1.0` tag without a published GitHub release; no security policy or code of conduct; no repository topics. Repository-level secret scanning, push protection, and private vulnerability reporting were reported disabled. These settings were inspected only, not changed.
- No app source or project settings were edited. Existing local signing changes remain uncommitted. This entry records the new checks without altering prior verification evidence.

Artifacts: `Test-HapticsLab-2026.10.11_16-28-24-+0530.xcresult` (27 passed), `BuildProject-Log-20261011-162847.txt` (normal build). Temporary artifacts are not distributed.

## README copy and setup instructions — 11 October 2026

Rewrote the README in a conversational tone, with a four-step simulator setup and separate physical-device instructions. Kept the feature list, API mappings, parameter behavior and limits, export details, source map, agent workflow, and verification limitations. Added links to the community templates and preserved the latest supplied screenshots. No app behavior, repository permissions, or release tags changed.

Reviewed the copy against the documented implementation and contribution workflow; all README local links, anchors, and image references resolve, and Git whitespace checks passed. No app builds, tests, or device setup checks were run for this documentation-only change.

## Refreshed README screenshots — 11 October 2026

Replaced the Home and Custom documentation images with the maintainer-supplied `IMG_3236.PNG` and `IMG_3237.PNG`, respectively. Both are 1206 × 2622 PNGs copied without image modification. Visually reviewed the supplied images: Home shows all thirteen system choices, including the two asterisk-marked canvas buttons; the navigation row and footer are outside the capture. Custom shows the top of its scrolling form. Updated README alt text and caption, removing the obsolete screenshot warning and avoiding unverified device/OS attribution for these new captures.

Verified byte-for-byte copies, PNG dimensions, README local links/image references/anchors, and Git whitespace. This was a documentation-only update; no app tests, builds, hardware checks, or release-tag changes were performed.

## Shared canvas feedback buttons — 11 October 2026

Added `Alignment*` and `Path complete*` to the shared System haptics catalog using SwiftUI `.alignment` and `.pathComplete`. Both appear on iPhone and iPad without device-specific filtering. The Home footer explains: “* Requires Apple Pencil Pro with a compatible iPad. Feedback is felt in the Pencil.” Device labels now read `Device model` and `OS version`; the existing custom Core Haptics support check remains separate from Pencil feedback. Native button sizing, semantic colors, and padding are preserved. README and agent scope guidance were updated; the supplied Home screenshot is explicitly identified as predating these additions.

Apple Pencil and SwiftUI documentation were reviewed through Xcode MCP. SwiftUI review continued with the previously reviewed external exported guidance, not a locally exposed built-in Xcode skill.

- Xcode MCP, explicitly selected iPhone 13 mini simulator / iOS 26.5: the affected repeated-native-request unit test passed, now checking distinct repeated requests across all thirteen choices and unique identifiers. No UI tests were added or run.
- Final normal build succeeded with no reported errors (`BuildProject-Log-20261011-154500.txt`). The tool did not report the exact Xcode application version; the destination list reported the iOS 27.0 SDK.
- Light and dark previews were rendered and visually inspected. Despite the selected test destination, preview rendering used iPhone Duo / iOS 27.1. Both new button labels were visible and fitted the equal-height grid. The footer was below the captured viewport; its appearance and scroll interaction were not verified. A Display override did not change the captured preview dimensions.
- Compact iPhone and iPad layout, accessibility text sizes, physical iPhone/Pencil feedback, and execution on the iOS/iPadOS 26.0 minimum runtime remain unverified. The previously recorded device-interaction skill limitation was not retried. No physical-device installation was performed.
- Documentation content/local references and Git whitespace checks passed. Existing local signing changes were preserved and left uncommitted.

Test artifact: `Test-HapticsLab-2026.10.11_15-44-26-+0530.xcresult` (one test passed). Temporary build/test/preview artifacts are not distributed.

## Manual contribution verification — 11 October 2026

Expanded CONTRIBUTING.md with the fork/branch/PR workflow, contributor-run and maintainer-run local verification, required PR evidence, and final-revision review. GitHub Actions is intentionally not required; local unit tests and normal builds remain part of app verification. Human contributors may use Xcode directly, while agents retain the Xcode MCP requirement. README and AGENTS.md now describe the same policy and distinguish owner-only merging from CI. Documentation-only checks, optional dedicated accessibility checks, excluded UI tests, and honest hardware limitations remain explicit.

Content, local links/image references/anchors, and Git whitespace checks passed. No app changes, tests, builds, hardware checks, GitHub Actions configuration, or repository permission changes were performed.

## Agent guidance audit — 11 October 2026

Updated AGENTS.md against the current code and maintainer preferences: replaced the obsolete ten-second cap and square-button requirement, made dedicated accessibility checks optional, and clarified device-derived ranges, numeric validation, session draft retention, envelope semantics, export parity, and playback safeguards. Clarified MCP versus documentation/Git tool boundaries and actual-destination reporting. Added the owner's main-update policy without claiming GitHub enforcement. Existing signing prohibitions remain intact. Removed README's now-resolved warning about stale AGENTS guidance; the capability-study follow-up remains.

Documentation content, relative links/image references, and Git whitespace checks passed. No app source or project changes were made, and no tests, builds, simulator interactions, hardware checks, or GitHub settings changes were performed for this audit.

## README and supplied screenshots — 11 October 2026

Rewrote README against the current source inspected through Xcode MCP: eleven native choices, current Custom sections, exact numeric editing, retained drafts, Reset, capabilities and limits, Play/Stop, and Swift file sharing. Added setup, source mapping, unit coverage, reuse, and AI-agent guidance. Removed obsolete Canvas/UI-test links and old slider/timing descriptions. Other contribution documents remain a separate follow-up, with their known drift identified in README.

- Copied the maintainer-supplied Home and Custom PNGs into `Docs/Screenshots/home.png` and `Docs/Screenshots/custom.png` as documentation assets. Both are 1206 × 2622 and byte-for-byte identical to the supplied files. The Home image reports hardware identifier iPhone18,3 and iOS 27.0.1. Images were visually reviewed; their contents do not verify physical vibration or playback lifecycle.
- Checked all 38 README relative links, image references, and local anchors; no missing destinations. Git whitespace check passed. Xcode MCP test discovery confirmed 27 enabled unit tests; tests were not executed for this documentation change.
- Before the supplied screenshots arrived, the requested iPhone 13 mini interaction session failed device selection; an iPhone 17 Pro session required a device-interaction skill unavailable in this environment. Session closure was requested. Xcode preview captures used iPhone Duo / iOS 27.1 but are not included in the README. Temporary preview source was created and removed through Xcode MCP; no app-source changes remain. No normal build, UI tests, hardware installation, or physical/minimum-runtime validation was performed for this documentation update.

## System haptics section — 11 October 2026

Added the native `System haptics` section header above the home button grid. The Custom navigation row remains in its own section with the existing device footer. No numeric padding or custom header styling was added. Source edits and verification used Xcode MCP; review followed the previously reviewed external exported SwiftUI guidance, not a built-in skill. README remains deferred.

- Light and dark Xcode previews were rendered and inspected on the preview-selected iPhone Duo / iOS 27.1 destination; the header, button grid, Custom row, and device footer were visible.
- Explicitly selected iPhone 13 mini simulator / iOS 26.5: existing repeated-native-request unit test passed, followed by a successful normal build. This unit test checks request behavior, not the section label.
- Compact-screen visual review, accessibility text sizes, physical vibration, and iOS 26.0 minimum-runtime execution were not checked. No UI tests or physical-device installation were performed.
- The prior Reset-label and Custom-title entries inferred the build destination from earlier state instead of checking it. Those builds succeeded, but their claimed iPhone 13 mini destination was not verified. The current simulator build covers both label changes as well.

## Custom title — 11 October 2026

Changed the custom screen navigation title to `Custom` through Xcode MCP. Normal build succeeded with no reported errors on the existing iPhone 13 mini / iOS 26.5 simulator destination. This copy-only change affects no unit-tested behavior; unit and UI tests were not run. Visual, physical-device, and iOS 26.0 minimum-runtime checks were not run. Native navigation remains consistent with the previously reviewed external exported SwiftUI guidance; no built-in skill was invoked. README remains deferred.

## Reset label — 11 October 2026

Changed the Custom haptics button label to `Reset to defaults` through Xcode MCP. Normal build succeeded with no reported errors on the existing iPhone 13 mini / iOS 26.5 simulator destination. This copy-only change affects no unit-tested behavior; unit and UI tests were not run. Visual, physical-device, and iOS 26.0 minimum-runtime checks were not run. The native Button and its action remain unchanged, consistent with the previously reviewed external exported SwiftUI guidance; no built-in skill was invoked. README remains deferred.

Date: 10 October 2026. Source, tests, project settings, builds, and simulator test execution were handled through Xcode MCP.

## API and skill review

Apple documentation searches covered SwiftUI SensoryFeedback platform support, native impact variants, Core Haptics intensity/sharpness and engine lifecycle, asynchronous start/stop, off-main callbacks, and Pencil canvas feedback. The sample excludes feedback documented only on other platforms.

Reviewed with the exported `swiftui-specialist` skill from the user-supplied [xcode27-skills repository](https://github.com/superagents-lab/xcode27-skills/tree/6f9ff8d5ad6000491cb0f483a776b7062e41cd97/swiftui-specialist). Applied separate View boundaries, private state ownership, MainActor observable state, stable enum identities, native modifiers, and LocalizedStringResource for pattern names. This was an external exported skill review; a built-in Xcode skill invocation is not exposed and was not performed. No copied skill content is distributed with this project.

## Exact input and retained custom draft — 11 October 2026

Numeric values beside the smooth sliders now open a native editor with a decimal keyboard, Save, Cancel, allowed-range guidance, and inline input errors. Validation rejects empty or malformed text, units/grouping, nonfinite/overflowing values, underflow to zero, and out-of-range values without clamping or changing the draft. Continuous duration must be positive. Input accepts locale decimal separators, decimal digits, and pasted Swift decimal/scientific notation. Opening and saving preserves the stored Double rather than the rounded display value; row values now show up to eight significant digits. Fixed device values cannot be edited. Cancelling or dismissing an editor does not apply its text.

Moved the draft into the existing MainActor controller owned by the home screen, so rebuilding or returning to Custom does not reset parameters. This is in-memory retention for the current app session, not persistence across launches. Reset now reads `Reset parameter to default` and restores the device-derived defaults. Playback requests remain immutable snapshots; leaving Custom or backgrounding still stops playback. No Undo, general disabled-action explanation, or playback-edit message was added. README remains deferred.

Apple TextField and FocusState documentation was reviewed through Xcode MCP. SwiftUI review continued with the previously reviewed external exported guidance; no built-in Xcode skill was invoked.

- Xcode MCP, iPhone 13 mini simulator, iOS 26.5: all 27 unit tests passed. Seven new tests cover strict text validation, exact bounds and precision, positive continuous duration, German and Arabic decimal input, round-trip formatting, draft retention through Stop/view construction, and Reset preserving an already captured snapshot.
- Normal build succeeded with no errors or warnings; a final normal build also succeeded after an indentation-only cleanup. Git whitespace check passed.
- Keyboard/editor interaction, Save/Cancel UI, actual navigation retention, compact/light/dark appearance, physical vibration, and iOS 26.0 minimum-runtime execution were not exercised. The previously recorded simulator-interaction limitation was not retried. No UI tests, dedicated accessibility checks, or physical-device installation were performed.

Artifacts: `Test-HapticsLab-2026.10.11_15-09-57-+0530.xcresult` (27 tests), `BuildProject-Log-20261011-151021.txt` (normal build), `BuildProject-Log-20261011-151048.txt` (final normal build after indentation cleanup). Temporary artifacts are not distributed.

## Home title capitalization — 11 October 2026

Changed the home navigation title to `Haptics lab`, matching the requested app display name. Source edit, unit execution, and build used Xcode MCP; README remains deferred. No control behavior or layout changed.

- iPhone 13 mini simulator, iOS 26.5: existing distinct-native-request unit test passed; final normal build succeeded with no reported errors. Git whitespace check passed.
- Visual title appearance, physical vibration, and iOS 26.0 minimum-runtime execution were not checked. No UI tests, dedicated accessibility checks, or physical-device installation were performed.

Artifacts: `Test-HapticsLab-2026.10.11_15-00-33-+0530.xcresult`, `BuildProject-Log-20261011-150041.txt` (temporary, not distributed).

## App display name and capability-copy review — 11 October 2026

Set `CFBundleDisplayName` to `Haptics lab` through Xcode MCP AddInfoPlist. Xcode MCP GetTargetBuildSettings confirmed the evaluated display name. The in-app navigation title remains `Haptics Lab`. Existing local signing settings and deferred README changes were preserved.

Reviewed the footer implementation through Xcode MCP: it shows Custom haptics supported only when `CHHapticEngine.capabilitiesForHardware().supportsHaptics` is true and the app is not a simulator build. Otherwise it shows Custom haptics unavailable. Capabilities are captured when the controller is initialized. This is a hardware-support check, not confirmation that a playback request has succeeded; no footer behavior was changed.

- Xcode MCP, iPhone 13 mini simulator, iOS 26.5: existing repeatable-Stop unit test passed, followed by a successful normal build with no reported errors. The unit test is a smoke check, not an assertion of the icon label. Git whitespace check passed.
- Home Screen icon-label appearance, physical playback, and iOS 26.0 minimum-runtime execution were not checked. No physical-device installation, UI tests, or dedicated accessibility checks were performed.

Artifacts: `Test-HapticsLab-2026.10.11_14-59-26-+0530.xcresult`, `BuildProject-Log-20261011-145939.txt` (temporary, not distributed).

## Native Swift file sharing — 11 October 2026

Replaced the direct file-export dialog with UIKit's native activity sheet presented from SwiftUI. Share Swift code captures the current validated configuration into a real UTF-8 `CustomHaptic.swift` attachment, allowing compatible sharing apps and Save to Files. Each request has a unique temporary directory, so later exports cannot overwrite an in-flight attachment. The file remains retained through child activity presentations and is cleaned up when the share sheet dismisses, including cancellation. Preparation and activity errors use the Sharing unavailable alert. The generated SwiftUI/Core Haptics code, validation, separate toolbar groups, and Play/Stop handling remain unchanged. Removed the obsolete FileDocument implementation.

Apple documentation for ShareLink, file sharing, UIActivityViewController, and its completion handler was reviewed through Xcode MCP. Review continued with the previously reviewed external exported SwiftUI guidance; no built-in Xcode skill was invoked. README remains deferred.

- Xcode MCP, iPhone 13 mini simulator, iOS 26.5: seven affected tests passed, covering generated values/timing, invalid drafts, immutable file snapshots, UTF-8 contents and filename, independent share files, idempotent cleanup, preparation failures, and repeatable Stop. The independent-file/cleanup test also passed after adopting item-driven sheet presentation.
- Final normal build succeeded with no reported errors or warnings after the attachment-retention refinement. Git whitespace check passed.
- Share-sheet interaction, actual receipt by another app, Save to Files, cancellation UI, and compact/light/dark layouts remain unexecuted because of the previously recorded simulator-interaction limitation. No UI tests or dedicated accessibility checks were run. Hardware playback and iOS 26.0 minimum-runtime execution remain unverified. No physical-device installation was performed.

Artifacts: `Test-HapticsLab-2026.10.11_14-51-03-+0530.xcresult` (seven affected tests), `Test-HapticsLab-2026.10.11_14-51-54-+0530.xcresult` (cleanup follow-up), `BuildProject-Log-20261011-145242.txt` (final normal build). Temporary artifacts are not distributed.

## Separate playback and export toolbar groups — 11 October 2026

Moved Export/Share after Play/Stop in the trailing toolbar and separated the two items with native `ToolbarSpacer(.fixed, placement: .topBarTrailing)`. Apple documentation retrieved through Xcode MCP confirms fixed toolbar spacers divide Liquid Glass toolbar groups. No numeric spacing or custom background was added; button actions and validation remain unchanged. Review continued with the previously reviewed external exported SwiftUI guidance; no built-in Xcode skill was invoked. README remains deferred.

- Xcode MCP, iPhone 13 mini simulator, iOS 26.5: export-snapshot and repeatable-Stop unit tests passed (2/2), followed by a successful normal build with no reported errors. Git whitespace check passed.
- Toolbar appearance on compact/light/dark screens remains visually unverified because of the previously recorded simulator-interaction limitation. No UI tests or dedicated accessibility checks were run. Physical playback and iOS 26.0 minimum-runtime execution were not checked; no physical-device installation was performed.

Artifacts: `Test-HapticsLab-2026.10.11_14-46-22-+0530.xcresult`, `BuildProject-Log-20261011-144632.txt` (temporary, not distributed).

## Inline section information buttons — 11 October 2026

Moved each information button directly after its section title (Haptics, Repetition, Envelope), with the flexible spacer after the button. Uses default HStack spacing and native vertical padding without numeric margins. Help content and presentation are unchanged. Review follows the previously reviewed external exported SwiftUI guidance; no built-in Xcode skill was invoked. README remains deferred.

- Xcode MCP, iPhone 13 mini simulator, iOS 26.5: existing configuration-snapshot unit test passed; final normal build succeeded with no reported errors. This unit check does not verify layout. Git whitespace check passed.
- Compact/light/dark visual checks remain unexecuted due to the previously recorded simulator-interaction limitation. UI tests and dedicated accessibility checks were not run, as requested. Physical vibration and iOS 26.0 minimum-runtime execution were not checked.

Artifacts: `Test-HapticsLab-2026.10.11_14-38-18-+0530.xcresult`, `BuildProject-Log-20261011-143827.txt` (temporary, not distributed).

## Swift code export and app icon — 11 October 2026

Added Export Swift code beside the Custom screen's Play/Stop button. Tapping captures the current valid draft as an immutable UTF-8 `CustomHaptic.swift` document and opens SwiftUI's native file exporter. Invalid drafts disable export; export failures have their own alert. Generated code is standalone SwiftUI with Core Haptics playback, preserving the event type, active available parameters, Float precision used by playback, repetition timing, and continuous duration. The example checks destination-device support/ranges and includes Play/Stop, cancellation, generation/engine identity checks, and scene/disappearance cleanup. It requires no HapticsLab module or third-party dependencies.

Apple's `fileExporter` and `UTType.swiftSource` documentation was reviewed through Xcode MCP. SwiftUI review continued with the previously reviewed external exported guidance above; no locally exposed built-in Xcode skill was invoked. README remains deferred. Dedicated accessibility testing is no longer required by the user; native accessibility labels remain.

- Xcode MCP, iPhone 13 mini simulator, iOS 26.5: all 18 unit tests passed, including four new export tests covering numeric parity with playback, transient/continuous timing, active/unsupported envelopes, invalid values, and immutable document snapshots. An initial test compilation failed because the test file lacked `UniformTypeIdentifiers`; the import was added before the passing run.
- A representative generated Swift file compiled as a temporary test source through Xcode MCP. Its three continuous events and pattern duration matched the app's configuration, and repeated Stop was safe. The first verification assertion assumed pattern duration equaled the last event's nominal end; Core Haptics includes envelope effects. Replacing that assumption with comparison against the app's actual Core Haptics pattern passed. The temporary source was removed through Xcode MCP.
- Xcode's snippet runner successfully produced the representative export, but could not compile its `@Observable` type in snippet-local scope (attached extension macro restriction). Normal Xcode test compilation provided the successful check above; no shell compilation fallback was used.
- Final normal build succeeded with no reported errors or warnings after removing the temporary source. Git whitespace checks passed.
- Native save-dialog interaction, compact/light/dark layouts, and SpringBoard icon appearance were not exercised; the earlier simulator-interaction limitation was not retried. No UI tests or dedicated accessibility checks were run. Physical vibration, destination-device playback, and iOS 26.0 minimum-runtime execution remain unverified. No physical-device installation was performed.

The app icon was generated with the built-in imagegen tool using the imagegen skill, visually inspected, resized to 1024×1024, and verified opaque. Xcode MCP could not read the asset catalog's `Contents.json` and exposes no binary image import. The user explicitly approved file-tool exceptions for PNG resize/copy and this icon JSON. The default iOS icon now references [HapticsLabIcon.png](HapticsLab/Assets.xcassets/AppIcon.appiconset/HapticsLabIcon.png); optional appearance slots remain unchanged. The original generated image was preserved outside the repository.

Final image prompt: “Use case: logo-brand. Create a production iOS app icon image for Haptics Lab, a native minimal haptic-testing utility. Square 1024 by 1024 opaque image. A single centered black waveform symbol inspired by SF Symbols waveform: seven evenly spaced vertical solid bars with fully rounded ends, varied heights forming a balanced rhythmic waveform silhouette, with generous negative space. Crisp clean vector-like edges, monochrome black mark on pure white background covering the entire square. Symbol about 60 percent of canvas width. No text, no letters, no border, no shadows, no gradients, no 3D, no device mockup, no pre-rounded app-icon corners; iOS applies its own corner mask.”

Artifacts: `Test-HapticsLab-2026.10.11_14-35-19-+0530.xcresult` (18 units), `Test-HapticsLab-2026.10.11_14-36-47-+0530.xcresult` (initial duration assumption failure), `Test-HapticsLab-2026.10.11_14-37-16-+0530.xcresult` (generated-file verification), `BuildProject-Log-20261011-143730.txt` (final normal build). Temporary artifacts are not distributed.

## Unified Play and Stop button — 11 October 2026

The Custom toolbar uses one button: `play.fill` starts playback while idle; `stop.fill` calls the existing stop action during startup or playback. Removed the separate Stop section. Stop remains enabled regardless of draft validation, with the corresponding accessible label and identifier. Existing completion, cancellation, interruption, and screen/background handling remain unchanged. README remains deferred. SwiftUI review continued with the previously reviewed external exported guidance above; no locally exposed built-in Xcode skill was invoked.

- Xcode MCP, iPhone 13 mini simulator, iOS 26.5: repeatable Stop and immutable configuration-snapshot unit tests passed (2/2). These cover controller/model behavior, not live toolbar interaction.
- Final normal build succeeded with no reported errors. Git diff whitespace check passed. No UI tests were added or run.
- Live Play/Stop transitions and physical vibration were not checked on hardware. Compact/light/dark/accessibility visual checks remain unexecuted because of the previously recorded simulator-interaction blocker, which was not retried. iOS 26.0 minimum-runtime execution remains unverified. No physical-device installation was performed.

Artifacts: `Test-HapticsLab-2026.10.11_14-29-46-+0530.xcresult`, `BuildProject-Log-20261011-142956.txt` (temporary, not distributed).

## Section information buttons — 11 October 2026

Replaced the Haptics, Repetition, and Envelope footers with an accessible information button in each section header. A single item-driven native sheet presents the selected section's unchanged explanation with its title, a Done button, and scrollable text. It offers medium/large sheet sizes and uses the large size for accessibility Dynamic Type categories. Controls remain visible; help state is independent of parameter values. Semantic styling, native `.padding()`, and existing playback safeguards are preserved. README remains deferred.

SwiftUI review continued with the previously reviewed external exported guidance above; no locally exposed built-in Xcode skill was invoked. Xcode MCP documentation review covered native sheet presentation configuration.

- Xcode MCP, iPhone 13 mini simulator, iOS 26.5: existing configuration-snapshot and envelope-mapping unit tests passed (2/2). These tests cover model behavior, not sheet interaction.
- Final normal build succeeded with no reported errors. Git diff whitespace check passed. No UI tests were added or run.
- Sheet opening/dismissal and compact/light/dark/accessibility visual checks were not executed. The simulator-selection blocker reported during the preceding screen review was not retried. Physical vibration and iOS 26.0 minimum-runtime execution remain unverified. No physical-device installation was performed.

Artifacts: `Test-HapticsLab-2026.10.11_14-27-50-+0530.xcresult`, `BuildProject-Log-20261011-142807.txt` (temporary, not distributed).

## Envelope order and guidance — 11 October 2026

Reordered Envelope to Sustained, Attack time, then Release time when sustained or Decay time otherwise. Replaced its footer with the agreed explanation for new testers, including relative values and changing one control at a time. Device capability handling, parameter bindings, native spacing, and playback behavior are unchanged. Review continued with the previously reviewed external exported SwiftUI guidance above; no locally exposed built-in Xcode skill was invoked. Apple envelope descriptions and normalized-value semantics were confirmed through Xcode MCP DocumentationSearch during the preceding copy review. README remains deferred.

- Xcode MCP, iPhone 13 mini simulator, iOS 26.5: the existing envelope parameter-mapping unit test passed for sustained and unsustained configurations.
- Final normal build succeeded with no reported errors. Git diff whitespace check passed. No UI tests were added or run.
- Compact/light/dark/accessibility visual checks were not executed; the previously recorded simulator interaction skill limitation was not retried. Physical vibration and iOS 26.0 minimum-runtime execution remain unverified. No physical-device installation was performed.

Artifacts: `Test-HapticsLab-2026.10.11_14-19-57-+0530.xcresult`, `BuildProject-Log-20261011-142007.txt` (temporary, not distributed).

## Repetition controls and UI test removal — 11 October 2026

Moved the former Timing section directly below Haptics and renamed it Repetition. The native Repetitions stepper defaults to one total vibration and retains its 1–8 range. Gap appears only above one repetition and retains its value while hidden. Reset restores one repetition. Added the agreed explanatory footer and updated validation terminology. Native spacing and playback lifecycle protections are unchanged. SwiftUI review continued with the previously reviewed external exported guidance above; no locally exposed built-in Xcode skill was invoked. README remains deferred.

At the user's request, removed the UI test source and its debug-only appearance override through Xcode MCP. Updated contributor guidance to use unit tests and normal builds. Xcode MCP exposes no target-removal operation, so the user approved a one-time direct edit of project.pbxproj to remove the empty UI test target, product, build phases, dependency, configurations, and remaining references. App and unit-test build settings, including local signing settings, were preserved exactly. Xcode MCP confirmed that only the app and unit-test targets remain.

- Xcode MCP, iPhone 13 mini simulator, iOS 26.5: all 14 remaining unit tests passed after complete UI test target removal. Final normal build succeeded with no reported errors. Git diff whitespace checks passed.
- Before removal, five affected unit tests passed. Custom controls UI coverage passed after correcting the generated Stepper button identifiers, including conditional Gap, remembered Gap, and Reset. The layout test failed at the largest accessibility size while its helper tried to reveal the composite Stepper; diagnostic results showed a full-sized row within screen bounds but an untappable container. Smaller scroll gestures did not fully resolve the helper failure. One intermediate test build failed on an XCTest argument label and was corrected. A final attempt targeting the actual increment button was cancelled when the user requested UI test removal. No passing layout result is claimed.
- Screenshots were not visually inspected. Complete compact/light/dark/accessibility layout verification, physical vibration, and iOS 26.0 minimum-runtime execution remain unverified. No physical-device installation was performed.

Final artifacts: `Test-HapticsLab-2026.10.11_14-11-26-+0530.xcresult` (14 unit tests), `BuildProject-Log-20261011-141136.txt`. Earlier diagnostic UI results: `Test-HapticsLab-2026.10.11_13-57-52-+0530.xcresult`, `Test-HapticsLab-2026.10.11_13-59-01-+0530.xcresult`, `Test-HapticsLab-2026.10.11_14-01-58-+0530.xcresult`, `Test-HapticsLab-2026.10.11_14-04-28-+0530.xcresult`. Temporary artifacts are not distributed.

## Haptics footer guidance — 11 October 2026

Replaced the Haptics footer with the user's wording explaining Intensity, Sharpness, and Continuous. Controls, native padding, parameter handling, and playback behavior are unchanged. Review continued with the previously reviewed external exported SwiftUI guidance above; no locally exposed built-in Xcode skill was invoked. README remains deferred at the user's request.

- Xcode MCP, iPhone 13 mini simulator, iOS 26.5: the compact light/dark/largest-accessibility layout test passed.
- Final normal build succeeded with no reported errors. Git diff whitespace check passed. Unit tests were not rerun for this copy-only change.
- Test screenshots were captured but not visually inspected. Physical vibration and iOS 26.0 minimum-runtime execution were not checked; no physical-device installation was performed.

Artifacts: `Test-HapticsLab-2026.10.11_13-46-02-+0530.xcresult`, `BuildProject-Log-20261011-134735.txt` (temporary, not distributed).

## Haptics section and Continuous toggle — 11 October 2026

The first Custom section is now titled “Haptics”, ordered Intensity, Sharpness, Continuous, then Duration only while Continuous is enabled. Continuous defaults off; its remembered duration starts at 0.2 seconds and supports smooth adjustment through the existing 30-second maximum. The toggle independently selects native transient/continuous event types. Zero duration is rejected for continuous playback and displays an inline explanation; it no longer selects a tap. Turning Continuous off preserves duration while scheduling zero-duration transient events. Reset turns Continuous off and restores 0.2 seconds.

Mode switching preserves parameter values valid for the selected event's device-reported ranges. Finite values outside a newly selected range use that range's default, as explained in the section footer; nonfinite values remain invalid and are never silently repaired. Native padding, other sections, and playback lifecycle protections are unchanged. SwiftUI review continued with the previously reviewed external exported guidance above; no locally exposed built-in Xcode skill was invoked. README remains deferred at the user's request.

Current-change checks through Xcode MCP on iPhone 13 mini simulator, iOS 26.5:

- Initial full suite: 15 passed, 2 failed. All 14 unit tests passed, including native event type/timing, remembered duration, valid-value preservation, new-range defaults, nonfinite rejection, and zero-duration rejection for continuous events. Native button UI coverage passed.
- Both Custom UI checks initially failed to reveal Duration because the test's center tap did not activate the native switch. Changed the tests to tap the switch at the trailing side of its accessibility element and assert its on-state. Both targeted reruns passed, covering hidden/visible Duration, remembered values, Reset, toolbar playback/error feedback, and compact light/dark/largest-accessibility layouts. App code was unchanged after the full suite; passing tests were not repeated.
- Final normal build succeeded with no reported errors. Git diff whitespace check passed.
- Test screenshots were captured but not visually inspected. Physical vibration, hardware playback/Stop, and iOS 26.0 minimum-runtime execution remain unchecked. No physical-device installation was performed.

Artifacts: `Test-HapticsLab-2026.10.11_13-27-29-+0530.xcresult` (full suite), `Test-HapticsLab-2026.10.11_13-29-48-+0530.xcresult` (targeted UI rerun), `BuildProject-Log-20261011-133240.txt` (final normal build). Temporary artifacts are not distributed.

## Envelope terminology — 11 October 2026

Renamed Attack, Decay, Release, and Sustain to “Attack time”, “Decay time”, “Release time”, and “Sustained”. Updated the envelope explanation and the fixed/unavailable Sustained label consistently. API mappings, values, native spacing, and playback behavior are unchanged. Review continued with the previously reviewed external exported SwiftUI guidance above; no locally exposed built-in Xcode skill was invoked. README remains deferred.

- Xcode MCP, iPhone 13 mini simulator, iOS 26.5: both affected UI tests passed (Custom controls/reset/error alert and compact light/dark/largest-accessibility layout).
- Final normal build succeeded with no reported errors. Git diff whitespace check passed. Unit tests were not rerun for this copy-only change.
- Screenshots were captured but not visually inspected. Physical vibration and iOS 26.0 minimum-runtime execution were not checked; no physical-device installation was performed.

Artifacts: `Test-HapticsLab-2026.10.11_13-14-29-+0530.xcresult`, `BuildProject-Log-20261011-131643.txt` (temporary, not distributed).

## Toolbar Play control — 11 October 2026

Moved Play to a native top-trailing toolbar button using the `play.fill` SF Symbol and an accessible “Play custom haptic” label. It uses primary foreground when enabled and secondary gray when disabled, preserving the existing starting/playing and validation disable conditions. The controller's duplicate-play guard, Stop control, and playback cancellation are unchanged. Removed the persistent playback status and hardware explanation from the Form; unsupported-hardware feedback now uses the existing playback error alert. Native spacing is preserved. README remains deferred.

Review continued with the external exported SwiftUI guidance identified above; no locally exposed built-in Xcode skill was invoked.

Current-change checks through Xcode MCP on iPhone 13 mini simulator, iOS 26.5:

- Compact light/dark/largest-accessibility layout test passed, including top-right navigation-bar placement, visibility while scrolling, and removed playback copy.
- The Custom controls test initially failed because the existing error alert was attached to the home List and did not present on the pushed Custom screen. Moved that alert to CustomHapticsView. The targeted Custom controls rerun passed, checking toolbar accessibility/activation, unsupported-hardware feedback, alert dismissal, and reset. The passing layout test was not repeated after this alert-only correction.
- Final normal build passed with no reported errors. Git diff whitespace check passed. Unit tests were not rerun for this UI change.
- Screenshots were captured as test attachments but not visually inspected. Disabled gray appearance and ignored taps during real playback were preserved in source but cannot be exercised with simulator haptic playback. Physical vibration, hardware playback/Stop, and iOS 26.0 minimum-runtime checks remain unexecuted. No physical device installation was performed.

Artifacts: `Test-HapticsLab-2026.10.11_12-19-15-+0530.xcresult` (initial), `Test-HapticsLab-2026.10.11_12-21-43-+0530.xcresult` (targeted rerun), `BuildProject-Log-20261011-122245.txt` (final build). Temporary artifacts are not distributed.

## Custom duration and title — 11 October 2026

Renamed the navigation title to “Custom haptics” and replaced the Tap/Continuous picker with an always-visible, smooth Duration slider. At the user's direction, zero selects a native transient event; positive values select a continuous event up to the existing 30-second limit. Reset returns duration to zero. Switching event types retains device-specific parameter defaults/ranges. Negative, nonfinite, and out-of-range durations remain rejected. Native padding and playback cancellation/lifecycle handling are preserved. README remains deferred.

SwiftUI review used the external exported guidance identified above, not a locally exposed built-in Xcode skill. Xcode MCP source inspection confirmed mappings for Intensity (`hapticIntensity`), Sharpness (`hapticSharpness`), Attack (`attackTime`), Sustain (`sustained`), Decay (`decayTime`), Release (`releaseTime`), and Duration (`CHHapticEvent.duration`). Pulses and Gap are app-defined repetition/spacing labels. A fresh Apple documentation confirmation is blocked because the current Xcode MCP tool set does not expose documentation search; no shell or web substitute was used.

Current-change checks through Xcode MCP on iPhone 13 mini simulator, iOS 26.5:

- Initial full suite: 15 passed, 1 failed. All 13 unit tests passed, including zero/positive/zero native event-type mapping, fractional duration preservation, the 30-second boundary, envelopes, and invalid-value rejection. Native-button and compact light/dark/largest-accessibility layout UI tests passed.
- The Custom controls UI test failed in its scroll helper after Reset. Updated that test to scroll upward to the first-row Duration control, including when Form removes offscreen rows from the accessibility tree. Its targeted rerun passed, covering smooth adjustment, return to zero, maximum duration, simulator feedback, and reset. No app code changed after the full run, and the other passing tests were not repeated.
- Final normal build succeeded with no reported errors. Git diff whitespace check passed.
- UI screenshots were captured as test attachments but were not visually inspected. Physical vibration and iOS 26.0 minimum-runtime execution remain unverified. No physical-device installation was performed.

Artifacts: `Test-HapticsLab-2026.10.11_12-10-22-+0530.xcresult` (full suite), `Test-HapticsLab-2026.10.11_12-13-32-+0530.xcresult` (targeted rerun), `BuildProject-Log-20261011-121439.txt` (final normal build). Temporary artifacts are not distributed. The earlier title-only two-test run also passed, but the results above cover the final implementation.

## Remove Alignment — 10 October 2026

Removed the Alignment enum case, label, symbol mapping, and feedback mapping, leaving 11 native haptic choices. The capability study now distinguishes the documented iOS/macOS availability of alignment from confirmed iPhone vibration, noting Apple's Pencil canvas guidance and the user's hardware observation. README remains deferred. SwiftUI review continued with the external guidance referenced above; the existing two-column layout handles the odd button count without fixed sizes or padding changes.

- Xcode MCP, iPhone 13 mini simulator, iOS 26.5: all 3 affected tests passed (1 unit, 2 UI), covering native identifiers/repeated requests, each remaining button, Alignment's absence, native Custom navigation, footer copy, and compact light/dark/largest-accessibility layout assertions.
- Final normal build passed with no reported errors. Git diff whitespace check passed.
- Visual screenshot inspection, physical vibration, and iOS 26.0 minimum-runtime checks were not performed. No physical-device installation was made.

Artifacts: `Test-HapticsLab-2026.10.10_19-24-31-+0530.xcresult`, `BuildProject-Log-20261010-192646.txt` (temporary, not distributed).

## Native Custom navigation row — 10 October 2026

Converted Custom haptics testing into a standard NavigationLink row inside an inset-grouped List. iOS supplies the disclosure chevron, row styling, and navigation behavior. Primary text and native spacing are preserved; no fixed row height or numeric padding was introduced. The 12 haptic buttons retain their two-column, equal-height layout and custom button styling. The device copy is the navigation section's footer. README was not edited. Review continued with the external SwiftUI guidance above and Xcode MCP Apple documentation for list navigation.

- Xcode MCP, iPhone 13 mini simulator, iOS 26.5: native button dispatch and Custom controls/navigation tests passed. The initial layout test failed because it queried the new list row's label before scrolling it into view.
- Moved the label assertion after the existing reveal helper. Targeted layout rerun passed in light, dark, and largest accessibility text, checking native list-cell membership, navigation, equal haptic-button heights, and footer copy. The other two tests were not repeated after this test-only ordering correction.
- Final normal build succeeded with no reported errors. Git diff whitespace check passed.
- Screenshot inspection, physical-device execution, and iOS 26.0 minimum-runtime checks remain unexecuted. Unit tests were not rerun for this UI-only change.

Artifacts: `Test-HapticsLab-2026.10.10_19-19-21-+0530.xcresult` (initial), `Test-HapticsLab-2026.10.10_19-21-45-+0530.xcresult` (targeted), `BuildProject-Log-20261010-192331.txt` (normal build). Temporary artifacts are not distributed.

## Device footer copy — 10 October 2026

The footer now uses three lines: `iPhone model: <detected hardware identifier>`, `iOS version: <system version>`, and `Custom haptics supported.` or `Custom haptics unavailable.` according to support (unavailable on simulators). No marketing-model lookup was added. Kept native padding, semantic colors, and combined accessibility labeling. README was not edited; SwiftUI review continued with the external guidance identified above.

- Xcode MCP, iPhone 13 mini simulator, iOS 26.5: the affected UI test passed for light, dark, and largest accessibility text, checking the new labels, unavailable simulator status, and home layout.
- Final normal build passed with no reported errors. Git diff whitespace check passed.
- Visual screenshot inspection, physical device execution, and iOS 26.0 minimum-runtime checks were not performed. Unit tests were not rerun for this copy/display change.

Artifacts: `Test-HapticsLab-2026.10.10_19-16-29-+0530.xcresult`, `BuildProject-Log-20261010-191754.txt` (temporary, not distributed).

## Equal home-button heights — 10 October 2026

All 13 home buttons now share the tallest intrinsic padded-label height, including the full-width Custom CTA. Removed Custom's additional vertical padding. A SwiftUI Layout measures the labels at their actual column widths, uses native ViewSpacing preferences, and responds to Dynamic Type and layout direction. Button padding remains `.padding()` with no numeric inset or fixed height. README remains deferred. Review used the external SwiftUI guidance referenced above and Xcode MCP Apple documentation for Layout and ViewSpacing.

- Xcode MCP, iPhone 13 mini simulator, iOS 26.5: native dispatch test passed. The first appearance/layout run passed its height comparisons but failed the full-button visibility assertion because the scroll helper accepted partially visible controls.
- Updated the helper to scroll in either direction until the whole control is visible. Targeted rerun passed both the light/dark/largest-accessibility layout test (all 13 heights equal) and the Custom controls/navigation test. The native dispatch test was not repeated after this test-helper-only correction.
- Final normal build succeeded with no reported errors. Git diff whitespace check passed.
- Screenshot inspection, physical hardware, and iOS 26.0 minimum-runtime checks remain unexecuted. No physical installation was performed. Unit tests were not rerun for this layout change.

Artifacts: `Test-HapticsLab-2026.10.10_19-10-36-+0530.xcresult` (initial), `Test-HapticsLab-2026.10.10_19-13-15-+0530.xcresult` (targeted), `BuildProject-Log-20261010-191452.txt` (normal build). Temporary artifacts are not distributed.

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
