# Public machine-class inventory. `just --list` shows every recipe. The
# canonical hook and check implementation is scripts/git-hook.ts; it is copied
# byte-identically into every repository in this organization.
set shell := ["bash", "-euo", "pipefail", "-c"]
set windows-shell := ["powershell.exe", "-NoLogo", "-NoProfile", "-Command"]
set positional-arguments

mise := "mise exec --"

default:
    @just --list

# Install pinned tools; this repository has no locked package set.
install:
    mise install

# Lefthook re-stages the fixes (`stage_fixed`).
# Format the given files, or the whole repository when none are given.
fmt *files:
    #!/usr/bin/env bash
    set -euo pipefail
    if (( $# )); then
        {{ mise }} bun fmt -- "$@"
    else
        {{ mise }} bun fmt
    fi

# Fail when anything is unformatted.
fmt-check:
    {{ mise }} bun fmt --check

# Workflows and shell are linted too because `lint` is a CI context.
# Lint the given files, or the whole repository when none are given.
lint *files:
    #!/usr/bin/env bash
    set -euo pipefail
    if (( $# )); then
        {{ mise }} oxlint --deny-warnings -- "$@"
    else
        {{ mise }} oxlint --deny-warnings .
        {{ mise }} actionlint
        {{ mise }} zizmor --quiet .github/workflows
        {{ mise }} shellcheck scripts/collect.sh
    fi

# JavaScript-only repository: the inventory scripts are .mjs run by Bun, so
# there is no TypeScript project to check. See docs/exceptions.md.
typecheck:
    @printf '%s\n' 'No TypeScript sources; the inventory scripts run under Bun (docs/exceptions.md).'

# Conservative secret-shaped content scan; matched values are never printed.
privacy:
    {{ mise }} bun scripts/git-hook.ts privacy

# Effective author and committer emails are the owner's GitHub no-reply address.
privacy-identity:
    {{ mise }} bun scripts/git-hook.ts privacy-identity

# The exact staged blobs.
privacy-staged:
    {{ mise }} bun scripts/git-hook.ts privacy-staged

# Staged secret scan; gitleaks never prints a finding value.
[private]
secrets-staged:
    {{ mise }} gitleaks git --staged --redact --no-banner

# Reject env files, private keys, kubeconfigs and files over 5 MB.
forbidden-files *files:
    #!/usr/bin/env bash
    set -euo pipefail
    {{ mise }} bun scripts/forbidden-files.ts "$@"

# actionlint and zizmor over the given workflows, or every workflow.
workflows *files:
    #!/usr/bin/env bash
    set -euo pipefail
    if (( $# )); then
        {{ mise }} actionlint -- "$@"
        {{ mise }} zizmor --quiet "$@"
    else
        {{ mise }} actionlint
        {{ mise }} zizmor --quiet .github/workflows
    fi

# shellcheck over the given scripts; nothing to do when none are given.
shellcheck *files:
    #!/usr/bin/env bash
    set -euo pipefail
    if (( $# )); then
        {{ mise }} shellcheck -- "$@"
    fi

# Advisory Conventional Commit check (C2.4); never fails the commit.
commit-msg file:
    {{ mise }} bun scripts/commit-msg.ts {{ quote(file) }}

# Commits in BASE..REV, including messages and diffs.
privacy-range revision base:
    {{ mise }} bun scripts/git-hook.ts privacy-range {{ quote(revision) }} {{ quote(base) }}

# Every commit reachable from REV.
privacy-commits revision:
    {{ mise }} bun scripts/git-hook.ts privacy-commits {{ quote(revision) }}

whitespace:
    {{ mise }} bun scripts/git-hook.ts whitespace

whitespace-staged:
    {{ mise }} bun scripts/git-hook.ts whitespace-staged

# gitleaks over the pushed range or pull-request diff; values are never printed.
gitleaks range="":
    {{ mise }} bun scripts/git-hook.ts gitleaks {{ quote(range) }}

# Verify .agents/skills and .claude/skills agree.
agent-files:
    {{ mise }} bun scripts/git-hook.ts agent-files

# Repository gate: every non-test recipe CI requires, in order.
check: fmt-check lint typecheck privacy-identity privacy privacy-staged whitespace gitleaks agent-files

# Validate and test the inventory.
test:
    {{ mise }} bun scripts/test.mjs

# Every test here is fast, so the full suite is the same command.
test-full: test

# Lint and test in one command.
verify: check test

# Scan every published ref. Run before publication; CI runs it on main and weekly.
history:
    {{ mise }} bun scripts/git-hook.ts history

# Read-only local orientation; never mutates.
inspect:
    {{ mise }} bun scripts/git-hook.ts inspect

# Refuses a global or foreign core.hooksPath; migrates only `.githooks`.
# Enable the shared Lefthook hooks without changing global Git settings.
hooks:
    #!/usr/bin/env bash
    set -euo pipefail

    if ! {{ mise }} lefthook version >/dev/null 2>&1; then
        printf 'lefthook is not installed; run `mise install` first.\n' >&2
        exit 1
    fi

    global=$(git config --global --get core.hooksPath || true)
    if [[ -n "$global" ]]; then
        printf 'A global core.hooksPath is set (%s); lefthook install refuses it.\n' "$global" >&2
        printf 'Remove it yourself, or use `lefthook install --force` only if you really mean it.\n' >&2
        exit 1
    fi

    existing=$(git config --get core.hooksPath || true)
    case "$existing" in
        ""|.githooks) ;;
        *)
            printf 'core.hooksPath is %s; integrate it manually.\n' "$existing" >&2
            exit 1
            ;;
    esac

    if [[ "$existing" == ".githooks" ]]; then
        git config --unset-all --local core.hooksPath
    fi

    {{ mise }} lefthook install
    # A failed remote sync only warns in 2.2.2 and still exits 0, so assert the
    # shared jobs loaded before declaring success. `dump` loads and merges the
    # same config that `validate` checks in CI.
    dump=$({{ mise }} lefthook dump)
    if ! grep -q 'name: core-' <<<"$dump" || ! grep -q 'name: owner-' <<<"$dump"; then
        printf 'The shared hook config did not load; check access to the .github repository.\n' >&2
        exit 1
    fi
    hookdir=$(git rev-parse --path-format=absolute --git-path hooks)
    if [[ ! -x "$hookdir/pre-commit" || ! -x "$hookdir/pre-push" ]]; then
        printf 'Lefthook did not write the pre-commit and pre-push shims.\n' >&2
        exit 1
    fi
    printf 'Shared Lefthook hooks installed; no global settings changed.\n'

[private]
hook-pre-commit:
    {{ mise }} bun scripts/git-hook.ts pre-commit

[private]
hook-pre-push:
    {{ mise }} bun scripts/git-hook.ts pre-push

# Fast subset for pre-push (C7.10): the inventory validation and tests, under 30 s.
pre-push-check: test

# Refresh pinned tools when the manifest changed (post-checkout, post-merge).
deps-refresh:
    {{ mise }} bun scripts/deps-refresh.ts mise.toml

# Rewrite the README machine table from machines/*.json.
render:
    {{ mise }} bun scripts/render.mjs

# Fail when the README machine table is stale.
render-check:
    {{ mise }} bun scripts/render.mjs --check

# Collect a machine record on Windows.
collect:
    pwsh -NoLogo -NoProfile -File scripts/collect.ps1

# Prune remote-tracking refs and delete local branches merged into main.
prune:
    {{ mise }} bun scripts/prune.mjs
