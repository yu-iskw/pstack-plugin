# Interactive smoke (Claude Code session)

Run from **repository root** after static verification passes.

For **automated** slash + Agent-tool checks (same requirements, `claude --print`), use `./scripts/run-pstack-claude-verification.sh --live-only --record` when logged in. See [completion-audit.md](completion-audit.md). This section is an optional **TUI** pass.

## Start session (workspace-only, all roles haiku)

**In this repository**, project `AGENTS.md` already `@`-includes the haiku fixture (no global `~/.claude` edits):

```bash
cd "$(git rev-parse --show-toplevel)"
claude --setting-sources project,local,user --model haiku
```

**Isolated temp HOME** (same as `--live`; does not touch your real `~/.claude/pstack-models.mdc`):

```bash
./scripts/claude-pstack-interactive-haiku.sh
```

Skip `/pstack:setup-pstack` in verification sessions unless you intentionally want a user-level config file.

## Slash command names

With **`pstack@pstack-plugin`** installed from this marketplace, skills are usually namespaced:

- `/pstack:poteto-help`, `/pstack:poteto-mode`, `/pstack:setup-pstack`

Ephemeral load (`--plugin-dir=plugins/pstack` only) may expose unprefixed `/poteto-help` depending on CLI version; prefer the prefixed form when the plugin is enabled in project settings.

## Checklist

| Step | Action                                                                      | Pass criteria                                                                                                            |
| ---- | --------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| 1    | `/plugin` or plugin UI                                                      | `pstack` enabled for this project                                                                                        |
| 2    | `/pstack:poteto-help` + simple question (e.g. playbook for a small bug fix) | Skill loads; sensible routing answer                                                                                     |
| 3    | `/pstack:poteto-mode` on a **read-only** task (e.g. explain one file)       | No tool errors; follows poteto-mode read path                                                                            |
| 4    | Spawn `pstack:poteto-agent` or **Comment Sicko** via Agent tool             | Subagent starts; `poteto-agent` may run in background per frontmatter                                                    |
| 5    | Optional: `/pstack:setup-pstack`                                            | Writes `~/.claude/pstack-models.mdc` — **skip** (Esc / No) if avoiding global config; use `--live` haiku fixture instead |

If you do run setup for a quick smoke: choose **`small — low reasoning`** (cost-efficient profile). That is **not** all-haiku; subagents can still use Sonnet/Opus per `pstack-role-defaults.cost-efficient.txt`.

## Model policy for tests

- Parent session: `--model haiku`.
- Without `pstack-models.mdc`, some skills still fall back to Sonnet/Opus in inline defaults. For all-haiku subagent roles during tests, use `--live` verification (temp HOME) or copy [assets/pstack-models.haiku-verification.mdc](../assets/pstack-models.haiku-verification.mdc) to `~/.claude/pstack-models.mdc` only when the operator allows user-level config.

## Regression reminders

- Model rule path for Claude Code: `~/.claude/pstack-models.mdc` (not Cursor’s `~/.cursor/rules/pstack-models.mdc`).
- Subagent spawns use the Agent tool; do not substitute `generalPurpose` for `poteto-agent` when testing poteto routing.
