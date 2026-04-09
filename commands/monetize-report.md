---
description: "Generate monetization assessment report"
allowed-tools:
  - Read
  - Agent
---

# /cks:monetize-report

Dispatch the monetize-reporter agent.

## Prerequisite

Verify `.monetize/evaluation.md` exists. If not, tell user to run `/cks:monetize-evaluate` first.

## Execution

```
Agent(subagent_type="cks:monetize-reporter", prompt="Generate the business case report. Read all .monetize/ artifacts. Write to docs/monetization-assessment.md.")
```
