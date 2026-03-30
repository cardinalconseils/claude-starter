---
description: "Monetization model evaluation — evidence-based tier scoring"
allowed-tools:
  - Read
  - Agent
---

# /cks:monetize-evaluate

Dispatch the monetize-evaluator agent.

## Prerequisite

Verify `.monetize/context.md`, `.monetize/research.md`, and `.monetize/cost-analysis.md` exist.

## Execution

```
Agent(subagent_type="monetize-evaluator", prompt="Evaluate monetization models. Read all .monetize/ artifacts. Write to .monetize/evaluation.md.")
```
