# Completion audit status (pstack Claude Code)

Update this file when `make verify-pstack-claude-live-record` succeeds. **Static evidence is current; live workflow log is stale.**

## Automated — pass

| Requirement                         | Evidence                                                                                                        |
| ----------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| Static workspace verify             | `make verify-pstack-claude`                                                                                     |
| Integration manifest / components   | `./integration_tests/run.sh --skip-loading`                                                                     |
| Live API smoke (haiku, core tokens) | [live-manual.log](./live-manual.log) — through `PSTACK_COMMENT_SICKO=ok` (re-run for slash + Agent-tool tokens) |
| Project-local haiku roles           | [AGENTS.md](../AGENTS.md) `@`-include                                                                           |
| Plugin agents via CLI               | `PSTACK_PLUGIN_AGENT=ok`, `PSTACK_COMMENT_SICKO=ok` in live log                                                 |

## Live workflow smoke — pending (required for “comprehensive”)

**Agent-tool steps need `--tools default`** (fixed 2026-10-08). **Haiku-only:** logs with `using Sonnet`/`using Opus` fail validation; on Vertex set `PSTACK_VERIFY_MODEL` to your haiku id. Re-run where `claude auth status` shows `loggedIn: true`:

```bash
# Vertex (example id from your deployment):
export PSTACK_VERIFY_MODEL='claude-haiku-4-5@20251001'
make verify-pstack-claude-live-record   # allow ~10–20 min; log shows STEP_OK: per token

# Resume (live-in-progress.log seeded from 024858Z — 3 steps left):
export PSTACK_LIVE_RESUME=1
make verify-pstack-claude-live-record
```

| Token                           | In latest partial log?                 | Notes                              |
| ------------------------------- | -------------------------------------- | ---------------------------------- |
| Core 5 + `SLASH_POTETO_HELP=ok` | **yes** in `live-20261008T024858Z.log` | bug-fix routing answer in log      |
| `SLASH_POTETO_MODE=ok`          | no (step 7 in flight)                  | resume from `live-in-progress.log` |
| `PSTACK_AGENT_TOOL=ok`          | no                                     | Agent tool → `pstack:poteto-agent` |
| `PSTACK_COMMENT_SICKO_TOOL=ok`  | no                                     | Agent tool → Comment Sicko         |

Core agent CLI tokens (`PSTACK_PLUGIN_AGENT=ok`, `PSTACK_COMMENT_SICKO=ok`) already pass in [live-manual.log](./live-manual.log).

Optional TUI pass: [interactive-smoke.md](../.claude/skills/try-pstack-claude/references/interactive-smoke.md). Skip `/pstack:setup-pstack` if avoiding `~/.claude/pstack-models.mdc`.

When the new log is green, update this table and paste into [verification-results.template.md](../.claude/skills/try-pstack-claude/assets/verification-results.template.md) or the goal thread.
