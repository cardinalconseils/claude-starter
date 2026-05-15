# Saga Pattern Implementation Workflow

Step-by-step process for implementing the saga pattern for distributed steps that must be rolled back on failure.

---

## When to Use the Saga Pattern

Use sagas when a single job requires multiple steps that each touch an **external system** (an API, a DB write that has side effects, a notification send). If any step fails after others have already succeeded, the completed steps must be undone.

If all steps are local and purely in-database, use a database transaction instead. Sagas are for cases where a transaction cannot span the boundary.

---

## Step 1 — List Every Step That Touches an External System

Walk the job's happy path and list each operation that:
- Calls an external API
- Sends a notification (email, SMS, push)
- Writes to a DB table that drives downstream behavior
- Charges a payment method
- Creates a resource that must be explicitly deleted (e.g., a calendar event, a reservation)

Write them in execution order. These become your saga steps.

---

## Step 2 — Define the Compensation for Each Step

For each step, define its compensation: the action that undoes the step's effect.

| Step | Compensation |
|---|---|
| Reserve a slot | Cancel the reservation |
| Charge a payment | Issue a refund |
| Send a confirmation SMS | Send a cancellation SMS |
| Create a calendar event | Delete the calendar event |
| Write a DB record | Delete or soft-delete the record |

**Compensation rules:**
- Compensations must be **idempotent** — safe to run more than once without creating duplicates or errors
- If a step has no compensation (e.g., "log an audit record"), that is acceptable — document it explicitly
- Compensations that call external APIs can fail too — handle this in Step 5

---

## Step 3 — Implement as a Try/Compensate Loop

Execute steps in order. On any failure, run compensations in reverse for all steps that already completed.

**Pseudocode pattern:**

```
completed_steps = []

for each step in saga_steps:
    try:
        result = execute(step)
        log_step_complete(step.name, result)
        completed_steps.append(step)
    except failure:
        log_step_failure(step.name, failure)
        for each completed_step in reversed(completed_steps):
            compensate(completed_step)
        raise saga_failed(failure)

log_saga_complete()
```

**Key points:**
- Append to `completed_steps` only after the step succeeds
- Iterate `completed_steps` in reverse for compensation (last completed → first compensated)
- A compensation failure is its own error — log it and escalate (do not silently continue)

---

## Step 4 — Log Every Action and Compensation

Every step execution and every compensation must write a log record. Minimum fields:

**Step log:**

| Field | Description |
|---|---|
| `job_id` | Parent job |
| `step_name` | Identifier for this step |
| `started_at` | When execution began |
| `completed_at` | When it succeeded (null if failed) |
| `failed_at` | When it failed (null if succeeded) |
| `result` | jsonb result payload |
| `error` | jsonb error if failed |

**Compensation log:**

| Field | Description |
|---|---|
| `job_id` | Parent job |
| `step_name` | Which step is being compensated |
| `compensated_at` | When compensation ran |
| `compensation_result` | jsonb — success or failure |
| `compensation_error` | jsonb — if compensation itself failed |

Without this log, you cannot debug partial failures or confirm that compensation ran.

---

## Step 5 — Handle Compensation Failures

Compensations can fail. Treat a compensation failure as a critical alert — it means you have a system in a partially-committed state that cannot self-heal.

**Required behavior:**
- Log the compensation failure with full error context
- Park the job in the DLQ with reason: `compensation_failed`
- Alert a human — do not silently discard

Never retry compensations in an infinite loop. Retry once (with a brief delay), then escalate. Infinite compensation retries can cause their own damage (e.g., issuing multiple refunds).

---

## Worked Example — Service Dispatch with 3 Steps

**Context:** A job dispatches a service request to a company. Three external steps are required. If any fails, the previous steps must be undone.

### Steps and Compensations

| # | Step | External System | Compensation |
|---|---|---|---|
| 1 | Reserve a time slot for the company | Company scheduling API | Cancel the reservation via API |
| 2 | Create the job record in the company's system | Company job API | Delete the job record via API |
| 3 | Send confirmation SMS to the customer | SMS provider | Send cancellation SMS to the customer |

### Execution on Happy Path

```
1. Reserve slot → success → log step 1 complete, add to completed_steps
2. Create job record → success → log step 2 complete, add to completed_steps
3. Send SMS → success → log step 3 complete, add to completed_steps
→ log saga complete
```

### Execution on Failure at Step 3

```
1. Reserve slot → success → add to completed_steps
2. Create job record → success → add to completed_steps
3. Send SMS → FAILURE → log step 3 failure
   → compensate step 2: delete job record → log compensation
   → compensate step 1: cancel reservation → log compensation
→ log saga failed, park to DLQ with error from step 3
```

### Execution on Compensation Failure

```
1. Reserve slot → success
2. Create job record → success
3. Send SMS → FAILURE
   → compensate step 2: delete job record → COMPENSATION FAILURE
   → log compensation failure for step 2
   → park to DLQ with reason: compensation_failed
   → ALERT: manual review required
```

Note: Step 1's compensation is not attempted if Step 2's compensation fails. The system stops and alerts. A human must inspect the state and manually resolve.

### Idempotency of the SMS Compensation

The cancellation SMS is safe to send more than once — it is informational, not transactional. If the compensation is retried, the customer receives a second cancellation SMS. This is acceptable. Document this behavior explicitly so it is a known trade-off, not a surprise.

If double-sending is not acceptable (e.g., a payment refund), add an idempotency key to the compensation call and check before sending.
