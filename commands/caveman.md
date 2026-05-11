---
description: "Caveman mode — compress agent output into caveman speak. Brain still big. Mouth small."
allowed-tools:
  - Agent
---

# /cks:caveman — Caveman Mode

Dispatch the **caveman-speaker** agent (which has `skills: caveman, core-behaviors` loaded at startup).

## Dispatch

Agent(subagent_type="cks:caveman-speaker", prompt="Compress prose into caveman speak. Target: $ARGUMENTS (default: --diff for recent prose changes via git diff). Read the caveman skill for level rules and auto-clarity overrides. Preserve all code, paths, commands, and block formats verbatim. Report before/after token estimates and reduction percentage.")

## Quick Reference

```
/cks:caveman                       Compress recent prose changes (git diff)
/cks:caveman README.md             Compress a specific file
/cks:caveman README.md full        Pick intensity: lite | full | ultra | wenyan
/cks:caveman --scope=retro         Compress all retro/learnings files
/cks:caveman --scope=devlog ultra  Crush the DEVLOG to bullet-level
```

## Levels

- `lite` (~30% cut) — drop articles + filler, keep sentence structure
- `full` (~65% cut) — telegraphic, imperative verbs, no hedging — **default**
- `ultra` (~80% cut) — minimum words, bullets, fragments
- `wenyan` (~85% cut) — symbol-heavy classical compression — status dumps only

## Auto-Clarity

Caveman drop to normal prose for: destructive-action warnings, Action Required / Decision Required blocks, security findings, PRD discovery questions, quoted error messages. Clarity beat brevity when stakes high.
