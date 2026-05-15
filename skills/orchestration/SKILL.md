---
name: orchestration
description: "Orchestration system design and implementation patterns for products with their own dispatch layer, state machines, worker coordination, and failure handling. Use when: building a control plane, designing a state machine, implementing saga pattern, adding circuit breakers, handling idempotency, designing dead letter queues, fan-out fan-in coordination, message queue patterns, job queue design, event-driven architecture, multi-worker dispatch, or any system that routes work across external dependencies."
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Orchestration

## Overview

Domain expertise for designing and building orchestration products — systems that route, coordinate, and recover work across multiple workers or external dependencies. Covers state machines, control plane design, saga pattern, circuit breakers, idempotency, dead letter queues, fan-out/fan-in, and health-aware routing.

The core discipline: **separate orchestration from execution**. The orchestrator reads state and dispatches. Workers do the work. Neither crosses into the other's domain.

## When to Use

- Designing a dispatch system that routes jobs to multiple workers or vendors
- Building a control plane that coordinates multiple services or agents
- Implementing state transitions for job lifecycle management
- Adding fault tolerance: retries, circuit breakers, fallback routing
- Handling partial failures across distributed steps (saga pattern)
- Designing a message queue or job queue schema
- Implementing fan-out (parallel workers) and fan-in (result merging)
- Building health-aware routing that skips degraded dependencies

## When NOT to Use

- Simple request/response to a single service (no orchestration needed)
- In-process function pipelines (use plain function composition)
- Claude agent dispatch (see `skills/parallel-dispatch/` instead)
- Failure classification after the fact (see `skills/failure-taxonomy/`)

## Core Patterns

### 1. State Machine

A deterministic finite state machine (FSM) governs every job's lifecycle. States are explicit; transitions are table-driven; no ML or heuristics for routing decisions.

**Key rules:**
- Every state maps to a DB status enum value
- Transitions are triggered by events, not by polling logic
- Guards are boolean conditions checked before a transition fires
- Actions are side effects executed on transition (write DB, enqueue next step)
- Terminal states (`completed`, `dead_letter`) have no outgoing transitions

See `workflows/state-machine.md` for the full design process and worked example.

### 2. Control Plane / Orchestrator

The orchestrator is a pure conductor. It:
- Reads current state from the job table
- Evaluates which transition is valid
- Dispatches the appropriate worker
- Records the new state after dispatch

It **never** does work itself. It does not call external APIs, parse responses, or apply business logic. That belongs to workers.

**Separation table:**

| Responsibility | Orchestrator | Worker |
|---|---|---|
| Read job state | Yes | No |
| Decide next step | Yes | No |
| Call external API | No | Yes |
| Parse API response | No | Yes |
| Write job result | No | Yes (own step only) |
| Mark job complete | Yes | No |

### 3. Message Queue (Job Table Pattern)

Use a database table as a durable job queue. Polling or triggers drive consumption. No separate message broker required for most products.

**Minimum job table columns:**

| Column | Type | Purpose |
|---|---|---|
| `id` | uuid | Primary key |
| `status` | enum | Current FSM state |
| `payload` | jsonb | Input data for workers |
| `retry_count` | int | Attempts so far |
| `max_retries` | int | Trip to DLQ after this |
| `error_log` | jsonb[] | Error per attempt |
| `state_history` | jsonb[] | All status transitions with timestamps |
| `idempotency_key` | text unique | Deduplication handle |
| `locked_until` | timestamptz | Optimistic locking for concurrent consumers |
| `created_at` | timestamptz | Job creation time |
| `updated_at` | timestamptz | Last state change |

Claim a job by updating `locked_until = now() + interval` in the same statement that reads it. Any job with an expired lock is available for re-claim.

### 4. Saga Pattern

Each step that touches an external system is paired with a compensation (the undo action). On any failure, completed steps are compensated in reverse order.

**Rules:**
- Log every action: `step_name`, `started_at`, `completed_at`
- Log every compensation: `step_name`, `compensated_at`, `compensation_result`
- Compensations must be idempotent — safe to run more than once
- Never silently swallow a compensation failure — log it and escalate to DLQ

See `workflows/saga.md` for the full design process and worked example.

### 5. Circuit Breaker

Prevents cascading failure when a dependency is degraded. States: `CLOSED` (normal), `OPEN` (blocking calls), `HALF_OPEN` (probing recovery).

**State transitions:**

