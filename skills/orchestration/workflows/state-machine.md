# State Machine Design Workflow

Step-by-step process for designing a deterministic FSM for a job dispatch system from scratch.

---

## Step 1 — Enumerate All States

List every stage a job can be in. Start by tracing the happy path, then add error and recovery stages.

**Questions to answer:**
- What is the first state when a job is created? (usually `pending`)
- What states does it pass through before completion?
- What is the terminal success state? (usually `completed`)
- What is the terminal failure state? (usually `dead_letter`)
- Are there intermediate wait states (e.g., waiting for external confirmation)?
- Are there rollback states if partial failure occurs?

Write all states as a flat list first — no transitions yet.

---

## Step 2 — Draw Transitions as a Table

For each possible transition, fill in one row:

| From State | Event | Guard | To State | Action |
|---|---|---|---|---|
| `pending` | job_claimed | retry_count < max_retries | `routing` | lock job, log transition |
| `routing` | vendor_selected | vendor.health == healthy | `dispatched` | write vendor_id, start timeout |
| `routing` | no_healthy_vendor | — | `dead_letter` | log reason, alert |
| `dispatched` | worker_success | — | `completed` | write result, release lock |
| `dispatched` | worker_failure | retry_count < max_retries | `pending` | increment retry_count, log error |
| `dispatched` | worker_failure | retry_count >= max_retries | `dead_letter` | write full error_log, alert |
| `dispatched` | timeout | retry_count < max_retries | `pending` | log timeout, increment retry |
| `dispatched` | timeout | retry_count >= max_retries | `dead_letter` | park with reason: timeout |

**Rules for this table:**
- Every cell in `From State` must be a state from Step 1
- Every cell in `To State` must also be a state from Step 1 (or a new state — add it to Step 1)
- Guards are optional boolean conditions; leave blank if unconditional
- Actions are DB writes or side effects — not business logic

---

## Step 3 — Identify Terminal States

Terminal states have **no outgoing transitions** in the table from Step 2.

- Mark them explicitly in your state list
- Verify: every non-terminal state has at least one outgoing transition for the failure event
- Verify: there is no path that loops forever without eventually reaching a terminal state

If you find a cycle that can run indefinitely, insert a `retry_count >= max_retries` guard that routes to `dead_letter`.

---

## Step 4 — Add Guards

Review every transition and ask: "Could this transition fire at the wrong time?"

Common guards to add:
- `retry_count < max_retries` — prevents infinite retry
- `vendor.circuit_state == CLOSED` — prevents routing to a tripped dependency
- `idempotency_key not already processed` — prevents duplicate execution
- `locked_until < now()` — prevents double-claiming a job

Add guards to the transition table. Guards that cannot be evaluated from DB state alone are a design smell — move that logic into the worker result payload.

---

## Step 5 — Map Each State to a DB Enum Value

Define the PostgreSQL enum (or equivalent):

```sql
CREATE TYPE job_status AS ENUM (
  'pending',
  'routing',
  'dispatched',
  'completed',
  'dead_letter'
);
```

Rules:
- Every state from Step 1 must appear in the enum
- The application must treat unknown enum values as an error, never silently ignore them
- Adding a new state requires a migration that adds the enum value before deploying the code that uses it

---

## Step 6 — Verify No Cycles That Bypass Terminal States

Walk every path through the transition table:
1. Start from the initial state
2. Follow each possible transition sequence
3. Confirm that every path eventually reaches `completed` or `dead_letter`

If any path can run indefinitely (cycles with no terminal exit), add a `max_retries` guard to break it.

---

## Worked Example — Emergency Dispatch Job

**Context:** A job dispatches a service request to one of several companies. Each company has an API. The system must retry on failure and park to DLQ after 3 attempts.

### States

| State | Meaning |
|---|---|
| `pending` | Created, waiting to be claimed |
| `routing` | Evaluating which company to dispatch to |
| `dispatched` | Sent to company API, waiting for response |
| `confirmed` | Company accepted the job |
| `completed` | Job finished successfully |
| `dead_letter` | Terminal failure — parked after max retries or unrecoverable error |

### Transition Table

| From State | Event | Guard | To State | Action |
|---|---|---|---|---|
| `pending` | claimed | retry_count < 3 | `routing` | set locked_until = now() + 30s |
| `routing` | company_selected | company.circuit == CLOSED | `dispatched` | write company_id to job |
| `routing` | no_available_company | — | `dead_letter` | log "no_healthy_company", alert |
| `dispatched` | api_success | — | `confirmed` | write confirmation_id |
| `dispatched` | api_failure | retry_count < 3 | `pending` | increment retry_count, log error |
| `dispatched` | api_failure | retry_count >= 3 | `dead_letter` | write full error_log, alert |
| `dispatched` | timeout_30s | retry_count < 3 | `pending` | log timeout, increment retry |
| `dispatched` | timeout_30s | retry_count >= 3 | `dead_letter` | park with reason: timeout |
| `confirmed` | job_finished | — | `completed` | write completed_at |

### Terminal States

- `completed` — no outgoing transitions
- `dead_letter` — no outgoing transitions

### Verification

Every non-terminal state has a failure path to `dead_letter` gated by `retry_count >= 3`. No cycle can run more than 3 times. The `routing` state handles the case where no healthy company exists by routing directly to `dead_letter` (no point retrying if no vendor is available).
