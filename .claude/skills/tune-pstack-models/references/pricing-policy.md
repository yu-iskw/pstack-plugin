# pstack model roster policy (Claude Code)

## Pricing source

Official table: [Claude pricing](https://platform.claude.com/docs/en/about-claude/pricing) (also [claude.com/pricing](https://claude.com/pricing)).

Record `pricingAsOf` in `model-roster.json` whenever you change token prices.

## Profiles

| Profile          | Rendered file                                                   | Default budget (`setup-pstack`) | Intent                                                                       |
| ---------------- | --------------------------------------------------------------- | ------------------------------- | ---------------------------------------------------------------------------- |
| `balanced`       | `plugins/pstack/claude/pstack-role-defaults.txt`                | `large`                         | Quality-first: Opus judgment, Sonnet code, Haiku parallel work               |
| `cost-efficient` | `plugins/pstack/claude/pstack-role-defaults.cost-efficient.txt` | `medium`                        | Lower spend: Sonnet judgment/code where floors require it, Haiku for fan-out |

`budgetProfile` in `model-roster.json` maps user budget to profile:

| Budget               | Profile        |
| -------------------- | -------------- |
| `unlimited`, `large` | balanced       |
| `medium`, `small`    | cost-efficient |

Effort per family still comes from `budgetEffort` (applied after profile role lines are chosen).

## Role assignment rules

| Workload                                  | Balanced tier | Cost-efficient tier            | Why                                                                                                                  |
| ----------------------------------------- | ------------- | ------------------------------ | -------------------------------------------------------------------------------------------------------------------- |
| Code delegates (feature, refactoring)     | Sonnet        | Haiku (scoped/mechanical bias) | Feature can tier down; see [capability-floors.md](capability-floors.md)                                              |
| Code delegates (bug-fix, perf, hillclimb) | Sonnet        | Sonnet                         | Floor: agentic coding                                                                                                |
| Judgment, prose, synthesis, hardest       | Opus / Opus   | Sonnet                         | Opus→Sonnet saves ~2×; keep Sonnet floor on hardest                                                                  |
| Exploration, swarm, investigators         | Haiku         | Haiku                          | High volume; [Haiku 5.5](https://platform.claude.com/docs/en/about-claude/pricing) $0.10 / $0.50 MTok (≤100k prompt) |
| Reflect tooling                           | Sonnet        | Haiku                          | Tooling lane                                                                                                         |
| Arena / architect / interrogate panels    | Sonnet + Opus | Sonnet + Haiku                 | Diversity without Opus                                                                                               |

Benchmark context: [benchmark-sources.md](benchmark-sources.md). Floors: [capability-floors.md](capability-floors.md).

Do not assign a slug the user has not confirmed. Prefer detected Claude Code identifiers over this roster when they conflict.

## Budget labels

`setup-pstack` offers `unlimited`, `large`, `medium`, and `small`. Budget selects **profile** (tier map) and **effort** on each family via `budgetEffort` in `model-roster.json` (append effort tokens only when the environment supports them on that slug).

## After Anthropic ships a new model

1. Add a row to `models` with pricing from the docs.
2. Decide whether either profile’s `roleDefaults` or `skillFallbacks` should move to the new slug.
3. Run `scripts/render-role-defaults.sh` (writes both `.txt` files).
4. Update `plugins/pstack/skills/setup-pstack/SKILL.md` if profile wiring or examples changed.
5. Update inline skill fallbacks to match `skillFallbacks` for the **balanced** profile (skill docs describe missing-config defaults; cost-efficient users rely on `/setup-pstack` or `pstack-models.mdc`).
