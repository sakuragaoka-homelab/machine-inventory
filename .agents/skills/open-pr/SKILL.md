---
name: open-pr
description: Take a change from a clean branch to a merged pull request in this repository: preflight checks, zero-review squash merge, automerge label rules and branch cleanup.
---

# Open a pull request

`AGENTS.md` is mandatory repository guidance; this skill is the repeatable procedure for landing a
change. Private repositories on the current GitHub plan have no branch protection or native
auto-merge, so the rules below are enforced by the local `pre-push` hook, the direct-push guard and
CI, and by the owner standard.

1. Update `main`, then create a branch named `type/kebab-slug` (for example `docs/link-fix`). Never
   commit on `main`; the `pre-push` hook blocks it unless `ALLOW_MAIN_PUSH=1` is set for an
   owner-approved recovery.
2. Make the change, then run the repository checks: `just check` and `just test`. Review the whole
   diff yourself; privacy checks are partial safeguards.
3. Commit with a concise imperative subject and the owner's GitHub no-reply identity. No AI
   attribution and no `Co-Authored-By` trailer.
4. Push the branch and open a pull request with `gh pr create`, describing what changed and the
   verification you ran.
5. Wait for every check on the head commit to finish. Never merge with a pending or failing check
   and never bypass a check.
6. Merge with squash and delete the branch: `gh pr merge --squash --delete-branch`. Pull requests
   need no approving review.
7. The `automerge` label means "safe to merge unattended", never "skip the checks". The owner is the
   only person who applies it; Dependabot minor and patch pull requests receive it from the
   workflow. An agent merges only with the owner's explicit authorization for that pull request.
   The owner standard (`standards/owner.md` in the standards repository) defines the criterion.
8. After merge, confirm `main` contains the change and the branch is gone. A `direct-push` issue
   means a commit reached `main` without a merged pull request.
