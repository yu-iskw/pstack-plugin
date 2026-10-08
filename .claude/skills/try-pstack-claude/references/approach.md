# Skill design approaches (try-pstack-claude)

Scores: Feasibility / Performance / Maintainability / Complexity (higher is better except Complexity where lower is better).

| #   | Approach                                                          | F   | P   | M   | C   | Notes                                                                                 |
| --- | ----------------------------------------------------------------- | --- | --- | --- | --- | ------------------------------------------------------------------------------------- |
| 1   | Thin skill + existing `scripts/verify-pstack-claude-workspace.sh` | 95  | 95  | 90  | 90  | **Chosen.** Single source of truth for automation; skill documents operator workflow. |
| 2   | Duplicate full bash script inside skill `scripts/`                | 80  | 90  | 40  | 50  | Drift risk vs repo verify script.                                                     |
| 3   | Extend `plugin-verification` only                                 | 70  | 85  | 75  | 80  | Generic; misses pstack slash workflows and haiku policy.                              |
| 4   | SKILL.md-only (no script wrapper)                                 | 90  | 95  | 85  | 95  | Agents may call wrong path; wrapper fixes repo root.                                  |
| 5   | Interactive-only doc, no automation                               | 85  | 80  | 70  | 95  | Insufficient for CI/pre-PR gates.                                                     |

**Recommendation:** Approach 1 — wrapper script resolves repo root; references hold install and interactive steps; automation stays in `scripts/verify-pstack-claude-workspace.sh`.
