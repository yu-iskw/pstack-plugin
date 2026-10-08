# Benchmark sources (tune-pstack-models)

Use these when deciding whether a role can move down a tier in the **cost-efficient** profile. Scores depend on effort setting, harness, and date—treat numbers as directional, not guarantees.

## Official and primary

| Benchmark             | What it measures                             | Where to read                                                                                                          |
| --------------------- | -------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| SWE-bench Pro         | Long-horizon repo-level coding (1,865 tasks) | [SWE-bench Pro leaderboard](https://benchlm.ai/benchmarks/swe-bench-pro); Anthropic system cards                       |
| Terminal-Bench 4.0    | Agentic terminal / shell coding              | [Claude Sonnet 5.5](https://www.anthropic.com/claude-sonnet-5-5) launch tables                                         |
| FrontierCode 1.1      | Agentic coding (vendor harness)              | Sonnet 5.5 launch; third-party summaries for Haiku 5.5                                                                 |
| Haiku 5.5 system card | Vendor-reported coding and agent scores      | [PDF](https://www-cdn.anthropic.com/e1080d6bf5ae2018ea3c2f414064be03232f5be5/Claude%20Haiku%205.5%20System%20Card.pdf) |

## Positioning (qualitative)

| Model      | Typical use in multi-agent stacks                                   |
| ---------- | ------------------------------------------------------------------- |
| Opus 5.5   | Planning, hardest judgment, high-stakes synthesis                   |
| Sonnet 5.5 | Primary code delegates, everyday implementation, polished prose     |
| Haiku 5.5  | Parallel explorers, swarm workers, routing, scoped mechanical edits |

See also [capability-floors.md](capability-floors.md) for minimum tiers per pstack role.

## When tuning the roster

1. Re-check [Claude pricing](https://platform.claude.com/docs/en/about-claude/pricing) ($/MTok).
2. If Anthropic publishes a new model card or launch post, note whether **Sonnet–Haiku** or **Opus–Sonnet** gaps changed for coding vs judgment tasks.
3. Update `profiles.costEfficient` only where floors still hold; prefer Opus→Sonnet before Sonnet→Haiku on bug-fix, perf, and hillclimb.
