# Workspace install (pstack @ pstack-plugin)

Use this when automated verification reports missing plugin agents or marketplace install errors.

## Ephemeral load (no install)

From repository root:

```bash
claude --plugin-dir=plugins/pstack plugin list
```

Must list `pstack`. Use **`--plugin-dir=`** (equals). A space form makes the CLI treat `plugin` as a second plugin path and breaks `plugin list`.

## Project-local install

One-time per machine (registers a directory marketplace):

```bash
cd "$(git rev-parse --show-toplevel)"
claude plugin marketplace add "$(pwd)"
claude --setting-sources project,local plugin install -s local pstack@pstack-plugin
```

Confirm:

```bash
cd "$(git rev-parse --show-toplevel)"
claude --setting-sources project,local agents
```

Expect **Plugin agents**: `pstack:poteto-agent`, `pstack:Comment Sicko`.

## Settings in this repo

- `.claude/settings.json` — enables `pstack@pstack-plugin` and `extraKnownMarketplaces` (`path: "."` from repo root)
- Optional `.claude/settings.local.json` — machine-specific overrides (not required when `settings.json` is committed)

If `plugin install` fails with “plugin not found”, `extraKnownMarketplaces` may not be loaded yet; run `marketplace add` with the absolute repo path above.

## Scope

`-s local` ties the install to this repository’s `projectPath`. Avoid editing global user plugin lists unless the operator explicitly wants user scope.
