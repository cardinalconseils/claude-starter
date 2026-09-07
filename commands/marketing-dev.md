---
description: "Luv Marketing — technical marketing development: tracking scripts, automation, integrations, marketing infra"
argument-hint: "[engineering task for marketing infrastructure]"
allowed-tools: Read, Agent, AskUserQuestion
---

# /cks:marketing-dev — Marketing Dev

Pure engineering work in the marketing stack — no strategy layer, this is code. Dispatches
`cks:builder` (the ex-CTO bench: frontend, backend, landing-page, data, automation).
Use when the task is technical: a tracking integration, an automation, a script, infra.

## Quick Reference

```
/cks:marketing-dev Wire Meta CAPI to our FastAPI backend for server-side conversion tracking
/cks:marketing-dev Build an n8n workflow that syncs new Stripe customers to our email list
/cks:marketing-dev Set up Playwright E2E tests for our lead gen funnel
/cks:marketing-dev Implement a referral tracking system with UTM persistence
/cks:marketing-dev Deploy a Vercel edge function for A/B test variant assignment
```

## Dispatch

**with args:**
```
Agent(subagent_type="cks:builder", prompt="Marketing engineering task: {$ARGUMENTS}. Deliver working code with tests. Tracking and CAPI work follows skills/analytics-tracking; n8n/Make automations follow skills/no-code. Report what was built and how it was verified.")
```

Deployment of the result is a separate `cks:shipper` dispatch; E2E validation of a funnel
is `cks:tester`.

**no args:** AskUserQuestion — "What engineering work is needed?" with options: Tracking
integration / Automation workflow / Marketing API / Infrastructure / Testing
