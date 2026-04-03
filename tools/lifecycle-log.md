# Lifecycle Log — Event Logging Protocol

## File Location

`.prd/logs/lifecycle.jsonl` — append-only, newline-delimited JSON.

## Event Schema

Every line is a single JSON object:

```json
{
  "timestamp": "2026-04-02T14:30:00.000Z",
  "severity": "INFO",
  "event": "phase.sprint.started",
  "feature_id": "03-backend-api",
  "session_id": "2026-04-02T14:30",
  "metadata": { "tasks": 4, "estimated_hours": 6 },
  "message": "Sprint planning complete, 4 tasks queued"
}
```

## Field Reference

| Field | Type | Values |
|-------|------|--------|
| `timestamp` | string | ISO-8601 UTC: `YYYY-MM-DDTHH:MM:SS.000Z` |
| `severity` | string | `INFO`, `WARN`, `ERROR` |
| `event` | string | Dot-notation event type (see below) |
| `feature_id` | string | Feature directory name or `system` |
| `session_id` | string | From `.prd/logs/.current_session_id` or `migration` |
| `metadata` | object | Event-specific key/value pairs |
| `message` | string | Human-readable description |

## Event Types

| Event | When |
|-------|------|
| `phase.discover.started` | Phase 1 begins |
| `phase.discover.completed` | Phase 1 done |
| `phase.design.started` | Phase 2 begins |
| `phase.design.completed` | Phase 2 done |
| `phase.sprint.started` | Phase 3 begins |
| `phase.sprint.completed` | Phase 3 done |
| `phase.review.started` | Phase 4 begins |
| `phase.review.completed` | Phase 4 done |
| `phase.release.started` | Phase 5 begins |
| `phase.release.completed` | Phase 5 done |
| `gate.pass` | Quality gate passed |
| `gate.fail` | Quality gate failed |
| `iteration.back` | Looping back to earlier phase |
| `migration` | State file migration applied |
| `session.start` | Session opened |
| `session.end` | Session closed |

## Writing Events

**With jq (preferred):**
```bash
jq -cn \
  --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")" \
  --arg sev "INFO" \
  --arg evt "phase.sprint.started" \
  --arg fid "03-backend-api" \
  --arg sid "$(cat .prd/logs/.current_session_id 2>/dev/null || date -u +"%Y-%m-%dT%H:%M")" \
  --argjson meta '{"tasks":4}' \
  --arg msg "Sprint started" \
  '{timestamp:$ts,severity:$sev,event:$evt,feature_id:$fid,session_id:$sid,metadata:$meta,message:$msg}' \
  >> .prd/logs/lifecycle.jsonl
```

**From an agent (Write tool):** Append a single JSON line. Ensure valid JSON — no trailing commas, no line breaks within the object.

## Reading Events

**Last N events:**
```bash
tail -n 20 .prd/logs/lifecycle.jsonl | jq .
```

**Filter by event type:**
```bash
grep '"event":"phase.sprint' .prd/logs/lifecycle.jsonl | jq .
```

## Constraints

- **Append-only** — never overwrite, reorder, or delete entries
- **One JSON object per line** — no pretty-printing, no multi-line entries
- **Always include all 7 fields** — no optional fields
- `metadata` can be `{}` but must be present
