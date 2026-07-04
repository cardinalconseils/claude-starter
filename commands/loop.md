---
description: "Loop lifecycle manager — design, run, health check, triage, cost monitor, migrate"
allowed-tools:
  - Read
  - Bash
  - Agent
  - AskUserQuestion
---

# /cks:loop — Loop Lifecycle Manager

Parse from user input:
- **sub-command**: first argument (design | run | health | triage | cost | migrate | status)
- **slug**: second argument (loop identifier, e.g. "daily-digest")
- **remaining args**: any additional flags

If sub-command is missing: pass empty string — orchestrator will ask.
If slug is missing: pass empty string — orchestrator will ask.

## Lifecycle Gate (design sub-command only)

When `sub-command = design` AND `slug` is not empty:

Check whether a lifecycle phase exists for this loop:
```
ls .prd/phases/ 2>/dev/null | grep -i "{slug}"
```

**If a matching directory is found** → proceed to loop-orchestrator dispatch below.

**If NO matching directory is found** → surface this decision block (full prose — auto-clarity override):

```
─────────────────────────────────────────────────
❓ DECISION REQUIRED
─────────────────────────────────────────────────
No lifecycle phase found for "{slug}".

Loop features follow the same development workflow as any other feature:
discovery → design → sprint → review → release.
Loop architecture design is a Phase 2 step — it happens after requirements
and design artifacts are established.

  1. Start full lifecycle (Recommended) — dispatch discovery for this loop
     feature; loop design runs automatically at Phase 2 when loop signals detected
  2. Design directly (override) — skip lifecycle and jump to six-part interview;
     use only for standalone operational loops with no user-facing surface or requirements

Reply with the number or describe what you want.
─────────────────────────────────────────────────
```

If user selects option 1 → dispatch `prd-discoverer` (do NOT proceed to loop-orchestrator):
```
Agent(
  subagent_type="cks:prd-discoverer",
  prompt="Start Phase 1 Discovery for a new loop feature. Context: the user wants to build
  a recurring autonomous agent with slug '{slug}'. Ask the full 11-element discovery questions.
  Note in CONTEXT.md that this feature is an agentic loop (loop signals will trigger 
  loop-designer automatically in Phase 2)."
)
```

If user selects option 2 → proceed to loop-orchestrator dispatch below (existing behavior).

## Dispatch

```
Agent(
  subagent_type="cks:loop-orchestrator",
  prompt="sub-command: {sub-command}, slug: {slug}, args: {remaining args}"
)
```

## Quick Reference

```
/cks:loop design <slug>    Design a new loop — interview + LOOP-DESIGN.md
/cks:loop run <slug>       Execute one iteration
/cks:loop health <slug>    Check run history + Sentry + LangSmith observers
/cks:loop triage <slug>    Curate findings → .triage/{slug}/{date}.md  ← PRIMARY UX
/cks:loop cost <slug>      Estimated cost (run-count × $0.01 static estimate)
/cks:loop migrate [slug]   Validate schema_version:1 compliance
/cks:loop status <slug>    Show last 5 runs (secondary — triage is primary)
```

Primary output: `.triage/{slug}/` — triage inbox, not a status console.
