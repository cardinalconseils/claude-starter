---
description: "Caveman mode — default CKS voice. Compress agent output. Brain still big. Mouth small."
allowed-tools:
  - Agent
---

# /cks:caveman — Caveman Mode

Default ON in CKS. Drop articles, filler, hedging. Cut ~65% tokens. Keep 100% technical truth. Auto-clarity overrides protect destructive ops, security warnings, and human-intervention blocks. See `.claude/rules/output-voice.md`.

## Dispatch

Agent(subagent_type="cks:caveman-speaker", prompt="Args: $ARGUMENTS. Read the caveman skill for level rules and auto-clarity overrides. Decide intent: (1) if arg starts with 'on' or 'off' or 'status', manage the `.cks/caveman-disabled` flag file and report current state; (2) otherwise, compress prose for the target (default: --diff for recent prose changes via git diff). Preserve all code, paths, commands, and block formats verbatim. Report state change or before/after token estimates and reduction percentage.")

## Quick Reference

```
/cks:caveman                       Compress recent prose (git diff)
/cks:caveman on                    Enable caveman default voice (default state)
/cks:caveman off                   Disable for this project (writes .cks/caveman-disabled)
/cks:caveman status                Report on/off state
/cks:caveman README.md             Compress a specific file
/cks:caveman README.md full        Pick level: lite | full | ultra | wenyan
/cks:caveman --scope=retro         Compress all retro/learnings files
/cks:caveman --scope=devlog ultra  Crush DEVLOG to bullet-level
```

## Levels

- `lite` (~30% cut) — drop articles + filler, keep sentence structure
- `full` (~65% cut) — telegraphic, imperative verbs, no hedging — **default**
- `ultra` (~80% cut) — minimum words, bullets, fragments
- `wenyan` (~85% cut) — symbol-heavy classical compression — status dumps only

## Auto-Clarity

Caveman drop to normal prose for: destructive-action warnings, Action Required / Decision Required blocks, security findings, PRD discovery questions, quoted error messages. Clarity beat brevity when stakes high.
