# pstack Claude verification results

Fill this after running static + live checks. Attach to a PR or goal thread.

## Environment

- Date:
- `claude --version`:
- Repo commit:
- `claude auth status` loggedIn:

## Static (no API)

```bash
make verify-pstack-claude
```

- [ ] Exit 0

## Live workflow (`--live-only --record`)

```bash
./scripts/run-pstack-claude-verification.sh --live-only --record
```

- [ ] Exit 0
- [ ] Log includes: `PSTACK_LIVE=ok`, `POTETO_HELP_SKILL=ok`, `POTETO_MODE_SKILL=ok`
- [ ] `PSTACK_PLUGIN_AGENT=ok`, `PSTACK_COMMENT_SICKO=ok`
- [ ] `SLASH_POTETO_HELP=ok`, `SLASH_POTETO_MODE=ok`
- [ ] `PSTACK_AGENT_TOOL=ok`, `PSTACK_COMMENT_SICKO_TOOL=ok`
- [ ] Final line: `OK: Static + live haiku smoke passed (including slash + Agent-tool workflow tokens).`

## Optional TUI

- [ ] [interactive-smoke.md](../references/interactive-smoke.md) — notes:
- [ ] Skipped `/setup-pstack` (avoid `~/.claude`): yes/no

## Verdict

- [ ] Comprehensive verification complete (see [completion-audit.md](../references/completion-audit.md))
