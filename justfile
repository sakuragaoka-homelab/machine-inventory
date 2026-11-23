# Public machine-class inventory. `just --list` shows every recipe. The
# canonical hook and check implementation is scripts/git-hook.ts; it is copied
# byte-identically into every repository in this organization.
set shell := ["bash", "-euo", "pipefail", "-c"]
set windows-shell := ["powershell.exe", "-NoLogo", "-NoProfile", "-Command"]

mise := "mise exec --"

default:
    @just --list

# Install pinned tools; this repository has no locked package set.
install:
    mise install

# Format the repository.
fmt:
    {{ mise }} bun fmt

# Fail when anything is unformatted.
fmt-check:
    {{ mise }} bun fmt --check

# Lint the scripts and workflows.
lint:
    {{ mise }} oxlint --deny-warnings .
    {{ mise }} actionlint
    {{ mise }} zizmor --quiet .github/workflows
    {{ mise }} shellcheck scripts/collect.sh

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

# Enable the repository-local Git guards without changing global settings.
hooks:
    #!/usr/bin/env bash
    set -euo pipefail
    existing=$(git config --get core.hooksPath || true)
    if [[ -n "$existing" && "$existing" != .githooks ]]; then
        printf 'Existing hooks path differs; integrate manually rather than replacing it.\n' >&2
        exit 1
    fi
    chmod +x .githooks/pre-commit .githooks/pre-push
    git config --local core.hooksPath .githooks
    printf 'Repository-local commit/push guards enabled. No global settings changed.\n'

[private]
hook-pre-commit:
    {{ mise }} bun scripts/git-hook.ts pre-commit

[private]
hook-pre-push:
    {{ mise }} bun scripts/git-hook.ts pre-push

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
