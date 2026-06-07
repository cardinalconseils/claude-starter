# Distributed Pattern Catalog

Reference catalog for 12 distributed/async patterns. Used by `arch-patterns.md` rule and `architecture-generator` Mode 3. When a trigger keyword matches, read the relevant entry for WHEN/WHEN-NOT guidance and ADR template hints.

---

## Dead Letter Queue

**Trigger keywords:** `dead letter`, `DLQ`, `failed message store`, `undeliverable`, `poison queue`

**WHEN to use:**
- Any queue-based processing where failed messages must not be silently dropped
- Async workflows where retry exhaustion should route to a holding area for inspection
- Event-driven pipelines where partial failures must be debuggable post-incident

**WHEN NOT to use:**
- Fire-and-forget telemetry where duplicates and drops are acceptable
- Synchronous request/response paths (no queue involved)

**ADR hint:** Record why the DLQ sink was chosen over simple discard and what SLA governs re-processing of dead-lettered messages.

**Cross-reference:** `skills/orchestration/SKILL.md` lines 135–149

---

## Saga

**Trigger keywords:** `compensating transaction`, `rollback step`, `multi-step workflow`, `saga`

**WHEN to use:**
- Multi-service workflows where each step modifies state and partial failure must be rolled back
- Long-running business transactions spanning databases or services (order fulfillment, booking flows)
- Workflows where 2PC distributed transactions are not feasible

**WHEN NOT to use:**
- Single-service workflows (use local transactions instead)
- Read-only aggregation pipelines (no state mutations to compensate)

**ADR hint:** Record whether choreography (event-driven) or orchestration (central coordinator) was chosen, and why.

**Cross-reference:** `skills/orchestration/workflows/saga.md`

---

## Circuit Breaker

**Trigger keywords:** `circuit breaker`, `circuit_breaker`, `open/half-open`, `failure threshold`

**WHEN to use:**
- Any call to an external service or third-party API that can degrade under load
- Preventing cascade failures when a downstream dependency is unhealthy
- Protecting resource pools from retry storms caused by an unavailable service

**WHEN NOT to use:**
- Internal in-process function calls (no network hop, no timeout risk)
- One-off scripts or batch jobs where retrying from the start is acceptable

**ADR hint:** Record the failure threshold (e.g., 5 failures in 10s), the open-to-half-open timeout, and which library or implementation was chosen.

**Cross-reference:** `skills/orchestration/SKILL.md` lines 103–120

---

## Idempotency

**Trigger keywords:** `idempotency key`, `idempotent`, `duplicate request`, `exactly-once`

**WHEN to use:**
- Payment endpoints, charge operations, or any mutation that must not double-execute on retry
- Webhook receipt handlers where the same event may be delivered more than once
- Queue consumers where at-least-once delivery is guaranteed by the broker

**WHEN NOT to use:**
- Pure read endpoints (GET requests are naturally idempotent)
- Truly fire-and-forget telemetry where duplicates are tolerable

**ADR hint:** Record the idempotency key storage mechanism (DB unique constraint, Redis TTL) and the TTL policy for key expiry.

**Cross-reference:** `skills/orchestration/SKILL.md` lines 122–133

---

## Retry / Backoff

**Trigger keywords:** `retry on failure`, `exponential backoff`, `max_retries`, `retry with delay`

**WHEN to use:**
- Transient failures on network calls (timeouts, 429 rate limits, 503 unavailable)
- Queue consumers that should retry processing before dead-lettering
- Any operation where the failure is likely temporary and immediate retry is safe

**WHEN NOT to use:**
- Non-idempotent operations without an idempotency key (retrying may cause duplicates)
- Permanent errors (4xx validation failures) — retrying will always fail

**ADR hint:** Record the max retry count, backoff formula (e.g., 2^n seconds + jitter), and which error codes trigger retry vs. immediate failure.

**Cross-reference:** `skills/orchestration/SKILL.md` (retry_count throughout)

---

## Fan-out / Fan-in

**Trigger keywords:** `fan-out`, `fan-in`, `parallel workers`, `broadcast job`, `scatter-gather`

**WHEN to use:**
- Splitting a large job into parallel sub-tasks then aggregating results (e.g., image processing, batch reports)
- Broadcasting an event to multiple independent consumers simultaneously
- Scatter-gather patterns where partial results must be merged before responding

**WHEN NOT to use:**
- Sequential workflows where each step depends on the prior step's output
- Low-volume tasks where parallelism overhead exceeds the gain

**ADR hint:** Record the fan-out concurrency limit, the aggregation strategy (first-N wins, wait-for-all, partial-results-ok), and how failures in sub-tasks are handled.

**Cross-reference:** `skills/orchestration/SKILL.md` lines 151–164

