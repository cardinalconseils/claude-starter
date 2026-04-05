# Status Packet — Machine-Readable State Protocol

## Purpose

A compressed, machine-readable snapshot of current project state. Replaces display-only dashboards with a structured format that both humans and agents can consume.

Inspired by ClawCode's "summary compression" pattern: collapse noisy state into current phase, last checkpoint, current blocker, and recommended next action.

## File Location

`.prd/status-packet.json` — overwritten on each generation (not append-only like lifecycle.jsonl).

## Schema

```json
{
  "generated_at": "2026-03-31T14:30:00.000Z",
  "feature_id": "03-backend-api",
  "prd_id": "PRD-003",
  "phase": "sprint",
  "sub_step": "3c-implementation",
  "status": "running",
  "last_checkpoint": "3b-plan-approved",
  "blocker": null,
  "recommended_action": "Run quality checks after implementation completes",
  "confidence_pct": 85,
  "last_event": "lane.started",
  "last_event_ts": "2026-03-31T14:25:00.000Z",
  "active_workers": 3,
  "gates_passed": 6,
  "gates_total": 10
}
```

## Field Reference

| Field | Type | Description |
|-------|------|-------------|
| `generated_at` | string | ISO-8601 UTC timestamp of packet generation |
| `feature_id` | string | Current feature directory name, or `null` if no active feature |
| `prd_id` | string | PRD identifier, or `null` |
| `phase` | string | `discover`, `design`, `sprint`, `review`, `release`, or `idle` |
| `sub_step` | string | Current sub-step (e.g., `3c-implementation`), or `null` |
| `status` | string | `running`, `blocked`, `completed`, `failed`, `idle` |
| `last_checkpoint` | string | Last successfully completed step |
| `blocker` | string\|null | Current blocker description, or `null` if unblocked |
| `recommended_action` | string | What should happen next |
| `confidence_pct` | number | From CONFIDENCE.md if available, or estimated (0-100) |
| `last_event` | string | Event type from lifecycle.jsonl |
| `last_event_ts` | string | Timestamp of last lifecycle event |
| `active_workers` | number | Count of dispatched workers still running |
| `gates_passed` | number | Quality gates passed so far |
| `gates_total` | number | Total applicable quality gates |

## Generation

### From hooks (session-start.sh)

```bash
source "$(dirname "$0")/lifecycle-event.sh"

# Read current state
PHASE=$(grep "^current_phase:" .prd/PRD-STATE.md 2>/dev/null | cut -d: -f2 | xargs)
FEATURE=$(grep "^active_feature:" .prd/PRD-STATE.md 2>/dev/null | cut -d: -f2 | xargs)
LAST_EVENT=$(tail -1 .prd/logs/lifecycle.jsonl 2>/dev/null | jq -r '.event // "none"')
LAST_TS=$(tail -1 .prd/logs/lifecycle.jsonl 2>/dev/null | jq -r '.timestamp // ""')

# Generate packet (use jq for safety)
jq -cn \
  --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")" \
  --arg fid "$FEATURE" \
  --arg phase "$PHASE" \
  --arg le "$LAST_EVENT" \
  --arg lt "$LAST_TS" \
  '{generated_at:$ts,feature_id:$fid,phase:($phase|if .=="" then "idle" else . end),status:"running",last_event:$le,last_event_ts:$lt}' \
  > .prd/status-packet.json
```

### From agents

Agents generating status packets should write the full JSON to `.prd/status-packet.json` using the Write tool, and emit a `status.packet` lifecycle event.

## Consumption

### By /cks:status and /cks:progress

Read `.prd/status-packet.json` and render both:
1. **Human format** — the existing dashboard display
2. **Machine format** — the raw JSON (for piping to other tools)

### By other agents

Any agent can read the status packet to understand current context without parsing PRD-STATE.md:

```
Read .prd/status-packet.json → know what phase, what's blocked, what to do next
```

### By the board (if present)

The board's sync function can consume the packet directly instead of regex-parsing PRD-STATE.md.
