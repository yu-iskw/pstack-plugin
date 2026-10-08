---
name: try-pstack-claude
description: Try out the migrated pstack Claude Code plugin from this repository using the claude CLI only—static workspace checks, optional haiku live smoke, and interactive slash-command exercises. Use when validating pstack after upstream sync, Claude overlay edits, or before merging plugin changes.
compatibility: Requires git, claude (Claude Code CLI), and jq for --live. Run from the pstack-plugin repository root.
---

# Try pstack on Claude Code

Validate that `plugins/pstack` loads in Claude Code and that core skills, agents, and workflows behave as expected—**without** changing global `~/.claude` config unless the operator explicitly opts into live model setup.

## When to use

- After `sync-pstack-upstream` or manual edits under `plugins/pstack/`.
- Before opening a PR that touches the Claude marketplace, plugin manifest, or vendored pstack tree.
- When someone asks to “smoke test”, “try out”, or “verify” pstack on Claude Code in this workspace.

## Constraints (default)

- Use the **`claude` command only**; do not rely on Cursor-only APIs for verification.
- Prefer **workspace scope**: project/local settings in `.claude/`, `claude --setting-sources project,local,user`, and `-s local` plugin install.
- Prefer **Haiku** for cost during manual and `--live` runs (`--model haiku`). Do not default to Opus or Sonnet for test sessions.
- **Minimize edits** to vendored `plugins/pstack/skills/` and `plugins/pstack/agents/`; put **test-only** fixtures in this skill’s `assets/` (not under `plugins/pstack/`). Shipped role defaults stay in `plugins/pstack/claude/`.

## Workflow

### 1. Confirm repository context

Resolve the repo root and ensure `plugins/pstack` exists:

```bash
git rev-parse --show-toplevel
test -f plugins/pstack/plugin.json
```

### 2. Run automated workspace verification

From the repository root:

```bash
./scripts/run-pstack-claude-verification.sh
# or: ./.claude/skills/try-pstack-claude/scripts/run-workspace-verify.sh
```

This delegates to `scripts/verify-pstack-claude-workspace.sh` and checks:

- Integration manifest and component discovery (skills/agents count)
- `claude plugin validate plugins/pstack`
- Ephemeral load: `claude --plugin-dir=plugins/pstack plugin list` includes `pstack`
- `claude agents` lists `pstack:poteto-agent` and `pstack:Comment Sicko` when run from repo root with project settings

If agent discovery fails, follow [references/workspace-install.md](references/workspace-install.md).

### 3. Optional API smoke (logged in, haiku only)

When `claude auth status` reports `loggedIn: true`:

```bash
./.claude/skills/try-pstack-claude/scripts/run-workspace-verify.sh --live
```

Uses **real HOME** for Vertex/trust and loads haiku roles from project **`AGENTS.md`** `@`-including [assets/pstack-models.haiku-verification.mdc](assets/pstack-models.haiku-verification.mdc). Does not write your real `~/.claude/pstack-models.mdc`.

### 4. Interactive exercise (operator session)

From the repo root, prefer the haiku temp-HOME launcher (no edits to real `~/.claude/pstack-models.mdc`):

```bash
./scripts/claude-pstack-interactive-haiku.sh
```

Or a plain session (subagents may use Sonnet/Opus without the fixture):

```bash
claude --setting-sources project,local,user --model haiku
```

Run the checklist in [references/interactive-smoke.md](references/interactive-smoke.md): `/pstack:poteto-help`, `/pstack:poteto-mode` (read-only task), subagent spawn (`pstack:poteto-agent` or Comment Sicko). Skip `/pstack:setup-pstack` unless the operator accepts writing `~/.claude/pstack-models.mdc`.

Record pass/fail per checklist row in the PR or issue.

### 5. Report outcome

- **Pass**: static script green; interactive items exercised or explicitly deferred with reason.
- **Fail**: capture failing command output, whether marketplace install or `--plugin-dir=` was used, and whether cwd was repo root (required for `claude agents`).

## Progressive disclosure

- Workspace install and marketplace pitfalls: [references/workspace-install.md](references/workspace-install.md)
- Interactive slash commands and subagents: [references/interactive-smoke.md](references/interactive-smoke.md)
- Haiku-only smoke fixture: [assets/pstack-models.haiku-verification.mdc](assets/pstack-models.haiku-verification.mdc)
- Extended smoke notes: `plugins/pstack/docs/claude-smoke-checklist.md`
- When is “comprehensive” done? [references/completion-audit.md](references/completion-audit.md)
- Vertex / third-party login (run `--live` in your terminal, not the agent shell): [references/vertex-and-external-auth.md](references/vertex-and-external-auth.md)

## Optional follow-ups

- Generic plugin packaging checks: `../plugin-verification/SKILL.md`
- Upstream catch-up: `../sync-pstack-upstream/SKILL.md`
