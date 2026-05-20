---
description: "Luv Marketing — marketing analytics: campaign performance, A/B tests, attribution, dashboards, tracking setup"
argument-hint: "[what to measure or analyze]"
allowed-tools: Read, Agent, AskUserQuestion
---

# /cks:marketing-analytics — Marketing Analytics

Dispatches the Luv Marketing CMO with an analytics brief. CMO routes to DataScientist (A/B tests, attribution, funnel analysis, segmentation) and DataEngineer (GA4, GTM, BigQuery, Looker Studio dashboards, CAPI) as needed.

## Quick Reference

```
/cks:marketing-analytics How is our last campaign performing — break down by channel and segment
/cks:marketing-analytics Set up GA4 + GTM for our new landing page
/cks:marketing-analytics Design an A/B test for our pricing page headline
/cks:marketing-analytics Build a Looker Studio dashboard for weekly campaign reporting
/cks:marketing-analytics Our conversion rate dropped last week — diagnose why
```

## Dispatch

**with args:** `Agent(subagent_type="luv:cmo", prompt="Analytics task: {$ARGUMENTS}. Route to DataScientist and/or DataEngineer as needed. Deliver findings, recommendations, or implementation — not just raw numbers.")`

**no args:** AskUserQuestion — "What analytics work should we do?" with options: Campaign performance review / Tracking setup (GA4/GTM) / A/B test design / Dashboard build / Conversion diagnosis
