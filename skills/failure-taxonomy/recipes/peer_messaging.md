# Recipe: peer_messaging

## Detection Confirmation

Before applying this recipe, verify:
- Error involves peer discovery, messaging, or broker communication
- The `claude-peers` MCP server was expected to be available
- This is NOT an MCP startup failure (use `mcp_startup` recipe for that)

## Auto-Recovery Steps

### Step 1: Identify the failure point

| Failure | Signal | Component |
|---------|--------|-----------|
| Broker unreachable | `ECONNREFUSED` on port 7899 | Broker daemon |
| No peers found | `list_peers` returns empty | Normal state — not an error |
| Message not delivered | `send_message` returns error | Broker or target peer |
| Peer went offline | Peer disappears from `list_peers` | Target peer process |
| Channel push failed | Messages arrive only via polling | Claude Code channel system |

### Step 2: Classify and recover

| Subtype | Auto-Fix? | Action |
|---------|-----------|--------|
| Broker unreachable | No | Fall back to single-session mode. Do not attempt to start broker. |
| Peer offline | Partial | Wait 60s, re-check `list_peers`. If still gone, reassign task locally. |
| Message delivery error | Yes | Retry once. If still failing, fall back to single-session. |
| Channel push degraded | Yes | Use `check_messages` polling as fallback — messages still arrive. |

### Step 3: Enter degraded mode

When peer messaging cannot be recovered:
1. Switch to single-session operation (subagents instead of peers)
2. Announce: "Peer coordination unavailable — continuing in single-session mode"
3. Emit `recovery.degraded` with lost capability: "cross-session coordination"

## Degraded Mode Behavior

| Lost Capability | Impact | Fallback |
|----------------|--------|----------|
| Peer discovery | Cannot find other sessions | All work stays in current session |
| Peer messaging | Cannot distribute tasks | Use subagent dispatch instead |
| Status sharing | Peers don't know your state | No impact on local work |
| Multi-session sprint | Cannot parallelize across terminals | Normal subagent parallelism |

**Key principle**: Peer unavailability is NEVER a blocker. Every peer-aware workflow has a single-session fallback that produces identical results (just potentially slower).

## Escalation

Only escalate to user if:
- User explicitly requested multi-session work and it's not possible
- A peer was mid-task when it disconnected and partial work may need manual merge

Report format:
```
Peer Issue: {broker_unreachable / peer_offline / delivery_failed}
Attempted: {retry / wait / nothing}
Impact: {lost capability}
Fallback: Single-session mode (automatic)
Action needed: {none — already degraded / check peer terminal / restart broker}
```
