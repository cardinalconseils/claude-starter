# Design Spec: CKS Lifecycle Structured Logging

**Date:** 2026-03-27
**Status:** Approved
**Scope:** Add structured JSONL logging to all CKS lifecycle phases, plus a `/cks:logs` query command

## Problem

CKS tracks state (PRD-STATE.md) and session snapshots (.learnings/) but has no structured event logging. When a phase fails, there's no audit trail of what happened. There's no way to measure velocity, trace decisions, or understand the full history of a feature lifecycle across sessions.

## Solution

Structured JSONL event logging emitted at every lifecycle phase, agent dispatch, user decision, and artifact creation. Stored in `.prd/logs/`, queryable via `/cks:logs`.

## Event Schema

Every CKS action emits a JSON event (one per line in JSONL format):

```json
{
  "timestamp": "2026-03-27T22:15:00.000Z",
  "severity": "INFO",
  "event": "phase.discover.started",
  "feature_id": "01-backend-api",
  "session_id": "2026-03-27T22:15",
  "metadata": {},
  "message": "Discovery phase started for feature 01-backend-api"
}
```

**Derived fields:** `phase` and `sub_step` are not stored — they are parsed from `event` at query time (e.g., `phase.discover.started` → phase=`discover`). This avoids redundancy and keeps the stored schema lean.

### Field Reference

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `timestamp` | ISO 8601 | Yes | UTC timestamp of the event |
| `severity` | enum | Yes | `INFO`, `WARN`, `ERROR` |
| `event` | string | Yes | Dot-notation event type (see Event Catalog) |
| `feature_id` | string | Yes | Phase ID + name (e.g., `01-backend-api`). Use `_project` for project-level events |
| `session_id` | string | Yes | Session identifier (ISO date + time of session start) |
| `phase` | string | No | Derived at query time from `event` field (e.g., `phase.discover.started` → `discover`). Not stored in JSONL. |
| `sub_step` | string | No | Derived at query time from `event` field (e.g., `step.1a.started` → `1a`). Not stored in JSONL. |
| `agent` | string | No | Agent name if an agent was dispatched (e.g., `prd-discoverer`). Passed via metadata. |
| `duration_ms` | number | No | Duration in milliseconds. Only meaningful for synchronous bash operations. Always `null` for events surrounding async agent dispatches — duration cannot be captured across separate processes. |
| `metadata` | object | No | Event-specific key-value data |
| `message` | string | Yes | Human-readable description of the event |

### Naming Conventions (OpenTelemetry-inspired)

- Field names use `snake_case`
- Event types use `dot.notation` with category first
- Timestamps are always UTC ISO 8601
- Severity uses standard syslog levels (INFO, WARN, ERROR)
- Correlation via `feature_id` (across sessions) and `session_id` (within session)

## Event Catalog

### Phase Events

| Event | Severity | When | Metadata |
|-------|----------|------|----------|
| `phase.{name}.started` | INFO | Phase begins | `{elements_count, prior_state}` |
| `phase.{name}.completed` | INFO | Phase finishes successfully | `{duration_ms, artifacts_created}` |
| `phase.{name}.failed` | ERROR | Phase fails | `{error, retry_count}` |
| `phase.{name}.resumed` | INFO | Phase resumed from prior session | `{prior_session_id, sub_step}` |

### Sub-Step Events

| Event | Severity | When | Metadata |
|-------|----------|------|----------|
| `step.{id}.started` | INFO | Sub-step begins (e.g., `step.1a.started`) | `{step_name}` |
| `step.{id}.completed` | INFO | Sub-step finishes | `{duration_ms}` |
| `step.{id}.skipped` | INFO | Sub-step skipped (e.g., single-SP fallback) | `{reason}` |

### Agent Events

| Event | Severity | When | Metadata |
|-------|----------|------|----------|
| `agent.dispatched` | INFO | Agent launched | `{agent_name, prompt_summary}` |
| `agent.completed` | INFO | Agent returned | `{agent_name, duration_ms, output_summary}` |
| `agent.failed` | ERROR | Agent errored | `{agent_name, error}` |

### User Decision Events

| Event | Severity | When | Metadata |
|-------|----------|------|----------|
| `user.decision` | INFO | AskUserQuestion answered | `{question_header, selected_options, custom_input}` |
| `user.approval` | INFO | User approved artifact/phase | `{what_approved}` |
| `user.rejection` | INFO | User requested changes | `{what_rejected, reason}` |

### Artifact Events

| Event | Severity | When | Metadata |
|-------|----------|------|----------|
| `artifact.created` | INFO | File written | `{path, type, size_bytes}` |
| `artifact.updated` | INFO | File modified | `{path, type, changes_summary}` |
| `artifact.validated` | INFO | Validation passed | `{path, checks_passed}` |
| `artifact.validation_failed` | WARN | Validation failed | `{path, checks_failed, missing}` |

### State Events

