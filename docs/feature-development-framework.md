# Feature Development Framework

## The Full Cycle

```
PROJECT LEVEL (one-time):
  /kickstart    → idea → research → monetize → feature roadmap → stack → architecture
  /bootstrap    → scaffold → .claude/ → CLAUDE.md → .prd/ → .context/ → deploy config

FEATURE LEVEL (repeatable):
  /new "feature" → creates feature entry → enters Phase 1

  Phase 1: Discovery (/discover)        → WHAT to build
  Phase 2: Design (/design)             → HOW it looks
  Phase 3: Sprint Execution (/sprint)   → CODE it
  Phase 4: Review & Retro (/review)     → EVALUATE it (+ iteration loop)
  Phase 5: Release Management (/release)→ SHIP it
```

---

## Phase 1: Discovery

### The 11 Elements of Discovery

#### 1. Problem Statement & Value Proposition

The core problem this feature solves and the value it delivers.

"What specific problem does this solve, and for whom?"

#### 2. User Stories

Format: "As a [user type], I want to [do something] so that [I get this value]."

- One feature = multiple user stories
- Each story = one buildable chunk
- The "so that" clause is mandatory

#### 3. Scope (In / Out)

- What is IN this feature
- What is OUT of this feature
- What belongs to a different feature

#### 4. API Surface Map (if applicable)

High-level map of what API endpoints this feature needs. Inherits project-level conventions (style, error format, auth) from Kickstart/Bootstrap — does not re-decide them.

| Resource | Operations | Auth | Notes |
|----------|-----------|------|-------|
| /api/invoices | CRUD + send | Bearer | New endpoints |

This enables acceptance criteria to reference specific endpoints, and test plans to include API integration tests. Full request/response schemas are designed in Phase 2.

#### 5. Acceptance Criteria

Specific, testable conditions that must be true for the story to be done. Written before coding starts. Reference API endpoints from Element 4 where applicable.

#### 6. Constraints & Negative Cases

Conditions that define failure — what must NOT happen. Business rules that must not be violated, and behaviors that must fail gracefully. These are your guardrails.

#### 7. Test Plan

Written during discovery, after acceptance criteria are finalized. One test case per acceptance criterion minimum. Include API endpoint tests for features with API surface.

Includes:
- **Unit test cases** — isolated logic validation
- **Integration test cases** — component interaction validation
- **End-to-end test scenarios** — full user journey validation from entry point to final outcome, covering every critical path defined in user stories

#### 8. UAT Scenarios

Written during discovery. Executed after development, before release.

A set of end-to-end flows that stakeholders will validate — not a single script, but a collection of realistic scenarios covering happy paths, edge cases, and error states.

#### 9. Definition of Done (DoD)

- Code written and reviewed
- All test cases passed (unit, integration, E2E)
- UAT completed and signed off
- Deployed to staging
- Documentation updated (auto-checked by [3h] Documentation Check):
  - Public APIs have JSDoc/docstrings
  - New endpoints documented in `docs/api/`
  - Architecture docs current if structure changed
  - Onboarding guide still accurate
- Product owner approval

#### 10. Success Metrics / KPIs

Adoption rate, error rate, time saved, support ticket reduction.

#### 11. Cross-Project Dependencies

For multi-sub-project setups (detected from `.prd/PROJECT-MANIFEST.md`): shared services, APIs consumed/provided, data contracts, build order constraints. Mark N/A for single-project setups.

### Discovery — Who Is Involved

| Role | Responsibility |
|------|---------------|
| Product Owner | Defines problem statement, user stories, scope |
| Tech Lead | Reviews feasibility, flags technical constraints |
| QA / Developer | Writes test plan based on acceptance criteria |
| Stakeholder | Reviews and signs off on UAT scenarios |

---

## Phase 2: Design

### The Design Flow

```
UX Research
    |
API Contract (if feature has API surface)
    |
Screen Generation (Stitch SDK)
    |
Design Iteration
    |
Component Specs
    |
Design Review
```

### Step 1 — UX Research

Map user flows, journey maps, and information architecture from the user stories and acceptance criteria defined in Discovery.

**Output**: User flow diagrams, journey maps, information architecture.

### Step 2 — API Contract (if applicable)

