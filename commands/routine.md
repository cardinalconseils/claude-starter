---
description: "Routines — propose, register, list, pause, resume, fire, or audit recurring Claude Code Remote triggers backed by ROUTINE.md profiles in HQ"
argument-hint: "new \"<idea>\" | list | status <slug> | pause <slug> | resume <slug> | run-now <slug> | audit"
allowed-tools:
  - Read
  - Skill
---

# /cks:routine — Routines

A routine is a `ROUTINE.md` profile in HQ (`.routines/<slug>/`) plus one Claude Code Remote
trigger that fires a fresh session on a cadence. Any role may propose one; only the chief
of staff registers, pauses, resumes, fires, or deletes the trigger — each is a gated action.
Domain knowledge lives in `skills/routines/`.

## Dispatch

This is an Orchestrator Exception command (`.claude/rules/commands.md`): the chief of staff
must dispatch the strategist, the operator and the watchdog, and must hold the Remote MCP
tools (`create_trigger`, `list_triggers`, `update_trigger`, `fire_trigger`), so it loads
top-level as a skill.

```
Skill(skill="cks:chief-of-staff")
```

Inbound for the chief of staff: `routine $ARGUMENTS`. The skill reads `skills/routines/`
and routes the sub-command:

| Sub-command | What the chief of staff does |
|---|---|
| `new "<idea>"` | Dispatches `cks:strategist` with `skills/routines/workflows/interview.md`; on approval, follows `workflows/register.md` |
| `list` | `list_triggers` joined on `.routines/*/ROUTINE.md` — slug, cadence, enabled, last run, level |
| `status <slug>` | Profile summary + `STATE.md` + newest `runs/*.md` + the trigger's last run |
| `pause <slug>` / `resume <slug>` | Gated: `update_trigger enabled` after approval, `STATE.md` updated (`workflows/register.md`) |
| `run-now <slug>` | Gated: `fire_trigger` after approval |
| `audit` | `workflows/audit.md` — drift between profiles and triggers, via `cks:watchdog` |

A fired routine session does not use this command; its trigger prompt loads the chief of
staff with `--routine <path>` (`/cks:chief --routine …`), which runs
`skills/routines/workflows/routine-run.md`.

## Quick Reference

```
/cks:routine new "watch Sentry and LangSmith on acme-app, fix what breaks"
/cks:routine list
/cks:routine status observe-production
/cks:routine pause finops-weekly
/cks:routine resume finops-weekly
/cks:routine run-now cultural-observer
/cks:routine audit
```

Seed profiles to start from: `skills/routines/templates/` (observe-production, finops-weekly,
contracts-renewals, workforce-review, cultural-observer) and `templates/imported/` for the
three triggers that already run.
