---
name: scheduled-agents
description: >
  Superseded by skills/routines/ — recurring, scheduled, cron-based agents are Routines
  (Claude Code Remote triggers with a ROUTINE.md profile in HQ). This file is a pointer and
  the migration note for legacy .agents/<name>/state.json CronCreate schedules.
allowed-tools: Read, Glob, Grep
---

# Scheduled Agents — superseded by `skills/routines/`

Anything that must run on a cadence and outlive a session is a **Routine**: a
`ROUTINE.md` profile in HQ plus a Claude Code Remote trigger, proposed by any role and
registered only by the chief of staff. Read `skills/routines/SKILL.md`.

`CronCreate` is session-bound and is used only for in-session `/cks:loop` iterations
(`skills/loop/`); never create a new `.agents/<name>/state.json` schedule.

## Migrating a `.agents/<name>/state.json` schedule

1. Run `/cks:routine new "<the job in one sentence>"` — the strategist interview fills a
   `ROUTINE.md` from the state file's `config` (sources, thresholds, output format).
2. `last_output` → the seed `last_findings:` line of `STATE.md`; any seen-list → `seen:`.
3. Register (chief of staff, gated), then leave the JSON in place until the first routine
   run commits; the audit (`skills/routines/workflows/audit.md`, row 9) flags it until removed.
