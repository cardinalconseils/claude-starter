---
description: "End-of-feature UAT — reads PREFLIGHT.md acceptance criteria + CONTEXT.md DoD, drives browser-automated testing, files GitHub issues for failures, writes dated UAT report"
allowed-tools:
  - Read
  - Bash
  - Agent
  - AskUserQuestion
---

# /cks:uat — Feature UAT

Trigger end-of-feature User Acceptance Testing. Reads the acceptance criteria in
PREFLIGHT.md (§E — Establish) and CONTEXT.md DoD, then drives browser-automated testing.
Files GitHub issues for failures and writes a dated UAT report. Run at the end of a
sprint, after implementation and code review, before merging.

## Pre-Check

Read `.prd/PRD-STATE.md` for the active phase number. Then:

```bash
find .prd/phases -name "*CONTEXT.md" | sort | tail -1
find .preflight -name "PREFLIGHT.md" 2>/dev/null | sort | tail -1
grep -rE 'dev_url|preview_url|localhost|https?://' .prd/phases/*/CONTEXT.md .prd/phases/*/PLAN.md 2>/dev/null | head -5
```

**CONTEXT.md not found** → `▶ ACTION REQUIRED` block: Run `/cks:discover` — CONTEXT.md
with acceptance criteria is required before UAT — then run `/cks:uat` again.

**PREFLIGHT.md not found** → `💡 SUGGESTION` (advisory, never a gate): UAT falls back to
CONTEXT.md DoD; run `/cks:preflight` first for richer acceptance criteria + edge cases.

## Dispatch

```
Agent(
  subagent_type="cks:tester",
  prompt="Mode: uat. Run end-of-feature UAT per skills/uat.
          Phase: {active_phase_number}.
          CONTEXT.md: {context_path}.
          PREFLIGHT.md: {preflight_path or 'not found'}.
          Detected URL: {url or 'ask user'}.
          File GitHub issues for failures. Write .uat/ report."
)
```

## Quick Reference

```
/cks:uat              UAT current active phase; offers debug loop if blocking issues found
/cks:uat https://...  UAT against a specific app URL
```

Requires: CONTEXT.md with acceptance criteria. Recommended: PREFLIGHT.md from `/cks:preflight`.
Output: `.uat/UAT-{date}-{run_id}.md` + GitHub issues + optional debug loop (`cks:debugger` → E2E re-verify).
