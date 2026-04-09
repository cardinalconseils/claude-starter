---
description: "Run full monetization evaluation: discover → research → cost → evaluate → report → roadmap"
argument-hint: "[path | \"description\"] (optional)"
allowed-tools:
  - Read
  - Write
  - Agent
  - AskUserQuestion
---

# /cks:monetize

Orchestrate the full monetization evaluation by dispatching agents in sequence.
Each agent has `skills: monetize` loaded at startup for domain expertise.

## Mode Detection

Parse `$ARGUMENTS`:
- No arguments → Mode A (self-analyze current project codebase)
- Local directory path → Mode B (analyze target project codebase)
- Quoted text / description → Mode C (business description, no code scan)

## Re-run Check

Read `.monetize/context.md`. If exists:
```
AskUserQuestion:
  question: "Previous assessment found. How to proceed?"
  options:
    - "Archive and start fresh (Recommended)"
    - "Update — skip discovery, re-run from research"
    - "Cancel"
```
- Archive: `mkdir -p .monetize/archive/$(date +%Y%m%d) && mv .monetize/*.md .monetize/archive/$(date +%Y%m%d)/`
- Update: skip Phase 1, start from Phase 2

## Phase Execution

### Phase 1: Discover

```
Agent(subagent_type="cks:monetize-discoverer", prompt="Gather business context. Mode: {detected_mode}. Arguments: $ARGUMENTS. Scan codebase if Mode A or B. Write to .monetize/context.md.")
```

### Phase 2: Research

```
Agent(subagent_type="cks:monetize-researcher", prompt="Research the market for this project. Read .monetize/context.md for context. Write findings to .monetize/research.md.")
```

### Phase 3a: Cost Research

```
Agent(subagent_type="cks:cost-researcher", prompt="Research real-world tech stack costs. Read .monetize/context.md for the stack. Write raw pricing data to .monetize/cost-research-raw.md.")
```

### Phase 3b: Cost Analysis

```
Agent(subagent_type="cks:cost-analyzer", prompt="Build unit economics from cost research. Read .monetize/cost-research-raw.md and .monetize/context.md. Write to .monetize/cost-analysis.md.")
```

### Phase 4: Evaluate

```
Agent(subagent_type="cks:monetize-evaluator", prompt="Evaluate monetization models using evidence-based tiers. Read .monetize/context.md, research.md, cost-analysis.md. Write to .monetize/evaluation.md.")
```

### Phase 5: Report

```
Agent(subagent_type="cks:monetize-reporter", prompt="Generate the business case report. Read .monetize/evaluation.md and all .monetize/ artifacts. Write to docs/monetization-assessment.md.")
```

### Phase 6: Roadmap

Read `.monetize/evaluation.md`. Extract recommended models and create:
- `.monetize/phases/*.md` — PRD-ready phase briefs for each recommended model
- Update `.prd/PRD-ROADMAP.md` with monetization phases (if .prd/ exists)

### Completion

Display summary: recommended model, revenue projection, and next steps.
