---
description: "Luv Marketing — build a full website or app: CEO coordinates CMO (content + positioning) and CTO (engineering)"
argument-hint: "[what to build and for whom]"
allowed-tools: Read, Agent, AskUserQuestion
---

# /cks:marketing-build — Marketing Build

Dispatches the Luv Marketing CEO to coordinate a full marketing build. CEO briefs the CMO on positioning and content, and the CTO on the technical stack and implementation. Use when the output is something that needs to be shipped — a site, a page, an app.

## Quick Reference

```
/cks:marketing-build A full marketing site for ServiConnect
/cks:marketing-build Landing page for our SaaS free trial — with tracking and A/B test ready
/cks:marketing-build Webinar registration page with GTM, Stripe, and confirmation email flow
/cks:marketing-build PWA storefront with product catalog and checkout
```

## Dispatch

**with args:** `Agent(subagent_type="luv:ceo", prompt="Build request: {$ARGUMENTS}. Coordinate CMO for positioning, copy, and conversion strategy, and CTO for technical architecture and implementation. Report build plan and outcomes.")`

**no args:** AskUserQuestion — "What should we build?" with options: Marketing website / Landing page / Web app / Mobile app
