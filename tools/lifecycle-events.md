# Lifecycle Events — Extended Event Schema

This extends `lifecycle-log.md` with lane-level, failure, and recovery events inspired by ClawCode's event-native architecture.

## Base Schema

Same as `lifecycle-log.md` — all events are JSONL in `.prd/logs/lifecycle.jsonl` with the 7 required fields: `timestamp`, `severity`, `event`, `feature_id`, `session_id`, `metadata`, `message`.

## Extended Event Types

### Lane Events (fine-grained progress within a phase)

| Event | When | Metadata |
|-------|------|----------|
| `lane.started` | A work lane (task group / worker) begins | `{ "lane_id": "...", "tasks": [...] }` |
| `lane.ready` | Worker loaded context and is executing | `{ "lane_id": "..." }` |
| `lane.blocked` | Worker hit a blocker | `{ "lane_id": "...", "blocker": "..." }` |
| `lane.green` | Worker's tasks pass quality checks | `{ "lane_id": "...", "checks": "build+lint+test" }` |
| `lane.red` | Worker's tasks fail quality checks | `{ "lane_id": "...", "failing_checks": [...] }` |
| `lane.completed` | Worker finished all tasks | `{ "lane_id": "...", "files_changed": N }` |

### Commit/PR Events

| Event | When | Metadata |
|-------|------|----------|
| `lane.commit.created` | Code committed during a lane | `{ "sha": "...", "message": "..." }` |
| `lane.pr.opened` | Pull request created | `{ "pr_number": N, "url": "..." }` |
| `lane.merge.ready` | PR passes all checks and is merge-ready | `{ "pr_number": N }` |

### Failure Events

| Event | When | Metadata |
|-------|------|----------|
| `failure.classified` | A failure has been categorized | `{ "failure_type": "compile\|test\|branch_divergence\|trust_gate\|mcp_startup\|plugin_startup\|infra\|prompt_delivery", "severity": "blocking\|degraded", "signal": "...", "source_file": "...", "auto_recoverable": true\|false }` |

### Recovery Events

| Event | When | Metadata |
|-------|------|----------|
| `recovery.attempted` | Auto-recovery recipe started | `{ "failure_type": "...", "recipe": "..." }` |
| `recovery.succeeded` | Recovery fixed the issue | `{ "failure_type": "...", "action_taken": "..." }` |
| `recovery.degraded` | Continued with reduced capability | `{ "failure_type": "...", "lost_capability": "..." }` |
| `recovery.escalated` | Recovery failed, needs human | `{ "failure_type": "...", "reason": "..." }` |

### Status Events

| Event | When | Metadata |
|-------|------|----------|
| `status.packet` | Status snapshot generated | `{ "phase": "...", "checkpoint": "...", "blocker": null\|"...", "recommended_action": "...", "confidence_pct": N }` |

## Backward Compatibility

All existing events from `lifecycle-log.md` remain valid:
- `phase.*.started`, `phase.*.completed`
- `gate.pass`, `gate.fail`
- `iteration.back`, `migration`
- `session.start`, `session.end`

New events coexist alongside existing ones. Consumers that only parse `phase.*` events are unaffected.

## Emitter

Use `hooks/handlers/lifecycle-event.sh` to emit events from hook scripts:

```bash
source "$(dirname "$0")/lifecycle-event.sh"
emit_event "INFO" "lane.started" "03-backend-api" '{"lane_id":"worker-1","tasks":["T1","T2"]}' "Worker 1 started"
```

Agents should emit events by appending JSONL directly via the Write tool.
