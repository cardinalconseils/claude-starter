# Workflow: Unified Dashboard SaaS Build Sequence (12 Stages)

## Overview

Runs 12 stages in order for a multi-role SaaS build. Most stages dispatch to an existing CKS
agent or skill — this workflow's job is sequencing and enforcing the single-app mandate, not
new content. Only Stage 1 produces a genuinely new artifact.

**Sequencing Note:** Stage 1's permissions matrix MUST exist before Stage 2's architecture
decision. Architecture-generator has no way to know what "role-gated" means for this project
without the matrix — it needs the role hierarchy, scopes, and visibility rules first. This is
a narrower ordering constraint than the 15-stage Agentic Build Sequence's Gap Check: mainly,
don't scaffold Stage 2's architecture as N separate apps before Stage 1 defines the roles that
make single-app-with-gating possible. `.claude/rules/saas-single-app.md` enforces the
consequence of skipping this (a second app root) as a deterministic fact-check — this workflow
file doesn't need its own separate Gap Check section for that reason.

## Prerequisites

- None mandatory. If earlier discovery (kickstart intake, PRD discovery) already captured
  role/user-type information, reuse it to pre-fill Stage 1 rather than starting from scratch.

## Stage-by-Stage

### Stage 1 — Product Definition & Monetization

**Produces:** A filled-in copy of `references/permissions-matrix-template.md` (role hierarchy,
permission/capability per role, scope, UI visibility, affected API endpoints, RLS policy
reference) plus the feature-visibility matrix implied by it.
**Dispatch:** Net-new template (fill directly) + `monetize-discoverer` pipeline for the
monetization half (which roles pay, which roles are free, tier-gated features).
**Prerequisite:** None — this is the first stage.

**Why this stage exists:** Every downstream stage (architecture, ERD, API contract, frontend)
depends on knowing the roles and what each one can see and do. Skipping this and going
straight to architecture is the exact failure mode this methodology prevents.

### Stage 2 — Architecture Blueprint (single app enforced)

**Produces:** `ARCHITECTURE.md` update + ADR(s), reflecting a single application with
role-gated visibility.
**Dispatch:** `agents/architecture-generator.md`
**Hard prerequisite:** Stage 1's permissions matrix must exist first — architecture-generator
needs it to know what "role-gated" means for this project.
**Enforcement:** `.claude/rules/saas-single-app.md` flags any architecture decision, PLAN.md,
or diff that scaffolds a second full app/dashboard root for this project. This is a mandatory
check wired via that rule, not optional guidance.

### Stage 3 — ERD (role/permission as first-class fields, RLS)

**Produces:** `ERD.md`
**Dispatch:** `agents/db-erd.md`
**Note (dependency for a future PR, not implemented here):** `db-erd.md` should surface
role/permission columns as first-class entities when a permissions matrix exists (e.g., a
`roles` table, a `role_permissions` join table, RLS policies keyed on role). This PR does not
edit `db-erd.md` — that dependency is tracked for the architecture-generator/kickstart-designer/
db-erd wiring PR later in the build order. For now, pass the permissions matrix path to
`db-erd.md` as context when dispatching it.
**Prerequisite:** Stage 2 architecture exists

### Stage 4 — API Contract (single role-aware endpoint set)

**Produces:** `API.md`
**Dispatch:** `skills/kickstart/workflows/design.md` § Contract Format table
**Note (documented here, not implemented by editing design.md):** Per-role duplicate endpoints
(`/admin/users`, `/vendor/users`, `/user/users` for what should be one role-aware
`/users` endpoint with permission-based response shaping) are a smell to flag during this
stage, not silently accept. If the contract being drafted has parallel per-role endpoint
families for the same resource, surface it as a finding before the contract is finalized.
**Prerequisite:** Stage 1 matrix exists (endpoints and their permission scoping come from it)

### Stage 5 — Frontend Architecture (one shell, permission-aware components)

**Produces:** Component specs reflecting one app shell with permission-gated visibility
**Dispatch:** `agents/kickstart-designer.md`
**Note (dependency for a future PR, not implemented here):** `kickstart-designer.md` should
generate one shell with permission-gated components for `multi-role-saas` projects, not N app
scaffolds. This PR does not edit `kickstart-designer.md` — tracked for the later wiring PR.
Pass the permissions matrix path as context when dispatching it in the meantime.
**Prerequisite:** Stage 2 architecture exists (single-app decision), Stage 1 matrix exists

### Stage 6 — Integration / Data Flow

**Produces:** Data flow notes (only if the project has non-trivial cross-service data flow)
**Dispatch:** Existing sprint/design flow — pointer only, no new capability added by this stage
**Prerequisite:** Stage 2 architecture exists

### Stage 7 — Security & Compliance (privilege escalation testing)

**Produces:** Security checklist findings, specifically cross-role privilege escalation tests
**Dispatch:** `agents/security-auditor.md` (extended in a future PR — the cross-role privilege
escalation checklist item is tracked as a separate PR in the build order, not implemented
here). This stage is a pointer only.
**Prerequisite:** Stage 1 matrix exists (roles and endpoints to test come from it)

### Stage 8 — Testing Strategy (permission tests per endpoint per role)

**Produces:** Test plan covering every (role, endpoint) pair from the permissions matrix
**Dispatch:** Existing test-generation flow — pointer + checklist reference to Stage 1's matrix
**Prerequisite:** Stage 1 matrix exists, Stage 4 API contract exists

### Stage 9 — Deployment

**Produces:** Deploy config (single app, not N app deployments)
**Dispatch:** Existing deploy config flow — pointer only
**Prerequisite:** Stage 2 architecture exists

### Stage 10 — Observability

**Produces:** Telemetry wiring confirmed
**Dispatch:** `.claude/rules/telemetry.md` — pointer only
**Prerequisite:** Stage 2 architecture exists

### Stage 11 — Maintenance / Refactoring

**Produces:** Refactor notes (if any)
**Dispatch:** Existing refactor flow — pointer only
**Prerequisite:** None specific — ongoing concern

### Stage 12 — Documentation

**Produces:** Project documentation reflecting the single-app, role-gated architecture
**Dispatch:** `cks:docs`
**Prerequisite:** All prior stages either complete or explicitly marked N/A with a reason

## Post-Conditions

- Each stage run has produced its named artifact at the path listed in SKILL.md's stage table
- Stage 1 (permissions matrix) exists before Stage 2 (architecture) was dispatched
- `.claude/rules/saas-single-app.md` checks ran at Stage 2 (and again at Sprint/Review gates
  per that rule) — no second app root exists without an ADR justification
- Any stage marked N/A has a one-line reason recorded in the calling agent's output
