---
description: "Luv Marketing — build a full website or app: marketing director frames positioning and content, builder ships it"
argument-hint: "[what to build and for whom]"
allowed-tools: Read, Agent, AskUserQuestion
---

# /cks:marketing-build — Marketing Build

Two dispatches, in order: `cks:marketer` (marketing-director persona) produces the
positioning, copy, and conversion plan; `cks:builder` implements it. Use when the output
is something that needs to be shipped — a site, a page, an app.

## Quick Reference

```
/cks:marketing-build A full marketing site for ServiConnect
/cks:marketing-build Landing page for our SaaS free trial — with tracking and A/B test ready
/cks:marketing-build Webinar registration page with GTM, Stripe, and confirmation email flow
/cks:marketing-build PWA storefront with product catalog and checkout
```

## Dispatch

**with args:**
```
Agent(subagent_type="cks:marketer", prompt="Persona: marketing-director. Build request: {$ARGUMENTS}. Produce the build brief: positioning, page map, final copy per page, conversion strategy, tracking events. Write .marketing/build-brief.md. Do not write code.")
```
Then, with the brief on disk:
```
Agent(subagent_type="cks:builder", prompt="Implement .marketing/build-brief.md: {$ARGUMENTS}. Follow the project stack from CLAUDE.md, wire the tracking events named in the brief, add tests. Report the build plan and what shipped.")
```

**no args:** AskUserQuestion — "What should we build?" with options: Marketing website /
Landing page / Web app / Mobile app
