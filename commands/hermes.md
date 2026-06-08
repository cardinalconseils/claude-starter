---
description: "Hermes Mode readiness — init, status, and smoke checks for always-on channel brain"
argument-hint: "[status|init|smoke]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:hermes — Hermes Mode Readiness

Manage the always-on conversational CKS setup described in `docs/hermes-mode.md`.

## Routing

Parse `$ARGUMENTS`:

| Invocation | Action |
|---|---|
| `/cks:hermes` | Run status checks |
| `/cks:hermes status` | Run status checks |
| `/cks:hermes init` | Add the Hermes channel-brain block to `CLAUDE.md` if missing |
| `/cks:hermes smoke` | Run deterministic readiness checks via `scripts/hermes-smoke-test.sh` |

## Dispatch

```
Agent(
  subagent_type="cks:hermes-readiness",
  prompt="Mode: {parsed mode or 'status'}. Project root: {cwd}. Arguments: $ARGUMENTS"
)
```

## Quick Reference

```
/cks:hermes          → Check Hermes readiness
/cks:hermes init     → Install CLAUDE.md channel-brain instruction
/cks:hermes smoke    → Run deterministic hook/memory/channel readiness checks
```
