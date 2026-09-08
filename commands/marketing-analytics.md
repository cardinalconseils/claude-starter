---
description: "Luv Marketing — marketing analytics: campaign performance, A/B tests, attribution, dashboards, tracking setup"
argument-hint: "[what to measure or analyze]"
allowed-tools: Read, Agent, AskUserQuestion
---

# /cks:marketing-analytics — Marketing Analytics

Dispatches `cks:marketer` with the data-scientist persona (A/B tests, attribution, funnel
analysis, segmentation). Tracking implementation (GA4, GTM, BigQuery, Looker Studio, CAPI)
is engineering — the marketer returns the spec and you dispatch `cks:builder`.

## Quick Reference

```
/cks:marketing-analytics How is our last campaign performing — break down by channel and segment
/cks:marketing-analytics Set up GA4 + GTM for our new landing page
/cks:marketing-analytics Design an A/B test for our pricing page headline
/cks:marketing-analytics Build a Looker Studio dashboard for weekly campaign reporting
/cks:marketing-analytics Our conversion rate dropped last week — diagnose why
```

## Dispatch

**with args:**
```
Agent(subagent_type="cks:marketer", prompt="Persona: data-scientist. Analytics task: {$ARGUMENTS}. Deliver findings, recommendations, or an implementation spec — not raw numbers. Apply skills/analytics-tracking for event taxonomy and pixels. Write to .marketing/analytics/. Anything that needs code returns as a spec for cks:builder.")
```

**no args:** AskUserQuestion — "What analytics work should we do?" with options: Campaign
performance review / Tracking setup (GA4/GTM) / A/B test design / Dashboard build /
Conversion diagnosis
