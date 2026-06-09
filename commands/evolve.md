---
name: /cks:evolve
description: AHE Evolution Agent — reads telemetry, governance, and harness-eval signals to propose golden cases for hook validation
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:evolve — AHE Evolution Agent

Dispatch `cks:ahe-evolution-agent` to analyze telemetry, governance, and harness-eval signals and propose validated golden cases for hook validation.

No args in v1.

```
Agent(
  subagent_type="cks:ahe-evolution-agent",
  prompt="
    project_root: {absolute path of project}
    Run the AHE evolution analysis. Read telemetry, governance, and harness-eval signals.
    Cluster patterns. Propose validated golden cases. Write proposals to .ahe/proposals/.
    Surface a DECISION REQUIRED block for each proposal.
  "
)
```

## Quick Reference

```
/cks:evolve    # run AHE evolution analysis — reads signals, proposes golden cases
```

Output: proposal files in `.ahe/proposals/` + a DECISION REQUIRED block listing each proposal.

If no actionable patterns found, agent emits "No proposals — [reason]" and exits.

Proposals are per-dev artifacts (`.ahe/` is gitignored). Human approves before copying to `.harness-evals/golden/`.
