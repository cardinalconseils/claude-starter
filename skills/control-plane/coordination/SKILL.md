---
name: control-plane/coordination
description: "File-based agent registry for multi-session coordination — claim resources, detect conflicts, clean stale locks"
allowed-tools: [Read, Bash, Write]
---

# Control Plane — Agent Coordination (Phase 3)

File-based presence registry for multi-session conflict detection.

## Registry Location

`.cks/control-plane/agents/registry/` — one `.lock` file per active session.

## Lock File Format

```json
{
  "session_id": "abc123",
  "pid": 45678,
  "task": "Implementing feature F-007 auth flow",
  "registered_at": "2026-05-20T14:00:00Z",
  "updated_at": "2026-05-20T14:32:00Z",
  "claimed_resources": [
    "src/auth/login.ts",
    "src/auth/session.ts",
    "task:T-007"
  ]
}
```

## Session ID

Session ID sourced from (priority order):
1. `$CKS_SESSION_ID` environment variable (set by hooks)
2. `cat .prd/logs/.current_session_id`
3. Fallback: `date +%Y%m%d-%H%M%S`

## Registry Operations (via `scripts/agent-registry.sh`)

| Operation | Command | When |
|-----------|---------|------|
| Register presence | `agent-registry.sh register <sid> "<task>"` | Session start (if CP active) |
| Claim a resource | `agent-registry.sh claim <sid> <resource>` | Before writing any shared file |
| Release a resource | `agent-registry.sh release <sid> <resource>` | After write completes |
| Release all | `agent-registry.sh release <sid>` | Session end |
| List active sessions | `agent-registry.sh list` | `/cks:agents` command |
| Clean stale locks | `agent-registry.sh clean` | Session start (before register) |

## Stale Lock Detection

A lock is stale when its PID is no longer alive:
```bash
kill -0 <pid> 2>/dev/null  # returns 1 if dead
```

`agent-registry.sh list` auto-cleans stale locks while listing.

## Conflict Detection

A conflict exists when two active lock files contain the same resource in `claimed_resources`:

```bash
cat .cks/control-plane/agents/registry/*.lock | jq -r '.claimed_resources[]' 2>/dev/null | sort | uniq -d
```

Any duplicate = conflict. Surface with owning session IDs.

## Supabase Sync

Same gate as memory-sync:
- `supabase_url` in `config.yaml` → `sync-agent-sessions.sh start` on session-start, `end` on session-end
- Absent → zero calls

## File Paths Reference

```
.cks/control-plane/agents/
  registry/
    {session-id}.lock     ← one per active session
```

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Two sessions won't edit the same file" | They will. Parallel sprints on the same feature always converge on shared files. |
| "Stale locks will block new sessions" | They won't — PID check auto-cleans dead locks on every list/clean call. |
| "File locking is unreliable" | We don't use OS-level locks. Presence + awareness is sufficient. |
| "I'll check for conflicts after writing" | Check before. Post-write conflict resolution is merge debt. |

## Verification

- [ ] Lock file written on session-start when control plane active
- [ ] Lock file removed on session-end
- [ ] `agent-registry.sh list` shows only sessions with live PIDs
- [ ] `agent-registry.sh list` auto-removes stale locks
- [ ] `/cks:agents` shows clean table of active sessions
- [ ] Conflict detection flags when two locks share a resource
