---
description: "End-of-feature UAT — reads PREFLIGHT.md acceptance criteria + CONTEXT.md DoD, drives browser-automated testing, files GitHub issues for failures, writes dated UAT report"
allowed-tools:
  - Read
  - Bash
  - Agent
  - AskUserQuestion
---

# /cks:uat — Feature UAT

Trigger end-of-feature User Acceptance Testing. Reads the acceptance criteria defined in PREFLIGHT.md (§E — Establish) and CONTEXT.md DoD, then drives browser-automated testing via the Claude-in-Chrome extension. Files GitHub issues for failures and writes a dated UAT report.

Run at the end of a sprint, after implementation and code review, before merging.

## Pre-Check

Read `.prd/PRD-STATE.md` to get the active phase number. Then:

```bash
# Locate CONTEXT.md
find .prd/phases -name "*CONTEXT.md" | sort | tail -1

# Locate PREFLIGHT.md
find .preflight -name "PREFLIGHT.md" 2>/dev/null | sort | tail -1

# Detect any app URL from artifacts
grep -rE 'dev_url|preview_url|localhost|https?://' .prd/phases/*/CONTEXT.md .prd/phases/*/PLAN.md 2>/dev/null | head -5
```

If **CONTEXT.md not found**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
▶ ACTION REQUIRED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Run:    /cks:discover
Why:    CONTEXT.md with acceptance criteria required before UAT
Then:   Run /cks:uat again
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

If **PREFLIGHT.md not found**, show suggestion (advisory — never a gate):
```
· · · · · · · · · · · · · · · · · · · · · · · ·
💡 SUGGESTION
· · · · · · · · · · · · · · · · · · · · · · · ·
No PREFLIGHT.md found. UAT will fall back to CONTEXT.md DoD.
Run /cks:preflight first for richer acceptance criteria + edge cases.
· · · · · · · · · · · · · · · · · · · · · · · ·
```

## Dispatch

```
Agent(
  subagent_type="cks:uat-runner",
  prompt="Run end-of-feature UAT.
          Phase: {active_phase_number}.
          CONTEXT.md: {context_path}.
          PREFLIGHT.md: {preflight_path or 'not found'}.
          Detected URL: {url or 'ask user'}.
          File GitHub issues for failures. Write .uat/ report."
)
```

## Quick Reference

```
/cks:uat              UAT current active phase
```

Requires: CONTEXT.md with acceptance criteria.
Recommended: PREFLIGHT.md from /cks:preflight.
Output: `.uat/UAT-{date}-{run_id}.md` + GitHub issues for failures.
