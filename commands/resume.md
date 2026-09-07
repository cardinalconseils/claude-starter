---
description: "Resume work from the last session handoff — reads .prd/HANDOFF.md and executes the next steps"
argument-hint: "[optional: specific focus or step to jump to]"
allowed-tools:
  - Read
  - Skill
---

# /cks:resume — Resume from Handoff

Read the latest session handoff and continue it. Executing the resume steps means
dispatching specialists, which only the session brain can do, so this loads the chief of
staff (Orchestrator Exception, `.claude/rules/commands.md`).

## Dispatch

```
Skill(skill="cks:chief-of-staff")
```

Inbound: `Resume from handoff. (1) Read .prd/HANDOFF.md — if missing, the newest file
under .prd/handoffs/. (2) Show the handoff: branch, phase/step, last commit, pending
items, blockers. (3) Show the Resume Steps section verbatim. (4) If '$ARGUMENTS' is
non-empty, treat it as a focus override that narrows or redirects the steps. (5) Ask before
executing — DECISION REQUIRED: (a) proceed with the steps as listed, (b) adjust focus
first, (c) show the full handoff only. (6) On confirmation, run the steps through the
normal triage and dispatch loop — do not re-discover what is already documented.`

Rule: never skip straight to execution without showing the handoff and getting
confirmation.

## Quick Reference

```
/cks:resume                        → load latest handoff, confirm, execute
/cks:resume fix auth tests         → resume with focus override on auth tests
/cks:resume show only              → display handoff without executing
```

Run in a fresh session after `/cks:handoff` was called in the previous one.
Handoff location: `.prd/HANDOFF.md` (latest pointer) or `.prd/handoffs/` (full history).
