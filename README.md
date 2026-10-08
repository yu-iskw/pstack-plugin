# pstack for Claude Code

[pstack](https://github.com/cursor/plugins/tree/main/pstack) is a plugin of rigorous agent workflows—playbooks, multi-model panels, and subagents—for serious engineering work in the IDE. This repository is the **Claude Code** distribution: same skills and agents as upstream, adapted for the `claude` CLI and Agent tool.

**Using Cursor?** Install pstack from the [Cursor marketplace](https://github.com/cursor/plugins/tree/main/pstack) (`/add-plugin pstack`). This README is for **Claude Code** only.

## Prerequisites

- [Claude Code](https://code.claude.com/docs) installed (`claude` on your PATH)
- Signed in: `claude auth status` should show `loggedIn: true`

## Install with the `claude` CLI

### 1. Add this repository as a marketplace

Clone the repo (or use a copy you already have), then register it with an **absolute** path:

```bash
git clone https://github.com/yu-iskw/pstack-plugin.git
cd pstack-plugin
claude plugin marketplace add "$(pwd)"
```

`marketplace add` with a bare `.` often fails; use `$(pwd)` or the full path to the clone.

### 2. Install the `pstack` plugin

Pick a scope:

| Scope                       | Command                                                                               | Use when                               |
| --------------------------- | ------------------------------------------------------------------------------------- | -------------------------------------- |
| **User** (all projects)     | `claude plugin install -s user pstack@pstack-plugin`                                  | You want pstack everywhere             |
| **Local** (this clone only) | `claude --setting-sources project,local plugin install -s local pstack@pstack-plugin` | You only use pstack from this checkout |

Enable if it is not already on:

```bash
claude plugin enable pstack@pstack-plugin
```

### 3. Confirm install

```bash
claude plugin list
```

You should see `pstack@pstack-plugin`. From a project directory where the plugin is enabled:

```bash
claude agents
```

Expect plugin agents such as `pstack:poteto-agent` and `pstack:Comment Sicko`.

### Try without installing (smoke test)

From a clone of this repository:

```bash
claude --plugin-dir=plugins/pstack plugin list
```

Use **`--plugin-dir=`** with equals; a space before `plugin` breaks the command.

## Get started after install

1. **Configure models (recommended once)** — In Claude Code, run `/pstack:setup-pstack` (or `/setup-pstack` if your CLI shows the short name). It writes `~/.claude/pstack-models.mdc` with per-role model choices and a reasoning budget. See [setup-pstack](plugins/pstack/skills/setup-pstack/SKILL.md).

2. **Rigorous work** — Use `/pstack:poteto-mode` (or `/poteto-mode`) at the start of a task. See [poteto-mode](plugins/pstack/skills/poteto-mode/SKILL.md).

3. **Not sure which skill to use?** — `/pstack:poteto-help` with your question. See [poteto-help](plugins/pstack/skills/poteto-help/SKILL.md).

4. **Deeper walkthrough** — [pstack guide](plugins/pstack/docs/guide/README.md) in `plugins/pstack/docs/guide/`.

Start a session from your project (with project settings if you use a local-scope install):

```bash
claude --setting-sources project,local,user
```

## What you get

- **Skills** — `/poteto-mode`, `/poteto-help`, `/setup-pstack`, `how`, `why`, `arena`, `swarm`, `reflect`, `interrogate`, `architect`, and more under `plugins/pstack/skills/`.
- **Subagents** — e.g. `pstack:poteto-agent`, `pstack:Comment Sicko` (spawn via the Agent tool in Claude Code).

Full skill list and philosophy: [plugins/pstack/README.md](plugins/pstack/README.md) (content below the Claude install header is shared with upstream).

## Troubleshooting

| Problem                                 | What to try                                                                                                                                |
| --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `make verify-pstack-claude` not found   | Run maintainer verification from a **clone of this repo** (`pstack-plugin`), not from [cursor/plugins](https://github.com/cursor/plugins). |
| `plugin not found` on install           | Run `claude plugin marketplace add` with the **absolute** path to this repo again.                                                         |
| Agents missing                          | Run `claude agents` from the repo root if you used `-s local`, or reinstall with `-s user`.                                                |
| `plugin list` fails with `--plugin-dir` | Use `claude --plugin-dir=plugins/pstack plugin list` (equals form).                                                                        |

More detail: [plugins/pstack/docs/claude-smoke-checklist.md](plugins/pstack/docs/claude-smoke-checklist.md).

## License

**MIT** (Lauren Tan), same as [cursor/plugins/pstack](https://github.com/cursor/plugins/tree/main/pstack). See [LICENSE](LICENSE) and [plugins/pstack/LICENSE](plugins/pstack/LICENSE).

## Contributing

Repository layout, CI, upstream sync, and verification for maintainers: [CONTRIBUTING.md](CONTRIBUTING.md).
