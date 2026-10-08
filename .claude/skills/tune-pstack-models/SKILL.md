---
name: tune-pstack-models
description: Refresh pstack Claude model recommendations from Anthropic pricing and update role defaults for setup-pstack. Use when Claude releases new models, pricing changes, or pstack role defaults need rebalancing for cost vs quality.
---

# Tune pstack models (Claude Code)

Keep pstack's per-role model recommendations aligned with [Claude pricing](https://platform.claude.com/docs/en/about-claude/pricing) and what Claude Code can run on subagents.

## When to use

- Anthropic published new models or changed $/MTok on the pricing page.
- `/setup-pstack` defaults feel too expensive or too weak for your team.
- After `sync-pstack-upstream` if upstream `setup-pstack` changed and you need to re-merge Claude defaults.

## Prerequisites

- `jq` on PATH.
- Read access to the pricing docs (browser or `WebFetch`).

## Workflow

### 1. Read current pricing

Open [platform.claude.com/docs/en/about-claude/pricing](https://platform.claude.com/docs/en/about-claude/pricing) and note input/output $/MTok for Opus, Sonnet, and Haiku tiers you intend to recommend.

### 2. Update the roster

Edit [references/model-roster.json](references/model-roster.json):

- Set `pricingAsOf` to today's date (ISO).
- Update `models[].inputUsdPerMTok` and `outputUsdPerMTok` to match the docs.
- Add new model objects when Anthropic ships replacements (new `slug`, keep old slug until retired).
- Adjust `roleDefaults` and `skillFallbacks` using [references/pricing-policy.md](references/pricing-policy.md).

### 3. Render the defaults file

From the repository root:

```bash
./.claude/skills/tune-pstack-models/scripts/render-role-defaults.sh
```

This writes [plugins/pstack/claude/pstack-role-defaults.txt](../../../plugins/pstack/claude/pstack-role-defaults.txt) (owned; not vendored from cursor/plugins).

### 4. Align setup-pstack

Update the example block in `plugins/pstack/skills/setup-pstack/SKILL.md` step 5 to match `pstack-role-defaults.txt`. Because that skill is vendored, apply the change through `patches/pstack/` (refresh `001-claude-overlay.patch` or add a focused patch). See [patches/pstack/README.md](../../../patches/pstack/README.md).

### 5. Align inline skill fallbacks

If `skillFallbacks` in the roster changed, update grok-era fallbacks in patched skills (`arena`, `swarm`, `how`, `why`, `reflect`, `poteto-mode`) via `patches/pstack/002-claude-model-fallbacks.patch`.

### 6. Verify

```bash
./integration_tests/run.sh --manifest-only --verbose
```

Ask a user to re-run `/setup-pstack` and confirm `~/.claude/pstack-models.mdc` reflects the new slugs.

## Progressive disclosure

- Cost vs role policy: [references/pricing-policy.md](references/pricing-policy.md)
- Machine-readable roster: [references/model-roster.json](references/model-roster.json)
- Upstream vendor sync: [../sync-pstack-upstream/SKILL.md](../sync-pstack-upstream/SKILL.md)

## Related skills

- [sync-pstack-upstream](../sync-pstack-upstream/SKILL.md) — vendored tree from cursor/plugins
- [implement-agent-skills](../implement-agent-skills/SKILL.md) — skill structure conventions
