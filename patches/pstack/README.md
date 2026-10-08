# pstack Claude overlay patches

Patches apply **after** `.claude/skills/sync-pstack-upstream/scripts/sync-pstack-upstream.sh` rsyncs
[cursor/plugins/pstack](https://github.com/cursor/plugins/tree/main/pstack).
Do not edit synced files under `plugins/pstack/{skills,agents,docs,...}` by hand;
change upstream or add/update a patch here.

## Apply order

Patches run in lexicographic order: `001-*.patch`, `002-*.patch`, …

## Refresh a patch after upstream drift

1. Run sync with patches disabled: `SKIP_PATCHES=true ./.claude/skills/sync-pstack-upstream/scripts/sync-pstack-upstream.sh`
2. Edit the file under `plugins/pstack/` with the Claude-specific fix.
3. From repo root:

```bash
git diff plugins/pstack/path/to/file > patches/pstack/NNN-description.patch
```

4. Re-run full sync (with patches) and `./integration_tests/run.sh --manifest-only`.

## Budget

Keep this directory small. Prefer one focused patch per concern (model config path,
subagent frontmatter, Agent-tool wording).
