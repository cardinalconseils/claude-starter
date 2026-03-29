# CKS Lifecycle Structured Logging — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add structured JSONL event logging to all CKS lifecycle phases with a `/cks:logs` query command.

**Architecture:** A shared bash utility (`scripts/cks-log.sh`) appends JSON events to `.prd/logs/lifecycle.jsonl`. Each workflow step-file calls this utility at start/end. A `/cks:logs` command reads and filters the JSONL. Session correlation via file-based session ID written by the session-start hook.

**Tech Stack:** Bash, `jq` (JSON encoding), JSONL (storage format), markdown workflow files

**Spec:** `docs/superpowers/specs/2026-03-27-lifecycle-logging-design.md`

---

## File Structure

### New Files
| File | Responsibility |
|------|---------------|
| `scripts/cks-log.sh` | Logging utility — accepts severity/event/feature_id/message/metadata, writes JSONL |
| `commands/logs.md` | `/cks:logs` command — reads, filters, and displays log events |
| `skills/prd/references/logging-events.md` | Event catalog reference for workflow authors |

### Modified Files
| File | Change |
|------|--------|
| `hooks/handlers/session-start.sh` | Write session ID to `.prd/logs/.current_session_id` |
| `skills/prd/workflows/discover-phase.md` | Add phase start/complete log calls |
| `skills/prd/workflows/discover-phase/step-*.md` (8 files) | Add step start/complete log calls |
| `skills/prd/workflows/design-phase.md` | Add phase start/complete log calls |
| `skills/prd/workflows/sprint-phase.md` | Add phase start/complete + sub-step log calls |
| `skills/prd/workflows/review-phase.md` | Add phase start/complete log calls |
| `skills/prd/workflows/release-phase.md` | Add phase start/complete log calls |
| `skills/kickstart/SKILL.md` | Add kickstart phase log calls in Phase 1-6 sections |
| `skills/kickstart/workflows/intake.md` | Add phase start/complete log calls |
| `skills/kickstart/workflows/compose.md` | Add phase start/complete log calls |
| `skills/kickstart/workflows/research.md` | Add phase start/complete log calls |
| `skills/kickstart/workflows/brand.md` | Add phase start/complete log calls |
| `skills/kickstart/workflows/design.md` | Add phase start/complete log calls |
| `skills/kickstart/workflows/handoff.md` | Add phase start/complete log calls |
| `commands/new.md` | Add `feature.created` log call |
| `skills/prd/SKILL.md` | Add `.prd/logs/` to file system docs, add `/cks:logs` to commands table |
| `.gitignore` | Add `.prd/logs/.current_session_id` |

---

## Chunk 1: Core Infrastructure

### Task 1: Create the logging utility script

**Files:**
- Create: `scripts/cks-log.sh`

- [ ] **Step 1: Create `scripts/cks-log.sh`**

