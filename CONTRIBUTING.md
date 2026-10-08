# Contributing

Thanks for contributing to **pstack-plugin**—the Claude Code distribution of [pstack](https://github.com/cursor/plugins/tree/main/pstack), with portable [Agent Plugins](https://agent-plugins.org/) packaging, shared CI/CD, and integration testing.

End-user install and daily use are documented in [README.md](README.md).

## Development prerequisites

- `git`
- `docker`
- `trunk` CLI
- Optional: `claude` CLI (`npm install -g @anthropic-ai/claude-code`) for full plugin loading and install tests

## Setup

1. Fork or branch from this repository.
2. Install Trunk:
   - `curl https://get.trunk.io -fsSL | bash`
3. Verify tools:
   - `trunk --version`
   - `docker --version`

## Local checks

Run these before opening a pull request:

1. `make format`
2. `make lint`
3. `make test-integration-docker` (builds the image and runs integration tests, including marketplace add + install + list/validate)

You can also run integration scripts directly:

- `./integration_tests/validate-manifest.sh`
- `./integration_tests/run.sh --verbose`
- `./integration_tests/test-plugin-install.sh` (requires `claude` CLI; run from repo root)
- `make verify-pstack-claude` or `./integration_tests/run-pstack-claude-workspace-verify.sh` (full static Claude Code workspace checks; invokes `claude` — run locally, not in minimal Docker image)
- `./scripts/run-pstack-claude-verification.sh` (static + optional `--live`)
- `./scripts/run-pstack-claude-verification.sh --live` (adds haiku API smoke when `claude auth status` is logged in)

Agent skill for maintainers: [try-pstack-claude](.claude/skills/try-pstack-claude/SKILL.md). Manual checklist: [plugins/pstack/docs/claude-smoke-checklist.md](plugins/pstack/docs/claude-smoke-checklist.md). This repo’s [AGENTS.md](AGENTS.md) `@`-includes a haiku-only fixture for verification sessions (not required for normal pstack use; end users use `/setup-pstack` per [README.md](README.md)).

### Comprehensive verification (pre-merge)

Automated (CI or local):

```bash
make verify-pstack-claude
make verify-pstack-claude-live   # requires claude login; haiku --print smoke + both plugin agents
./scripts/run-pstack-claude-verification.sh --live --record   # log under verification-evidence/
```

Interactive (logged-in terminal, **skip** `/pstack:setup-pstack` to avoid writing `~/.claude/pstack-models.mdc`):

```bash
claude --setting-sources project,local,user --model haiku
```

Run `./scripts/run-pstack-claude-verification.sh --live-only --record` when `claude auth status` shows `loggedIn: true` (slash + Agent-tool workflow tokens). Optionally exercise the TUI checklist in [interactive-smoke.md](.claude/skills/try-pstack-claude/references/interactive-smoke.md). Record results using [verification-results.template.md](.claude/skills/try-pstack-claude/assets/verification-results.template.md). Pass criteria: [completion-audit.md](.claude/skills/try-pstack-claude/references/completion-audit.md).

## Architecture

The portable Agent Plugin package is canonical. Client-specific capabilities live in optional adapters and do not modify the portable contract.

```text
.
├── .claude-plugin/
│   └── marketplace.json              # Claude Code distribution catalog
├── plugins/
│   └── pstack/
│       ├── plugin.json               # Agent Plugins v1 manifest
│       ├── skills/                   # Portable Agent Skills (vendored; Claude fork edits in-tree)
│       ├── .claude-plugin/           # Claude Code adapter manifest
│       ├── claude/                   # Claude-only owned defaults (not synced from upstream)
│       └── agents/                   # Subagent definitions
├── integration_tests/
└── .github/workflows/
```

Agent Plugins v1 standardizes Agent Skills and MCP servers. Distribution, installation, permissions, updates, agents, commands, hooks, and LSP behavior remain client-specific.

## Quickstart (maintainers)

```bash
make lint
./integration_tests/run.sh --skip-loading
make test-integration-docker
```

## Vendored pstack (`plugins/pstack`)

Most of `plugins/pstack` is synced from [cursor/plugins/pstack](https://github.com/cursor/plugins/tree/main/pstack). Prefer an upstream PR to [cursor/plugins](https://github.com/cursor/plugins) for changes that belong in both distributions.

For Claude Code–only behavior, edit `plugins/pstack/` directly, then run the [sync-pstack-upstream](.claude/skills/sync-pstack-upstream/SKILL.md) script when catching up with upstream and re-merge any overlapping files:

```bash
./.claude/skills/sync-pstack-upstream/scripts/sync-pstack-upstream.sh
./integration_tests/run.sh --manifest-only
```

Owned paths preserved across sync: `plugins/pstack/plugin.json`, `plugins/pstack/.claude-plugin/`, `plugins/pstack/README.claude-header.md`, `plugins/pstack/claude/`, `plugins/pstack/UPSTREAM.json` (generated), and `plugins/pstack/docs/claude-smoke-checklist.md`.

`plugins/pstack/LICENSE` is **not** owned: it is replaced from upstream on each sync and must stay the upstream **MIT** text (aligned with the repository root `LICENSE`). Manifest `license` and `repository` fields must remain `MIT` and `https://github.com/cursor/plugins` (see upstream `pstack/plugin.json`).

Catch-up workflow: [.claude/skills/sync-pstack-upstream/SKILL.md](.claude/skills/sync-pstack-upstream/SKILL.md).

## Adding a plugin to this monorepo

Create `plugins/<name>/plugin.json`:

```json
{
  "$schema": "https://agent-plugins.org/schemas/1.0.0/plugin.schema.json",
  "name": "my-plugin",
  "version": "0.1.0",
  "description": "A portable Agent Plugin"
}
```

Optional portable components:

- `plugins/<name>/skills/<skill>/SKILL.md`
- `plugins/<name>/mcp.json`

Optional client adapters:

- `plugins/<name>/.claude-plugin/plugin.json`
- `plugins/<name>/.cursor-plugin/plugin.json`
- `plugins/<name>/.codex-plugin/plugin.json`

The integration runner discovers plugins from `plugins/*/plugin.json`. A missing optional component is not an error.

## Adding or updating pstack components

- **Skills:** `plugins/pstack/skills/<skill-name>/SKILL.md` — keep instructions specific and testable.
- **Agents:** Markdown under `plugins/pstack/agents/` with front matter (`name`, `description`).
- **Hooks / commands:** under `hooks/`, `commands/` as needed; keep JSON valid.

Minimize vendored skill edits when a Claude-only overlay or repo-owned path (`plugins/pstack/claude/`) suffices.

## Portable MCP rules

`mcp.json` must use the Agent Plugins MCP schema and declare each transport explicitly:

```json
{
  "$schema": "https://agent-plugins.org/schemas/1.0.0/mcp.schema.json",
  "mcpServers": {
    "example": {
      "type": "stdio",
      "command": "npx",
      "args": ["example-server", "--data", "${PLUGIN_DATA}/state"],
      "cwd": "${PLUGIN_ROOT}"
    }
  }
}
```

Important constraints:

- Plugin-relative executable paths begin with `./` and stay inside the plugin root.
- `command` is one executable token and does not receive placeholder expansion.
- `${PLUGIN_ROOT}` and `${PLUGIN_DATA}` are expanded only in `args`, `env` values, and `cwd`.
- Plugins may not override `PLUGIN_ROOT` or `PLUGIN_DATA` in `env`.
- Non-loopback remote MCP URLs must use HTTPS.
- Secrets must not be embedded in MCP headers or environment configuration.

## Claude marketplace (maintainers)

`.claude-plugin/marketplace.json` is the Claude Code catalog for this repo (`pstack@pstack-plugin` → `./plugins/pstack`). Agent Plugins does not define a universal marketplace protocol; each client keeps its own install path.

Workspace install pitfalls: [.claude/skills/try-pstack-claude/references/workspace-install.md](.claude/skills/try-pstack-claude/references/workspace-install.md).

## Testing

```bash
./integration_tests/run.sh
./integration_tests/run.sh --skip-loading
./integration_tests/run.sh --manifest-only
```

The suite validates:

- Agent Plugins root manifests
- Portable MCP configuration
- Skills and component discovery
- Optional Claude, Cursor, and Codex adapters
- Claude Code loading when the CLI is available
- pstack-specific license and Claude component checks

## Specification version

This repository targets Agent Plugins **1.0.0 (Working Draft)**. Canonical schema identifiers are pinned in each portable manifest and MCP configuration.

## Pull request guidelines

1. Keep changes scoped and focused.
2. Update [README.md](README.md) for user-facing install or behavior changes; update this file for maintainer workflow changes.
3. Include test evidence in your PR description (commands run and outcomes).
4. Ensure CI passes (`trunk_check` and `integration_tests` workflows).

## Commit guidelines

- Use clear, imperative commit messages.
- Prefer small commits that are easy to review.

## Reporting issues

Open an issue with:

- expected behavior
- actual behavior
- reproduction steps
- logs or screenshots when relevant
