# Security policy

## Supported versions

Security fixes focus on the latest release (currently **v1.0**) and ongoing development on `main`. Older releases do not receive separate security backports. Please include your tag or commit when reporting a problem.

## Report a vulnerability privately

Use GitHub's [Report a vulnerability form](https://github.com/sahilsatralkar/HapticsLab/security/advisories/new). You can also find it under **Security → Advisories → Report a vulnerability** in this repository. Reports are shared privately with the maintainer.

Include:

- The affected version or commit, device/OS, and Xcode version when relevant.
- Steps to reproduce, a minimal example, and the possible impact.
- Whether the issue affects the app itself or Swift code exported from Custom.

Remove credentials, personal signing details, and unrelated private data from examples and logs. Please do not disclose a suspected vulnerability through a public issue or pull request. If you find an exposed credential, report its location without copying its value; the credential owner should revoke or rotate it promptly.

The maintainer will use the private report to discuss reproduction, a fix, and coordinated disclosure. Ordinary bugs and feature requests can use the [community issue template](.github/ISSUE_TEMPLATE/community_issue.md).

## Repository safeguards

GitHub secret scanning and push protection are enabled for this repository. They help detect supported secret types, but do not replace reviewing your diff. Keep development team IDs, personal signing settings, provisioning details, and credentials out of commits as described in [CONTRIBUTING.md](CONTRIBUTING.md).