| From | Condition | To | Action |
|---|---|---|---|
| CLOSED | Failures ≥ threshold in window | OPEN | Stop routing to this dependency |
| OPEN | Cooldown period elapsed | HALF_OPEN | Allow one probe request |
| HALF_OPEN | Probe succeeds | CLOSED | Resume normal routing |
| HALF_OPEN | Probe fails | OPEN | Reset cooldown |

**Rules:**
- Store circuit state in DB or cache — not in memory (processes restart)
- Failure threshold: 5 failures in 60 seconds is a reasonable starting point
- Cooldown: 30–60 seconds before probing
- Never call a OPEN dependency in a tight retry loop

### 6. Idempotency

Every job must be safe to process more than once. Duplicate submissions return the same result, not a duplicate execution.

**Idempotency key construction:**
```
key = hash(caller_id + intent_fingerprint + timestamp_window)
```

- `timestamp_window`: round the timestamp to a window (e.g., 5 minutes) so retries within the window reuse the same key
- Store the key with the result; check before processing
- Return the cached result immediately on duplicate — do not re-execute

### 7. Dead Letter Queue

After `max_retries` exhausted, park the job to a DLQ. Never loop forever.

**DLQ record must include:**
- Full original payload
- Full error log (all attempts)
- State history at time of parking
- `parked_at` timestamp
- Reason: `max_retries_exceeded` | `unrecoverable_error` | `compensation_failed`

**DLQ handling:**
- Alert on DLQ inserts (do not silently discard)
- Provide an admin tool to inspect, requeue, or discard DLQ records
- Never auto-requeue from DLQ without human review — DLQ means something unexpected happened

### 8. Fan-Out / Fan-In

Dispatch multiple workers simultaneously; collect and merge results.

**Fan-out:**
- Create one child job record per worker before dispatching any
- Dispatch all workers in parallel (not sequentially)
- Each child job is independent — failure in one does not cancel others unless the saga requires it

**Fan-in:**
- Poll or subscribe for child job completion
- Merge results only after all children reach a terminal state
- Apply results sequentially to avoid write conflicts even though workers ran in parallel
- If any child fails: apply saga compensations or mark the parent as partially failed (document which behavior is correct for the use case)

### 9. Health Checks

Per-dependency health is stored and checked before routing. Unhealthy dependencies are bypassed, not passed through.

**Health record per dependency:**

| Column | Purpose |
|---|---|
| `dependency_id` | Which vendor/service |
| `status` | `healthy` \| `degraded` \| `offline` |
| `last_checked_at` | Freshness of the status |
| `consecutive_failures` | Input to circuit breaker |
| `notes` | Free-text from last probe |

**Routing rule:** if `status != 'healthy'` and an alternative exists, route to the alternative. If no alternative, return a clear error — do not attempt a call you expect to fail.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The orchestrator can just call the API directly — it's faster" | Mixing orchestration and execution destroys observability. When it fails, you cannot tell whether routing or execution caused the failure. |
| "We'll add retries later when it becomes a problem" | Retries are architectural. Adding them later requires changing the job schema, state machine, and every worker. Do it at design time. |
| "We don't need a circuit breaker for a single vendor" | You need it most when you have a single vendor. A tight retry loop against an offline dependency can exhaust your request budget in seconds. |
| "Idempotency keys are extra complexity" | Every distributed system retries. Without idempotency, retries create duplicate state. Idempotency keys are the minimum viable safety net. |
| "The DLQ is where jobs go to die — we'll ignore it" | The DLQ is a signal. Jobs parked there represent real failures that need diagnosis. Ignoring it hides bugs and loses user requests. |
| "We can merge fan-in results in parallel too" | Parallel writes to shared state cause conflicts. Merge sequentially even when workers ran in parallel. |
| "State history is nice to have" | State history is your audit trail, your debugging tool, and your compliance record. It is not optional for a production orchestration system. |

## Verification

- [ ] Every job has a state machine with explicit states and transitions
- [ ] Terminal states have no outgoing transitions
- [ ] Orchestrator does not call external APIs directly
- [ ] Job table includes: status, retry_count, error_log, state_history, idempotency_key, locked_until
- [ ] Circuit breaker state is stored durably (not in memory)
- [ ] Idempotency keys prevent duplicate processing on retry
- [ ] DLQ is populated after max_retries (not silently discarded)
- [ ] DLQ inserts trigger an alert
- [ ] Fan-out creates all child job records before dispatching
- [ ] Fan-in merges results sequentially
- [ ] Health checks stored per dependency and consulted before routing
- [ ] Saga compensations are idempotent
- [ ] Compensation failures are logged and escalated (not swallowed)
