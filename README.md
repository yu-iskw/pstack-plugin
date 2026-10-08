# pstack-plugin

Repository for the Claude Code distribution of [pstack](https://github.com/cursor/plugins/tree/main/pstack): portable [Agent Plugins](https://agent-plugins.org/) packaging, shared CI/CD, and integration testing.

## Key Features

- **Portable Core**: Each plugin has a root `plugin.json`, `skills/`, and optional `mcp.json` following Agent Plugins v1.0.0.
- **Claude Code Adapter**: Existing `.claude-plugin`, agents, commands, hooks, MCP compatibility, LSP, and marketplace support remain available.
- **Monorepo Ready**: Host multiple plugins under `plugins/`.
- **Conformance Checks**: Validate manifest fields, MCP transports, path rules, reserved variables, and component discovery.
- **Real Claude Installation Tests**: Docker CI adds the repository marketplace, installs each Claude-compatible plugin, and verifies the installation.

## Architecture

The portable Agent Plugin package is canonical. Client-specific capabilities live in optional adapters and do not modify the portable contract.

```text
.
├── .claude-plugin/
│   └── marketplace.json              # Claude Code distribution catalog
├── plugins/
│   └── pstack/
│       ├── plugin.json               # Agent Plugins v1 manifest
│       ├── skills/                   # Portable Agent Skills (vendored + patches)
│       ├── .claude-plugin/           # Claude Code adapter manifest
│       ├── claude/                   # Claude-only owned defaults (not synced from upstream)
│       └── agents/                   # Subagent definitions
├── integration_tests/
└── .github/workflows/
```

Agent Plugins v1 intentionally standardizes only Agent Skills and MCP servers. Distribution, installation, permissions, updates, user experience, agents, commands, hooks, and LSP behavior remain client-specific.

## Quickstart

1. Clone this repository.
2. Install `pstack` from `.claude-plugin/marketplace.json`.
3. Run `/setup-pstack` after install (see [pstack plugin](#pstack-plugin-claude-code) below).
4. Run:

```bash
make lint
./integration_tests/run.sh --skip-loading
make test-integration-docker
```

## Adding a Plugin

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

## Portable MCP Rules

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

## pstack plugin (Claude Code)

This repository ships [pstack](https://github.com/cursor/plugins/tree/main/pstack) under `plugins/pstack` for Claude Code. Content is vendored from `cursor/plugins` on `main`, with Claude-specific overlay patches in `patches/pstack/`. Upstream revision is recorded in `plugins/pstack/UPSTREAM.json`.

**Install:** add this repo as a Claude Code marketplace (`.claude-plugin/marketplace.json`), install `pstack`, then run `/setup-pstack` and use `/poteto-mode` for rigorous work. For Cursor, use the official `pstack` plugin from the Cursor marketplace instead.

**Catch up with upstream:**

```bash
./.claude/skills/sync-pstack-upstream/scripts/sync-pstack-upstream.sh
./integration_tests/run.sh --manifest-only
```

Use the [sync-pstack-upstream](.claude/skills/sync-pstack-upstream/SKILL.md) skill (or `/sync-pstack-upstream` when loaded) for the full catch-up workflow. See [patches/pstack/README.md](patches/pstack/README.md) before editing synced files.

Manual smoke checklist: [plugins/pstack/docs/claude-smoke-checklist.md](plugins/pstack/docs/claude-smoke-checklist.md).

## Claude Marketplace

Agent Plugins does not define a universal marketplace protocol. `.claude-plugin/marketplace.json` remains the Claude Code distribution catalog, while each plugin's root files form the portable package consumed by compatible clients.

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

## Specification Version

This repository targets Agent Plugins **1.0.0 (Working Draft)**. Canonical schema identifiers are pinned in each portable manifest and MCP configuration. Because clients must select locally supported schemas rather than fetch them while loading a plugin, production client implementations should vendor recognized schemas.

## License

Apache License 2.0. See `LICENSE`.
