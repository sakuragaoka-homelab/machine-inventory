# Exceptions

| Rule     | Reason                                                                                                                                                                                                                      | Revisit    |
| -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- |
| C7.4     | The validator, renderer, collector helpers and test runner are 768 lines of existing `.mjs`. They now run under Bun, but porting them to TypeScript is a separate change rather than part of this conformance pull request. | 2027-06-30 |
| C7.5, H9 | There is no TypeScript project, so the `typecheck` context is omitted from `checks.yml` and `just typecheck` is a documented no-op.                                                                                         | 2027-06-30 |
| C7.2     | `just collect` runs `pwsh` on the Windows target. The PowerShell runtime is provided by Windows, not installed by mise on the Linux CI runner.                                                                              | 2027-06-30 |
| H1       | `just history` is not in CI. Published history predates the canonical scanner and reports historical false positives; rewriting published history is forbidden.                                                             | 2027-06-30 |
