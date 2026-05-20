---
description: "Show active agent sessions, claimed resources, and conflicts — multi-session coordination"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:agents — Agent Coordination Dashboard

Parse `$ARGUMENTS` for one of: `--claim <resource>`, `--release [resource]`, `--clean`.
Default to `status` mode if no argument.

Dispatch:

```
Agent(
  subagent_type="cks:coordination-agent",
  prompt="
    Mode: {parsed mode — status | claim | release | clean}
    Resource: {resource path or task ID, if provided}
    Registry: .cks/control-plane/agents/registry/
    Show active sessions, claimed resources, and any conflicts.
  "
)
```

## Quick Reference

```
/cks:agents                               Show all active sessions + conflicts
/cks:agents --claim src/auth/login.ts     Claim a resource before editing
/cks:agents --release src/auth/login.ts   Release after done
/cks:agents --release                     Release all claims for this session
/cks:agents --clean                       Sweep stale locks (dead PIDs)
```
