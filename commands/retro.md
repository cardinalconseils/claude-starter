---
description: "Run a retrospective — analyze what worked, extract learnings, propose CLAUDE.md updates"
argument-hint: "[--auto] [--metrics] or no args for interactive"
allowed-tools:
  - Read
  - Agent
---

# /cks:retro — Retrospective & Learning

Dispatch the **retrospective** agent (which has `skills: retrospective` loaded at startup).

## Dispatch

```
Agent(subagent_type="retrospective", prompt="Run a retrospective. Mode: {interactive if no flags, auto if --auto, metrics if --metrics}. Read recent git log, .prd/ state, and .prd/logs/lifecycle.jsonl. Extract learnings and save to .learnings/. Arguments: $ARGUMENTS")
```

## Quick Reference

```
/cks:retro               → Interactive — guided reflection + review proposals
/cks:retro --auto        → Auto — lightweight post-ship analysis (no interaction)
/cks:retro --metrics     → Metrics — show velocity dashboard
```

The retrospective agent handles: git/log analysis, reflection Q&A (interactive mode), convention extraction, CLAUDE.md proposals (never auto-edits), and `.learnings/` output.
