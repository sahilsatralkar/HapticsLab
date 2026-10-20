# Changelog

This file records user-facing changes by app version. **Unreleased** entries describe development on `main`; tagged versions link to their source or published GitHub release. Build numbers identify app builds within that history.

## [1.3](https://github.com/sahilsatralkar/HapticsLab/releases/tag/v1.3) — 2026-10-21

App version **1.3**, build **4**.

The source tag was created on 20 October; the GitHub source release was published on 21 October. The existing tag remains on verified app commit `80095e1`. Publication status and refreshed README screenshots were committed to `main` afterward and do not change the tagged source archive.

### Changed

- Continuous haptics use a native **Constant | Vary over time** segmented control instead of a variation toggle, making clear that these are alternative ways to set Intensity and Sharpness.
- Switching modes retains constant values and the separately edited curve points. Only the selected mode's values affect playback and Swift export; turning Continuous off uses the constant controls while retaining the curve for later.
- Added three regression tests for independent value retention, selected-mode playback/export, Continuous round trips, and rejection of unsupported variation. The suite now has 43 tests.

[Changes since v1.2](https://github.com/sahilsatralkar/HapticsLab/compare/v1.2...v1.3).

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