```bash
#!/bin/bash
# scripts/cks-log.sh — Append a structured event to .prd/logs/lifecycle.jsonl
#
# Usage: bash scripts/cks-log.sh <severity> <event> <feature_id> <message> [metadata_json]
#
# Example:
#   bash scripts/cks-log.sh INFO "phase.discover.started" "01-backend-api" "Discovery started" '{"elements":0}'

set -euo pipefail

SEVERITY="${1:?Usage: cks-log.sh <severity> <event> <feature_id> <message> [metadata_json]}"
EVENT="${2:?Missing event}"
FEATURE_ID="${3:?Missing feature_id}"
MESSAGE="${4:?Missing message}"
METADATA="${5:-{}}"

# Validate severity
case "$SEVERITY" in
  INFO|WARN|ERROR) ;;
  *) echo "cks-log: invalid severity '$SEVERITY' (use INFO, WARN, ERROR)" >&2; exit 1 ;;
esac

# Validate jq is available
if ! command -v jq &>/dev/null; then
  echo "cks-log: jq is required but not installed. Install via: brew install jq" >&2
  exit 1
fi

mkdir -p .prd/logs

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")

# Session ID: read from file (written by session-start hook), fallback to timestamp
SESSION_ID_FILE=".prd/logs/.current_session_id"
if [ -f "$SESSION_ID_FILE" ]; then
  SESSION_ID=$(cat "$SESSION_ID_FILE")
else
  SESSION_ID=$(date -u +"%Y-%m-%dT%H:%M")
fi

# Build JSON event safely using jq
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

- [ ] **Step 2: Make executable**

```bash
chmod +x scripts/cks-log.sh
```

- [ ] **Step 3: Test the utility**

```bash
bash scripts/cks-log.sh INFO "test.event" "_test" "Test message" '{"key":"value"}'
cat .prd/logs/lifecycle.jsonl | jq .
```

Expected: Valid JSON with all fields populated. Then clean up:
```bash
rm .prd/logs/lifecycle.jsonl
```

- [ ] **Step 4: Commit**

```bash
git add scripts/cks-log.sh
git commit -m "feat: add cks-log.sh structured logging utility"
```

---

### Task 2: Update session-start hook for session ID

**Files:**
- Modify: `hooks/handlers/session-start.sh`
- Modify: `.gitignore`

- [ ] **Step 1: Add session ID file write to session-start.sh**

At the top of the script (after the shebang), add:

```bash
# Write session ID for log correlation
mkdir -p .prd/logs
date -u +"%Y-%m-%dT%H:%M" > .prd/logs/.current_session_id
```

- [ ] **Step 2: Add `.current_session_id` to .gitignore**

Append to `.gitignore`:
```
.prd/logs/.current_session_id
```

- [ ] **Step 3: Commit**

```bash
git add hooks/handlers/session-start.sh .gitignore
git commit -m "feat: write session ID file for log correlation in session-start hook"
```

---

### Task 3: Create the event catalog reference

**Files:**
- Create: `skills/prd/references/logging-events.md`

- [ ] **Step 1: Create the reference file**

This is a compact reference for workflow authors. Copy the Event Catalog section from the spec (`docs/superpowers/specs/2026-03-27-lifecycle-logging-design.md` lines 57-122) into `skills/prd/references/logging-events.md`, prefixed with a usage guide:

```markdown
# CKS Logging Event Catalog

Reference for workflow authors. Use `${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh` to emit events.

## Usage

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh <severity> <event> <feature_id> <message> [metadata_json]
```

## Quick Reference

| Pattern | Example | When |
|---------|---------|------|
| `phase.{name}.started` | `phase.discover.started` | Phase begins |
| `phase.{name}.completed` | `phase.discover.completed` | Phase ends successfully |
| `step.{id}.started` | `step.1a.started` | Sub-step begins |
| `step.{id}.completed` | `step.1a.completed` | Sub-step ends |
| `agent.dispatched` | — | Agent launched |
| `agent.completed` | — | Agent returned |
| `user.decision` | — | AskUserQuestion answered |
| `artifact.created` | — | File written |
| `state.transition` | — | PRD-STATE.md updated |
| `feature.created` | — | /cks:new creates feature |
| `kickstart.phase.started` | — | Kickstart phase begins |

## Full Event Catalog

{Include the full event tables from the spec here}
```

- [ ] **Step 2: Commit**

```bash
git add skills/prd/references/logging-events.md
git commit -m "docs: add logging event catalog reference for workflow authors"
```

---

### Task 4: Create `/cks:logs` command

**Files:**
- Create: `commands/logs.md`

- [ ] **Step 1: Create the command file**

```markdown
---
description: "View and query CKS lifecycle logs — filter by feature, phase, severity, date"
argument-hint: "[--feature ID] [--phase NAME] [--severity LEVEL] [--since DATE] [--metrics] [--summary]"
allowed-tools:
  - Read
  - Bash
  - Glob
---

# /cks:logs — Lifecycle Log Viewer

Read and filter structured events from `.prd/logs/lifecycle.jsonl`.

## Argument Handling

Parse arguments from `$ARGUMENTS`:

| Flag | Filter | Example |
|------|--------|---------|
| (none) | Show last 20 events | `/cks:logs` |
| `--feature ID` | Filter by feature_id prefix | `/cks:logs --feature 01` |
| `--phase NAME` | Filter by phase (derived from event field) | `/cks:logs --phase discover` |
| `--severity LEVEL` | Filter by severity (INFO, WARN, ERROR) | `/cks:logs --severity ERROR` |
| `--since DATE` | Filter events after date | `/cks:logs --since 2026-03-27` |
| `--metrics` | Show velocity metrics dashboard | `/cks:logs --metrics` |
| `--summary` | Human-readable activity summary | `/cks:logs --summary` |
| `--extract ID` | Extract per-feature log to `.prd/logs/features/` | `/cks:logs --extract 01-backend` |

## Pre-Check

```bash
if [ ! -f ".prd/logs/lifecycle.jsonl" ]; then
  echo "No logs found. Logs are created automatically as you use CKS lifecycle commands."
  exit 0
