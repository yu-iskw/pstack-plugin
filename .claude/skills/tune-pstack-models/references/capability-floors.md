# Capability floors (cost-efficient profile)

The **cost-efficient** profile lowers tier per role; these floors prevent silent quality collapse. Do not assign a slug below the floor without documenting an exception in [pricing-policy.md](pricing-policy.md).

## Floors by role group

| Role group                                                                                           | Floor (minimum tier)                                 | Rationale                                                                                     |
| ---------------------------------------------------------------------------------------------------- | ---------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| `bug-fix`, `perf-issue`, `hillclimb`                                                                 | Sonnet (`sonnet` alias)                              | Long-horizon and agentic coding; Haiku trails Sonnet on SWE-bench Pro–class tasks             |
| `hardest tasks`                                                                                      | Sonnet                                               | Cross-cutting design and gnarly work; Opus optional in balanced only                          |
| `feature, refactoring`                                                                               | Haiku allowed                                        | Mechanical or well-scoped feature work; user can override up to Sonnet in `pstack-models.mdc` |
| `how explorer`, `why investigators`, `swarm workers`                                                 | Haiku                                                | Read-heavy / high fan-out; designed for parallel cheap seats                                  |
| `judgment and prose`, `how explainer`, `why synthesizer`, `reflect judgment, divergent, synthesizer` | Sonnet in cost-efficient                             | Opus reserved for balanced profile                                                            |
| `reflect tooling`                                                                                    | Haiku                                                | Tooling pass; judgment lens stays on Sonnet                                                   |
| Panel lists (`arena runners`, `architect runners`, `interrogate reviewers`, cross-judge pool)        | At least Sonnet on one seat; Haiku ok on second seat | Keeps diversity without Opus spend                                                            |

## Balanced profile

Balanced uses Opus for judgment and hardest tasks and Sonnet for primary code delegates. No floor changes—this is the quality-first default.

## Aliases

Role files and `pstack-models.mdc` should use Claude Code aliases `haiku`, `sonnet`, and `opus` (see [claude-code-model-aliases.md](claude-code-model-aliases.md)). Use full slugs from `models[].slug` only when `/setup-pstack` detects a non-first-party environment or the user pins a version.
