---
name: setup-pstack
description: Configure which models pstack uses per role and at what reasoning budget. Detects your available models and writes a user config file that overrides the skill defaults. Use for /setup-pstack, "configure pstack models", "pstack budget", or changing pstack's model choices.
---

# Setup pstack

Write `~/.claude/pstack-models.mdc`, a user-level config file that pstack skills read for model-per-role overrides.

Canonical Claude Code defaults live under the plugin `claude/` directory (maintained by **tune-pstack-models**):

| Profile          | File                                                                   |
| ---------------- | ---------------------------------------------------------------------- |
| `balanced`       | `${CLAUDE_PLUGIN_ROOT}/claude/pstack-role-defaults.txt`                |
| `cost-efficient` | `${CLAUDE_PLUGIN_ROOT}/claude/pstack-role-defaults.cost-efficient.txt` |

## Steps

### 1. Detect available models

Enumerate model identifiers you can assign to subagents (Agent tool `model` parameter, `/model`, or your environment's model list). If you cannot detect any, ask the user to paste the models they have access to. Never write a model id you have not confirmed is available. The aliases `inherit-parent` and `auto` are always valid even though they are not detected slugs.

Common Claude families: `claude-opus-*`, `claude-sonnet-*`, `claude-haiku-*`, or short aliases `opus`, `sonnet`, `haiku` when supported.

### 2. Load current state

If `~/.claude/pstack-models.mdc` already exists, read its `# profile`, `# budget`, and role lines as the current choices.

Otherwise start from the profile file for the budget the user will pick in step 3 (see profile table below). If the plugin is installed, read that file from `${CLAUDE_PLUGIN_ROOT}/claude/`; if not installed, use the balanced example in step 5.

Drop retired roles such as `how critics`.

**Budget → profile → defaults file**

| Budget      | Profile          | Defaults file                             |
| ----------- | ---------------- | ----------------------------------------- |
| `unlimited` | `balanced`       | `pstack-role-defaults.txt`                |
| `large`     | `balanced`       | `pstack-role-defaults.txt`                |
| `medium`    | `cost-efficient` | `pstack-role-defaults.cost-efficient.txt` |
| `small`     | `cost-efficient` | `pstack-role-defaults.cost-efficient.txt` |

### 3. Budget, map, and confirm

**(a) Ask for a budget.** Prefer structured multiple-choice when available. Offer these four options with these exact labels, and name the current budget when the file records one. With no file, say that `large` selects the **balanced** profile.

- `unlimited — max reasoning`
- `large — high reasoning`
- `medium — medium reasoning`
- `small — low reasoning`

**(b) Apply profile and effort.** Load role lines from the defaults file for the chosen budget (table in step 2). On a re-run, keep any role the user changed manually.

Write `# profile: balanced` or `# profile: cost-efficient` to match the file. Write `# budget: <label> (<effort summary>)` using the profile’s header budget as a template when the user keeps the default mapping.

Map budget to effort on each slug when the environment supports effort tokens (`max` > `high` > `medium` > `low`):

| Budget    | Opus-tier slugs   | Sonnet-tier slugs | Haiku-tier slugs |
| --------- | ----------------- | ----------------- | ---------------- |
| unlimited | highest available | high              | high             |
| large     | high              | high              | medium           |
| medium    | medium            | medium            | low              |
| small     | low               | low               | low              |

If a target effort is unavailable on a slug, use the highest effort at or below the target in the same family. `inherit-parent` and `auto` never change.

Pricing and floors for maintainers: [Claude pricing](https://platform.claude.com/docs/en/about-claude/pricing); repo **tune-pstack-models** skill (`pricing-policy.md`, `capability-floors.md`).

**(c) Show the roles and confirm.** Show every role with its model and the selected profile, marking any slug not in the detected set as needing a choice. List dropped retired roles. Offer detected models plus `inherit-parent` and `auto`. Panel roles use comma-separated lists (one subagent per entry).

### 4. Validate

Every real slug written must be in the detected set. `inherit-parent` and `auto` always pass. If a chosen slug is not available, stop and ask again.

### 5. Write the config file

Create `~/.claude/` if needed. Write `~/.claude/pstack-models.mdc` with `# profile`, `# budget`, and one line per role. Overwrite the whole file so re-runs stay idempotent.

**Balanced fallback example** (when the plugin defaults file is unavailable):

```
# pstack model configuration. One line per role. Delete a line to fall back to the skill default.
# `inherit-parent` or `auto`: run on the parent chat model (omit subagent `model`).
# profile: balanced
# budget: large (high)
feature, refactoring: claude-sonnet-5-5
bug-fix: claude-sonnet-5-5
perf-issue: claude-sonnet-5-5
hillclimb: claude-sonnet-5-5
judgment and prose: claude-opus-5-5
hardest tasks: claude-opus-5-5
how explorer: haiku
how explainer: claude-opus-5-5
why investigators: haiku
why synthesizer: claude-opus-5-5
reflect tooling: claude-sonnet-5-5
reflect judgment, divergent, synthesizer: claude-opus-5-5
arena runners: claude-sonnet-5-5, claude-opus-5-5
arena cross-judge pool: claude-opus-5-5, claude-sonnet-5-5
swarm workers: haiku
architect runners: claude-opus-5-5, claude-sonnet-5-5
interrogate reviewers: claude-opus-5-5, claude-sonnet-5-5
```

For `medium` or `small`, prefer reading `pstack-role-defaults.cost-efficient.txt` from the plugin instead of this block.

### 6. Confirm

Tell the user the file was written, which profile was selected, and that new sessions should pick it up. Optional: set `CLAUDE_CODE_SUBAGENT_MODEL` for a global subagent default (see Claude Code subagent docs).

### 7. Offer a verification skill (optional)

Check whether the project has a way to drive the real app for proof (a `verify-*` skill, or an existing harness). If not, offer once: "want a project-local verification skill, so agents can drive the app the way a user does and prove changes work? I can generate one with /create-verification-skill." On yes, invoke `/create-verification-skill`. On no, move on without pushing.