fi
```

## Default View (last 20 events)

```bash
tail -20 .prd/logs/lifecycle.jsonl | jq -r '[.timestamp[11:19], .severity, .event, .message] | join(" | ")'
```

Display as a formatted table:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 CKS LOGS — Last 20 Events
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Time     | Sev   | Event                        | Message
 22:15:00 | INFO  | phase.discover.started       | Discovery started for 01-backend-api
 22:15:05 | INFO  | step.0.started               | Progress banner displayed
 ...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Filtered View

Apply jq filters based on flags:

```bash
# --feature: filter by feature_id prefix
jq -r 'select(.feature_id | startswith("01"))' .prd/logs/lifecycle.jsonl

# --phase: filter by event containing phase name
jq -r 'select(.event | contains("discover"))' .prd/logs/lifecycle.jsonl

# --severity: exact match
jq -r 'select(.severity == "ERROR")' .prd/logs/lifecycle.jsonl

# --since: timestamp comparison
jq -r 'select(.timestamp >= "2026-03-27")' .prd/logs/lifecycle.jsonl
```

Combine multiple filters with `and`. Display in the same table format as default view.

## Metrics Dashboard (--metrics)

Scan `lifecycle.jsonl` and compute:
- Count features by status (started vs completed)
- Average phase durations (from paired started/completed events)
- Iteration count (count `state.iteration` events per feature)
- Agent dispatch count, user decision count, artifact count

Cache result to `.prd/logs/metrics.json`. Re-compute if `lifecycle.jsonl` is newer.

Display the metrics dashboard:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 CKS METRICS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Features: {N} completed | {N} in progress
 Avg Feature Duration: {N}h

 Phase Averages:
   Discover:  {N}h  {bar}
   Design:    {N}h  {bar}
   Sprint:    {N}h  {bar}
   Review:    {N}h  {bar}
   Release:   {N}h  {bar}

 Iterations: {N} avg per feature
 Decisions: {N} avg user decisions per feature

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Summary View (--summary)

Group events by feature and phase, show a human-readable timeline:
```
Feature 01-backend-api:
  [discover] ✅ 2026-03-27 10:00 → 11:00 (1h) — 11 elements gathered
  [design]   ✅ 2026-03-27 11:30 → 13:30 (2h) — 5 screens designed
  [sprint]   ▶  2026-03-27 14:00 → in progress — 3/7 sub-steps done
```

## Extract (--extract)

```bash
mkdir -p .prd/logs/features
jq -r "select(.feature_id | startswith(\"$FEATURE_ID\"))" .prd/logs/lifecycle.jsonl \
  > ".prd/logs/features/${FEATURE_ID}.jsonl"
echo "Extracted to .prd/logs/features/${FEATURE_ID}.jsonl"
```
```

- [ ] **Step 2: Commit**

```bash
git add commands/logs.md
git commit -m "feat: add /cks:logs command for lifecycle log querying"
```

---

## Chunk 2: Instrument PRD Phase Workflows

### Task 5: Instrument discover-phase orchestrator and step files

**Files:**
- Modify: `skills/prd/workflows/discover-phase.md`
- Modify: `skills/prd/workflows/discover-phase/step-0-progress.md`
- Modify: `skills/prd/workflows/discover-phase/step-1-target.md`
- Modify: `skills/prd/workflows/discover-phase/step-2-research.md`
- Modify: `skills/prd/workflows/discover-phase/step-3-resume.md`
- Modify: `skills/prd/workflows/discover-phase/step-4-elements.md`
- Modify: `skills/prd/workflows/discover-phase/step-4b-secrets.md`
- Modify: `skills/prd/workflows/discover-phase/step-5-validate.md`
- Modify: `skills/prd/workflows/discover-phase/step-6-state.md`
- Modify: `skills/prd/workflows/discover-phase/step-7-complete.md`

