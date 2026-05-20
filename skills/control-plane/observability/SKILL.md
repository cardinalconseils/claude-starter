---
name: control-plane/observability
description: "Session cost tracking, tool-call metrics, and duration analytics for CKS v6 control plane. Covers reading totals.json, session JSON files, and surfacing cost breakdowns."
allowed-tools: [Read, Bash, Write]
---

# Control Plane — Observability / Cost Tracking

File-first session metrics. Bash hooks write `.json` files at session boundaries. Supabase sync is additive durability, session-end only.

## What Is Tracked

| Metric | Source | Accuracy |
|--------|--------|----------|
| Session duration | Stop - Start timestamps | Exact |
| Tool calls | PreToolUse counter file | Exact count |
| Session count | totals.json | Exact |
| Cumulative dev hours | Sum of duration_seconds | Exact |

**Not tracked** (Claude Code does not expose these in hooks): real token counts, per-model API costs, prompt vs completion split. Label any cost figure as "proxy estimate."

## File Paths

```
.cks/control-plane/observability/
  sessions/
    YYYY-MM-DD-HHMM.json   ← one file per session
  totals.json               ← running totals (updated at stop)
  .tool-count               ← ephemeral counter, reset each SessionStart
  .current-session-id       ← current session ID for cross-script reference
```

## Session JSON Schema

```json
{
  "session_id":       "2026-05-20-1430",
  "start_ts":         "2026-05-20T14:30:00Z",
  "end_ts":           "2026-05-20T16:15:00Z",
  "branch":           "42-fix-auth",
  "tool_calls":       87,
  "cks_commands":     0,
  "duration_seconds": 6300
}
```

## Totals JSON Schema

```json
{
  "total_sessions":         42,
  "total_duration_seconds": 189000,
  "total_tool_calls":       3654,
  "week_duration_seconds":  12600,
  "week_sessions":          3,
  "week_start":             "2026-05-14",
  "last_updated":           "2026-05-20T16:15:00Z"
}
```

## Reading Metrics

Never load all session files. Compute from `totals.json` for summaries; read individual session files only when showing per-session detail.

```bash
# Total dev hours
jq '.total_duration_seconds / 3600 | floor' .cks/control-plane/observability/totals.json

# This week sessions
jq '.week_sessions' .cks/control-plane/observability/totals.json

# Last 5 sessions
ls -t .cks/control-plane/observability/sessions/*.json 2>/dev/null | head -5
```

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I should track real token costs" | Claude Code hooks don't expose token counts. Label estimates as estimates. |
| "Load all session files for the trend" | Use totals.json for aggregates. Session files for per-session detail only. |
| "The counter file is unreliable if Claude crashes" | Yes. It's a best-effort proxy. Document this in the output. |

## Verification

- [ ] `totals.json` exists after first session stop
- [ ] Session file created at SessionStart with `end_ts: null`
- [ ] Session file finalized at Stop with real `duration_seconds`
- [ ] `.tool-count` resets to 0 at each SessionStart
- [ ] Banner line appears in session-start output (requires `jq`)
- [ ] Supabase sync skipped when `supabase_url` absent
