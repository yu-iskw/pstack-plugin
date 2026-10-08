# pstack-plugin (Claude Code)

This repo ships and verifies the **pstack** Claude Code plugin (`plugins/pstack`).

## Verification model config (project-local)

Haiku-only role overrides for smoke tests load from the fixture below. This does **not** modify your global `~/.claude/pstack-models.mdc`. Skip `/pstack:setup-pstack` unless you intentionally want a user-level config file.

@.claude/skills/try-pstack-claude/assets/pstack-models.haiku-verification.mdc

Automated checks: `./scripts/verify-pstack-claude-workspace.sh` (add `--live` when logged in). Interactive: `./scripts/claude-pstack-interactive-haiku.sh` or `claude --setting-sources project,local,user --model haiku` from the repo root.
