# Claude Code model aliases (pstack defaults)

Official reference: [Model configuration](https://code.claude.com/docs/en/model-config) and [CLI reference](https://code.claude.com/docs/en/cli-reference) (`--model`).

## Aliases pstack uses

| Alias    | Intended use in pstack                       | Resolves to (Anthropic API)     |
| -------- | -------------------------------------------- | ------------------------------- |
| `opus`   | Judgment, prose, hardest tasks, arena seat   | Latest Opus (e.g. Opus 5.5)     |
| `sonnet` | Code delegates, synthesis when not on Opus   | Latest Sonnet (e.g. Sonnet 5.5) |
| `haiku`  | High fan-out workers, explorers, cheap seats | Latest Haiku (e.g. Haiku 5.5)   |

Aliases track the **recommended current model** for each tier. They can change when Anthropic ships a new default; pin a version with a full model id (e.g. `claude-sonnet-5-5`) only when you need a fixed billing or capability line.

## Where aliases work

- Interactive session: `/model sonnet`, `claude --model haiku`
- Subagent spawns: Agent tool `model` parameter (same aliases as CLI when using first-party Claude Code)
- `pstack-models.mdc` role lines and rendered `plugins/pstack/claude/pstack-role-defaults*.txt`

## Special values (not tier aliases)

| Value            | Behavior                                       |
| ---------------- | ---------------------------------------------- |
| `inherit-parent` | Omit subagent `model`; use parent chat model   |
| `auto`           | Same as inherit-parent in pstack docs          |
| `default`        | Clears override; account default (Claude Code) |
| `opusplan`       | Opus in plan mode, Sonnet in execution         |

## Provider and enterprise caveats

On **Anthropic API / first-party Claude Code**, `opus`, `sonnet`, and `haiku` resolve per the provider table in the docs (5.5 tiers on API as of 2026).

On **Bedrock, Vertex, Foundry**, or setups with `availableModels` + `modelOverrides`, bare aliases may fail validation or fall back to the parent model until overrides map alias → provider id ([example issue](https://github.com/anthropics/claude-code/issues/81995)). In those environments, `/setup-pstack` should detect available ids and write **full slugs** (or override keys) the user confirms—not blind alias lines.

## Pinning versions

Environment variables (from model-config docs): `ANTHROPIC_DEFAULT_OPUS_MODEL`, `ANTHROPIC_DEFAULT_SONNET_MODEL`, `ANTHROPIC_DEFAULT_HAIKU_MODEL` change what each alias resolves to without editing pstack role files.

## Roster maintenance

Store **aliases** in `model-roster.json` `roleDefaults` and `skillFallbacks`. Keep full `slug` values under `models[]` for pricing and detection hints in `/setup-pstack`.
