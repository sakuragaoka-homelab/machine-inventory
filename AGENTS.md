# Agent entry point

The public machine-class inventory for the `sakuragaoka-homelab` fleet. It holds hardware
classes, counts and buckets, never an identifying value. Read `README.md` and
[the schema](docs/schema.md) before working. Skills in `.agents/skills` describe optional task
procedures.

## Layout

- `machines/<id>.json` is one machine record; `docs/schema.md` defines the schema and the
  non-identifying rules, enforced by `scripts/lib/inventory.mjs`.
- `scripts/` holds the collectors, the validator, the renderer and the test runner. They are
  JavaScript run by Bun; porting them to TypeScript is recorded in `docs/exceptions.md`.
- `docs/manifest.json` lists the documentation artifacts and `docs/architecture.md` carries the
  diagram.

## Commands

`just --list` shows every recipe. `just check` runs the non-test gates and `just test` validates
and tests the inventory. `just render` rewrites the README table and `just render-check` fails when
it is stale. `just hooks` installs the shared Lefthook hooks in `.git/hooks`; it migrates a local
`core.hooksPath=.githooks` and refuses any other value. `just agent-files` verifies the skill links.

Hooks load the shared jobs from `sakuragaoka-homelab/.github` at the `hooks-v3` tag. Agents never
bypass them (C7.11): no `LEFTHOOK=0`, no `git commit --no-verify`, and no `lefthook-local.yml`.

## Invariants

- No hostname, username, machine serial, drive path, IP or MAC is committed.
- No secret, credential or machine path is committed.
- A record holds classes, counts and buckets. Never write an exact disk model or an exact disk
  size.
- A value the collector cannot detect degrades to a safe empty value where the schema allows it.
  For the OS and the disk set it refuses and exits 2 rather than write an invalid record. Never
  guess a value.
- Regenerate the README table with `just render` after a record change. Do not hand-edit the table
  between the machines markers.
- Run `just check` and `just test`, then review the whole diff before publication.

## Git workflow

`main` changes only through a branch and a merged pull request; the merge is a squash merge and
pull requests need **0** approving reviews. Never push to `main`; `ALLOW_MAIN_PUSH=1` is only for
an owner-approved recovery. The single definition is
[the owner standard](https://github.com/sakuragaoka-homelab/.github/blob/main/standards/owner.md):
do not restate or vary it here.
