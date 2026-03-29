# {NN}-TDD.md — Technical Design Document

> Phase 3 [3b]: Design & Architecture for Phase {NN}: {phase_name}
> Generated: {date}
> Complexity: {Standard | Comprehensive | Full | Minimal}

## Sprint Goal

{One sentence describing what this sprint delivers}

---

## Required: Data Model & Schema Design

### Entities

| Entity | Description | Key Fields |
|--------|-------------|------------|
| {Entity} | {purpose} | id, {field1}, {field2}, ... |

### Relationships

```
{Entity A} --[1:N]--> {Entity B}
{Entity A} --[M:N]--> {Entity C} (via {JoinTable})
```

### Schema Changes

```sql
-- New tables / columns / indexes
{SQL or migration pseudocode}
```

### Migration Plan

- [ ] Create migration file
- [ ] Test migration on dev database
- [ ] Verify rollback works
- [ ] Document breaking changes (if any)

---

## Required: API Implementation Design

**Source of truth:** Project-level API contract (`.kickstart/artifacts/API.md`), feature-level surface (CONTEXT.md § 4), feature-level contracts (design/api-contract.md).

{Import from these sources in priority order:
1. `.kickstart/artifacts/API.md` — project-level conventions, existing endpoints, request/response shapes
2. `design/api-contract.md` — feature-level contract from Phase 2 Design
3. `CONTEXT.md § 4` — feature-level API surface from Phase 1 Discovery
Do NOT re-invent the API shape — extend it with implementation details.}

### Endpoints (from Discovery + Design)

| Method | Path | Auth | Description | Source |
|--------|------|------|-------------|--------|
| {from api-contract.md or CONTEXT.md} | | | | Discovery / Design |

### Implementation Details (Sprint additions)

For each endpoint, add what Discovery and Design didn't cover:

#### `{METHOD} {path}`
- **Validation:** {Zod schema / Pydantic model — specific implementation}
- **Database queries:** {what SQL/ORM calls this triggers}
- **Side effects:** {emails sent, webhooks fired, cache invalidated}
- **Error handling:** {specific error codes and when they trigger}
- **Performance:** {caching strategy, query optimization, pagination implementation}

### Rate Limits

| Endpoint | Limit | Window | Implementation |
|----------|-------|--------|---------------|
| {path} | {N} requests | per {time} | {Redis / in-memory / middleware} |

### API Conventions Check
- [ ] Error format matches CLAUDE.md API Conventions
- [ ] Auth pattern matches project standard
- [ ] Naming follows project conventions (from bootstrap)

---

## Required: Test Strategy

### Unit Tests
| What to Test | File | Assertions |
|-------------|------|------------|
| {function/component} | `{test file}` | {what to verify} |

### Integration Tests
| What to Test | Setup | Assertions |
|-------------|-------|------------|
| {API endpoint / service interaction} | {fixtures/mocks} | {expected behavior} |

### End-to-End Tests
| User Journey | Steps | Expected Outcome |
|-------------|-------|-----------------|
| {journey name} | {step sequence} | {final state} |

### Coverage Target
- Unit: {N}%
- Integration: {N}%
- E2E: critical paths covered

---

## Complex: Data Flow Design

```
Input → {Processing Step 1} → {Processing Step 2} → Storage
                                      ↓
                                  {Side Effect}
```

- Real-time vs batch: {decision}
- Caching strategy: {approach}

---

## Complex: Architecture Review

- **Scalability**: {how this handles growth}
- **Performance**: {expected response times, bottlenecks}
- **Maintainability**: {complexity, coupling, extensibility}
- **Security**: {attack surface, data exposure}

---

## Complex: Security Review

- **Authentication**: {how users are verified}
- **Authorization**: {how permissions are checked}
- **Data protection**: {encryption at rest/transit, PII handling}
- **Input validation**: {sanitization approach}

---

## Complex: Non-Functional Requirements

| Metric | Target | Measurement |
|--------|--------|-------------|
| Response time (p95) | < {N}ms | {how measured} |
| Throughput | {N} req/sec | {how measured} |
| Availability | {N}% | {monitoring} |

---

## As-Needed: Observability Design

- **Logging**: {what gets logged, format, destination}
- **Metrics**: {custom metrics, dashboards}
- **Alerting**: {thresholds, notification channels}
- **Tracing**: {distributed tracing approach}

---

## As-Needed: Release Strategy

- **Deployment method**: {blue/green | canary | rolling | direct}
- **Feature flags**: {flags needed for this feature}
- **Rollback plan**: {how to revert if issues arise}

---

## As-Needed: Configuration & Secrets

| Variable | Purpose | Required | Default |
|----------|---------|----------|---------|
| {VAR_NAME} | {purpose} | {yes/no} | {value or none} |

---

## As-Needed: Dependency Analysis

### Internal Dependencies
| Dependency | Status | Risk |
|-----------|--------|------|
| {service/module} | {available | in progress} | {low | medium | high} |

### External Dependencies
| Service | Purpose | Fallback |
|---------|---------|----------|
| {API/service} | {what it does} | {what happens if unavailable} |

---

## Implementation Tasks

Ordered by dependency:

1. [ ] {task} — {estimated effort}
2. [ ] {task} — {estimated effort}
3. [ ] {task} — {estimated effort}

Total estimated effort: {hours/points}
