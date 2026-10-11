# Contributing to Haptics lab

Contributions are welcome through focused pull requests. Start with [README.md](README.md) for setup, features, and the source map. Keep changes native and dependency-free, preserving iOS/iPadOS 26.0 and Swift 6 support.

## Contribution workflow

1. Fork the repository and create a branch for your change. For substantial features or behavior changes, discuss the scope in an issue before implementation.
2. Make a focused change and update relevant documentation. Preserve unrelated work and keep personal signing settings local.
3. Perform the applicable local verification below and record the results in your pull request.
4. Open a pull request targeting upstream `main`, explaining the problem and resulting behavior. Address review feedback and repeat affected checks when the code changes.
5. The repository owner, `sahilsatralkar`, reviews contributions and controls updates and merges into upstream `main`. Contributors should not push directly to that branch.

## Manual verification — no GitHub Actions required

This project intentionally uses contributor-run and maintainer-run verification. **GitHub Actions is not required and no CI workflow is configured.** Local unit tests are still automated tests; contributors and the maintainer start them in Xcode. The absence of a CI check is not a failed check or an incomplete contribution.

Human contributors can use Xcode directly; no AI assistant or MCP setup is required. Coding agents must follow [AGENTS.md](AGENTS.md), including its Xcode MCP requirements.

For app changes:

1. Open `HapticsLab.xcodeproj`, select the **HapticsLab** scheme, and choose an installed iOS simulator. Confirm the actual device and runtime selected.
2. Run affected tests from **HapticsLabTests** using the Test navigator. Use **Product → Test** to run the full unit suite when changes span multiple areas or the affected scope is unclear. Add or update meaningful unit coverage for changed behavior; do not add unrelated tests for copy-only edits.
3. Manually exercise the changed flow. For layout changes, check a compact screen and light/dark appearance. Preserve native Dynamic Type and accessibility support; dedicated accessibility audits and text-size passes are optional unless requested. UI tests are intentionally excluded.
4. For haptic behavior changes, test on supported physical hardware when available. Record the model/hardware identifier, iOS version, event type, parameter values, and observations. Check Play/Stop, leaving Custom, and backgrounding when playback or lifecycle behavior changes. Simulator results cannot establish physical vibration or tactile quality.
5. For export/sharing changes, check the generated Swift file and, when possible, share it to Files or another app and verify its use in a destination project. Distinguish unit coverage from actual share-sheet and destination-device checks.
6. Finish with a normal **Product → Build**. Report failures and unexecuted checks honestly, including hardware and iOS 26.0 minimum-runtime checks when relevant. A missing device need not prevent opening a PR; identify the validation the maintainer still needs to arrange.

For documentation-only changes, review the content, relative links, image references, and diff. App tests and builds are not required. Keep dated results in [VERIFICATION.md](VERIFICATION.md) distinct from checks performed for the current PR.

## What to include in a pull request

- The problem, scope, and resulting behavior.
- Tests run and pass/fail results, plus the final build result.
- Xcode version and actual simulator/device model and OS version used.
- Manual flows exercised and screenshots for visible UI changes where useful.
- Whether physical haptics were tested, including values used and observations when applicable.
- Skipped checks, known limitations, and any failures that remain unresolved. For documentation-only PRs, state the content/link/diff checks instead of app test results.

Before merging an app change, the maintainer reviews the final revision, runs affected unit tests and a normal build locally, and performs relevant manual checks. Hardware-dependent changes need appropriate device verification or an explicitly recorded limitation accepted by the maintainer. Documentation-only PRs use the documentation checks above. If the PR changes after verification, repeat the checks affected by those changes.

Owner-only merging is a repository access policy separate from GitHub Actions. Documentation does not enforce GitHub permissions; branch rules must be configured and verified separately. Do not add Actions workflows or require CI status checks unless the maintainer explicitly requests a change to this manual workflow.

## Implementation and repository hygiene

- Keep SwiftUI state and native framework objects on MainActor; use Sendable value snapshots across isolation boundaries. Preserve cancellation, playback-generation checks, and engine-identity checks.
- Use device-reported parameter ranges and strict validation. Keep UI, playback, export, and unit coverage consistent. See README for current timing limits and envelope semantics.
- Use semantic colors, stable accessibility identifiers, native controls, and native padding. Keep default system feedback unchanged as a comparison baseline.
- Never commit personal Apple development team IDs, signing identities, provisioning details, credentials, Xcode user state, build output, analytics, or private data. Inspect the staged diff, including project settings, before committing; `.gitignore` does not protect changes inside tracked files.
- Preserve the maintainer's local signing configuration. Report accidentally committed sensitive settings without repeating their values; do not rewrite published history without authorization.

## License

Contributions are licensed under the repository's [MIT license](LICENSE).
