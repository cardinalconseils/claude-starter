---
description: "Show session cost breakdown, dev time, and tool-call metrics from control plane observability"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:cost — Development Cost & Observability

Parse `$ARGUMENTS`:
- No args → `summary` mode
- `--sessions` → `sessions` mode
- `--trends` → `trends` mode
- `--session <ID>` → `session` mode, pass the ID

Dispatch:

```
Agent(
  subagent_type="cks:observability-agent",
  prompt="
    Mode: {parsed mode}
    Session ID: {ID if --session flag, else empty}
    Observability base: .cks/control-plane/observability/
    Show the requested metrics view.
  "
)
```

## Quick Reference

```
/cks:cost                        Summary — sessions, dev hours, tool calls
/cks:cost --sessions             Last 10 sessions with duration + tool calls
/cks:cost --trends               7-session trend: avg duration, avg tool calls
/cks:cost --session 2026-05-20-1430   Single session detail
```
