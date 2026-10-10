# HapticsLab

A native SwiftUI playground for system feedback and configurable Core Haptics patterns. Minimum iOS 26.0, Swift 6, iPhone and iPad. No packages, accounts, analytics, permissions, or app-owned network services.

## Run

Open `HapticsLab.xcodeproj`, select the **HapticsLab** scheme, select your own development team, and run on a supported iPhone to feel the patterns. No personal signing team is committed.

The simulator verifies controls and pattern construction; it cannot reproduce physical vibration. Availability and the resulting feedback depend on hardware, system settings, and foreground state.

## Screenshots

Captured from the iPhone 13 mini simulator on iOS 26.5.

<p>
  <img src="Docs/Screenshots/haptics-light.png" width="240" alt="Haptics in light mode">
  <img src="Docs/Screenshots/haptics-dark.png" width="240" alt="Haptics in dark mode">
  <img src="Docs/Screenshots/custom-light.png" width="240" alt="Custom haptic parameters">
</p>

## Native patterns

- Impact: Light, Medium, Heavy, Soft, Solid, Rigid, Default impact
- Selection
- Notification: Success, Warning, Error
- Alignment
- Apple Pencil Pro: Canvas alignment and Canvas path completed, requiring a compatible Pencil and iPad

The main screen uses two columns of rounded square buttons and a compact navigation title. The SwiftUI patterns retain system defaults. UIKit impact styles overlap these choices. Feedback exclusive to other platforms is excluded.

## Custom patterns

Open **Custom haptics** to edit intensity, sharpness, pulse count, gap, and continuous duration. Tap **Play custom haptic** to request the current immutable configuration; **Stop** cancels playback. Leaving the screen or backgrounding the app stops custom playback.

Edit the defaults near the top of `HapticsLab/CustomHapticConfiguration.swift`:

```swift
static let defaults = Self(
    kind: .transient,
    intensity: 0.65,
    sharpness: 0.35,
    duration: 0.20,
    pulseCount: 2,
    gap: 0.12
)
```

Intensity and sharpness: 0...1. Continuous duration: 0.05...3 seconds. Pulses: 1...8. Gap: 0.05...2 seconds of silence between pulses. The sample caps a pattern at 10 seconds. Invalid or nonfinite parameters are rejected, not silently clamped. Duration does not affect transient taps.

## Architecture and tests

SwiftUI state and native framework objects stay on MainActor. Core Haptics startup suspends asynchronously. Owned tasks, playback generations, and engine identities reject obsolete completion and interruption callbacks. Configuration is an immutable Sendable value for each playback request; no detached tasks or unchecked Sendable wrappers are needed.

Run **Product → Test** in Xcode. Tests cover timing, validation, repeated requests, stop behavior, control navigation, unsupported simulator hardware, and light/dark/Dynamic Type layouts. See [VERIFICATION.md](VERIFICATION.md) for executed results and remaining limitations.

```sh
xcodebuild test -project HapticsLab.xcodeproj -scheme HapticsLab \
  -destination 'platform=iOS Simulator,id=YOUR_SIMULATOR_UDID'
```

## References

- [Apple haptics design guidance](https://developer.apple.com/design/human-interface-guidelines/playing-haptics)
- [SwiftUI SensoryFeedback](https://developer.apple.com/documentation/swiftui/sensoryfeedback)
- [Core Haptics](https://developer.apple.com/documentation/corehaptics)
- [UICanvasFeedbackGenerator](https://developer.apple.com/documentation/uikit/uicanvasfeedbackgenerator)

## License

MIT. See [LICENSE](LICENSE). Initially published as a private repository; the owner can make it public when ready.
