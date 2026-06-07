# CONTEXT.md Template (Discovery Output — 12 Elements)

Use this template when the prd-discoverer agent writes discovery output to `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md`.

All 12 elements are REQUIRED (Element 4 — Data Flow & API Surface Map — Part A can be marked N/A for read-only/UI-only features; Part B can be marked N/A if the feature has no API; Element 11 — Cross-Project Dependencies — can be marked N/A for single-project setups; Element 12 — System Architecture Tier — select Tier 1/2/3 or mark N/A if not infrastructure-relevant). The discoverer agent must gather all of them using AskUserQuestion.

---

```markdown
# Discovery: {Feature/Phase Title}

**Phase:** {NN}
**Date:** {YYYY-MM-DD}
**Status:** {Complete | In Progress}
**Elements:** {N}/12 gathered

---

## 1. Problem Statement & Value Proposition

{What specific problem does this solve, and for whom?}

**Problem:** {the pain point}
**Who has it:** {user types affected}
**Cost of not solving:** {business/user impact}
**Value delivered:** {what changes when this is built}

---

## 2. User Stories

| ID | Story | Priority |
|----|-------|----------|
| US-{NN}-01 | As a {user type}, I want to {action} so that {value} | Must Have |
| US-{NN}-02 | As a {user type}, I want to {action} so that {value} | Must Have |
| US-{NN}-03 | As a {user type}, I want to {action} so that {value} | Should Have |

Minimum 3 user stories per feature. Each must have the "so that" clause.

---

## 3. Scope (In / Out)

**In scope:**
- {what we ARE building}
- {what we ARE building}

**Out of scope:**
- {what we are NOT building} — {why}
- {what belongs to a different feature} — {which feature}

---

## 4. Data Flow & API Surface Map

### Part A — Data Flow Map

{If read-only or UI-only: "N/A — read-only feature, no data mutations"}

{If data mutations exist:}
For each user action:
1. {User Action}: {Entity A} → {Entity B} → cascades: {side effects}
2. {User Action}: {Entity A} → {Entity B} → cascades: {side effects}

**Entities touched:** {list all entities/tables written to}
**Async operations:** {yes/no — if yes, list them}

### Part B — API Surface

{If this feature involves API endpoints. If not, write "N/A — this feature has no API component."}

**Inherited conventions:** {from .kickstart/artifacts/API.md (if exists) or CLAUDE.md — API style, error format, auth pattern, existing endpoints}

| Resource | Method | Path | Auth | Description | New/Modified |
|----------|--------|------|------|-------------|-------------|
| {resource} | GET | /api/{resource} | {auth} | {what it does} | New |
| {resource} | POST | /api/{resource} | {auth} | {what it does} | New |

**Consumers:** {who calls these endpoints — web frontend, mobile, third party}
**Notes:** {any special considerations — real-time needs, file uploads, pagination}

This is the feature-level API surface. Full request/response schemas are designed in Phase 2 (Design) and implemented in Phase 3 (Sprint TDD).

---

## 5. Acceptance Criteria

Per user story, specific and testable. Reference API endpoints from Section 4 where applicable:

### US-{NN}-01: {story title}
- [ ] AC-01: {testable condition}
- [ ] AC-02: {testable condition}

### US-{NN}-02: {story title}
- [ ] AC-03: {testable condition}
- [ ] AC-04: {testable condition}

---

## 6. Constraints & Negative Cases

**Business rules that must NOT be violated:**
- {constraint}
- {constraint}

**Behaviors that must fail gracefully:**
- {negative case} → {expected behavior}
- {negative case} → {expected behavior}

---

## 7. Test Plan

### Unit Tests
| ID | What to Test | Input | Expected Output |
|----|-------------|-------|-----------------|
| UT-01 | {function/logic} | {input} | {expected} |
| UT-02 | {function/logic} | {input} | {expected} |

### Integration Tests
| ID | What to Test | Components | Expected Behavior |
|----|-------------|------------|-------------------|
| IT-01 | {interaction} | {A + B} | {expected} |

### End-to-End Test Scenarios
| ID | User Journey | Steps | Expected Outcome |
|----|-------------|-------|-----------------|
| E2E-01 | {journey name} | {step 1 → step 2 → step 3} | {final state} |
| E2E-02 | {journey name} | {step sequence} | {final state} |

One test case per acceptance criterion minimum.

---

## 8. UAT Scenarios

### Scenario 1: {Happy Path}
```
Given {initial state}
When {user action}
Then {expected outcome}
```

### Scenario 2: {Error Recovery}
```
Given {state}
When {user makes mistake}
Then {clear error feedback}
When {user corrects}
Then {success}
```

### Scenario 3: {Edge Case}
```
Given {boundary condition}
When {action}
Then {graceful handling}
```

---

## 9. Definition of Done

- [ ] Code written and reviewed
- [ ] All unit tests passing
- [ ] All integration tests passing
- [ ] All E2E tests passing
- [ ] UAT scenarios validated by stakeholder
- [ ] Deployed to staging
- [ ] Documentation updated
- [ ] Product owner approval

---

## 10. Success Metrics / KPIs

| Metric | Target | Measurement Method | Baseline |
|--------|--------|--------------------|----------|
| {metric} | {target value} | {how measured} | {current value} |
| {metric} | {target value} | {how measured} | {current value} |

---

## 11. Cross-Project Dependencies

{If PROJECT-MANIFEST.md exists with 2+ sub-projects. Otherwise write "N/A — single project, no cross-project dependencies."}

**This sub-project:** {SP-NN name from manifest}

### Consumes (needs from other sub-projects)
| Dependency | Source Sub-Project | Type | Details |
|------------|-------------------|------|---------|
| {API endpoint / data model / auth token} | SP-{NN} ({name}) | {API / Data / Auth / Event} | {specific endpoint, schema, or contract} |

### Provides (exposes to other sub-projects)
| Interface | Consumer Sub-Projects | Type | Details |
|-----------|----------------------|------|---------|
| {API endpoint / event / data} | SP-{NN}, SP-{NN} | {API / Data / Auth / Event} | {what others depends on} |

### Shared Concerns Used
| Concern | ID | Alignment Notes |
|---------|-----|----------------|
| {Auth / Payments / etc.} | SC-{NN} | {token format, naming conventions, data format agreements} |

---

## 12. System Architecture Tier

{Select the target infrastructure scale. N/A for features with no infrastructure decisions (pure UI components, plugin-only changes, etc.)}

**Selected Tier:** {Tier 1 — Bootstrap | Tier 2 — Traction | Tier 3 — Scale | N/A}

**Tier rationale:** {why this tier fits the current product stage and expected load}

| Tier | Target Scale | Infrastructure |
|------|-------------|----------------|
| Tier 1 | ~$1 MRR | Single VM, co-located app + DB |
| Tier 2 | ~$1,000 MRR | Dedicated app server + dedicated DB, monitoring, analytics |
| Tier 3 | ~$100,000+ MRR | Horizontal scaling, read replicas, caching, async queues |

**Architecture implications for this feature:**
- {what infrastructure choices this feature must align with}
- {any tier-specific constraints: e.g., "no Redis available at Tier 1", "must work behind load balancer at Tier 3"}

---

## Technical Context

### Files to modify
- `{path}` — {what changes}

### New files
- `{path}` — {purpose}

### Data model changes
{Description or "None"}

### Dependencies
{New libraries, APIs, or other features}

### External Secrets

See `{NN}-SECRETS.md` for the full manifest. Summary:

| Secret | Provider | Status |
|--------|----------|--------|
| {ENV_VAR_NAME} | {Provider} | {pending/resolved} |

_Generated by the secrets discovery hook (step-4b). Track and resolve via the secrets manifest._

## Codebase Research Notes

{What was found in the existing code relevant to this feature.}

## Open Questions

- [ ] {unresolved item}

## Assumptions

- {assumption — flag for review}

## Discovery Method

{Interactive session | Autonomous analysis | Brief-based}
```
