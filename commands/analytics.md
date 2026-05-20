---
description: "Analytics tracker — GA4 event taxonomy, GTM setup, ad pixel checklist, tracking gap audit by maturity stage"
argument-hint: "[setup|audit|report]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:analytics — Analytics Tracker

Dispatch the analytics tracker agent to set up, audit, or report on tracking instrumentation.

## Mode Detection

Parse `$ARGUMENTS`:

| Pattern | Mode |
|---------|------|
| `setup` | New project — event taxonomy + GTM setup + pixel checklist |
| `audit` | Existing project — scan codebase for tracking gaps vs taxonomy |
| `report` | Pull GA4 summary (requires GA4 credentials in env) |
| No args | Ask user which mode |

## Dispatch

`Agent(subagent_type="cks:analytics-tracker", prompt="Mode: {mode}. Scan codebase for existing tracking. Read analytics-tracking/events.yaml for event taxonomy and pixels.yaml for platform pixel requirements. Detect maturity stage from PROJECT.md. Write output to .analytics/{mode}.md.")`

## Quick Reference

```
/cks:analytics setup    → GA4 events + GTM config + pixel checklist for new project
/cks:analytics audit    → Gap analysis: what's tracked vs. what's missing
/cks:analytics report   → GA4 summary (requires GOOGLE_ANALYTICS_CREDENTIALS)
/cks:analytics          → Pick mode interactively
```

Output: `.analytics/` directory (setup.md, audit.md, or report.md)
