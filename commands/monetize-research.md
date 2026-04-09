---
description: "Monetization market research"
allowed-tools:
  - Read
  - Agent
---

# /cks:monetize-research

Dispatch the monetize-researcher agent for market intelligence.

## Prerequisite

Verify `.monetize/context.md` exists. If not, tell user to run `/cks:monetize-discover` first.

## Execution

```
Agent(subagent_type="cks:monetize-researcher", prompt="Research the market. Read .monetize/context.md for context. Write to .monetize/research.md.")
```
