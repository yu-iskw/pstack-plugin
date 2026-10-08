---
name: tune-pstack-models
description: Refresh pstack Claude model recommendations from Anthropic pricing and update role defaults for setup-pstack. Use when Claude releases new models, pricing changes, or pstack role defaults need rebalancing for cost vs quality.
---

# Tune pstack models (Claude Code)

Keep pstack's per-role model recommendations aligned with [Claude pricing](https://platform.claude.com/docs/en/about-claude/pricing), benchmark evidence, and what Claude Code can run on subagents.

## When to use

- Anthropic published new models or changed $/MTok on the pricing page.
- `/setup-pstack` defaults feel too expensive or too weak for your team.
- After `sync-pstack-upstream` if upstream `setup-pstack` changed and you need to re-merge Claude defaults.

## Prerequisites

- `jq` on PATH.
- Read access to the pricing docs (browser or `WebFetch`).

## Workflow

### 1. Read current pricing and benchmarks

- Open [platform.claude.com/docs/en/about-claude/pricing](https://platform.claude.com/docs/en/about-claude/pricing) and note input/output $/MTok for Opus, Sonnet, and Haiku tiers you intend to recommend.
- Skim [references/benchmark-sources.md](references/benchmark-sources.md) when changing the **cost-efficient** profile; respect [references/capability-floors.md](references/capability-floors.md).

### 2. Update the roster

Edit [references/model-roster.json](references/model-roster.json):

- Set `pricingAsOf` to today's date (ISO).
- Update `models[].inputUsdPerMTok` and `outputUsdPerMTok` to match the docs.
- Add new model objects when Anthropic ships replacements (new `slug`, keep old slug until retired).
- Adjust `profiles.balanced` and `profiles.costEfficient` (`roleDefaults`, `skillFallbacks`) using [references/pricing-policy.md](references/pricing-policy.md).
- Keep `budgetProfile` aligned with setup-pstack (`unlimited`/`large` → balanced; `medium`/`small` → cost-efficient).

### 3. Render the defaults files

From the repository root:

```bash
./.claude/skills/tune-pstack-models/scripts/render-role-defaults.sh
```

This writes:

- [plugins/pstack/claude/pstack-role-defaults.txt](../../../plugins/pstack/claude/pstack-role-defaults.txt) (balanced)
- [plugins/pstack/claude/pstack-role-defaults.cost-efficient.txt](../../../plugins/pstack/claude/pstack-role-defaults.cost-efficient.txt)

Owned paths; not vendored from cursor/plugins.

### 4. Align setup-pstack

Update `plugins/pstack/skills/setup-pstack/SKILL.md` if profile selection, headers (`# profile:` / `# budget:`), or fallback paths changed.

### 5. Align inline skill fallbacks

If `profiles.balanced.skillFallbacks` changed, update inline defaults in routed skills (`arena`, `swarm`, `how`, `why`, `reflect`, `poteto-mode`, playbooks) so they match the balanced profile (missing-config path).

### 6. Verify

```bash
./integration_tests/run.sh --manifest-only --verbose
```

Ask a user to re-run `/setup-pstack` with `large` vs `medium` and confirm `~/.claude/pstack-models.mdc` reflects the expected profile and slugs.

## Progressive disclosure

- Cost vs role policy: [references/pricing-policy.md](references/pricing-policy.md)
- Benchmarks: [references/benchmark-sources.md](references/benchmark-sources.md)
- Floors: [references/capability-floors.md](references/capability-floors.md)
- Machine-readable roster: [references/model-roster.json](references/model-roster.json)
- Upstream vendor sync: [../sync-pstack-upstream/SKILL.md](../sync-pstack-upstream/SKILL.md)

## Related skills

- [sync-pstack-upstream](../sync-pstack-upstream/SKILL.md) — vendored tree from cursor/plugins
- [implement-agent-skills](../implement-agent-skills/SKILL.md) — skill structure conventions
