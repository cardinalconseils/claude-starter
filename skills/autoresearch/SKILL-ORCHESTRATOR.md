---
name: cks:autoresearch-orchestrator
description: Autonomous keep/discard loop — one consent block, then per iteration dispatch cks:builder to mutate the single target file, measure the metric (cks:tester for eval metrics), keep or git reset, log results.tsv until budget, three crashes, or STOP. Runs in the top-level session so Agent() dispatch works.
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - Grep
  - Agent
  - AskUserQuestion
  - CronCreate
---

# Autoresearch — The Loop

You run the Karpathy keep/discard pattern at the top level of the session. `SKILL.md` is
the doctrine (deterministic shell / indeterministic core, `.claude/rules/autoresearch.md`
carve-outs); `workflows/loop-engine.md` is the exact iteration sequence;
`references/metric-adapters.md` maps metrics to parsers. You never edit the target file
yourself — the mutation is a `cks:builder` dispatch, the shell around it is yours.

Inputs: `start <tag> --metric=<cmd> --target=<file> --budget=<N> [--dry-run]
[--schedule=<cron>]` | `status <tag>` | `stop <tag>`.

---

## Init (`start`)

1. Read `skills/autoresearch/SKILL.md`, `workflows/loop-engine.md`,
   `references/metric-adapters.md`.
2. `mkdir -p .autoresearch/<tag>`; write `program.md` from the SKILL.md template.
3. Match the metric to an adapter (direction, parser).
4. Consent — once, full prose, then `AskUserQuestion` approve/decline:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔ LOOP-SCOPE CONSENT — READ BEFORE PROCEEDING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Action:     Autonomous keep/discard loop on branch autoresearch/<tag>
Target:     <target> — ONLY this file is mutated
Metric:     <metric command>
Budget:     <N> iterations (default 20)
Resets:     git reset --hard HEAD after each failed iteration
            This warning covers ALL resets — you will NOT be asked again
Reversible: YES — loop stays on autoresearch/<tag>; main untouched
You lose:   Failed iterations (by design)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
Decline → exit. `--dry-run` → one simulated iteration, no commit, no reset, exit.

## Iteration (follow `workflows/loop-engine.md` exactly)

The deterministic shell — step order, keep/discard comparison, exit checks, TSV logging —
never varies. The indeterministic core is the mutation, which is one dispatch:

```
Agent(subagent_type="cks:builder", prompt="Mode: autoresearch mutation. Iteration {n} of {budget}. Read .autoresearch/<tag>/program.md and results.tsv (what was kept and discarded). Edit ONLY <target> — one focused change that could improve `<metric>` (direction: {higher|lower} is better). Do not run the metric, do not commit, do not touch any other file. Return one line describing the change for results.tsv and one line for program.md.")
```

Then, in order: run the metric (eval metrics →
`Agent(subagent_type="cks:tester", prompt="Mode: evals. Tier: smoke. Return pass rate 0.0–1.0 on the last line.")`;
all others → Bash, parse the last numeric token); compare; **keep** = `git commit` with
the description; **discard** = `git reset --hard HEAD`; crash = `git checkout -- <target>`,
`consecutive_crashes += 1`; log every iteration to `results.tsv`
(`iteration | commit | metric_value | delta | status | description`); update `program.md`;
write `checkpoint.json`.

Exit on: budget exhausted | 3 consecutive crashes | `.autoresearch/<tag>/STOP` exists.

## `status <tag>`

From `results.tsv`: iterations, baseline, best value (iteration N), current, trend.

## `stop <tag>`

Write `.autoresearch/<tag>/STOP` — the loop exits after the current iteration.

## `--schedule=<cron>`

After the loop exits: write `.agents/autoresearch-<tag>/state.json` (`tag`, `metric`,
`target`, `budget`, `schedule`, `last_run`, `best_value`); `CronCreate` with prompt
`/cks:autoresearch start <tag> --metric=<metric> --target=<target> --budget=<N> --schedule=<cron>`
and `delaySeconds: 60`; confirm the next run. On a scheduled restart read
`checkpoint.json` first and resume from `checkpoint.iteration`.

## Invariants

- Never ask the user mid-iteration after consent
- Never mutate any file other than `--target`; the builder brief says so every time
- Never push — the branch stays local until the user decides
- Every iteration is logged regardless of outcome
