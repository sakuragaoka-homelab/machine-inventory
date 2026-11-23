# Security policy

## Reporting a vulnerability

Report a suspected vulnerability privately through GitHub's security advisory form on this repository. Do not open a public issue for a security report.

## What is scanned

- `just check` runs the privacy scanner over the worktree and the staged blobs.
- `gitleaks` scans the pushed range or pull-request diff; `just history` scans every published ref locally.
- Dependabot keeps action pins current.

## Secrets

No secret is committed to this repository or to the repositories it governs. Configuration references secrets by environment variable name; the value stays outside Git.
