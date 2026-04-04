---
description: "R-P-I sub-cycle status — show Research/Plan/Implement stage, quality gates, and artifact inventory"
allowed-tools:
  - Read
  - Glob
  - Grep
---

# /cks:rpi — Research-Plan-Implement Sub-Cycle Status

Show R-P-I sub-cycle status for the current phase including quality gate checks.

## Steps

1. Read `.prd/PRD-STATE.md` — get `active_phase`, `phase_name`, `phase_status`, `iteration_count`
2. If no `.prd/` → display: "No PRD project found. Run `/cks:new` first."
3. If no active phase → display: "No active phase. Run `/cks:new` to start a feature."
4. Scan `.prd/phases/{NN}-{name}/` for R-P-I artifacts:
   - Research: `{NN}-RESEARCH.md`, relevant `.context/*.md`, `.research/*/report.md`
   - Plan: `{NN}-PLAN.md` (check for `### Task` and `## Acceptance Criteria`)
   - Implement: `{NN}-VERIFICATION.md` (check for PASS verdict)
5. Evaluate R→P gate and P→I gate per `skills/rpi/workflows/rpi-subcycle.md`
6. Display status using the format from the workflow

## Quick Reference

```
/cks:rpi              Show R-P-I status for current phase
```

| Sub-Stage | Meaning | Next Action |
|-----------|---------|-------------|
| Research | Gathering knowledge | `/cks:context` or `/cks:research` |
| Plan | Defining what to build | `/cks:sprint` |
| Implement | Building it | `/cks:sprint` (continue) |
| Complete | All gates passed | `/cks:review` or `/cks:release` |
