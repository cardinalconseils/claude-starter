# Generate → Evaluate → Repair Workflow

Automated repair loop for eval failures. Triggered when `--auto-repair` is passed to the evals-runner, or when prd-executor detects an AI feature at the [3c] build gate.

## Loop Algorithm

```
run_evals(cases, tier)
  → if all pass: done
  → if any fail:
      classify_failures(failing_cases)
      → per failure type, dispatch fixer
      → re-run ONLY the failing cases
      → if pass: done
      → if still fail (iteration 2): escalate to user
```

Max iterations: 2. After 2 failed repair attempts, stop and escalate — blind retrying wastes tokens and masks the real problem.

## Failure Type Classification

| Failure signal | Type | Fixer |
|---|---|---|
| Deterministic assertion failed (`not_contains`, `contains_pattern`) | code | cks:debugger |
| LLM-judge score low on `scope_adherence` | prompt | cks:prd-executor-worker |
| LLM-judge score low on `assumption_surfacing` | prompt | cks:prd-executor-worker |
| LLM-judge score low on `discovery_completeness` | prompt | cks:prd-executor-worker |
| LLM-judge score low on `question_quality` | prompt | cks:prd-executor-worker |
| Score dropped ≥5% vs baseline after intentional change | golden | escalate to user |
| Runtime crash / tool error during feature invocation | code | cks:debugger |

**Rule:** When in doubt between `prompt` and `code`, default to `prompt` — system prompt changes are lower-risk than code edits.

## Fixer Dispatch

### Code failures → cks:debugger

```
Agent(
  subagent_type="cks:debugger",
  prompt="
    Eval failure in: {feature}
    Case: {case_id}
    Failure type: code
    Assertion that failed: {assertion.type} — pattern: {assertion.pattern}
    Actual output excerpt: {actual_output[:500]}
    Diagnosis: {diagnosis}

    Find the root cause in the feature code that produces this output.
    Propose a fix. Do not modify the golden case — fix the feature.
  "
)
```

### Prompt failures → cks:prd-executor-worker

```
Agent(
  subagent_type="cks:prd-executor-worker",
  isolation="worktree",
  prompt="
    Eval failure in: {feature}
    Case: {case_id}
    Dimension: {dimension} scored {score} (threshold: {threshold})
    Diagnosis: {diagnosis}
    Agent file: agents/{feature}.md

    Read the agent file. Update the system prompt to address the diagnosis.
    The fix must be targeted — change only what makes this dimension fail.
    Do not change unrelated instructions.
  "
)
```

### Golden failures → escalate

```
AskUserQuestion:
  question: "Eval case {case_id} failed — score dropped from {baseline_score} to {actual_score} on {dimension}. Was this intentional?"
  options:
    - label: "Intentional change — update the golden case"
      description: "The expected behavior changed on purpose. Update expected.md to match new behavior."
    - label: "Regression — fix the feature"
      description: "This should still pass. Fix the prompt or code to restore the original behavior."
    - label: "Investigate first"
      description: "Show me the diff between actual output and expected.md before deciding."
```

## After Repair

After fixer completes:
1. Re-run only the cases that failed (not the full suite)
2. If pass: log "repair succeeded on iteration {N}" and continue
3. If still fail: iteration + 1
4. If iteration > 2: escalate with full history:
   ```
   REPAIR LOOP EXHAUSTED
   Feature: {feature}
   Case: {case_id}
   Iterations: 2
   Last diagnosis: {diagnosis}
   What was tried: {repair_attempts}
   Action required: manual investigation
   ```

## Escalation Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔ EVAL REPAIR FAILED — MANUAL ACTION REQUIRED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Feature:    {feature}
Case:       {case_id}
Iterations: 2 (cap reached)
Last score: {score} on {dimension}
Diagnosis:  {last_diagnosis}
Tried:
  1. {repair_attempt_1}
  2. {repair_attempt_2}
Next:       Investigate manually or update golden set
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Integration Points

- Called by: `evals-runner.md` step 7 (when `--auto-repair` flag present)
- Called by: `prd-executor.md` step 5c (AI feature build gate)
- Dispatches: `cks:debugger` (code failures), `cks:prd-executor-worker` (prompt failures)
- References: `.evals/baseline.json` (regression detection), `.evals/golden/{feature}/` (cases)
