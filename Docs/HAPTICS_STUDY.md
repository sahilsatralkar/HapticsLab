# iPhone vibration capability study

Reviewed 10 October 2026 using Apple documentation searches through Xcode MCP and the current app sources. Scope: the installed device's built-in vibration output. Audio synthesis/playback is excluded by request. This is an API and implementation audit, not a claim of physical-device validation or complete implementation of every API listed below. README is intentionally unchanged.

## Detection and limits

`CHHapticEngine.capabilitiesForHardware()` provides `supportsHaptics` and parameter attributes. Query `attributes(forEventParameter:eventType:)` separately for each event type; retain `minValue`, `maxValue`, and `defaultValue` as an immutable value snapshot. The app now does this for all six fixed haptic parameters. Invalid/nonfinite attributes and failed queries never become invented supported ranges. Missing required intensity/sharpness attributes block supported-hardware playback; missing optional envelope parameters are omitted and shown as unavailable. Query success does not prove a perceptible vibration occurred.

Sources: [device capabilities](https://developer.apple.com/documentation/corehaptics/chhapticdevicecapability), [event attributes](https://developer.apple.com/documentation/corehaptics/chhapticdevicecapability/attributes(foreventparameter:eventtype:)), [parameter attributes](https://developer.apple.com/documentation/corehaptics/chhapticparameterattributes).

Duration is not an event-parameter ID and this API exposes no device-specific duration attribute. Apple documents **30 seconds per continuous haptic event**. The app now permits that maximum, with positive duration required. The old three-second event limit and ten-second total-pattern restriction were app policies, not hardware limits; they were removed for the requested full-duration testing. Eight pulses and a gap of zero to two seconds remain explicitly labeled app limits, giving at most 254 seconds of scheduled events. Envelope tails can affect physical output beyond scheduled timing. These limits do not describe the maximum possible Core Haptics composition.

Source: [continuous haptic event](https://developer.apple.com/documentation/corehaptics/chhapticevent/eventtype/hapticcontinuous), [event duration](https://developer.apple.com/documentation/corehaptics/chhapticevent/duration).

Home now shows `UIDevice.model`, OS name/version, the hardware model identifier, and custom-haptic support. Simulator identity is labeled separately. `UIDevice.model` can return a generic name such as iPhone; it is not a marketing-model lookup. The raw hardware identifier is displayed rather than guessing a marketing name from a stale lookup table. No personal device name, vendor identifier, or signing information is displayed or stored. Hardware identity is informational; capability decisions use Core Haptics, not model-name comparisons.

Source: [UIDevice model](https://developer.apple.com/documentation/uikit/uidevice/model).

## Fixed vibration parameters implemented

| Parameter | Meaning and UI | Range handling |
| --- | --- | --- |
| Haptic intensity | Strength, smooth native slider | Device-reported range and reset value; documented normalized domain 0–1 |
| Haptic sharpness | Rounded-to-crisp character, smooth native slider | Device-reported range and reset value; documented normalized domain 0–1 |
| Attack | Envelope rise, smooth native slider | Device-reported range; normalized value, not a seconds control |
| Sustain | Sustained versus unsustained envelope, native toggle | Toggle only when reported range contains both 0 and 1; fixed/unavailable otherwise |
| Decay | Envelope fall with Sustain off, smooth native slider | Device-reported range; omitted from the generated event when Sustain is on |
| Release | Fade after a sustained event, smooth native slider | Device-reported range; omitted when Sustain is off |

All six are queried for Tap and Continuous separately. Only reported parameters are encoded into events. Changing the event type deliberately resets its parameter values to that event's reported defaults. Native sliders have no step argument; display rounding to three decimals does not quantize stored values or Float values sent to Core Haptics. Values still have finite precision; smooth does not imply arbitrary physical resolution.

The AHAP guide explicitly describes envelope values as normalized: a value of 1 does not mean one second. Some individual symbol descriptions use time-oriented wording, so the UI avoids promising exact envelope durations. A release tail may overlap the gap after a scheduled event; the app does not claim that gap always equals physical silence. Hardware observation is still needed to establish each event type's perceptual response.

Sources: [haptic event parameter catalog](https://developer.apple.com/documentation/corehaptics/chhapticevent/parameterid), [intensity](https://developer.apple.com/documentation/corehaptics/chhapticevent/parameterid/hapticintensity), [sharpness](https://developer.apple.com/documentation/corehaptics/chhapticevent/parameterid/hapticsharpness), [AHAP parameter and envelope semantics](https://developer.apple.com/documentation/corehaptics/representing-haptic-patterns-in-ahap-files).

## Other vibration capabilities found

These are real API features; this change does not present them as completed UI features.

| Capability | API and distinction | App coverage |
| --- | --- | --- |
| Tap and continuous building blocks | `CHHapticEvent` transient/continuous | Both implemented; each sequence repeats one chosen kind |
| Mixed sequences and overlapping events | Events can have individual start times, types, parameters and durations | Arbitrary mixed-event timeline editor remains absent |
| Dynamic intensity | `hapticIntensityControl` multiplies event intensity | No live/scheduled modulation control yet |
| Dynamic sharpness | `hapticSharpnessControl` offsets sharpness; AHAP docs specify continuous haptics | No live/scheduled control yet |
| Dynamic envelope adjustment | Haptic attack, decay and release time controls | Not yet exposed; fixed envelopes are implemented |
| Smooth modulation curves | `CHHapticParameterCurve`, relative control points, linear interpolation | Not implemented; curves apply across a player's pattern, not just one event |
| Pause, resume and seek | `CHHapticAdvancedPatternPlayer` | Advanced player is used, but only Play/Stop and completion are exposed |
| Looping | `loopEnabled` and `loopEnd` | Not exposed; pulse count creates a finite event sequence, not player looping |
| Playback rate | Advanced player's `playbackRate` | Not exposed; do not invent a device range without additional validated API constraints |
| Muting | Player `isMuted`, engine `isMutedForHaptics` | Not exposed; zero intensity is already available |
| Scheduled starts/updates | Engine time and player timing APIs | Current playback starts immediately |
| Multiple players | Engine creates separate players | One active custom pattern at a time by design |
| Portable patterns | AHAP/dictionary construction and `exportDictionary()` | In-memory event construction only; no import/export/preset persistence |

Dynamic ranges should be queried with `attributes(forDynamicParameter:)` before adding those controls. They are distinct from event ranges: intensity modulation is multiplicative, while sharpness and other controls have different semantics. Framework limiting of combined values does not justify silently clamping user input in the app. A future implementation must validate each input, preserve immutable requests, and handle live changes on MainActor.

Sources: [dynamic parameters](https://developer.apple.com/documentation/corehaptics/chhapticdynamicparameter), [dynamic attributes](https://developer.apple.com/documentation/corehaptics/chhapticdevicecapability/attributes(fordynamicparameter:)), [parameter curves](https://developer.apple.com/documentation/corehaptics/chhapticparametercurve), [advanced player](https://developer.apple.com/documentation/corehaptics/chhapticadvancedpatternplayer), [pattern construction and export](https://developer.apple.com/documentation/corehaptics/chhapticpattern), [engine](https://developer.apple.com/documentation/corehaptics/chhapticengine).

## Native system feedback and other hardware

The current home catalog keeps default SwiftUI impact weight/flexibility variants, default impact, selection, success, warning, error and alignment. These are system-defined requests, not custom waveforms. UIKit impact/selection/notification generators overlap those categories. Additional native impact intensity is a possible future comparison control; it is distinct from custom Core Haptics intensity.

`SensoryFeedback.pathComplete` is also documented for iOS, but iOS availability alone does not establish an iPhone Taptic response: Apple's drawing-feedback guidance includes Pencil-specific routing. The removed canvas controls remain removed. Do not add them back or call them confirmed iPhone effects without suitable hardware evidence. `start`/`stop` are documented for watchOS, `increase`/`decrease` for watchOS/visionOS, and `levelChange` for macOS. Their availability in a shared framework does not make them useful iPhone buttons.

Sources: [SensoryFeedback](https://developer.apple.com/documentation/swiftui/sensoryfeedback), [impact flexibility/intensity](https://developer.apple.com/documentation/swiftui/sensoryfeedback/impact(flexibility:intensity:)), [path complete](https://developer.apple.com/documentation/swiftui/sensoryfeedback/pathcomplete), [start](https://developer.apple.com/documentation/swiftui/sensoryfeedback/start), [stop](https://developer.apple.com/documentation/swiftui/sensoryfeedback/stop), [increase](https://developer.apple.com/documentation/swiftui/sensoryfeedback/increase), [decrease](https://developer.apple.com/documentation/swiftui/sensoryfeedback/decrease), [level change](https://developer.apple.com/documentation/swiftui/sensoryfeedback/levelchange).

Apple Pencil Pro feedback belongs to compatible iPad/Pencil hardware. Game controllers expose separate haptic engines and actuator localities such as handles or triggers. Neither is inferred from the installed iPhone's built-in-haptics capability. Audio continuous/custom events, audio parameters, sound resources and audio playback controls are intentionally outside the requested vibration-only scope.

Sources: [Apple Pencil haptics](https://developer.apple.com/documentation/applepencil/playing-haptic-feedback-in-your-app), [game-controller haptics](https://developer.apple.com/documentation/corehaptics/playing-haptics-on-game-controllers), [actuator localities](https://developer.apple.com/documentation/gamecontroller/gcdevicehaptics/supportedlocalities).

## Lifecycle, confidence and remaining verification

The controller retains MainActor ownership, value snapshots, cancellable startup, playback-generation checks, engine-identity checks, explicit Stop, and cleanup when leaving Custom or moving the scene out of active. There is no automatic restart after interruption. The engine remains haptics-only. Stopped reasons include interruptions, suspension, idle shutdown, destruction, and system errors; physical-device tests must exercise these paths.

Source: [engine stopped reasons](https://developer.apple.com/documentation/corehaptics/chhapticengine/stoppedreason).

The first simulator run showed that explicitly setting envelope parameters can change the framework-reported pattern duration: a requested 30-second event with zero release produced a reported pattern duration of approximately 29.98 seconds on iOS 26.5. Tests therefore verify the exact encoded event duration and successful pattern construction separately; this observation is not a measurement of physical vibration.

Unit coverage validates reported ranges/defaults, invalid capability attributes, nonfinite/out-of-range input, absent parameters, event encoding for sustain/decay/release, smooth intermediate values, zero gap/intensity, 30-second event duration, finite sequence timing, snapshots and repeated Stop. UI coverage checks the runtime footer, supported/unavailable controls, navigation, duration adjustment and compact light/dark/accessibility layouts. See VERIFICATION.md for actual outcomes; test existence is not evidence that a run passed.

No physical installation was authorized or performed. Simulator checks cannot establish vibration feel, intensity calibration across iPhone models, envelope timing, delivery under system settings/interruption, or a parameter's perceptual effect. Hardware acceptance requires exercising both event types at reported boundaries and intermediate values, each envelope mode, 30-second playback with Stop/navigation/background interruption, and checking capability failures. iOS 26.0 minimum-runtime execution remains a separate unexecuted check.

The research covers the relevant documented iPhone vibration API families and identifies remaining features. It does not claim every future SDK symbol, accessory behavior, or hardware effect has been exhaustively verified.
