---
description: "Adherence audit — checks codebase against .claude/rules/ and reports per-rule compliance"
argument-hint: "[--quick | --full]"
allowed-tools:
  - Read
  - Agent
---

# /cks:review-rules — Guardrail Adherence Audit

Parse the mode argument and dispatch the rules-auditor agent.

## Routing

| Invocation | Mode |
|------------|------|
| `/cks:review-rules` | Quick — scan changed files only |
| `/cks:review-rules --quick` | Quick — scan changed files only |
| `/cks:review-rules --full` | Full — scan entire codebase |

## Dispatch

```
Agent(subagent_type="rules-auditor", prompt="
  mode: {quick or full based on args}
  caller: manual
")
```

When called by other commands (sprint-close, sprint [3d], release [5c]):
```
Agent(subagent_type="rules-auditor", prompt="
  mode: quick
  caller: {sprint-close | sprint-3d | release-5c}
")
```

## Quick Reference

```
/cks:review-rules          → Quick audit (changed files)
/cks:review-rules --full   → Full codebase audit
```
