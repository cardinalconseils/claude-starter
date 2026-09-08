---
description: Build the Process Evaluator feature — complete process card generation from text input
argument-hint: "[phase number]"
allowed-tools:
  - Read
  - Skill
---

# /cks:evaluate — Build Process Evaluator Feature

Plan and implement the Process Evaluator feature — process cards with executive summary,
KPIs, benchmarks, SOPs, flow charts, and bottleneck analysis — through the attractor
pipeline (Orchestrator Exception, `.claude/rules/commands.md`).

## Quick Reference

```
/cks:evaluate           — Start from Phase 01
/cks:evaluate 2         — Resume from Phase 02
```

## Dispatch

```
Skill(skill="cks:attractor")
```

pipeline: `sprint` · Arguments: `--auto` · context_hint: `Build the Process Evaluator
feature: raw text/documents in, complete process cards out. PRD with 4 phases — (01)
Completeness Checker + Question Flow, (02) Full Card Generator, (03) Enriched Flow Chart
Generation, (04) Smart ChatBot Integration. Phase arg: $ARGUMENTS (start there when given).`

The engine seeds Discover (`cks:strategist`) from the context hint, then runs Plan →
Implement → Verify → Release with goal gates.
