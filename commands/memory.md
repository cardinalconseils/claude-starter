---
description: "View and manage project memory — facts, decisions, gotchas, session snapshots, global memory"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:memory — Project Memory

Parse `$ARGUMENTS` for the mode flag.

If `$ARGUMENTS` contains `--global`, dispatch the global memory writer:

```
Agent(
  subagent_type="cks:global-memory-writer",
  prompt="
    Arguments: {$ARGUMENTS}
    Write a global memory entry to ~/.cks/memory/user/.
    Confirm target file and content with the user before writing.
  "
)
```

Otherwise, parse for one of: `--facts`, `--decisions`, `--gotchas`, `--sessions`, `--sync`.
Default to summary if no flag provided.

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
/cks:memory --global "text"  Write cross-project learning to ~/.cks/memory/user/
```
