# Upstream sync reference

## Source

- Repository: [cursor/plugins](https://github.com/cursor/plugins)
- Path: `pstack/`
- Default ref: `main`

## Owned files (never overwritten by rsync)

| Path                                            | Purpose                                    |
| ----------------------------------------------- | ------------------------------------------ |
| `plugins/pstack/plugin.json`                    | Agent Plugins manifest                     |
| `plugins/pstack/.claude-plugin/`                | Claude adapter manifest                    |
| `plugins/pstack/README.claude-header.md`        | Claude distribution banner                 |
| `plugins/pstack/docs/claude-smoke-checklist.md` | Manual smoke steps                         |
| `plugins/pstack/UPSTREAM.json`                  | Written by sync script                     |
| `plugins/pstack/claude/`                        | Role defaults and other Claude-only assets |

## After a successful sync

1. Read `plugins/pstack/UPSTREAM.json` for `commit` and `version`.
2. If `version` changed, align `version` in `plugin.json`, `.claude-plugin/plugin.json`, and the `pstack` entry in `.claude-plugin/marketplace.json`.
3. Run `./integration_tests/run.sh --manifest-only`.
4. Run full tests before merging: `./integration_tests/run.sh --verbose` or `make test-integration-docker`.
5. Re-merge Claude-specific skill edits if upstream changed the same files (compare with `git diff` before/after sync).
6. Use [claude-smoke-checklist.md](../../../../plugins/pstack/docs/claude-smoke-checklist.md) for manual Claude Code checks.
