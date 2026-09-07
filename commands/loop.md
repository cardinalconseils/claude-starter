---
description: "Loop lifecycle manager — design, run, health check, triage, cost monitor, migrate"
argument-hint: "<design|run|health|triage|cost|migrate|status> [slug] [flags]"
allowed-tools:
  - Read
  - Skill
---

# /cks:loop — Loop Lifecycle Manager

Parse from `$ARGUMENTS`:
- **sub-command**: first token (design | run | health | triage | cost | migrate | status)
- **slug**: second token (loop identifier, e.g. `daily-digest`)
- **remaining args**: any additional flags

Missing sub-command or slug → pass an empty string; the loop asks.

## Dispatch

This is an Orchestrator Exception command (`.claude/rules/commands.md`): each sub-command
dispatches a role, and only the top-level session can, so it loads as a skill rather than
running as a sub-agent.

```
Skill(skill="cks:loop")
```

sub-command: `{sub-command}` · slug: `{slug}` · args: `{remaining args}`.

The skill's `SKILL-ORCHESTRATOR.md` routes design → `cks:architect` (+ `cks:operator` for
the schedule, behind the lifecycle gate), run → `cks:builder`, health → `cks:watchdog` +
`cks:observer`, triage → `cks:historian`, cost → `cks:watchdog` (+ `cks:finops`),
migrate → `cks:operator` (`--fix` only), and answers `status` inline.

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
