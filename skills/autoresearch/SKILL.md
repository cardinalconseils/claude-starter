---
name: autoresearch
description: "Autonomous keep/discard optimization loop — Karpathy autoresearch pattern generalized to any measurable metric (eval pass rate, bundle KB, web vitals, LLM cost, accessibility score)"
allowed-tools: Read, Bash, Glob, Grep
---

# autoresearch Skill

## What This Is

The Karpathy autoresearch pattern applied to CKS. An autonomous agent runs an overnight optimization loop:

1. Mutate one target file (the lever)
2. Run one metric command (the judge)
3. If metric improved: `git commit` (keep)
4. If metric regressed or flat: `git reset --hard` (discard)
5. Repeat until budget exhausted

The value is the discipline: one lever, one metric, branch isolation, no human gates inside the loop.

## Deterministic vs Indeterministic Design

This is the core architecture. Violating this split produces non-reproducible experiments.

| Component | Nature | Rule |
|---|---|---|
| Loop step sequence | **Deterministic** | Always: checkpoint → mutate → run → compare → keep/reset → log → check-budget |
| Keep/discard decision | **Deterministic** | Purely numerical. Improved = keep. Flat or regressed = reset. No judgment. |
| Exit conditions | **Deterministic** | Budget exhausted OR 3 consecutive crashes OR STOP file exists |
| Metric command | **Deterministic** | Same command string every iteration — no variations |
| TSV schema and timing | **Deterministic** | Append one row after every iteration, regardless of outcome |
| Consent gate | **Deterministic** | Fires exactly once at loop start. Never again. |
| Baseline measurement | **Deterministic** | Run metric once before iteration 1. Record as `iteration=0, status=baseline` |
| Crash threshold | **Deterministic** | 3 consecutive crashes → exit. Reset counter on any non-crash. |
| **Mutation content** | **Indeterministic** | Agent decides what to change. Informed by program.md but creative. |
| **TSV description** | **Indeterministic** | Natural language summary of what was tried. Generated fresh each iteration. |
| **program.md learning** | **Indeterministic** | What the agent extracts as learnings. No template — genuine reflection. |
| **Hypothesis selection** | **Indeterministic** | Which optimization to try next. Guided by history, not constrained. |

The deterministic shell makes experiments reproducible. The indeterministic core explores the search space. Never mix them.

## Core Concepts

**program.md** — agent's steering document at `.autoresearch/<tag>/program.md`. Describes what to try, what has worked, what has failed. Agent updates every 5 iterations. User can edit between sessions to steer.

**Branch isolation** — loop runs on `autoresearch/<tag>`. Main is never touched. Branch is disposable.

**Keep/discard discipline** — a change is worth keeping only if the metric strictly improved. The number decides.

**Consent contract** — user approves the loop once. That covers all in-loop resets. See `.claude/rules/autoresearch.md`.

**TSV log** — `.autoresearch/<tag>/results.tsv`. Schema:
```
iteration	commit	metric_value	delta	status	description
```
`status`: `kept` | `reset` | `crash` | `baseline`

## Metric Taxonomy

See `references/metric-adapters.md` for command patterns.

| Category | Examples | Direction |
|---|---|---|
| Eval quality | cks:evals pass rate, test pass % | higher = better |
| Bundle size | webpack bundle KB, gzip size | lower = better |
| Web vitals | LCP ms, FID ms | lower = better |
| LLM cost | tokens/request | lower = better |
| Accessibility | Lighthouse a11y score | higher = better |

## Loop Engine

Step-by-step execution: `workflows/loop-engine.md`. Load before starting.

## program.md Template

```markdown
# Optimization Program: <tag>

## Goal
Improve `<metric command>` by modifying `<target file>`.
Direction: <higher is better | lower is better>

## What to Try
- Pass 1: Conservative changes (config flags, quick wins)
- Pass 2: Moderate changes (restructuring, algorithm tweaks)
- Pass 3: Aggressive changes (larger refactors if budget remains)

## What Has Worked
(agent fills in every 5 iterations)

## What Has Failed
(agent fills in every 5 iterations)
```

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll also change this other file while I'm here" | One target only. Multi-file mutations hide the causal signal. |
| "The metric barely improved, I'll keep it anyway" | Keep = strictly improved. Flat = reset. |
| "I should ask the user before this reset" | Consent was given at loop start. Mid-loop prompts violate the contract. |
| "I should vary the metric command for a cleaner signal" | The metric command is deterministic. Same string every iteration. |

## Verification

- [ ] TSV has header row + `baseline` row before iteration 1
- [ ] No file other than `--target` modified in any `kept` commit
- [ ] Loop exited with summary: final metric, best iteration, kept/reset/crash counts
- [ ] `--dry-run` produced no commits and no git resets
- [ ] Consent gate used `AskUserQuestion` (not plain text)