- [ ] **Step 1: Add phase-level logs to discover-phase.md**

After the "Load shared context" section and before Step 0, add:
```markdown
### Log: Phase Start
`bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "phase.discover.started" "{NN}-{name}" "Discovery phase started"`
```

Before the "Do NOT chain" line at the end, add:
```markdown
### Log: Phase Complete
`bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "phase.discover.completed" "{NN}-{name}" "Discovery phase completed — {NN}-CONTEXT.md written"`
```

- [ ] **Step 2: Add step-level logs to each step file**

For each step file, add a log call at the start of the Instructions section:

| File | Event |
|------|-------|
| `step-0-progress.md` | `step.0.started` / `step.0.completed` |
| `step-1-target.md` | `step.1.started` / `step.1.completed` |
| `step-2-research.md` | `step.2.started` / `step.2.completed` |
| `step-3-resume.md` | `step.3.started` / `step.3.completed` |
| `step-4-elements.md` | `step.4.started` / `step.4.completed` + `agent.dispatched` for prd-discoverer |
| `step-4b-secrets.md` | `step.4b.started` / `step.4b.completed` |
| `step-5-validate.md` | `step.5.started` / `step.5.completed` or `artifact.validation_failed` |
| `step-6-state.md` | `step.6.started` / `step.6.completed` + `state.transition` |
| `step-7-complete.md` | `step.7.started` / `step.7.completed` |

Pattern for each file — add after the `## Instructions` heading:

```markdown
**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.{N}.started" "{NN}-{name}" "Step {N}: {step_name}"`
```

And before the `## Success Condition` or end of instructions:

```markdown
**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.{N}.completed" "{NN}-{name}" "Step {N} complete"`
```

- [ ] **Step 3: Commit**

```bash
git add skills/prd/workflows/discover-phase.md skills/prd/workflows/discover-phase/step-*.md
git commit -m "feat: instrument discover phase with structured logging"
```

---

### Task 6: Instrument design, sprint, review, release phase workflows

**Files:**
- Modify: `skills/prd/workflows/design-phase.md`
- Modify: `skills/prd/workflows/sprint-phase.md`
- Modify: `skills/prd/workflows/review-phase.md`
- Modify: `skills/prd/workflows/release-phase.md`

- [ ] **Step 1: Add phase start/complete logs to each file**

Same pattern as discover-phase. For each file, add at the beginning of execution:

```markdown
**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "phase.{name}.started" "{NN}-{name}" "{Phase} phase started"`
```

And at the end (before context reset banner):

```markdown
**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "phase.{name}.completed" "{NN}-{name}" "{Phase} phase completed"`
```

For sprint-phase.md, also add sub-step logs for [3a] through [3g]:
```markdown
**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3a.started" "{NN}-{name}" "Sprint planning started"`
```

For review-phase.md, add logs for [4a] through [4d], and a `state.iteration` log if iteration loop triggers:
```markdown
**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "state.iteration" "{NN}-{name}" "Iteration: back to {phase}" '{"from_phase":"review","to_phase":"{target}","reason":"{reason}"}'`
```

- [ ] **Step 2: Commit**

```bash
git add skills/prd/workflows/design-phase.md skills/prd/workflows/sprint-phase.md skills/prd/workflows/review-phase.md skills/prd/workflows/release-phase.md
git commit -m "feat: instrument design, sprint, review, release phases with logging"
```

---

## Chunk 3: Instrument Kickstart & Feature Lifecycle

### Task 7: Instrument kickstart workflows

**Files:**
- Modify: `skills/kickstart/SKILL.md`
- Modify: `skills/kickstart/workflows/intake.md`
- Modify: `skills/kickstart/workflows/compose.md`
- Modify: `skills/kickstart/workflows/research.md`
- Modify: `skills/kickstart/workflows/brand.md`
- Modify: `skills/kickstart/workflows/design.md`
- Modify: `skills/kickstart/workflows/handoff.md`

