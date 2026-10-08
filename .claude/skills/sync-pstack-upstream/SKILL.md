---
name: sync-pstack-upstream
description: Vendor-sync plugins/pstack from cursor/plugins main, apply Claude overlay patches, and verify manifests. Use when catching up with upstream pstack, refreshing UPSTREAM.json, or fixing patch drift after upstream changes.
---

# Sync pstack upstream

Keep the Claude Code distribution of pstack aligned with [cursor/plugins/pstack](https://github.com/cursor/plugins/tree/main/pstack).

## When to use

- Upstream pstack released new skills, playbooks, or version bumps.
- A patch under `patches/pstack/` fails to apply after upstream edits.
- You need to record a new upstream commit in `plugins/pstack/UPSTREAM.json`.

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

| Variable | Default | Meaning |
|----------|---------|---------|
| `UPSTREAM_REPO` | `https://github.com/cursor/plugins.git` | Upstream git remote |
| `UPSTREAM_REF` | `main` | Branch or tag |
| `SKIP_PATCHES` | `false` | Set `true` while regenerating patches |
| `CHECK_ONLY` | `false` | Set `true` (or pass `--check`) to fail if the tree would change |

### 2. Handle patch failures

If `git apply` fails, follow [patches/pstack/README.md](../../../patches/pstack/README.md): sync with `SKIP_PATCHES=true`, edit `plugins/pstack/`, export a new patch, then re-run the full sync.

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

Commit the vendored tree, `UPSTREAM.json`, and any version manifest updates. Do not edit synced skill bodies except via `patches/pstack/`.

## Progressive disclosure

- Owned vs synced paths and post-sync checklist: [references/upstream-sync.md](references/upstream-sync.md)
- Patch policy: [patches/pstack/README.md](../../../patches/pstack/README.md)
- Claude smoke tests: [plugins/pstack/docs/claude-smoke-checklist.md](../../../plugins/pstack/docs/claude-smoke-checklist.md)

## Related skills

- Plugin verification: `../plugin-verification/SKILL.md`
- Implement agent skills: `../implement-agent-skills/SKILL.md`
