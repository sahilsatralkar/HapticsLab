# Changelog

This file records user-facing changes by app version. **Unreleased** entries describe development on `main`; published versions link to their GitHub releases. Build numbers identify app builds within that history.

## [1.2](https://github.com/sahilsatralkar/HapticsLab/releases/tag/v1.2) — 2026-10-18

App version **1.2**, build **3**.

### Added

- Continuous haptics can vary Intensity and Sharpness over time using **2–16 configurable points**. Three flat points are created initially from the constant values.
- Native expandable point editors with smooth sliders, validated exact entry, Add point, and deletion of intermediate points. Start and End remain fixed; changing Duration scales point times proportionally.
- Device-reported dynamic-parameter ranges and validation of curve ordering, encoded multipliers/offsets, and combined event values. Each repetition restarts the complete curve.
- Swift exports include the active curves and destination-device validation, alongside the existing device comments and playback safeguards.
- Eleven curve unit tests, bringing the suite to **40 tests**.

### Changed

- Custom displays an inline validation message when a configuration cannot play or export. Hidden curve drafts survive mode changes and navigation; Reset clears them.
- Community documentation now distinguishes development features from published releases and documents the manual release workflow.

The point count is an app limit. Envelope controls still affect curve playback. Physical feel, share-sheet interaction, and minimum-runtime coverage remain subject to the limitations in [VERIFICATION.md](VERIFICATION.md#configurable-intensity-and-sharpness-curves--18-october-2026).

[Changes since v1.1](https://github.com/sahilsatralkar/HapticsLab/compare/v1.1...v1.2).

## [1.1](https://github.com/sahilsatralkar/HapticsLab/releases/tag/v1.1) — 2026-10-12

App version **1.1**, build **2**.

- Exported Swift headers record the exporting device type and hardware identifier, iOS/iPadOS version, and simulator or physical-device environment.
- Added metadata and runtime-detection coverage, with 29 unit tests in this release.

## [1.0](https://github.com/sahilsatralkar/HapticsLab/releases/tag/v1.0) — 2026-10-11

App version **1.0**, build **1**.

- Thirteen native System haptics choices, including Apple Pencil Pro canvas feedback with a hardware explanation.
- Custom transient/continuous vibration testing with device-reported Intensity, Sharpness, envelope parameters, finite repetition, and exact numeric entry.
- Unified Play/Stop, session draft retention, Reset, contextual help, and standalone Swift source sharing.
- Native SwiftUI controls and no third-party dependencies; iOS/iPadOS 26.0 or later.

See each release's notes and the dated [verification log](VERIFICATION.md) for the checks performed and remaining limitations.
