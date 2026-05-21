---
description: "Conversational project orchestrator — ask, proceed, delegate to the right CKS agent"
argument-hint: "[ask|proceed|status] [intent]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:concierge — Conversational Orchestrator

Talk to your project. The concierge maps natural language to the right CKS workflow.

## Argument Parsing

| Input | What happens |
|---|---|
| `/cks:concierge ask "what's the status?"` | Dispatch with that intent |
| `/cks:concierge proceed` | Dispatch with "proceed" intent — reads current phase from PRD-STATE.md |
| `/cks:concierge status` | Dispatch with "status" intent — shows dashboard |
| `/cks:concierge` (no args) | Dispatch with empty intent — agent asks what to do |
| `/cks:concierge "sprint on user auth"` | Bare text also works |

## Pre-Dispatch Context Injection

Before dispatching the concierge agent, read:

```bash
# Current branch
git branch --show-current

# PRD state (if exists)
cat .prd/PRD-STATE.md 2>/dev/null
```

Pass both to the agent prompt as context.

## Dispatch

```
Agent(
  subagent_type="cks:concierge",
  prompt="
    SOURCE: cli
    ARGUMENTS: {$ARGUMENTS}
    BRANCH: {current branch}
    PRD_STATE: {contents of .prd/PRD-STATE.md or 'none'}
  "
)
```

## Quick Reference

```
/cks:concierge "start planning the user auth feature"
/cks:concierge proceed
/cks:concierge status
/cks:concierge "fix the login bug"
/cks:concierge ask "deploy to staging"
```
