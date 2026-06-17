---
type: decision
name: loop-runtime-go
description: Go verdict for Loop Architecture (Full Runtime) — /cks:loop as first-class lifecycle. Branch pending V1 interviews.
---

# Decision: Loop Architecture (Full Runtime) — Go

**Date:** 2026-06-16
**Score:** 4.33/5 — Go
**Branch:** `loop-runtime-concept` (not yet opened — see blocker below)

## What Was Decided

`/cks:loop` becomes a first-class CKS lifecycle: design → scaffold → run → health-check →
cost monitor → triage inbox. Wraps (does not replace) `/cks:schedule` and `.agents/`.

## Artifacts

| File | Status |
|---|---|
| `.concept/loop-runtime/FEASIBILITY.md` | Written |
| `.concept/loop-runtime/PRE-MORTEM.yaml` | Written — 7 Go/No-Go items |
| `.concept/loop-runtime/PLAN.md` | Written — build order locked |
| `.claude/rules/loops.md` | **Written** — deterministic gate wired |
| `.claude/rules/scheduling.md` | **Updated** — loop supersedes schedule |

## Deterministic Gates (wired now, enforce before agents exist)

- Loop signals trigger `cks:loop-designer` dispatch before PLAN.md (`.claude/rules/loops.md`)
- `scheduling.md` defers to `loops.md` when both signals present
- Schema versioning, migration command, cost monitor mode, stop condition, autonomy level are rule-enforced
- `state.json` must include `sentry_dsn` before Level 2+ (empty string = explicit opt-out; absent = gate fail)
- LLM loops must include `langsmith_project` in `state.json`
- `loop-runner` MUST capture every unhandled exception to Sentry (when DSN non-empty) — no silent swallowing
- `loop-runner` MUST open/close a LangSmith trace on every run (when project non-empty) — not only on failure
- `loop-health-checker` MUST dispatch `cks:sentry-observer` + `cks:langsmith-observer` as part of every health run

## Indeterministic (agent judgment)

- Loop design (six-part composition) — `cks:loop-designer`
- Sentry tags/breadcrumbs beyond mandatory capture — `cks:loop-runner`
- LangSmith trace naming — `cks:loop-runner`
- Sentry alert thresholds — `cks:loop-designer` (asks user during design)
- Triage severity scoring — `cks:loop-triage-curator`
- LangSmith/Sentry trace correlation — `cks:loop-health-checker`
- Cost estimate calibration — `cks:loop-cost-monitor`
- Orchestrator sub-command routing — `cks:loop-orchestrator`

## One Remaining Blocker

**V1** — 3 user interviews to validate operator-console framing:
> "Do you check on your running loops? How? What would you check if it were one command?"
> If 2/3 say "I don't check" → pivot framing from operator console to digest emails.

V2 (Layer 2 telemetry) — CLOSED. Layer 2 not shipped → degraded cost monitor is v1. No action needed.

## Next Step When V1 Complete

```
/cks:new "loop-runtime"
```

Then follow PLAN.md build order: schema lock → migration command → degraded cost monitor → rest of runtime.

Pre-merge Go/No-Go checklist (7 items) is in `.concept/loop-runtime/PLAN.md`.
