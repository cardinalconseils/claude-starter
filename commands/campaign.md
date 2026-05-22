---
description: "Campaign orchestrator — intake, specialist dispatch, and artifact generation for outbound email, product launch, ABM, and content/paid campaigns"
argument-hint: "[outbound|launch|abm|content] [optional brief]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:campaign — Campaign Orchestrator

Build and run a marketing campaign end-to-end: intake, positioning, copy, sequences, and a RUNBOOK.

## Mode Detection

Parse `$ARGUMENTS`:

| Pattern | Behavior |
|---------|----------|
| `outbound ...` | Dispatch directly as outbound campaign |
| `launch ...` | Dispatch directly as product launch campaign |
| `abm ...` | Dispatch directly as account-based campaign |
| `content ...` | Dispatch directly as content + paid campaign |
| No args | Ask user to pick campaign type |

If no args, ask:

`AskUserQuestion("What type of campaign?", options=["Outbound email — cold prospecting sequence", "Product launch — 8-week launch plan + assets", "Account-based (ABM) — personalized multi-touch for target accounts", "Content + Paid ads — keyword-driven content plan + ad copy"])`

## Dispatch

`Agent(subagent_type="cks:campaign-orchestrator", prompt="Campaign request: {$ARGUMENTS or user selection}. Run intake, select specialists, produce campaign artifacts.")`

Output lands in `.campaign/{slug}/`.

## Quick Reference

```
/cks:campaign outbound    → Cold email sequence (3-touch) + Apollo load option
/cks:campaign launch      → 8-week launch plan + hero copy + social posts
/cks:campaign abm         → Target account list + personalized multi-touch sequence
/cks:campaign content     → Keyword content plan + ad copy (Google, Meta, LinkedIn)
/cks:campaign             → Pick campaign type interactively
```
