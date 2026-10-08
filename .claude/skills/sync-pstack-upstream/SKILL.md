---
name: sync-pstack-upstream
description: Vendor-sync plugins/pstack from cursor/plugins main and verify manifests. Use when catching up with upstream pstack or refreshing UPSTREAM.json.
---

# Sync pstack upstream

Keep the Claude Code distribution of pstack aligned with [cursor/plugins/pstack](https://github.com/cursor/plugins/tree/main/pstack).

## When to use

- Upstream pstack released new skills, playbooks, or version bumps.
- You need to record a new upstream commit in `plugins/pstack/UPSTREAM.json`.
- After upstream changes, re-merge Claude-specific edits in `plugins/pstack/` (see workflow step 2).

## Prerequisites

- `git`, `rsync`, and `jq` on PATH.
- Run from the **pstack-plugin** repository root (or any subdirectory; the script resolves the repo via `git rev-parse`).

## Workflow

### 1. Run the sync script

From the repository root:

```bash
./.claude/skills/sync-pstack-upstream/scripts/sync-pstack-upstream.sh
```

Optional environment variables:

| Variable        | Default                                 | Meaning                                                         |
| --------------- | --------------------------------------- | --------------------------------------------------------------- |
| `UPSTREAM_REPO` | `https://github.com/cursor/plugins.git` | Upstream git remote                                             |
| `UPSTREAM_REF`  | `main`                                  | Branch or tag                                                   |
| `CHECK_ONLY`    | `false`                                 | Set `true` (or pass `--check`) to fail if the tree would change |

### 2. Re-merge Claude-specific changes

Rsync overwrites vendored paths. After sync, diff `plugins/pstack/` against the pre-sync commit and restore Claude Code adaptations (for example `~/.claude/pstack-models.mdc` paths, Agent tool wording, model fallbacks in skills, and `setup-pstack`). Owned paths under `plugins/pstack/claude/` are preserved automatically.

### 3. Align version metadata

When `UPSTREAM.json` reports a new `version`, update the same version in:

- `plugins/pstack/plugin.json`
- `plugins/pstack/.claude-plugin/plugin.json`
- `.claude-plugin/marketplace.json` (pstack entry)

### 4. Verify

```bash
./integration_tests/run.sh --manifest-only --verbose
```

Before opening a PR, run `./integration_tests/run.sh --verbose` or `make test-integration-docker`.

### 5. Commit

Commit the vendored tree, `UPSTREAM.json`, and any version manifest updates.

## Progressive disclosure

- Owned vs synced paths and post-sync checklist: [references/upstream-sync.md](references/upstream-sync.md)
- Claude smoke tests: [plugins/pstack/docs/claude-smoke-checklist.md](../../../plugins/pstack/docs/claude-smoke-checklist.md)

## Related skills

- Try pstack on Claude Code: `../try-pstack-claude/SKILL.md`
- Plugin verification: `../plugin-verification/SKILL.md`
- Implement agent skills: `../implement-agent-skills/SKILL.md`
