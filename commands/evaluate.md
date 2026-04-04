---
description: Build the Process Evaluator feature — complete process card generation from text input
argument-hint: "[phase number]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:evaluate — Build Process Evaluator Feature

Dispatch the PRD orchestrator to plan and implement the Process Evaluator feature — process cards with executive summary, KPIs, benchmarks, SOPs, flow charts, and bottleneck analysis.

## Quick Reference

```
/cks:evaluate           — Start from Phase 01
/cks:evaluate 2         — Resume from Phase 02
```

## Dispatch

```
Agent(subagent_type="prd-orchestrator", prompt="Build the Process Evaluator feature. This takes raw text/documents and produces complete process cards. Create a PRD with 4 phases: (01) Completeness Checker + Question Flow, (02) Full Card Generator, (03) Enriched Flow Chart Generation, (04) Smart ChatBot Integration. Then run the autonomous cycle: discuss → plan → execute → verify → commit → ship. Phase arg: $ARGUMENTS")
```
