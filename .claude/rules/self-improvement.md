# Self-Improvement Rules

The workforce changes itself only through evidence. Record → measure → improve, each gated.

## Mandatory Behavior

- **No change to `agents/<role>.md` or `skills/*/SKILL.md` merges without a role eval.** `scripts/test-integrity.sh` check 12b requires a fresh, passing `.evals/results/roles/<role>.json` (`pass_rate` 1.0, `agent_file_sha` matching, `delta.delta >= 0`) for every role file changed versus `main`. Skills changes are measured through the roles that load them: re-run the evals of every role whose `skills:` lists the changed skill.
- **Level 2 cap on the plugin.** Any automated change to this repository (the `workforce-review` routine, the sleep cycle, an improvement proposal) lands as a pull request. A human merges. No routine, agent or hook may push to `main` or merge its own PR.
- **Delta below zero blocks.** A proposal whose pre/post role-eval delta is negative is not merged, not "merged with a follow-up". Fix the proposal or drop it.
- **Evidence has a source.** Every proposed edit cites the dispatch trace lines (`.prd/logs/agents/<role>.jsonl`), routine `STATE.md` entries, or learnings it derives from. "The role seems weak at X" is not evidence.
- **Results are per-machine.** `.evals/results/` is gitignored; the committing machine runs the evals. A PR body pastes the delta table so reviewers see it without re-running.

## What Improves What

| Signal | Recorded by | Read by | Changes |
|---|---|---|---|
| Dispatch outcome | `hooks/handlers/subagent-stop-trace.sh` | historian (`workforce-review`), watchdog hunt 6 | role bodies, skill workflows |
| Routine run | chief of staff in `--routine` mode → `STATE.md`, `runs/` | historian, watchdog audit | routine profiles, owner role |
| Learnings | historian (`skills/learnings`) | historian | skills, rules (by PR) |
| Hook behaviour | harness evals (`.harness-evals/`) | tester, `/cks:evolve` proposals | hook handlers (by PR) |
| Skill quality | sleep cycle (`skillopt`, optional) | historian review | `skills/*/SKILL.md` (adoption gated, §6 of `sleep.md`) |

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "It's a one-word prompt tweak, no eval needed" | One word changes behaviour. The eval takes minutes; a regressed role costs every dispatch after it. |
| "The delta is only slightly negative" | Negative is negative. The gate exists so that nobody argues about "slightly". |
| "Let the routine merge its own PR at Level 3, it's been right for weeks" | The plugin is the workforce's source. Level 2 on it is a constitutional limit, not a maturity stage. |
| "Results are gitignored, so the gate can't be enforced" | It is enforced where it matters: on the machine that commits, by the integrity hook, and by the PR body's delta table. |

## Verification

- [ ] Every role-file change in a PR has a delta table in the PR body
- [ ] `bash scripts/test-integrity.sh --quick` passes check 12b on the committing machine
- [ ] No routine profile targeting this repository declares `autonomy_level` above 2
- [ ] `.evals/results/` is not tracked (`git check-ignore .evals/results/x.json` succeeds)
