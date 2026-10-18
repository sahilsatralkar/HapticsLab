# Haptics capability study

Updated 11 October 2026 against the current app sources using Xcode MCP. Apple documentation was first reviewed on 10 October; the continuous-event limit, envelope semantics, and Pencil canvas guidance were checked again during this update. This document separates framework capabilities from features implemented in Haptics lab. It does not establish physical feedback on a particular device.

The app targets iPhone and iPad with iOS/iPadOS 26.0 or later. Custom testing covers built-in vibration, with no audio. Home also offers native canvas feedback requests intended for Apple Pencil Pro with a compatible iPad.

## Detection and limits

`CHHapticEngine.capabilitiesForHardware()` provides `supportsHaptics` and parameter attributes. The app queries `attributes(forEventParameter:eventType:)` separately for transient and continuous events, retaining valid minimum, maximum, and default values for each of the six fixed haptic parameters. Missing required Intensity or Sharpness attributes prevent validation. Missing optional envelope parameters are shown as unavailable and omitted from events. Invalid or nonfinite capability data never becomes an invented supported range.

Home displays `Device model`, `OS version`, and the detected custom-haptic support status. Simulators show custom haptics as unavailable. The model is a raw hardware identifier, not a guessed marketing name. Capability decisions use Core Haptics rather than that identifier. Neither the custom-haptic support check nor the canvas buttons detect a connected Pencil.

