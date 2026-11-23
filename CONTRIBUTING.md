# Contributing

## Branches

- `main` is the integration branch. It is protected.
- Everything else is a feature branch that opens a pull request into `main`.

## Pull requests

- Open the pull request against `main`.
- Required checks are `fmt`, `lint`, `test` and `privacy` from the `Checks` workflow. Keep them green.
- Pull requests are squash-merged with zero approving reviews. Delete the branch after merge.

## Commits

Commits on a branch must be signed. The standard requires signed commits on `main`. Configure an SSH signing key and set `commit.gpgsign`, `gpg.format=ssh`, and `user.signingkey`.

## Scope

Keep changes inside the repository's purpose. Do not commit secrets or machine-specific paths. [The owner standard](https://github.com/sakuragaoka-homelab/.github/blob/main/standards/owner.md) defines the branch model and the protection rules.
