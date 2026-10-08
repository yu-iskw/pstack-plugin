# pstack model roster policy (Claude Code)

## Pricing source

Official table: [Claude pricing](https://platform.claude.com/docs/en/about-claude/pricing) (also [claude.com/pricing](https://claude.com/pricing)).

Record `pricingAsOf` in `model-roster.json` whenever you change token prices.

## Role assignment rules

| Workload                                           | Tier     | Typical slug        | Why                                                  |
| -------------------------------------------------- | -------- | ------------------- | ---------------------------------------------------- |
| Code delegates (feature, bug-fix, perf, hillclimb) | Balanced | `claude-sonnet-5-5` | Strong coding; lower $/MTok than Opus                |
| Judgment, prose, synthesis, hardest tasks          | Flagship | `claude-opus-5-5`   | Highest capability for ambiguous or high-stakes work |
| Exploration, swarm workers, investigators          | Fast     | `claude-haiku-4-5`  | Cheapest parallel fan-out                            |
| Reflect tooling                                    | Balanced | `claude-sonnet-5-5` | Tool-heavy review without full Opus cost             |
| Arena / architect / interrogate panels             | Mixed    | Sonnet + Opus lists | Model diversity within Claude family                 |

Do not assign a slug the user has not confirmed. Prefer detected Claude Code identifiers over this roster when they conflict.

## Budget labels

`setup-pstack` still offers `unlimited`, `large`, `medium`, and `small`. On Claude Code, map budget to **effort** on each family using `budgetEffort` in `model-roster.json` (append effort tokens only when the user's environment supports them on that slug).

## After Anthropic ships a new model

1. Add a row to `models` with pricing from the docs.
2. Decide whether any `roleDefaults` or `skillFallbacks` should move to the new slug.
3. Run `scripts/render-role-defaults.sh`.
4. Update `plugins/pstack/skills/setup-pstack/SKILL.md` step 5 example if defaults changed (via `patches/pstack/` after upstream sync).
5. Update `patches/pstack/002-claude-model-fallbacks.patch` if skill inline fallbacks changed.