| Event | Severity | When | Metadata |
|-------|----------|------|----------|
| `state.transition` | INFO | PRD-STATE.md updated | `{from_status, to_status}` |
| `state.iteration` | INFO | Iteration loop triggered | `{from_phase, to_phase, reason}` |

### Feature Events

| Event | Severity | When | Metadata |
|-------|----------|------|----------|
| `feature.created` | INFO | `/cks:new` creates a feature entry | `{feature_id, name, brief}` |
| `feature.completed` | INFO | Feature released or abandoned | `{feature_id, total_duration_ms, phases_completed}` |

### Kickstart Events

| Event | Severity | When | Metadata |
|-------|----------|------|----------|
| `kickstart.phase.started` | INFO | Kickstart phase begins | `{phase_number, phase_name}` |
| `kickstart.phase.completed` | INFO | Kickstart phase ends | `{phase_number, duration_ms, output}` |
| `kickstart.phase.skipped` | INFO | Optional phase skipped | `{phase_number, phase_name}` |
| `kickstart.compose.sub_project` | INFO | Sub-project identified | `{sp_id, name, type, priority}` |

## File Structure

```
.prd/logs/
├── lifecycle.jsonl              # Master log — all events, append-only
├── features/
│   ├── 01-backend-api.jsonl     # Per-feature extract (created on feature completion)
│   └── 02-admin-panel.jsonl
└── metrics.json                 # Aggregated velocity metrics
```

### lifecycle.jsonl

The master log file. Every event is appended here as it happens. Never truncated during a project — only archived if it grows very large.

### Per-Feature Logs

Feature-level filtering is done at query time via `/cks:logs --feature {id}`, which greps `lifecycle.jsonl` for matching `feature_id`. For local CLI usage, lifecycle.jsonl will be kilobytes to low megabytes — full scans are instant. Per-feature extract files (`features/{feature_id}.jsonl`) are an optional optimization generated by `/cks:logs --extract {feature_id}` for archival purposes.

### metrics.json

Computed lazily when `/cks:logs --metrics` is run (not maintained as a live aggregate). The command scans `lifecycle.jsonl`, computes stats, and caches the result to `metrics.json` for fast re-reads. The cache is invalidated when `lifecycle.jsonl` is newer than `metrics.json`.

```json
{
  "updated": "2026-03-27T22:30:00Z",
  "features": {
    "01-backend-api": {
      "started": "2026-03-27T10:00:00Z",
      "completed": "2026-03-28T14:00:00Z",
      "total_duration_ms": 100800000,
      "phases": {
        "discover": { "duration_ms": 3600000, "iterations": 0 },
        "design": { "duration_ms": 7200000, "iterations": 1 },
        "sprint": { "duration_ms": 72000000, "iterations": 2 },
        "review": { "duration_ms": 3600000, "iterations": 0 },
        "release": { "duration_ms": 14400000, "iterations": 0 }
      },
      "total_iterations": 3,
      "agents_dispatched": 12,
      "user_decisions": 28,
      "artifacts_created": 15
    }
  },
  "velocity": {
    "avg_feature_duration_ms": 100800000,
    "avg_discover_ms": 3600000,
    "avg_sprint_ms": 72000000,
    "features_completed": 1,
    "features_in_progress": 2
  }
}
```

## Logging Utility

A shared bash script (`scripts/cks-log.sh`) that all workflows call. Requires `jq` for safe JSON encoding (available on all macOS/Linux dev environments, and already a common dev dependency alongside `git`, `node`, etc.):

```bash
#!/bin/bash
# scripts/cks-log.sh — Append a structured event to .prd/logs/lifecycle.jsonl
#
# Usage: bash scripts/cks-log.sh <severity> <event> <feature_id> <message> [metadata_json]
#
# Example:
#   bash scripts/cks-log.sh INFO "phase.discover.started" "01-backend-api" "Discovery started" '{"elements":0}'

SEVERITY="$1"
EVENT="$2"
FEATURE_ID="$3"
MESSAGE="$4"
METADATA="${5:-{}}"

mkdir -p .prd/logs

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")

# Session ID: read from file (written by session-start hook), fallback to timestamp
SESSION_ID_FILE=".prd/logs/.current_session_id"
if [ -f "$SESSION_ID_FILE" ]; then
  SESSION_ID=$(cat "$SESSION_ID_FILE")
else
  SESSION_ID=$(date -u +"%Y-%m-%dT%H:%M")
fi

# Build JSON event safely using jq (handles special chars in message/metadata)
jq -cn \
  --arg ts "$TIMESTAMP" \
  --arg sev "$SEVERITY" \
  --arg evt "$EVENT" \
  --arg fid "$FEATURE_ID" \
  --arg sid "$SESSION_ID" \
  --argjson meta "$METADATA" \
  --arg msg "$MESSAGE" \
  '{timestamp:$ts, severity:$sev, event:$evt, feature_id:$fid, session_id:$sid, metadata:$meta, message:$msg}' \
  >> .prd/logs/lifecycle.jsonl
```

