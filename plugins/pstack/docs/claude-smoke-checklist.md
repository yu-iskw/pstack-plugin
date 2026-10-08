# Claude Code smoke checklist (pstack)

Run after importing or syncing `plugins/pstack`, or before merging an upstream sync PR.

## Workspace-only (this repository)

From the repo root, without editing global `~/.claude` settings:

```bash
./scripts/verify-pstack-claude-workspace.sh
# or: ./.claude/skills/try-pstack-claude/scripts/run-workspace-verify.sh
```

Full workflow: [.claude/skills/try-pstack-claude/SKILL.md](../../../.claude/skills/try-pstack-claude/SKILL.md).

Optional haiku API smoke (project `AGENTS.md` fixture; requires `claude login`):

```bash
./scripts/verify-pstack-claude-workspace.sh --live-only
```

Ephemeral load (no install): `claude --plugin-dir=plugins/pstack plugin list` must list `pstack`.

Project-local install (scoped to this repo only):

```bash
claude plugin marketplace add "$(pwd)"   # once per machine; registers directory marketplace
claude --setting-sources project,local plugin install -s local pstack@pstack-plugin
claude --setting-sources project,local agents   # expect pstack:poteto-agent, pstack:Comment Sicko
```

`.claude/settings.local.json` can register the same marketplace with `extraKnownMarketplaces` (`path: "."` from repo root). If install fails with “plugin not found”, run `marketplace add` with the absolute repo path above.

Use `--model haiku` for the parent session. For **all roles on haiku** without touching `~/.claude/pstack-models.mdc`, use repo-root `AGENTS.md` or `./scripts/claude-pstack-interactive-haiku.sh`. Maintainer live smoke: `make verify-pstack-claude-live-record` from [pstack-plugin](https://github.com/yu-iskw/pstack-plugin) (not cursor/plugins).

## Install (any checkout)

1. Add this repository as a Claude Code marketplace.
2. Install the `pstack` plugin from the marketplace (`-s local` or `-s project` for workspace scope).
3. Confirm `pstack` appears in `/plugin` as enabled.

## Configuration

1. Run `/setup-pstack` and complete the budget / model flow (`large` → balanced profile; `medium` or `small` → cost-efficient).
2. Confirm `~/.claude/pstack-models.mdc` exists with `# profile` and `# budget` lines and role entries (skip if you only use `--live` verification with a temp HOME).

## Core workflows

1. Run `/pstack:poteto-help` (marketplace install) with a simple question (e.g. which playbook for a small bug fix).
2. Run `/pstack:poteto-mode` on a trivial, read-only task (e.g. explain how a file works) and confirm it routes without errors.
3. Invoke a bundled subagent (e.g. `pstack:poteto-agent` or Comment Sicko) if exposed in your session.

## Regression notes

- Model config path is `~/.claude/pstack-models.mdc`, not Cursor's `~/.cursor/rules/pstack-models.mdc`.
- Subagent spawns use the Agent tool; `poteto-agent` uses `background: true` in frontmatter.
- Pass `--plugin-dir=plugins/pstack` (equals form). A space after `--plugin-dir` makes the CLI treat `plugin` as a second path and breaks `plugin list`.
