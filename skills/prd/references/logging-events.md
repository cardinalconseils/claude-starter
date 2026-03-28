# CKS Logging Event Catalog

Reference for workflow authors. Use the logging utility to emit structured events at phase and step boundaries.

## Usage

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh <severity> <event> <feature_id> <message> [metadata_json]
```

**Parameters:**
| Param | Required | Description |
|-------|----------|-------------|
| severity | Yes | `INFO`, `WARN`, or `ERROR` |
| event | Yes | Dot-notation event type (see tables below) |
| feature_id | Yes | Phase ID + name (e.g., `01-backend-api`). Use `_project` for project-level events |
| message | Yes | Human-readable description |
| metadata_json | No | JSON object with event-specific data (default: `{}`) |

## Quick Reference

| Pattern | Example | When |
|---------|---------|------|
| `phase.{name}.started` | `phase.discover.started` | Phase begins |
| `phase.{name}.completed` | `phase.discover.completed` | Phase ends successfully |
| `phase.{name}.failed` | `phase.sprint.failed` | Phase fails |
| `phase.{name}.resumed` | `phase.design.resumed` | Phase resumed from prior session |
| `step.{id}.started` | `step.1a.started` | Sub-step begins |
| `step.{id}.completed` | `step.1a.completed` | Sub-step ends |
| `step.{id}.skipped` | `step.4b.skipped` | Sub-step skipped |
| `agent.dispatched` | — | Agent launched |
| `agent.completed` | — | Agent returned |
| `agent.failed` | — | Agent errored |
| `user.decision` | — | AskUserQuestion answered |
| `user.approval` | — | User approved artifact/phase |
| `user.rejection` | — | User requested changes |
| `artifact.created` | — | File written |
| `artifact.updated` | — | File modified |
| `artifact.validated` | — | Validation passed |
| `artifact.validation_failed` | — | Validation failed |
| `state.transition` | — | PRD-STATE.md updated |
| `state.iteration` | — | Iteration loop triggered |
| `feature.created` | — | /cks:new creates feature |
| `feature.completed` | — | Feature released or abandoned |
| `kickstart.phase.started` | — | Kickstart phase begins |
| `kickstart.phase.completed` | — | Kickstart phase ends |
| `kickstart.phase.skipped` | — | Kickstart phase skipped |
| `kickstart.compose.sub_project` | — | Sub-project identified |

## Phase Events

| Event | Severity | Metadata |
|-------|----------|----------|
| `phase.{name}.started` | INFO | `{elements_count, prior_state}` |
| `phase.{name}.completed` | INFO | `{artifacts_created}` |
| `phase.{name}.failed` | ERROR | `{error, retry_count}` |
| `phase.{name}.resumed` | INFO | `{prior_session_id, sub_step}` |

## Sub-Step Events

| Event | Severity | Metadata |
|-------|----------|----------|
| `step.{id}.started` | INFO | `{step_name}` |
| `step.{id}.completed` | INFO | `{}` |
| `step.{id}.skipped` | INFO | `{reason}` |

## Agent Events

| Event | Severity | Metadata |
|-------|----------|----------|
| `agent.dispatched` | INFO | `{agent_name, prompt_summary}` |
| `agent.completed` | INFO | `{agent_name, output_summary}` |
| `agent.failed` | ERROR | `{agent_name, error}` |

## User Decision Events

| Event | Severity | Metadata |
|-------|----------|----------|
| `user.decision` | INFO | `{question_header, selected_options}` |
| `user.approval` | INFO | `{what_approved}` |
| `user.rejection` | INFO | `{what_rejected, reason}` |

## Artifact Events

| Event | Severity | Metadata |
|-------|----------|----------|
| `artifact.created` | INFO | `{path, type}` |
| `artifact.updated` | INFO | `{path, type, changes_summary}` |
| `artifact.validated` | INFO | `{path, checks_passed}` |
| `artifact.validation_failed` | WARN | `{path, checks_failed, missing}` |

## State Events

| Event | Severity | Metadata |
|-------|----------|----------|
| `state.transition` | INFO | `{from_status, to_status}` |
| `state.iteration` | INFO | `{from_phase, to_phase, reason}` |

## Feature Events

| Event | Severity | Metadata |
|-------|----------|----------|
| `feature.created` | INFO | `{feature_id, name, brief}` |
| `feature.completed` | INFO | `{feature_id, phases_completed}` |

## Kickstart Events

| Event | Severity | Metadata |
|-------|----------|----------|
| `kickstart.phase.started` | INFO | `{phase_number, phase_name}` |
| `kickstart.phase.completed` | INFO | `{phase_number, output}` |
| `kickstart.phase.skipped` | INFO | `{phase_number, phase_name}` |
| `kickstart.compose.sub_project` | INFO | `{sp_id, name, type, priority}` |

## Integration Pattern

Add log calls at step boundaries in workflow files:

```markdown
**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.{id}.started" "{NN}-{name}" "Step {id}: {description}"`

{... step instructions ...}

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.{id}.completed" "{NN}-{name}" "Step {id} complete"`
```
