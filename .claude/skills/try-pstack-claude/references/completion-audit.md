# Goal completion audit (pstack on Claude Code)

Use this matrix before claiming comprehensive verification. Evidence must be from the **current** run, not memory.

## Workspace-only config

| Requirement                                      | Evidence                                                                              | Automated? |
| ------------------------------------------------ | ------------------------------------------------------------------------------------- | ---------- |
| No edits to global `~/.claude` for static verify | `verify-pstack-claude-workspace.sh` without `--live`                                  | Yes        |
| Project-local haiku model overrides              | Root `AGENTS.md` `@`-includes try-pstack-claude haiku fixture                         | Yes        |
| Plugin enabled from repo                         | `.claude/settings.json` + local install or `--plugin-dir=`                            | Partial    |
| Haiku-only models for tests                      | `--live` or `./scripts/claude-pstack-interactive-haiku.sh` (temp `pstack-models.mdc`) | Partial    |

## CLI (`claude` only)

| Requirement          | Evidence                                                                        | Automated? |
| -------------------- | ------------------------------------------------------------------------------- | ---------- |
| Manifest + discovery | `./integration_tests/run.sh --skip-loading`                                     | Yes        |
| Plugin validate      | `claude plugin validate plugins/pstack`                                         | Yes        |
| Ephemeral load       | `claude --plugin-dir=plugins/pstack plugin list` shows `pstack`                 | Yes        |
| Subagents registered | `claude agents` → `pstack:poteto-agent`, `pstack:Comment Sicko` (repo root cwd) | Yes        |
| Core skills on disk  | verify script step 6                                                            | Yes        |

## Live workflow smoke (`--live` / `--live-only`)

Requires `claude auth status` → `loggedIn: true`. Uses `claude --print` from repo root with project `AGENTS.md` haiku fixture (no write to `~/.claude/pstack-models.mdc`).

| Requirement                           | Token / evidence               |
| ------------------------------------- | ------------------------------ |
| `/pstack:poteto-help` routing         | `SLASH_POTETO_HELP=ok`         |
| `/pstack:poteto-mode` read-only path  | `SLASH_POTETO_MODE=ok`         |
| `claude --agent pstack:poteto-agent`  | `PSTACK_PLUGIN_AGENT=ok`       |
| `claude --agent pstack:Comment Sicko` | `PSTACK_COMMENT_SICKO=ok`      |
| Agent tool → `pstack:poteto-agent`    | `PSTACK_AGENT_TOOL=ok`         |
| Agent tool → Comment Sicko            | `PSTACK_COMMENT_SICKO_TOOL=ok` |

Record output: `./scripts/run-pstack-claude-verification.sh --live-only --record`

## Optional (not required if live workflow tokens pass)

| Requirement              | How to prove                                                                    |
| ------------------------ | ------------------------------------------------------------------------------- |
| Interactive TUI slash UX | [interactive-smoke.md](interactive-smoke.md) transcript                         |
| `/setup-pstack`          | Optional; writes `~/.claude/pstack-models.mdc` — skip if avoiding global config |

## Haiku-only policy (objective)

Live log must **not** show a real Sonnet/Opus **session** fallback (`validate-pstack-live-log.sh`). The Vertex **Opus tier availability** banner (`Warning: Opus: … not available`) is ignored. On Vertex, set `PSTACK_VERIFY_MODEL` to your haiku Model Garden id (e.g. `claude-haiku-4-5@20251001`).

## Pass criteria for “comprehensive”

1. All automated static rows green (`./scripts/verify-pstack-claude-workspace.sh`).
2. Live smoke green with every workflow token above (`--live-only --record` log in `verification-evidence/`) and haiku-only log policy.
3. No blocking failures in subagent routing or slash-command discovery.

Until (2) is recorded with login, treat the goal as **in progress**.
