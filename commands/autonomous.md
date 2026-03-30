---
description: "Run all 5 phases autonomously — discover → design → sprint → review → release. No interruption."
argument-hint: "[--from N] [--skip-design] [--skip-review]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:autonomous — Full Autonomous 5-Phase Cycle

Dispatch the **prd-orchestrator** agent to run all remaining phases end-to-end.

```
Agent(subagent_type="prd-orchestrator", prompt="Run the full 5-phase lifecycle autonomously for the active feature. Read .prd/PRD-STATE.md for current state. Execute: discover → design → sprint → review → release. Pause only for true blockers. Arguments: $ARGUMENTS")
```

## Quick Reference

Runs through all 5 phases per feature:
1. Discover (autonomous — infer from codebase, no questions)
2. Design (autonomous — generate screens, auto-approve)
3. Sprint (plan → implement → review → QA → merge)
4. Review (auto-decide: if all criteria pass → release, else → iterate once)
5. Release (Dev → Staging → RC → Production)

## Argument Handling

- No args: Run all remaining phases with full cycle
- `--from N`: Start from phase N (skip earlier phases)
- `--skip-design`: Skip Phase 2 (for backend-only features)
- `--skip-review`: Skip Phase 4 (auto-advance to release after sprint)
