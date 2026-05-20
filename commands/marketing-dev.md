---
description: "Luv Marketing — technical marketing development: tracking scripts, automation, integrations, marketing infra — CTO-led"
argument-hint: "[engineering task for marketing infrastructure]"
allowed-tools: Read, Agent, AskUserQuestion
---

# /cks:marketing-dev — Marketing Dev

Dispatches the Luv Marketing CTO for pure engineering work in the marketing stack. No marketing strategy layer — this is code. Use when the task is technical: building a tracking integration, wiring an automation, writing a script, setting up infrastructure.

## Quick Reference

```
/cks:marketing-dev Wire Meta CAPI to our FastAPI backend for server-side conversion tracking
/cks:marketing-dev Build an n8n workflow that syncs new Stripe customers to our email list
/cks:marketing-dev Set up Playwright E2E tests for our lead gen funnel
/cks:marketing-dev Implement a referral tracking system with UTM persistence
/cks:marketing-dev Deploy a Vercel edge function for A/B test variant assignment
```

## Dispatch

**with args:** `Agent(subagent_type="luv:cto", prompt="Marketing engineering task: {$ARGUMENTS}. Route to the right engineering specialist. Deliver working code with tests.")`

**no args:** AskUserQuestion — "What engineering work is needed?" with options: Tracking integration / Automation workflow / Marketing API / Infrastructure / Testing
