---
description: "View and manage project memory — facts, decisions, gotchas, session snapshots"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:memory — Project Memory

Parse `$ARGUMENTS` for one of: `--facts`, `--decisions`, `--gotchas`, `--sessions`, `--sync`.
If none provided, default to showing a summary of all memory types.

Dispatch the `memory-agent`:

```
Agent(
  subagent_type="cks:memory-agent",
  prompt="
    Mode: {parsed arg or 'summary'}
    Memory base: .cks/control-plane/memory/
    Show the requested memory view. If mode is 'sync', trigger memory-sync.sh.
  "
)
```

## Quick Reference

```
/cks:memory                  Summary — all memory types + counts
/cks:memory --facts          Project facts KB
/cks:memory --decisions      Architectural decisions
/cks:memory --gotchas        Traps and non-obvious behaviors
/cks:memory --sessions       Recent session snapshots
/cks:memory --sync           Force sync to Supabase (requires supabase_url in config)
```
