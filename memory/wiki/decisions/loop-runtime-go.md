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

## V1 Interview Results — CLOSED (2026-06-17)

**Question asked:** "Do you check on your running loops? How? What would you check if it were one command?"

| # | Persona | Answer |
|---|---------|--------|
| 1 | Builder (first loop) | "I don't really check" — looks at PRs it opens |
| 2 | Power user (3+ loops) | "I don't really check" — noticed failure after a week |
| 3 | N/A | User clarified: CKS target audience is **vibecoders with zero dev/devops experience** |

**Result: 2/3 said "I don't check" + audience has no DevOps instinct → PIVOT confirmed.**

**Framing pivot: operator console → digest/triage inbox**

The primary user-facing output of a loop is not a status dashboard you run commands against.
It is a **triage inbox**: the loop writes findings to a visible place (Slack, email, `.triage/`)
and notifies on failure. The user opens results when something surfaces, not on a schedule.

Implications for build:
- `/cks:loop status` can exist but is NOT the primary UX
- `loop-triage-curator` + `loop output → triage inbox` is the primary UX
- Loop health failure → push notification (Slack/Telegram/email) not `/cks:loop health` command
- Autonomy ladder framing stays; digest framing replaces console framing

**V2 (Layer 2 telemetry) — CLOSED.** Degraded cost monitor is v1.

## Next Step

Branch `loop-runtime-concept` is open. Follow PLAN.md build order:

```
schema lock → migration command → degraded cost monitor → triage-inbox-first UX → rest of runtime
```

Key UX shift from original plan: triage inbox is the primary output surface, not operator console.
Pre-merge Go/No-Go checklist (7 items) still applies.
