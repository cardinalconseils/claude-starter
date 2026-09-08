---
description: "Campaign orchestrator — intake, specialist dispatch, and artifact generation for outbound email, product launch, ABM, and content/paid campaigns"
argument-hint: "[outbound|launch|abm|content] [optional brief]"
allowed-tools:
  - Read
  - Skill
  - AskUserQuestion
---

# /cks:campaign — Campaign Orchestrator

Build and run a marketing campaign end-to-end: intake, positioning, copy, sequences, and a RUNBOOK.

## Mode Detection

Parse `$ARGUMENTS`:

| Pattern | Behavior |
|---------|----------|
| `outbound ...` | Outbound campaign |
| `launch ...` | Product launch campaign |
| `abm ...` | Account-based campaign |
| `content ...` | Content + paid campaign |
| No args | Ask which type |

If no args, ask:

`AskUserQuestion("What type of campaign?", options=["Outbound email — cold prospecting sequence", "Product launch — 8-week launch plan + assets", "Account-based (ABM) — personalized multi-touch for target accounts", "Content + Paid ads — keyword-driven content plan + ad copy"])`

## Dispatch

This is an Orchestrator Exception command (`.claude/rules/commands.md`): the campaign
chains `cks:marketer` personas, and only the top-level session can dispatch, so it loads
as a skill rather than running as a sub-agent.

```
Skill(skill="cks:campaign")
```

Campaign request: `{$ARGUMENTS or user selection}`. The skill's `SKILL-ORCHESTRATOR.md`
runs the intake from `skills/marketing/workflows/campaign.md`, the Apollo check, the
persona dispatches, and writes `.campaign/{slug}/` (brief, assets, RUNBOOK).

## Quick Reference

```
/cks:campaign outbound    → Cold email sequence (3-touch) + Apollo load option
/cks:campaign launch      → 8-week launch plan + hero copy + social posts
/cks:campaign abm         → Target account list + personalized multi-touch sequence
/cks:campaign content     → Keyword content plan + ad copy (Google, Meta, LinkedIn)
/cks:campaign             → Pick campaign type interactively
```
