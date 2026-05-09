---
description: "Run all 5 phases autonomously — discover → design → sprint → review → release. No interruption."
argument-hint: "[--from N] [--skip-design] [--skip-review] [--role=coder|marketer|analyst|devops]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:autonomous — Full Autonomous 5-Phase Cycle

Dispatch the **prd-orchestrator** agent to run all remaining phases end-to-end.

Parse `--role=<role>` from `$ARGUMENTS` (default `coder`). The orchestrator forwards it to every dispatched sub-agent so only role-appropriate skills load.

```
Agent(subagent_type="cks:prd-orchestrator", prompt="Run the full 5-phase lifecycle autonomously for the active feature. Read .prd/PRD-STATE.md for current state. Execute: discover → design → sprint → review → release. Role: {parsed-role-or-coder} — load only role-appropriate skills in every dispatched sub-agent. Pause only for true blockers OR business-decision gates (see .claude/rules/business-decisions.md). Arguments: $ARGUMENTS")
```

## Role Mapping

| Role | Skills loaded |
|------|---------------|
| `coder` (default) | prd, incremental-implementation, testing-discipline, debug, code-simplification |
| `marketer` | ai-marketing, brand-marketing, online-marketing, product-marketing |
| `analyst` | repo-exploration, deep-research, observability, monitoring |
| `devops` | cicd-starter, shipping-checklist, environment-management, security-hardening, ciso |

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
- `--role=<role>`: Load role-specific skill set (coder | marketer | analyst | devops)
