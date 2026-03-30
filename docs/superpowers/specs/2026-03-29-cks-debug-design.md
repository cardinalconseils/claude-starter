# CKS Debug — Design Spec

**Date:** 2026-03-29
**Status:** Approved

## Overview

Unified debug command for both application runtime debugging and CKS self-debugging. Language-agnostic approach using strategic logging and code-tracing (no debugger attachment). Diagnoses first, fixes only with user approval.

## Entry Points

```
/cks:debug                          → Exploratory app debugging
/cks:debug "TypeError: cannot..."   → Error-driven app debugging
/cks:debug --cks                    → CKS self-debug (last action)
/cks:debug --cks discover           → CKS self-debug (specific phase/command)
```

## Components

| Component | File | Purpose |
|-----------|------|---------|
| Command | `commands/debug.md` | Thin router — detects mode, dispatches agent |
| Agent | `agents/debugger.md` | Diagnosis workhorse for both app and CKS modes |
| Skill | `skills/debug/SKILL.md` | Diagnostic strategies, CKS introspection, templates |

## App Debugging (no --cks flag)

### Error-driven mode
1. Parse the error/stack trace
2. Read referenced files
3. Trace data flow backward from the error site
4. Inject strategic logging if needed (language-agnostic print/log)
5. Identify root cause with confidence level

### Exploratory mode
1. Ask "expected vs actual behavior?"
2. Identify the code path involved
3. Trace through the path reading code
4. Inject strategic logging at decision points
5. Narrow to root cause

## CKS Self-Debug (--cks flag)

Covers five failure modes:

| Problem | Diagnosis Method |
|---------|-----------------|
| Skill produces wrong output | Read skill file, compare instructions to agent actions via logs |
| Skill doesn't trigger | Check skill description vs user input, flag mismatch |
| Agent goes off-rails | Read agent prompt, check tools list, inspect output |
| Workflow state corrupted | Validate PRD-STATE against actual .prd/ files |
| Phase skipped steps | Cross-reference workflow steps against lifecycle.jsonl events |

## Diagnosis Report Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 DEBUG REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Mode:       App / CKS
  Trigger:    [error message or "exploratory"]

  Root Cause: [concise explanation]
  Chain:      [step-by-step trace]
  Evidence:   [files, logs, state]

  Confidence: High / Medium / Low
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Fix available? Yes/No
  Proposed:  [what would change]
  Files:     [list]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Apply fix? [waiting for user]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Design Decisions

- **Language-agnostic**: Strategic logging over debugger integration — works everywhere, plays to Claude's strengths
- **Diagnose-first**: Always show root cause before proposing fix — user approves before code changes
- **Unified entry point**: Single `/cks:debug` command routes to correct mode
- **Reuses existing infra**: Reads lifecycle.jsonl, PRD-STATE, and skill/agent files already in the plugin