**Dependency:** `jq` is required. If not installed, the script fails with a clear error rather than producing malformed JSON. This is intentional — broken logs are worse than no logs.

### Workflow Integration Pattern

Each workflow step-file includes log calls at start and end:

```markdown
## Step N: {Step Name}

**Log:** `bash ${PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.{id}.started" "{feature_id}" "{step description}"`

{... step instructions ...}

**Log:** `bash ${PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.{id}.completed" "{feature_id}" "{step result}" '{"duration_ms":{N}}'`
```

## /cks:logs Command

A new command (`commands/logs.md`) for querying and viewing logs.

### Usage

```
/cks:logs                    # Show recent events (last 20)
/cks:logs --feature 01       # Filter by feature
/cks:logs --phase discover   # Filter by phase
/cks:logs --severity ERROR   # Filter by severity
/cks:logs --since 2026-03-27 # Filter by date
/cks:logs --metrics          # Show velocity metrics dashboard
/cks:logs --summary          # Human-readable summary of recent activity
```

### Metrics Dashboard (--metrics)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 CKS METRICS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Features: 3 completed | 1 in progress
 Avg Feature Duration: 28h

 Phase Averages:
   Discover:  1.0h  ████░░░░░░░░░░░░░░░░
   Design:    2.0h  ████████░░░░░░░░░░░░
   Sprint:   20.0h  ████████████████████
   Review:    1.0h  ████░░░░░░░░░░░░░░░░
   Release:   4.0h  ████████░░░░░░░░░░░░

 Iterations: 3 avg per feature (most in sprint)
 Decisions: 28 avg user decisions per feature

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Integration Points

Every workflow step-file that needs logging:

| File | Events Emitted |
|------|---------------|
| `skills/prd/workflows/discover-phase.md` (orchestrator) | `phase.discover.started/completed` |
| `skills/prd/workflows/discover-phase/step-*.md` (each step) | `step.{id}.started/completed` |
| `skills/prd/workflows/design-phase.md` | `phase.design.started/completed` |
| `skills/prd/workflows/sprint-phase.md` | `phase.sprint.started/completed`, sub-steps |
| `skills/prd/workflows/review-phase.md` | `phase.review.started/completed` |
| `skills/prd/workflows/release-phase.md` | `phase.release.started/completed` |
| `skills/kickstart/SKILL.md` | `kickstart.phase.started/completed/skipped` |
| `skills/kickstart/workflows/*.md` | Per-kickstart-phase events |
| `commands/new.md` | `feature.created` |
| Agent dispatch points | `agent.dispatched/completed/failed` |
| AskUserQuestion calls | `user.decision` (logged by workflow, not by tool) |

## Files to Create

| File | Purpose |
|------|---------|
| `scripts/cks-log.sh` | Logging utility script |
| `commands/logs.md` | `/cks:logs` query command |
| `skills/prd/references/logging-events.md` | Event catalog reference for workflow authors |

## Files to Modify

| File | Change |
|------|--------|
| All workflow step-files in `skills/prd/workflows/` | Add log calls at step boundaries |
| All kickstart workflow files in `skills/kickstart/workflows/` | Add log calls at phase boundaries |
| `commands/new.md` | Log feature creation |
| `skills/prd/SKILL.md` | Document `.prd/logs/` in file system section, add `/cks:logs` to commands |
| `hooks/handlers/session-start.sh` | Write session ID to `.prd/logs/.current_session_id` file for correlation (env vars don't propagate from hook subprocesses) |

## Design Decisions

1. **JSONL over SQLite/DB** — Zero dependencies beyond `jq`, greppable, git-friendly, standard format
2. **`jq` for JSON encoding** — `printf` cannot safely produce JSON from arbitrary strings (messages with quotes, backslashes, newlines). `jq` is ubiquitous on dev machines and produces correct output. The dependency is worth it.
3. **Bash utility over inline** — Single source of truth for log format, easy to change
4. **Workflow-level logging, not agent-level** — Agents run in subprocesses with limited context; the orchestrating workflow knows more context and can log before/after dispatch
5. **File-based session ID** — Hook subprocesses can't export env vars to the Claude process. Writing `.prd/logs/.current_session_id` solves session correlation reliably.
6. **`duration_ms` only for synchronous operations** — Agent dispatches run in separate processes across indeterminate time. Duration is only meaningful for atomic bash operations, not for events that bracket async agent work.
7. **Derived fields (`phase`, `sub_step`) not stored** — Parsed from `event` at query time to keep stored schema lean and avoid redundancy
8. **Lazy metrics computation** — Scanning a local JSONL file is instant; maintaining a live aggregate adds complexity for no benefit
9. **OpenTelemetry naming** — Future-proof; if you ever want to ship logs to Datadog/Grafana, the field names already match

## What This Does NOT Include

- Real-time log streaming (not needed for CLI tool)
- Log rotation/archival (can be added later if lifecycle.jsonl grows large)
- Application-level logging for scaffolded projects (separate concern)
- External log shipping (Datadog, ELK, etc.) — but JSONL format is compatible
