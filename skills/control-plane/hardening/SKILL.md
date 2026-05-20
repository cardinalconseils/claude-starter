---
name: control-plane/hardening
description: "Production hardening patterns for CKS v6 control plane — health checks, graceful degradation, sync-queue, backup/restore, and reset"
allowed-tools: [Read, Bash]
---

# Control Plane Hardening

Production-grade operation of the CKS v6 control plane layer.

## Component Map

| Component | Files | Health Signal |
|-----------|-------|---------------|
| Config | `.cks/control-plane/config.yaml` | Present/absent |
| Memory dirs | `.cks/control-plane/memory/{project,sessions,agents}/` | Exist — auto-recreate if missing |
| Heartbeat state | `.cks/control-plane/heartbeat/state/*.json` | Count of registered agents |
| Supabase | `supabase_url` in config → curl HEAD check | 200/401 = reachable; else degrade |
| Sync queue | `.cks/control-plane/sync-queue/*.json` | Count = backlog depth |
| Stale locks | `find .cks/control-plane -name '*.lock' -mmin +5` | >0 = warn |

## Graceful Degradation Rules

1. **Missing config.yaml** → show error in banner, block no operation, suggest init
2. **Missing memory dirs** → auto-recreate silently (never fail)
3. **Supabase unreachable** → write payload to sync-queue, log to errors.log, continue
4. **Sync-queue non-empty at session stop** → drain attempted once; remaining items persist
5. **Stale locks** → warn only; never auto-delete (user intervention required)

## Sync-Queue Schema

Each file in `.cks/control-plane/sync-queue/failed-{timestamp_ms}.json` contains the exact POST body for `POST /rest/v1/memory`. The drain script replays it verbatim with `Prefer: resolution=merge-duplicates`.

## Backup Naming

```
.cks/backups/control-plane-YYYY-MM-DD-HHMM.tar.gz
```

Before any destructive operation (`--reset`, `--restore`), the agent MUST take a fresh backup.

## Health JSON Schema

`.cks/control-plane/health/latest.json`:

```json
{
  "timestamp": "2026-05-20T14:32:00Z",
  "overall": "ok | degraded",
  "components": [
    { "component": "config",   "status": "ok | warn | error", "detail": "..." },
    { "component": "sync-queue", "status": "warn", "detail": "3 item(s) queued" }
  ]
}
```

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Supabase is flaky — I'll skip the sync-queue and just log a warning" | Silent drops cause invisible data loss. Queue and drain — the retry is automatic. |
| "The health check runs on every session — it slows things down" | It's 6 bash checks with no LLM. Runtime is <200ms. Always run it. |
| "I'll reset without a backup — I can reconstruct the memory" | You can't. Session snapshots and KB entries take weeks to accumulate. Always backup first. |
| "Stale locks are harmless — I'll auto-delete them" | Stale locks may indicate a crashed session with in-flight writes. Warn; let the human decide. |

## Verification

- [ ] `control-plane-health.sh` exits 0 even when config.yaml is missing
- [ ] `memory-sync.sh` writes to sync-queue on curl failure
- [ ] `control-plane-drain.sh` removes queue files only on confirmed HTTP 200/201
- [ ] `--reset` mode always runs `--backup` first, before deletion
- [ ] `--restore` mode shows destructive-ops warning before running restore script
- [ ] Session banner shows sync-queue depth only when > 0
