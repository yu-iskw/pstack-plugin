# Vertex / third-party auth (Claude Code)

Run verification from a terminal where `claude auth status` shows `loggedIn: true`. Cursor’s agent shell is a **different** environment and often shows `loggedIn: false` even when your local terminal is authenticated.

## Example (Vertex)

```json
{
  "loggedIn": true,
  "authMethod": "third_party",
  "apiProvider": "vertex"
}
```

## Commands (from repo root)

```bash
cd /path/to/pstack-plugin
claude auth status
# Vertex: roster slug claude-haiku-5-5 is often NOT deployed. Use Model Garden id from CLI hint:
# export PSTACK_VERIFY_MODEL='claude-haiku-4-5@20251001'
./scripts/run-pstack-claude-verification.sh --live-only --record
claude --setting-sources project,local,user --model haiku
```

Paste the full `--live` output into the goal thread for completion audit.

## Model aliases on Vertex

`haiku`, `sonnet`, and `opus` resolve per provider ([model configuration](https://code.claude.com/docs/en/model-config)). On Vertex, the `haiku` alias may still print Sonnet/Opus fallback warnings; comprehensive verification treats that as **fail** unless you set `PSTACK_VERIFY_MODEL` to an allowlisted haiku model id for live smoke. Role overrides still come from project `AGENTS.md` (no write to `~/.claude/pstack-models.mdc`).

## Workspace vs global config

- **Static verify:** no change to `~/.claude`.
- **`--live` / `--live-only`:** uses **real HOME** for Vertex/trust and loads haiku roles from project **`AGENTS.md`** (no write to `~/.claude/pstack-models.mdc`). Accept the workspace trust dialog once: `claude` from repo root.
- **`claude-pstack-interactive-haiku.sh`:** optional temp HOME (symlinks `.claude.json` + plugins); prefer plain `claude --setting-sources project,local,user --model haiku` when using `AGENTS.md`.