Sources: [device capabilities](https://developer.apple.com/documentation/corehaptics/chhapticdevicecapability), [event attributes](https://developer.apple.com/documentation/corehaptics/chhapticdevicecapability/attributes(foreventparameter:eventtype:)), [parameter attributes](https://developer.apple.com/documentation/corehaptics/chhapticparameterattributes). Implementation: [HapticCapabilities.swift](../HapticsLab/HapticCapabilities.swift), [ContentView.swift](../HapticsLab/ContentView.swift).

| Limit | Origin and behavior |
| --- | --- |
| Continuous Duration greater than 0, up to 30 seconds | Apple's documented maximum per continuous event; there is no device-specific duration attribute query |
| 1–8 Repetitions | App limit; each repetition uses the same event type and parameters |
| Gap of 0–2 seconds | App limit; spacing after the scheduled event duration and before the next event |
| Up to 254 seconds of scheduled continuous events | Eight 30-second events plus seven 2-second gaps; no ten-second total-pattern cap |

Transient events have zero encoded duration. Their starts are separated by Gap; a zero gap schedules them together. A release tail can overlap the gap, so Gap does not guarantee physical silence. Scheduled duration is not a measurement of tactile output.

Sources: [continuous event](https://developer.apple.com/documentation/corehaptics/chhapticevent/eventtype/hapticcontinuous), [event duration](https://developer.apple.com/documentation/corehaptics/chhapticevent/duration). Implementation: [CustomHapticConfiguration.swift](../HapticsLab/CustomHapticConfiguration.swift).

## Controls and fixed event parameters

Custom groups controls into Haptics, Repetition, and Envelope, each with an information button. Continuous reveals Duration; more than one repetition reveals Gap. Repetitions and Gap are app-defined sequence controls, not Core Haptics parameter IDs.

| UI label | Apple API | Meaning and availability |
| --- | --- | --- |
| Intensity | `.hapticIntensity` | Strength; device-reported range and default |
| Sharpness | `.hapticSharpness` | Soft/rounded to crisp character; device-reported range and default |
| Attack time | `.attackTime` | Envelope rise; relative value, not seconds |
| Sustained | `.sustained` | Sustained versus unsustained envelope; editable only if the reported range contains both 0 and 1 |
| Decay time | `.decayTime` | Envelope fall with Sustained off; omitted when Sustained is on |
| Release time | `.releaseTime` | Fade after a sustained event; omitted when Sustained is off |
| Duration | `CHHapticEvent.duration` | Seconds for a continuous event; not an event-parameter ID |

The six event parameters are queried separately for both event types. Only available, active parameters are encoded. Switching Continuous preserves values valid for the new type, using its reported defaults only when the new range requires a replacement. Reset to defaults resets the draft, including device-reported transient parameter defaults.

Sliders have no step increment. Tapping a displayed value opens locale-aware numeric entry with range guidance. Invalid, nonfinite, out-of-range, and nonzero values that underflow to zero are rejected. Invalid text and Cancel do not change the draft. Displayed values use up to eight significant digits; editing preserves the stored `Double`, while event parameters are converted to `Float` for Core Haptics. Smooth sliders do not promise arbitrary hardware resolution.

Apple's AHAP guide describes envelope values as normalized: 1 does not mean one second. The app therefore labels them as relative values. A successful parameter query or event construction does not prove a perceptible effect for every value and event type.

Sources: [event parameter catalog](https://developer.apple.com/documentation/corehaptics/chhapticevent/parameterid), [intensity](https://developer.apple.com/documentation/corehaptics/chhapticevent/parameterid/hapticintensity), [sharpness](https://developer.apple.com/documentation/corehaptics/chhapticevent/parameterid/hapticsharpness), [AHAP envelope semantics](https://developer.apple.com/documentation/corehaptics/representing-haptic-patterns-in-ahap-files). Implementation: [CustomHapticsView.swift](../HapticsLab/CustomHapticsView.swift), [HapticValueEditor.swift](../HapticsLab/HapticValueEditor.swift).

## Playback, drafts, and Swift export

The toolbar combines Play and Stop in one action, with Stop available during startup and playback. Share is a separate action. Playback captures an immutable configuration; later edits apply to the next request. The controller retains the draft across navigation during the app session, without persistence across launches.

Engines, players, and observable state remain on MainActor. Cancellable startup, playback-generation tokens, and engine-identity checks prevent stale asynchronous work from affecting newer playback. Leaving Custom or making the scene inactive stops playback. Engine interruptions do not automatically restart it. The engine is haptics-only and uses automatic shutdown.

Share creates a standalone UTF-8 `CustomHaptic.swift` attachment containing `ExportedHapticView` and `ExportedHapticPlayer`. It uses the same validation, event timing, active-parameter selection, and Float conversion as playback. The native share sheet can send it to another app or save it to Files. Each attachment captures the draft at export time, stays available through sharing, and has its own temporary directory for cleanup. As of v1.1 (12 October 2026), header comments also capture the exporting device type, hardware identifier, OS version, and simulator/physical environment using the same detection as Home. These comments do not affect generated playback or destination-device validation. Preparation and sharing errors are surfaced to the user.

The generated Swift 6 / iOS 26.0+ example checks the destination device's support and parameter ranges and retains Play/Stop, error handling, cancellation, and lifecycle safeguards. It has no dependency on this app's module. This is **Swift source export**, not AHAP export; the app has no AHAP import or saved preset library.

Implementation: [HapticsController.swift](../HapticsLab/HapticsController.swift), [HapticSwiftExport.swift](../HapticsLab/HapticSwiftExport.swift), [HapticShareSheet.swift](../HapticsLab/HapticShareSheet.swift). Framework reference: [engine stopped reasons](https://developer.apple.com/documentation/corehaptics/chhapticengine/stoppedreason).

## Configurable curves — implementation update, 18 October 2026

Custom now offers continuous-event intensity/sharpness curves. Dynamic ranges are queried separately using `attributes(forDynamicParameter:)`; no ranges are invented when unavailable. Native expandable point rows support exact numeric entry, insertion preserving the linear shape, and deletion of intermediate points. Start and End stay at 0 and Duration; stored positions scale times proportionally when Duration changes. Two to sixteen points is an app limit, with three flat points initially. Invalid ordering, nonfinite/out-of-range values, missing dynamic ranges, and unsupported combined Float values block playback/export. Constant and transient modes retain but ignore the curve; Reset clears it.

Playback and export share event construction and curve scheduling. Each repetition schedules its own pair of pattern-wide curves; zero-gap boundaries are included in unit coverage. The generated standalone player validates destination dynamic ranges and combined event/curve values. Envelope settings still apply, and tails may overlap subsequent activity. This implements scheduled modulation, not live controls, selectable motor frequency, or proof of engine-like tactile output.

## Other vibration capabilities

These framework features provide context for contributors; their presence here is not a commitment to add them.

| Capability | API distinction | App coverage |
| --- | --- | --- |
| Transient and continuous events | `CHHapticEvent` building blocks | Both implemented; one selected type per sequence |
| Mixed and overlapping timelines | Individually timed events with different types and parameters | No arbitrary timeline editor |
| Dynamic intensity | `hapticIntensityControl` multiplies event intensity | Scheduled curves implemented on 18 October 2026; no live updates |
| Dynamic sharpness | `hapticSharpnessControl` adds an offset; AHAP documents continuous haptics | Scheduled continuous-event curves implemented on 18 October 2026; no live updates |
| Dynamic envelope adjustment | Attack, decay, and release controls | Fixed event envelopes only |
| Smooth modulation curves | `CHHapticParameterCurve` interpolates between control points across a pattern | Configurable 2–16 points, with a fresh curve pair scheduled for each repetition; included in Swift export |
| Pause, resume, and seek | `CHHapticAdvancedPatternPlayer` | Advanced player is used for Play/Stop and completion only |
| Looping | `loopEnabled` and `loopEnd` | Finite event repetition only, not player looping |
| Playback rate | Advanced player's `playbackRate` | Not exposed |
| Muting | Player `isMuted`, engine `isMutedForHaptics` | No separate mute control; zero intensity is valid |
| Scheduled starts | Engine and player timing APIs | Playback starts immediately |
| Multiple players | Separate players from an engine | One active custom pattern at a time |
| Portable pattern data | AHAP, dictionary construction, `exportDictionary()` | Swift source export only; no AHAP import/export |

Dynamic ranges require `attributes(forDynamicParameter:)`; event-parameter ranges are not interchangeable with them. Intensity modulation is multiplicative, while sharpness and envelope adjustments have different semantics. Any future implementation needs its own validation and playback/export parity.

Sources: [dynamic parameters](https://developer.apple.com/documentation/corehaptics/chhapticdynamicparameter), [dynamic attributes](https://developer.apple.com/documentation/corehaptics/chhapticdevicecapability/attributes(fordynamicparameter:)), [parameter curves](https://developer.apple.com/documentation/corehaptics/chhapticparametercurve), [advanced player](https://developer.apple.com/documentation/corehaptics/chhapticadvancedpatternplayer), [pattern construction and export](https://developer.apple.com/documentation/corehaptics/chhapticpattern).

## System feedback and other hardware

Home offers thirteen unchanged system requests: Light, Medium, Heavy, Soft, Solid, Rigid, Default impact, Selection, Success, Warning, Error, Alignment*, and Path complete*. UIKit impact, selection, and notification generators overlap these categories. The app does not expose adjustable intensity for native system feedback; custom intensity is a separate Core Haptics control.

Both canvas buttons appear on iPhone and iPad. Their footer explains that they require Apple Pencil Pro with a compatible iPad and that feedback is felt in the Pencil. Apple's canvas guidance describes this hardware path; iOS API availability alone does not establish iPhone Taptic output. Physical Pencil delivery remains unverified in this project.

Other `SensoryFeedback` effects target other platforms, such as start/stop on watchOS and level changes on macOS; they are not additional iPhone test choices. Game controllers expose separate haptic engines and actuator localities. These capabilities cannot be inferred from built-in Core Haptics support. Custom accessory patterns and all audio synthesis/playback remain outside the app's scope.

Sources: [SensoryFeedback](https://developer.apple.com/documentation/swiftui/sensoryfeedback), [canvas feedback](https://developer.apple.com/documentation/applepencil/playing-haptic-feedback-in-your-app), [alignment](https://developer.apple.com/documentation/swiftui/sensoryfeedback/alignment), [path complete](https://developer.apple.com/documentation/swiftui/sensoryfeedback/pathcomplete), [game-controller haptics](https://developer.apple.com/documentation/corehaptics/playing-haptics-on-game-controllers), [actuator localities](https://developer.apple.com/documentation/gamecontroller/gcdevicehaptics/supportedlocalities). Implementation: [NativeHaptic.swift](../HapticsLab/NativeHaptic.swift).

## Verification and limits of this study

The 11 October readiness review ran all **27 unit tests** through Xcode MCP on the iPhone 13 mini simulator with iOS 26.5, followed by a successful normal build. That is prior execution evidence, not a new run for this documentation update. UI tests are intentionally excluded. See [VERIFICATION.md](../VERIFICATION.md) for dated results and limitations.

Unit coverage includes capabilities, validation, mode changes, event construction and timing, envelope branches, snapshots, repeated Stop, numeric entry, draft retention, and export/attachment behavior. It does not establish physical vibration, interactive share-sheet success, or independent compilation of generated Swift in another app.

Physical feedback and calibration across devices, envelope feel and interruption behavior, Apple Pencil delivery, iPad layout, sharing into other apps, standalone export compilation, and execution on the minimum iOS/iPadOS 26.0 runtime remain unverified in the recorded checks. Screenshots and successful simulator construction cannot substitute for these observations. Framework-reported pattern duration can also differ from encoded event duration; tests check those separately rather than treating either as measured vibration time.

This study describes the reviewed API families and current implementation. It does not claim exhaustive verification of future SDK symbols or hardware behavior. Confirm the current source and relevant Apple documentation before extending the app.