Take the API Surface Map from Discovery (Element 4) and define the full contract:
- Request/response schemas (typed fields, validation rules)
- Authentication requirements per endpoint
- Error responses with specific error codes
- Example request/response pairs for each endpoint

Inherits project-level conventions from Kickstart (API style, versioning) and Bootstrap (error format, naming, auth pattern). Does not re-decide those.

**Input**: API Surface Map from Discovery + project conventions from CLAUDE.md
**Output**: `api-contract.md` with full typed schemas. Enables frontend to build against a defined contract.

### Step 3 — Screen Generation

Use Stitch SDK to generate UI screens from natural language prompts derived from user stories.

**Input**: User stories + UX flows from Step 1.
**Output**: Generated HTML screens + screenshots for each key screen.

**Tool chain**: Stitch SDK (`@google/stitch-sdk`) — generates HTML/CSS/JS from text prompts.

### Step 4 — Design Iteration

Edit and refine generated screens. Generate variants for different devices (mobile, desktop, tablet). Review rendered screens via browser.

**Tool chain**: Stitch SDK (editing API) + Chrome DevTools MCP (browser review + screenshots).

### Step 5 — Component Specs

Extract HTML from approved screens. Map to component hierarchy. Define design tokens (colors, spacing, typography).

**Output**: Component hierarchy, design tokens, HTML reference for each screen.

### Step 6 — Design Review

Stakeholder review of screenshots, rendered screens, and API contract (if applicable). Feedback loops back to Step 3 if changes needed. Sign-off required to proceed to Sprint.

**Output**: Stakeholder sign-off on design.

---

## Phase 3: Sprint Execution

### The Sprint Flow

```
Sprint Planning
    |
Design & Architecture (TDD)
    |
Implementation
    |
Code Review
    |
QA Validation
    |
UAT (User Acceptance Testing)
    |
Merge to Main
```

### Step 1 — Sprint Planning

Team reviews user stories, prioritizes, estimates effort, commits to sprint scope.

**Output**: Prioritized sprint backlog, effort estimates, sprint goal statement.

### Step 2 — Design & Architecture

Produce a Technical Design Document (TDD) covering the relevant sections below. Not every story requires all sections — mark complexity-appropriate items.

**Required for all stories:**

- **2a. Data Model & Schema Design** — Entities, relationships, attributes, primary/foreign keys, tables, columns, data types, indexes, constraints, normalization rules
- **2b. API Implementation Design** — Takes API contract from Design phase (api-contract.md) and adds implementation details: validation logic, database queries, side effects, caching, rate limit implementation. Does NOT re-design the API surface or schemas — those are settled in Discovery and Design.
- **2c. Test Strategy** — Unit test approach, integration test approach, end-to-end test approach, coverage targets

**Required for complex stories:**

- **2d. Data Flow Design** — How data moves: input, processing, storage, output, real-time vs batch
- **2e. Architecture Review** — Scalability, security, performance, maintainability assessment
- **2f. Security Review** — Authentication flows, authorization rules, encryption standards, data privacy requirements
- **2g. Non-Functional Requirements (NFRs)** — Response time SLAs, load capacity, scalability targets, caching strategy

**As-needed:**

- **2h. Observability Design** — Error handling strategy, logging standards, metrics, alerting thresholds, dashboards, tracing
- **2i. Release Strategy** — Blue/green, canary, feature flags, rollback plan
- **2j. Configuration & Secrets Management** — Environment variables, secrets, feature flags, environment-specific configs
- **2k. Dependency Analysis** — Internal and external dependencies, third-party services, blockers, fallback plans

### Step 3 — Implementation

Code targets acceptance criteria — nothing more, nothing less.

- Any scope change goes back to Product Owner
- Commits reference the user story ID
- Follow the test strategy defined in Step 2
- Reference design specs and component hierarchy from Phase 2

### Step 4 — Code Review

Checklist:

- Acceptance criteria met
- No bugs or missed edge cases
- Code clean and documented
- Constraints and negative cases handled
- No security vulnerabilities
- Matches design specs from Phase 2

### Step 5 — QA Validation

Checklist:

