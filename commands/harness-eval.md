---
description: Run hook fixture evals against CKS harness handlers — validate hook behavior for G2 AHE Evolution Agent
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:harness-eval — Hook Fixture Evaluator

Dispatch `cks:harness-eval-runner` to run golden-case evals against hook handlers.

Parse args:
- `--hook=<name>` — run only cases for this hook (e.g. `destructive-op-guard`); omit to run all
- `--tier=smoke` — tier selector (v1 only supports smoke; default: smoke)

Dispatch:

```
Agent(
  subagent_type="cks:harness-eval-runner",
  prompt="
    project_root: {project_root}
    hook: {value of --hook arg, or 'all' if omitted}
    tier: {value of --tier arg, or 'smoke' if omitted}

    Run harness evals per the harness-evals skill.
    Emit a markdown results table when done.
    Write results JSON to .harness-evals/results/.
  "
)
```

## Quick Reference

```
/cks:harness-eval                         # smoke evals for all hooks
/cks:harness-eval --hook=destructive-op-guard   # one hook only
/cks:harness-eval --tier=smoke            # explicit tier (only tier in v1)
```

Output: pass/fail table + result JSON in `.harness-evals/results/`.

If zero golden cases exist, agent emits scaffold instructions — no error.

Harness evals test hook pipeline behavior (exit codes, stderr patterns).
NOT the same as `/cks:evals` which tests LLM output quality.
