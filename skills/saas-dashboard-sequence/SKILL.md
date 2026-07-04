---
name: saas-dashboard-sequence
description: "Unified Dashboard SaaS Build Sequence — 12-stage methodology for multi-role SaaS products (super admin/admin/user/vendor). Enforces single application with role-gated dashboard visibility, never separate dashboards per role, generated from one permissions matrix. Use for multi-role SaaS, admin/user/vendor roles, role-gated dashboard, permission matrix, tenant roles, super admin panel design."
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
---

# Unified Dashboard SaaS Build Sequence

## Overview

The most common architecture mistake in multi-role SaaS products is building N separate
applications — one per role (a customer app, an admin panel, a vendor portal) — instead of
one application with role-gated visibility. Separate apps duplicate auth, duplicate API
surface, drift out of sync, and turn every cross-role feature into a 3x change. This skill is
a 12-stage ordered methodology that fixes the shape, not just the content:

**ONE application. Role-gated visibility. Never separate dashboards per role.**

Every role (super_admin, admin, user, vendor, or whatever the project's hierarchy is) sees the
same shell, the same routes, the same components — gated by what they're permitted to see and
do. The single source of truth is a permissions matrix, declared once and cited by name from
three places: RLS policies, API middleware, and frontend visibility guards.

## When to Use

- Building a SaaS product with more than one user role (admin/user, super admin/admin/vendor,
  tenant admin/tenant member, etc.)
- A feature description mentions "role-gated dashboard", "admin panel", "vendor portal",
  "super admin", or "permission matrix"
- `project_type: multi-role-saas` is set in `.kickstart/state.md` or `.bootstrap/scan-context.md`
- Any point where a second app root, second routing tree, or second deployment target is being
  proposed for a role that already has a home in the existing app

## When NOT to Use

- Single-role products (every authenticated user has the same capabilities) — there's no
  permissions matrix to generate, this methodology adds nothing
- `project_type` is anything other than `multi-role-saas` and no role/permission keywords matched
- A genuinely separate product is being built for a separate audience (e.g., a public
  marketing site alongside the app) — that's a different deployment target, not a role, and
  is not what this methodology governs

## The 12 Stages

Full gate-check detail (produced artifact, exact dispatch target) lives in
`workflows/build-sequence.md`. This table is the map — read the workflow file before running
any stage.

| # | Stage | Produces | Dispatch Target |
|---|---|---|---|
| 1 | Product Definition & Monetization | `references/permissions-matrix-template.md` filled in | Net-new artifact + `monetize-discoverer` pipeline |
| 2 | Architecture Blueprint (single app enforced) | `ARCHITECTURE.md` / ADRs | `agents/architecture-generator.md` + `.claude/rules/saas-single-app.md` |
| 3 | ERD (role/permission as first-class fields, RLS) | `ERD.md` | `agents/db-erd.md` |
| 4 | API Contract (single role-aware endpoint set) | `API.md` | `skills/kickstart/workflows/design.md` Contract Format table |
| 5 | Frontend Architecture (one shell, permission-aware components) | Component specs | `agents/kickstart-designer.md` |
| 6 | Integration / Data Flow | Data flow notes | Existing sprint/design flow — pointer only |
| 7 | Security & Compliance (privilege escalation testing) | Security checklist findings | `agents/security-auditor.md` |
| 8 | Testing Strategy (permission tests per endpoint per role) | Test plan | Existing test-generation flow |
| 9 | Deployment | Deploy config | Existing deploy config flow |
| 10 | Observability | Telemetry wiring | `.claude/rules/telemetry.md` |
| 11 | Maintenance / Refactoring | Refactor notes | Existing refactor flow |
| 12 | Documentation | Docs | `cks:docs` |

## Ordering Constraint (the actual value-add)

Stage 1's permissions matrix MUST exist before Stage 2's architecture decision, because
architecture-generator cannot enforce "role-gated" design without knowing what the roles and
scopes actually are. See `workflows/build-sequence.md` § Sequencing Note.

## The Single-App Mandate

This is not just methodology guidance — it's an enforceable constraint. See
`.claude/rules/saas-single-app.md`: any PLAN.md, ADR, or diff that scaffolds a second full
app/dashboard root for a `multi-role-saas` project is flagged and requires an explicit ADR
justification, a redesign, or a recorded dismissal. The rule is separate from this skill
because the skill is judgment (how to design roles and permissions); the rule is a fact-check
(does a second app root exist, and do RLS/API/frontend all cite the same matrix file).

## Net-New Content

Only one piece of this skill is genuinely new — everything else is a dispatch pointer:

- **Stage 1 — Permissions Matrix template** (`references/permissions-matrix-template.md`): the
  single source of truth for role/permission/scope/visibility/endpoint/RLS mapping. No existing
  CKS artifact captures this in one place.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The admin panel is simpler as its own app" | It's simpler to build once, then duplicates every future change forever. One shell with gated views is the cheaper long-term path. |
| "We'll unify the apps later once we know the roles better" | Later means auth, API, and data model have already diverged three ways. Unify now, while it's one diff instead of three. |
| "This project only has two roles, the matrix is overkill" | Two roles is exactly when a lightweight matrix costs nothing and prevents assumption drift as a third role gets added. |
| "RLS already restricts data, the frontend doesn't need to cite the matrix" | RLS prevents data leaks, not UI confusion. Citing the same file keeps all three layers reasoning about the same source of truth. |
| "architecture-generator can figure out the roles itself" | It can't — Stage 2 depends on Stage 1's matrix as input. See the Sequencing Note in the workflow file. |

## Verification

- [ ] Every stage that was run produced its named artifact at the expected path
- [ ] Stage 1 (permissions matrix) exists before Stage 2 (architecture) started
- [ ] No second app/dashboard root was scaffolded without an ADR justification (see
      `.claude/rules/saas-single-app.md`)
- [ ] RLS policies, API middleware, and frontend visibility guards all cite the same
      `PERMISSIONS-MATRIX.md` path in a code comment
- [ ] Any stage skipped as "N/A" has a one-line reason recorded, not silently omitted
