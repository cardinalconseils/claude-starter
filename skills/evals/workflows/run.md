# Workflow: Run Evals

Execution loop for an eval suite. Ported from the `evals-runner` agent. Run by the tester role
(evals mode). Surfaces failures; never fixes them.

## Step 1: Eval type

From args: `memory | api | tool | regression | safety | structured | red-team | role`. Missing →
infer from `.claude/rules/evals.md` "Eval Type Detection"; ambiguous → ask, never pick
silently (roles without `AskUserQuestion` return the question in their report).

## Step 2: Tier

From args: `smoke | standard | comprehensive`. Default `standard`; say which tier and why.
Thresholds and case counts: `references/eval-tiers.md`.

## Step 3: Workflow

| Type | Workflow |
|---|---|
| memory | `workflows/memory-eval.md` |
| api | `workflows/api-response-eval.md` |
| tool | `workflows/tool-use-eval.md` |
| regression | `workflows/prompt-regression.md` |
| safety, structured | `workflows/safety-eval.md` |
| red-team | `workflows/red-team.md` |
| role | `workflows/role-eval.md` — `--role=<role>`; smoke only, its own case layout, scoring and result path; Steps 4–8 below do not apply |

The workflow supplies scoring criteria, thresholds, and case structure.

## Step 4: Cases

`.evals/golden/{feature-name}/`. Cases exist → validate structure, continue. None → scaffold
the minimum set for the tier per the workflow, show them, and ask "These are the eval cases
I'll run. Confirm to proceed, or edit them first." Never run scaffolded cases without
confirmation. Golden set empty or older than 30 days → flag it before running.

## Step 5: Run

Per case: call the feature with `input.json`; collect output; score — exact match or schema
validation for structured output and tool params, LLM-as-judge with `.evals/judge-prompt.md`
at temperature 0 for prose; record `case_id`, `input`, `actual_output`, `score`,
`explanation`, `case_pass`. Run every case — never stop at the first failure.

## Step 6: Report

```
Eval Report — {feature} | {type} | {tier} tier
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CASE ID     | SCORE | PASS | NOTE
------------|-------|------|------
case-001    | 0.94  | ✓    |
case-002    | 0.71  | ✗    | Groundedness below threshold (0.80)

Results: {pass_count}/{total} passed
Overall: PASS / FAIL (threshold: {threshold}%)

Failures:
- case-002: groundedness 0.71 < 0.80. Likely cause: {specific diagnosis}
```

## Step 7: On failure

Always: which cases, which metric, by how much, one-line diagnosis each.

`--auto-repair` passed → `workflows/generate-evaluate-repair.md`: classify each failure as
`code`, `prompt`, or `golden`; the fix itself is the builder's or debugger's — return to the
chief of staff with the classification, then re-run only the failing cases when the fix
lands (max 2 iterations, then the escalation block from that workflow).

Without `--auto-repair`: ask how to proceed — investigate / update the golden set
(intentional behavior change) / fix and re-run.

## Step 8: Store

`.evals/results/{timestamp}-{feature}-{tier}.json` (create `.evals/results/`).

## Never

- Modify the golden set without explicit approval
- Declare "evals pass" without the full table
- Raise a threshold to make a tier pass
