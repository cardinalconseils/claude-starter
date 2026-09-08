---
description: "Run all 5 phases autonomously — discover → design → sprint → review → release. No interruption."
argument-hint: "[--start-at <node>] [--resume] [--role=coder|marketer|analyst|devops]"
allowed-tools:
  - Read
  - Skill
---

# /cks:autonomous — Full Autonomous 5-Phase Cycle

Runs the whole lifecycle end-to-end with the AI deciding at every gate. Since 5.x the
lifecycle is the attractor pipeline (`pipelines/sprint.dot`); this command is
`/cks:sprint-auto` with a role hint.

Parse `--role=<role>` from `$ARGUMENTS` (default `coder`); the engine forwards it in every
dispatch so only role-appropriate skills load.

## Dispatch

This is an Orchestrator Exception command (`.claude/rules/commands.md`): the pipeline
dispatches a role per node, so it loads the attractor engine as a top-level skill.

```
Skill(skill="cks:attractor")
```

pipeline: `sprint` · Arguments: `$ARGUMENTS --auto` · Role hint: `{parsed-role-or-coder}`.
Pauses only for true blockers or business-decision gates
(`.claude/rules/business-decisions.md`).

## Role Mapping

| Role | Skills loaded |
|------|---------------|
| `coder` (default) | prd, incremental-implementation, testing-discipline, debug, code-simplification |
| `marketer` | ai-marketing, brand-marketing, online-marketing, product-marketing |
| `analyst` | repo-exploration, deep-research, observability, monitoring |
| `devops` | cicd-starter, shipping-checklist, environment-management, security-hardening, ciso |

## Quick Reference

```
/cks:autonomous                        # all remaining nodes, AI decides at gates
/cks:autonomous --start-at Implement   # skip discovery/planning
/cks:autonomous --resume               # continue an interrupted run
/cks:autonomous --role=devops          # devops skill set in every dispatch
```

Nodes: Discover (`cks:strategist`) → Plan (`cks:architect`) → Implement (`cks:builder`) →
Verify (`cks:tester`) → Release (`cks:shipper`) → CreatePR → ReviewAndTest (`cks:reviewer`)
→ BrowserUAT (`cks:tester`) → AutoMerge → Learnings.