- All unit tests executed and passing
- All integration tests executed and passing
- All end-to-end tests executed and passing
- Acceptance criteria verified
- Constraints and negative cases verified
- Edge cases tested
- Bugs logged and fixed

### Step 6 — UAT (User Acceptance Testing)

Checklist:

- UAT scenarios executed end-to-end
- Feature delivers expected value
- Stakeholder sign-off obtained

### Step 7 — Merge to Main

The sprint produces a **potentially shippable increment**. Code is merged to main via pull request. The decision to deploy to production is separate and belongs to Phase 5.

---

## Phase 4: Sprint Review & Retrospective

### The Post-Sprint Flow

```
Sprint Review (Demo + Feedback + Metrics)
    |
Sprint Retrospective
    |
Backlog Refinement
    |
Iteration Decision
    |
├── "UX issues"           → back to Phase 2 (Design)
├── "Logic/bug issues"    → back to Phase 3 (Sprint)
├── "Requirements changed" → back to Phase 1 (Discovery)
└── "Ready to release"    → forward to Phase 5 (Release)
```

### Step 1 — Sprint Review

Demo the increment to stakeholders. Collect feedback. Present success metrics.

**Output**: Feedback log, bug list, UX observations, metrics report.

### Step 2 — Sprint Retrospective

- What went well?
- What slowed us down?
- What do we do differently next sprint?

**Output**: Retrospective notes, process improvements, action items.

### Step 3 — Backlog Refinement

Review and reprioritize the backlog based on sprint review feedback, metrics analysis, and new information.

- Iterate on the same feature, fix bugs, or promote to release
- Update estimates and priorities

**Output**: Updated backlog, priorities for next sprint.

### Step 4 — Iteration Decision

Based on feedback and metrics, route to the correct next phase:

| Feedback Type | Route To | Reason |
|---|---|---|
| UX/UI issues, layout problems, design debt | Phase 2: Design | Visual/interaction changes needed |
| Logic bugs, missed acceptance criteria, performance issues | Phase 3: Sprint | Code changes needed |
| Requirements fundamentally changed, scope shift | Phase 1: Discovery | Re-discovery needed |
| Feedback positive, metrics on track, stakeholder sign-off | Phase 5: Release | Ready to ship |

---

## Phase 5: Release Management

### Environments

| Stage | Who Tests | Purpose |
|-------|-----------|---------|
| Development | Internal team only | Catch obvious bugs, validate core flow |
| Staging | Limited external users | Real feedback, monitor metrics |
| Release Candidate (RC) | Wider users, production-like | Full validation, performance, security |
| Production | Everyone | Live for all users |

### The Release Flow

```
Code merged to main via PR
    |
CI/CD builds and runs tests
    |
Deploy to Development (internal preview)
    |
Internal validation — acceptance criteria met, no major bugs
    |
Deploy to Staging
    |
Real user feedback, metrics monitoring, bug fixes
    |
Deploy to Release Candidate
    |
Full validation, performance testing, security sign-off
    |
End-to-end regression suite passes
    |
Deploy to Production
    |
Post-deploy smoke test + E2E validation
    |
Monitor success metrics
```

### Quality Gates

#### Development -> Staging

- No major bugs
- Acceptance criteria met internally
- Core data flow verified
- Unit and integration tests passing

#### Staging -> Release Candidate

- Real user feedback positive
- Error rate within acceptable range
- Success metrics trending in right direction
- All known bugs triaged (critical/blocker = fixed)

#### Release Candidate -> Production

- Full staging validation passed
- Performance targets met
- Security sign-off obtained
- **End-to-end regression suite executed and passing** — full critical path coverage across all features, not just the new increment
- Rollback plan ready and tested

#### Post-Production

- Post-deploy smoke test passed
- **End-to-end validation on production** — critical user journeys confirmed working in the live environment
- Error rate within acceptable range
- Performance within SLA
- Success metrics being tracked
- Monitoring and alerting confirmed active

### Vercel-Specific Notes

- Use separate Vercel preview URLs per branch — never deploy directly to production URL during testing
- Use feature flags to hide new features from production users until ready
- Development environment = Vercel preview on feature branch — safe to break, internal only
- Each PR on Vercel auto-generates a preview URL — use these for staging/beta testing

---

*Framework built during Cloud Starter Project — March 2026*