- [ ] **Step 1: Add log calls to kickstart SKILL.md phase sections**

In each `### Phase N:` section of SKILL.md, add after "Display progress banner":
```markdown
**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "kickstart.phase.started" "_project" "Kickstart Phase {N}: {name}" '{"phase_number":"{N}","phase_name":"{name}"}'`
```

And in the "After completion" block:
```markdown
**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "kickstart.phase.completed" "_project" "Kickstart Phase {N} complete" '{"phase_number":"{N}","output":"{artifact_path}"}'`
```

For skipped phases:
```markdown
**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "kickstart.phase.skipped" "_project" "Phase {N} ({name}) skipped" '{"phase_number":"{N}","phase_name":"{name}"}'`
```

- [ ] **Step 2: Add log calls to each kickstart workflow file**

Same pattern: `kickstart.phase.started` at the top of Steps, `kickstart.phase.completed` at Step N: Validate & Report.

For `compose.md`, also log each identified sub-project:
```markdown
**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "kickstart.compose.sub_project" "_project" "Sub-project identified: {name}" '{"sp_id":"SP-{NN}","name":"{name}","type":"{type}","priority":{N}}'`
```

- [ ] **Step 3: Commit**

```bash
git add skills/kickstart/SKILL.md skills/kickstart/workflows/*.md
git commit -m "feat: instrument kickstart phases with structured logging"
```

---

### Task 8: Instrument feature creation

**Files:**
- Modify: `commands/new.md`

- [ ] **Step 1: Add `feature.created` log after feature entry creation**

In the `## 3. Create Feature Entry` step, after the validation block, add:

```markdown
**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "feature.created" "{NN}-{kebab-name}" "Feature created: {NN} — {name}" '{"feature_id":"{NN}-{kebab-name}","name":"{name}","brief":"{brief}"}'`
```

- [ ] **Step 2: Commit**

```bash
git add commands/new.md
git commit -m "feat: log feature creation events in /cks:new"
```

---

## Chunk 4: Documentation & Finalization

### Task 9: Update PRD SKILL.md documentation

**Files:**
- Modify: `skills/prd/SKILL.md`

- [ ] **Step 1: Add `.prd/logs/` to the file system diagram**

In the `.prd/` tree section, add:
```
├── logs/
│   ├── lifecycle.jsonl             # Structured event log (append-only)
│   ├── .current_session_id         # Session correlation (gitignored)
│   ├── features/                   # Per-feature log extracts
│   └── metrics.json                # Cached velocity metrics
```

- [ ] **Step 2: Add `/cks:logs` to the commands table**

In the Utility Commands table, add:
```markdown
| `/cks:logs [flags]` | View and query lifecycle logs — filter by feature, phase, severity, date |
```

- [ ] **Step 3: Commit**

```bash
git add skills/prd/SKILL.md
git commit -m "docs: add logging file structure and /cks:logs command to PRD docs"
```

---

### Task 10: Final verification

- [ ] **Step 1: Test end-to-end**

```bash
# 1. Verify jq is available
jq --version

# 2. Test logging utility
bash scripts/cks-log.sh INFO "test.verify" "_test" "Verification test" '{"check":"e2e"}'
bash scripts/cks-log.sh WARN "test.warning" "_test" 'Message with "quotes" and special chars'
bash scripts/cks-log.sh ERROR "test.error" "_test" "Error test"

# 3. Verify valid JSONL
cat .prd/logs/lifecycle.jsonl | jq . >/dev/null && echo "Valid JSON" || echo "INVALID JSON"

# 4. Verify filtering works
cat .prd/logs/lifecycle.jsonl | jq -r 'select(.severity == "ERROR")'
cat .prd/logs/lifecycle.jsonl | jq -r 'select(.event | contains("warning"))'

# 5. Clean up test data
rm .prd/logs/lifecycle.jsonl
```

- [ ] **Step 2: Verify all files are committed**

```bash
git status
git diff --stat main
```

Expected: All changes committed, no unstaged files.