---

## Health-aware Routing

**Trigger keywords:** `health check routing`, `health-aware`, `route around failures`

**WHEN to use:**
- Load balancers or API gateways that must stop routing to unhealthy upstream instances
- Multi-region deployments where traffic must fail over to a healthy region automatically
- Service meshes where sidecar proxies can observe per-instance health signals

**WHEN NOT to use:**
- Single-instance deployments with no routing layer
- Internal microservice-to-microservice calls where the service mesh handles health transparently

**ADR hint:** Record the health check endpoint path, polling interval, the unhealthy threshold (N consecutive failures), and the recovery threshold.

**Cross-reference:** `skills/orchestration/SKILL.md` lines 166–180

---

## CQRS

**Trigger keywords:** `CQRS`, `command query separation`, `read model`, `write model`, `projection`

**WHEN to use:**
- High read/write ratio where read scaling and write scaling have different requirements
- Features where the read shape (flat, denormalized) differs significantly from the write shape (normalized)
- Event-sourced systems where projections build read models from the event log

**WHEN NOT to use:**
- Simple CRUD features where the same model serves both reads and writes adequately
- Low-traffic systems where operational complexity outweighs the scaling benefit

**ADR hint:** Record which storage systems are used for commands vs. queries, how read models are kept in sync (synchronous projection vs. eventual consistency), and the accepted staleness window.

**Cross-reference:** (no cross-reference — net-new)

---

## Event Sourcing

**Trigger keywords:** `event sourcing`, `event log`, `event store`, `append-only log`, `replay events`

**WHEN to use:**
- Systems where audit trail or temporal queries ("what was the state at time T?") are required
- Features where replaying history to rebuild state is a first-class requirement
- Domains where business events are the primary modeling unit (finance, inventory, booking)

**WHEN NOT to use:**
- Simple state stores where the current value is all that matters (no history needed)
- High-frequency metrics or telemetry where event volume makes log storage prohibitive

**ADR hint:** Record the event store technology (Postgres events table, EventStoreDB, Kafka), the snapshot strategy for long-lived aggregates, and the schema versioning approach for event upcasting.

**Cross-reference:** (no cross-reference — net-new)

---

## Outbox Pattern

**Trigger keywords:** `outbox pattern`, `transactional outbox`, `inbox outbox`, `at-least-once delivery`

**WHEN to use:**
- Publishing events or messages atomically with a DB write (avoids dual-write inconsistency)
- Any place where "write to DB and then publish to queue" could fail between the two steps
- Systems requiring at-least-once delivery guarantees with transactional safety

**WHEN NOT to use:**
- Systems where eventual consistency is unacceptable and events must be synchronously consumed before returning to the caller
- Simple pub/sub where atomic consistency with DB state is not required

**ADR hint:** Record the outbox table schema (id, event_type, payload, published_at), the polling or CDC mechanism used to relay outbox rows to the queue, and the idempotency strategy for consumers.

**Cross-reference:** (no cross-reference — net-new)

---

## Bulkhead

**Trigger keywords:** `bulkhead`, `thread pool isolation`, `resource partition`, `blast radius isolation`

**WHEN to use:**
- Isolating calls to different downstream services so one slow dependency cannot exhaust shared thread pools
- Multi-tenant systems where one tenant's load must not degrade service for others
- High-criticality paths (payments, auth) that must stay responsive even when lower-priority paths degrade

**WHEN NOT to use:**
- Single-dependency systems where isolation adds complexity with no benefit
- Homogeneous workloads where all calls have the same priority and resource profile

**ADR hint:** Record which dependencies get isolated pools, the pool size per bulkhead, the queue depth before shedding load, and the fallback behavior when a bulkhead is full.

**Cross-reference:** (no cross-reference — net-new)

---

## Service Mesh

**Trigger keywords:** `service mesh`, `sidecar proxy`, `Istio`, `Linkerd`, `Envoy`, `mTLS between services`

**WHEN to use:**
- Microservice deployments where cross-cutting concerns (mTLS, observability, traffic shaping) should be handled at the infrastructure layer rather than in application code
- Progressive rollouts (canary, blue/green) requiring fine-grained traffic control
- Multi-language service fleets where per-language SDK overhead is unacceptable

**WHEN NOT to use:**
- Monoliths or two-service deployments where sidecar overhead exceeds the operational benefit
- Teams without platform/DevOps capacity to operate a mesh control plane

**ADR hint:** Record the chosen mesh technology (Istio, Linkerd, Cilium), the mTLS policy (strict/permissive), which traffic policies are enforced at the mesh layer vs. in code, and the observability integration.

**Cross-reference:** (no cross-reference — net-new)
