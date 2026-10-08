# Claude Code smoke checklist (pstack)

Run after importing or syncing `plugins/pstack`, or before merging an upstream sync PR.

## Install

1. Add this repository as a Claude Code marketplace.
2. Install the `pstack` plugin from the marketplace.
3. Confirm `pstack` appears in `/plugin` as enabled.

## Configuration

1. Run `/setup-pstack` and complete the budget / model flow.
2. Confirm `~/.claude/pstack-models.mdc` exists and lists role lines.

## Core workflows

1. Run `/poteto-help` with a simple question (e.g. which playbook for a small bug fix).
2. Run `/poteto-mode` on a trivial, read-only task (e.g. explain how a file works) and confirm it routes without errors.
3. Invoke a bundled subagent (e.g. `pstack:poteto-agent` or Comment Sicko) if exposed in your session.

## Regression notes

- Model config path is `~/.claude/pstack-models.mdc`, not Cursor's `~/.cursor/rules/pstack-models.mdc`.
- Subagent spawns use the Agent tool; `poteto-agent` uses `background: true` in frontmatter.
