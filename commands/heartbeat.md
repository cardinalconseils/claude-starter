---
description: "Manage CKS v6 heartbeat agents — register a new agent or view all agents' heartbeat status"
allowed-tools:
  - Agent
---

# /cks:heartbeat — Heartbeat Engine Management

Register and monitor CKS v6 heartbeat agents.

## Routing

| Invocation | Behavior |
|------------|----------|
| `/cks:heartbeat init <agent-id>` | Register agent in DB, create schedule, write state file |
| `/cks:heartbeat init <agent-id> --interval 1800` | Same, with custom interval (seconds) |
| `/cks:heartbeat status` | Show all agents: last beat, status, cycles missed |

## Dispatch

Parse `$ARGUMENTS` for `init` or `status`.

**Mode 1 — `init <agent-id>`:**

Extract `<agent-id>` from arguments. Extract `--interval <N>` if present (default from config).

```
Agent(
  subagent_type="cks:heartbeat-agent",
  prompt="Mode: init. agent_id: <agent-id>. interval_seconds: <N or 'default'>. Read config from .cks/control-plane/config.yaml."
)
```

**Mode 2 — `status`:**

```
Agent(
  subagent_type="cks:heartbeat-agent",
  prompt="Mode: status. Read config from .cks/control-plane/config.yaml."
)
```

## Quick Reference

```
/cks:heartbeat init my-agent                  # Register with default interval
/cks:heartbeat init my-agent --interval 1800  # Register with 30-min interval
/cks:heartbeat status                         # View all agents
```
