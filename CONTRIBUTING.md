# Contributing to Haptics lab

Contributions are welcome through focused pull requests. Start with [README.md](README.md) for setup, features, and the source map. Keep changes native and dependency-free, preserving iOS/iPadOS 26.0 and Swift 6 support.

Use the [community issue template](.github/ISSUE_TEMPLATE/community_issue.md) for bugs, feature requests, and documentation suggestions. The [pull request template](.github/pull_request_template.md) prompts you for a summary and local verification results. Complete only the sections relevant to your change.

For suspected security vulnerabilities, use [private vulnerability reporting](https://github.com/sahilsatralkar/HapticsLab/security/advisories/new) instead of a public issue or PR. See [SECURITY.md](SECURITY.md) for supported versions and reporting details. Secret scanning and push protection are enabled, but you should still inspect every diff for credentials and personal signing settings.

## Contribution workflow

1. Fork the repository and create a branch for your change. For substantial features or behavior changes, discuss the scope in an issue before implementation.
2. Make a focused change and update relevant documentation. For user-facing behavior, add a short entry under the next Unreleased version in [CHANGELOG.md](CHANGELOG.md). Preserve unrelated work and keep personal signing settings local.
3. Perform the applicable local verification below and record the results in your pull request.
4. Open a pull request targeting upstream `main`, explaining the problem and resulting behavior. Address review feedback and repeat affected checks when the code changes.
5. The repository owner, `sahilsatralkar`, reviews and merges contributions. GitHub blocks other users from pushing or merging into upstream `main`; submit your changes through a PR.

## Manual verification — no GitHub Actions required

This project intentionally uses contributor-run and maintainer-run verification. **GitHub Actions is not required and no CI workflow is configured.** Local unit tests are still automated tests; contributors and the maintainer start them in Xcode. The absence of a CI check is not a failed check or an incomplete contribution.

Contributors can use Xcode directly; no AI assistant or Xcode MCP setup is required to submit a pull request. Follow the verification steps below and report the tools used, results, and any unexecuted checks.

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

The active [Owner-only main updates ruleset](https://github.com/sahilsatralkar/HapticsLab/rules/24876927) applies to `main`, with **sahilsatralkar** as its only bypass user. Only the owner can push, merge, delete, or recreate that branch. You can still submit a PR from your fork for the owner to review and merge.

This branch protection works independently of GitHub Actions and doesn't require CI status checks. Do not add Actions workflows or require CI checks unless the maintainer explicitly requests a change to this manual workflow.

## Versions and releases

README describes the current `main` branch, which may contain features that are not in the latest published release. Use the [changelog](CHANGELOG.md) and [published releases](https://github.com/sahilsatralkar/HapticsLab/releases) to identify the version you tested. Include its tag or commit in issues and PRs.

The maintainer handles versioning and publication:

1. Set the app target's **Marketing Version** and **Current Project Version** for the intended release. Keep personal signing settings local.
2. Review the Unreleased changelog entry, README, security support scope, and screenshot provenance. Keep unreleased features clearly identified until publication.
3. Complete the relevant local verification on the final revision and record results and limitations in VERIFICATION.md, following the manual workflow above.
4. When the release is ready and publication is authorized, replace Unreleased with the release date, commit the final documentation, and create an annotated `v<version>` tag at that verified commit on `main`. Push the tag and publish GitHub release notes covering the changes, setup, checks, and known limitations. Preserve existing published tags unless the owner explicitly requests moving one.

GitHub Actions and prebuilt app binaries are not required for these source releases. Contributors should not bump the version or publish a release as part of an ordinary feature PR unless the maintainer requests it.

## Implementation and repository hygiene

- Keep SwiftUI state and native framework objects on MainActor; use Sendable value snapshots across isolation boundaries. Preserve cancellation, playback-generation checks, and engine-identity checks.
- Use device-reported parameter ranges and strict validation. Keep UI, playback, export, and unit coverage consistent. See README for current timing limits and envelope semantics.
- Use semantic colors, stable accessibility identifiers, native controls, and native padding. Keep default system feedback unchanged as a comparison baseline.
- Never commit personal Apple development team IDs, signing identities, provisioning details, credentials, Xcode user state, build output, analytics, or private data. Inspect the staged diff, including project settings, before committing; `.gitignore` does not protect changes inside tracked files.
- Preserve the maintainer's local signing configuration. Report accidentally committed sensitive settings without repeating their values; do not rewrite published history without authorization.

## License

Contributions are licensed under the repository's [MIT license](LICENSE).
