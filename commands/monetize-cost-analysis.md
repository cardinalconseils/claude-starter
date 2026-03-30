---
description: "Monetization cost analysis — tech stack costs and unit economics"
allowed-tools:
  - Read
  - Agent
---

# /cks:monetize-cost-analysis

Dispatch cost-researcher then cost-analyzer in sequence.

## Prerequisite

Verify `.monetize/context.md` exists. If not, tell user to run `/cks:monetize-discover` first.

## Execution

### Step 1: Cost Research
```
Agent(subagent_type="cost-researcher", prompt="Research tech stack costs. Read .monetize/context.md. Write to .monetize/cost-research-raw.md.")
```

### Step 2: Cost Analysis
```
Agent(subagent_type="cost-analyzer", prompt="Build unit economics. Read .monetize/cost-research-raw.md and .monetize/context.md. Write to .monetize/cost-analysis.md.")
```
