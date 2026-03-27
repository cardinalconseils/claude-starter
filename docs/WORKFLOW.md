# CKS Development Lifecycle — Complete Artifact Map

> **Version 3.2.0** | Built 2026-03-27 | `e0150d3`

> Every file created by the 5-phase lifecycle, mapped to the step that creates it.

---

## The Complete Hierarchy

```
PROJECT LEVEL (one-time):
  /kickstart    → idea → research → monetize → feature roadmap → stack
  /bootstrap    → scaffold → .claude/ → CLAUDE.md → .prd/ → .context/

FEATURE LEVEL (repeatable):
  /new "feature" → creates feature entry → enters Phase 1

PHASE LEVEL (5-phase cycle per feature):
  /discover     → Phase 1: Discovery (10 Elements + Secrets Manifest)
  /design       → Phase 2: Design (Stitch SDK)
  /sprint       → Phase 3: Sprint Execution (with secrets gate)
  /review       → Phase 4: Review & Retro (+ iteration loop)
  /release      → Phase 5: Release Management
```

---

## Project Level (One-Time)

### /kickstart

| File | Created By | Purpose |
|------|-----------|---------|
| `.kickstart/context.md` | Phase 1: Intake | Full idea context from Q&A |
| `.kickstart/research.md` | Phase 2: Research | Market & competitor research |
| `.kickstart/artifacts/PRD.md` | Phase 4: Design | First-draft PRD |
| `.kickstart/artifacts/ERD.md` | Phase 4: Design | Entity Relationship Diagram |
| `.kickstart/artifacts/ARCHITECTURE.md` | Phase 4: Design | Architecture & stack decisions |
| `.kickstart/artifacts/FEATURE-ROADMAP.md` | Phase 5: Feature Roadmap | Prioritized feature list |
| `.monetize/*` | Phase 3: Monetize | Revenue model artifacts |

### /bootstrap

| File | Created By | Purpose |
|------|-----------|---------|
| `CLAUDE.md` | Step 2 | Project-specific instructions |
| `.prd/PRD-PROJECT.md` | Step 3 | Project context |
| `.prd/PRD-REQUIREMENTS.md` | Step 3 | Requirements tracking (starts empty) |
| `.prd/PRD-ROADMAP.md` | Step 4 | Feature roadmap (imported from kickstart) |
| `.prd/PRD-STATE.md` | Step 3 | Session state |
| `docs/ROADMAP.md` | Step 4 | Public roadmap (copy) |
| `.context/{technology}.md` | Step 5 | Stack research briefs |

---

## Feature Level

### /new

| File | Created By | Purpose |
|------|-----------|---------|
| `.prd/phases/{NN}-{name}/` | Step 3 | Phase directory created |
| `.prd/PRD-STATE.md` | Step 3 | Updated: active_phase = {NN} |
| `.prd/PRD-ROADMAP.md` | Step 3 | Updated: new feature entry |

---

## Phase 1: Discovery (/discover)

**Command:** `/cks:discover [phase]`
**Agent:** prd-discoverer
**Template:** `skills/prd/templates/context.md`
**Architecture:** Chunked orchestrator (`discover-phase.md` → `discover-phase/step-*.md`)

| File | Created By Step | Purpose |
|------|----------------|---------|
| `.context/{technology}.md` | Step 2: Auto-Research | Technology context briefs |
| `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md` | Step 4: Discoverer Agent | **The 10 Elements** |
| `.prd/phases/{NN}-{name}/{NN}-SECRETS.md` | Step 4b: Secrets Hook | **Secrets manifest** (from tech stack) |
| `.prd/PRD-STATE.md` | Step 6 | Updated: status = `discovered` |
| `.prd/PRD-ROADMAP.md` | Step 6 | Updated: phase = "Discovered" |

### Discover Sub-Steps (Chunked Architecture)

```
discover-phase.md (orchestrator, 61 lines)
  → step-0-progress.md     Display lifecycle progress banner
  → step-1-target.md       Determine target phase from args/state
  → step-2-research.md     Auto-research technologies via /context
  → step-3-resume.md       Check for existing CONTEXT.md, offer resume/redo
  → step-4-elements.md     Dispatch prd-discoverer agent (10 Elements)
  → step-4b-secrets.md     Invoke secrets/hook-discover.md → SECRETS.md
  → step-5-validate.md     Validate CONTEXT.md has all 10 elements
  → step-6-state.md        Update PRD-STATE.md + PRD-ROADMAP.md
  → step-7-complete.md     Completion banner + context reset
```

**{NN}-CONTEXT.md contains all 10 Elements:**

| Element | Section | ID Format |
|---------|---------|-----------|
| 1. Problem Statement & Value Proposition | `## 1. Problem Statement` | — |
| 2. User Stories | `## 2. User Stories` | US-{NN}-01, US-{NN}-02 |
| 3. Scope (In/Out) | `## 3. Scope` | — |
| 4. API Surface Map | `## 4. API Surface` | Resource + operations (or N/A) |
| 5. Acceptance Criteria | `## 5. Acceptance Criteria` | AC-01, AC-02 |
| 6. Constraints & Negative Cases | `## 6. Constraints` | — |
| 7. Test Plan | `## 7. Test Plan` | UT-01, IT-01, E2E-01 |
| 8. UAT Scenarios | `## 8. UAT Scenarios` | Given/When/Then |
| 9. Definition of Done | `## 9. Definition of Done` | Checklist |
| 10. Success Metrics / KPIs | `## 10. Success Metrics` | Metric + target |

---

## Phase 2: Design (/design)

**Command:** `/cks:design [phase]`
**Agent:** prd-designer
**Template:** `skills/prd/templates/design-summary.md`
**Reference:** `skills/prd/references/design-patterns.md`

| File | Created By Step | Purpose |
|------|----------------|---------|
| `.prd/phases/{NN}-{name}/design/ux-flows.md` | [2a] UX Research | User flows, journey maps, IA |
| `.prd/phases/{NN}-{name}/design/api-contract.md` | [2b] API Contract | Request/response schemas, auth, examples (if API feature) |
| `.prd/phases/{NN}-{name}/design/screens/{screen}/screenshot.png` | [2c] Screen Generation | Visual reference |
| `.prd/phases/{NN}-{name}/design/screens/{screen}/source.html` | [2c] Screen Generation | Generated HTML (Stitch SDK) |
| `.prd/phases/{NN}-{name}/design/screens/{screen}/variants/mobile.html` | [2d] Design Iteration | Mobile variant |
| `.prd/phases/{NN}-{name}/design/screens/{screen}/variants/tablet.html` | [2d] Design Iteration | Tablet variant |
| `.prd/phases/{NN}-{name}/design/component-specs.md` | [2e] Component Specs | Component hierarchy + design tokens |
| `.prd/phases/{NN}-{name}/design/review-signoff.md` | [2f] Design Review | Stakeholder approval |
| `.prd/phases/{NN}-{name}/{NN}-DESIGN.md` | Step 5: Summary | **Consolidated design summary** |
| `.prd/PRD-STATE.md` | Step 6 | Updated: status = `designed` |
| `.prd/PRD-ROADMAP.md` | Step 6 | Updated: phase = "Designed" |

---

## Phase 3: Sprint Execution (/sprint)

**Command:** `/cks:sprint [phase]`
**Agents:** prd-planner, prd-executor, prd-verifier, reviewer, db-migration, security-auditor
**Templates:** `tdd.md`, `prd.md`
**References:** `testing-strategy.md`, `uat-patterns.md`, `verification-patterns.md`, `security-checklist.md`

| File | Created By Step | Purpose |
|------|----------------|---------|
| `docs/prds/PRD-{NNN}-{name}.md` | [3a] Sprint Planning | PRD document |
| `.prd/phases/{NN}-{name}/{NN}-PLAN.md` | [3a] Sprint Planning | Execution plan + tasks |
| `.prd/PRD-REQUIREMENTS.md` | [3a] Sprint Planning | Updated: new REQ-IDs |
| `.prd/PRD-ROADMAP.md` | [3a] Sprint Planning | Updated: phases + criteria |
| `.prd/phases/{NN}-{name}/{NN}-TDD.md` | [3b] Design & Architecture | Technical Design Document |
| `{source files}` | [3c] Implementation | Actual code changes |
| `{migration files}` | [3c] Implementation | Database migrations (if schema changes) |
| `.prd/phases/{NN}-{name}/{NN}-SUMMARY.md` | [3c] Implementation | What was built, files changed |
| `.prd/phases/{NN}-{name}/{NN}-VERIFICATION.md` | [3e] QA Validation | Test results: PASS/FAIL per criterion |
| `.prd/PRD-STATE.md` | [3g] Merge | Updated: status = `sprinted`, PR info |
| `.prd/PRD-ROADMAP.md` | [3g] Merge | Updated: "Sprinted — Pending Review" |

**Git artifacts from [3g] Merge:**
```
git commit — feat(phase-{NN}): {name}
gh pr create — PR #{number}
```

### Sprint Sub-Steps

```
[3a]  Sprint Planning          → PLAN.md + PRD
[3a+] Secrets Pre-Conditions   → inject unresolved secrets into PLAN.md
[3b]  Design & Architecture    → TDD.md
[3b+] Secrets Gate             → blocking retrieval tasks for pending secrets
[3c]  Implementation           → source files + SUMMARY.md
[3d]  Code Review              → review findings (inline) + doc coverage check
[3e]  QA Validation            → VERIFICATION.md
[3f]  UAT                      → UAT results (in VERIFICATION.md)
[3g]  Merge to Main            → git commit + PR
[3h]  Documentation Check      → auto-update API docs if endpoints changed
```

---

## Phase 4: Review & Retro (/review)

**Command:** `/cks:review [phase]`
**Template:** `skills/prd/templates/review.md`, `skills/prd/templates/backlog.md`

| File | Created By Step | Purpose |
|------|----------------|---------|
| `.prd/phases/{NN}-{name}/{NN}-REVIEW.md` | [4a] + [4b] | Feedback log + retrospective notes |
| `.prd/phases/{NN}-{name}/{NN}-BACKLOG.md` | [4c] Backlog Refinement | Items to fix (only if iterating) |
| `.learnings/session-log.md` | [4b] Retrospective | Append-only retro history |
| `.learnings/conventions.md` | [4b] Retrospective | Proposed conventions |
| `.learnings/gotchas.md` | [4b] Retrospective | Project-specific pitfalls |
| `.learnings/metrics.md` | [4b] Retrospective | Velocity tracking |
| `.prd/PRD-STATE.md` | [4d] Iteration Decision | Updated: status + routing |
| `.prd/PRD-ROADMAP.md` | [4d] Iteration Decision | Updated based on decision |

### Iteration Routing from [4d]

| Decision | STATE.md Status | Next Command | Uses |
|----------|----------------|-------------|------|
| Release | `reviewed` | `/cks:release` | — |
| Iterate: Design | `iterating_design` | `/cks:design` | BACKLOG.md |
| Iterate: Sprint | `iterating_sprint` | `/cks:sprint` | BACKLOG.md |
| Re-discover | `iterating_discover` | `/cks:discover` | — |

### Iteration Artifacts

When sprinting in iteration mode, artifacts use an `-iter{N}` suffix to preserve history:

| Artifact | First Sprint | Iteration #{N} |
|----------|-------------|----------------|
| Plan | `{NN}-PLAN.md` | `{NN}-PLAN-iter{N}.md` |
| Summary | `{NN}-SUMMARY.md` | `{NN}-SUMMARY-iter{N}.md` |
| Verification | `{NN}-VERIFICATION.md` | `{NN}-VERIFICATION-iter{N}.md` |
| TDD | `{NN}-TDD.md` | Updated in place (if needed) |
| Commit | `feat(phase-{NN}): ...` | `fix(phase-{NN}): ... — Iteration #{N}` |
| PR title | `PRD-{NNN}: Feature` | `PRD-{NNN}: Feature — Iteration #{N}` |

STATE.md tracks `iteration_count` which increments on each cycle through Review [4d] → Sprint.

---

## Phase 5: Release Management (/release)

**Command:** `/cks:release [phase|all]`
**Agent:** deployer, security-auditor
**References:** `release-checklist.md`, `performance-testing.md`, `security-checklist.md`

| File | Created By Step | Purpose |
|------|----------------|---------|
| `CHANGELOG.md` | [5e] Post-Deploy | Auto-generated from git history |
| `docs/api/**` | [5e] Post-Deploy | API documentation refreshed (doc-generator agent) |
| `docs/architecture/**` | [5e] Post-Deploy | Architecture docs refreshed |
| `docs/components/**` | [5e] Post-Deploy | Component docs refreshed |
| `docs/onboarding.md` | [5e] Post-Deploy | Developer onboarding guide refreshed |
| `CLAUDE.md` | [5e] Post-Deploy | Updated: new deps, env vars, conventions |
| `.learnings/*` | [5e] Post-Deploy (auto-retro) | Session learnings |
| `.prd/PRD-STATE.md` | [5e] Post-Deploy | Updated: status = `released` |
| `.prd/PRD-ROADMAP.md` | [5e] Post-Deploy | Updated: phase = "Released" |
| `docs/prds/PRD-{NNN}-{name}.md` | [5e] Post-Deploy | Updated: status = "Complete" |

### Release Sub-Steps

```
[5a] Dev Deploy + Internal Validation     → preview URL
[5b] Staging Deploy + Feedback            → staging URL
[5c] RC Deploy + E2E Regression Suite     → RC URL + test results
[5d] Production Deploy + Smoke Test       → production URL
[5e] Post-Deploy (changelog, CLAUDE.md, monitoring, retro)
```

### Quality Gates

| Gate | From → To | Key Requirements |
|------|-----------|-----------------|
| Gate 1 | Dev → Staging | Unit + integration tests pass, acceptance criteria met, code review done |
| Gate 2 | Staging → RC | Real user feedback positive, error rate acceptable, bugs triaged |
| Gate 3 | RC → Production | E2E regression suite passes, performance targets met, security sign-off, rollback ready |
| Gate 4 | Post-Production | Smoke test, E2E on prod, error rate stable, monitoring active |

---

## Complete File Tree (One Feature, Full Lifecycle)

```
.prd/
├── PRD-PROJECT.md                              ← bootstrap
├── PRD-REQUIREMENTS.md                         ← bootstrap + Phase 3 [3a]
├── PRD-STATE.md                                ← every step
├── PRD-ROADMAP.md                              ← every step
└── phases/
    └── 01-user-authentication/
        ├── 01-CONTEXT.md                       ← Phase 1 (10 Elements)
        ├── 01-SECRETS.md                       ← Phase 1 Step 4b (secrets manifest)
        ├── 01-DESIGN.md                        ← Phase 2 (summary)
        ├── design/
        │   ├── ux-flows.md                     ← Phase 2 [2a]
        │   ├── screens/
        │   │   ├── login/
        │   │   │   ├── screenshot.png          ← Phase 2 [2b]
        │   │   │   ├── source.html             ← Phase 2 [2b]
        │   │   │   └── variants/
        │   │   │       └── mobile.html         ← Phase 2 [2c]
        │   │   └── register/
        │   │       ├── screenshot.png          ← Phase 2 [2b]
        │   │       └── source.html             ← Phase 2 [2b]
        │   ├── component-specs.md              ← Phase 2 [2d]
        │   └── review-signoff.md               ← Phase 2 [2e]
        ├── 01-PLAN.md                          ← Phase 3 [3a]
        ├── 01-TDD.md                           ← Phase 3 [3b]
        ├── 01-SUMMARY.md                       ← Phase 3 [3c]
        ├── 01-VERIFICATION.md                  ← Phase 3 [3e]
        ├── 01-REVIEW.md                        ← Phase 4 [4a-4b]
        └── 01-BACKLOG.md                       ← Phase 4 [4c] (if iterating)

docs/
├── ROADMAP.md                                  ← bootstrap
├── feature-development-framework.md            ← reference doc
├── onboarding.md                               ← Phase 5 [5e] (doc-generator)
├── api/
│   ├── README.md                               ← Phase 3 [3h] / Phase 5 [5e]
│   ├── endpoints/{resource}.md                 ← Phase 3 [3h] / Phase 5 [5e]
│   └── openapi.yaml                            ← Phase 5 [5e] (optional)
├── architecture/
│   ├── README.md                               ← Phase 5 [5e] (doc-generator)
│   ├── data-flow.md                            ← Phase 5 [5e]
│   └── decisions.md                            ← Phase 5 [5e]
├── components/
│   ├── README.md                               ← Phase 5 [5e] (doc-generator)
│   └── {module}.md                             ← Phase 5 [5e]
└── prds/
    └── PRD-001-user-authentication.md          ← Phase 3 [3a]

.context/
├── nextjs.md                                   ← bootstrap / Phase 1
├── supabase.md                                 ← bootstrap / Phase 1
└── stripe.md                                   ← bootstrap / Phase 1

.learnings/
├── session-log.md                              ← Phase 4 [4b]
├── conventions.md                              ← Phase 4 [4b]
├── gotchas.md                                  ← Phase 4 [4b]
└── metrics.md                                  ← Phase 4 [4b]

.kickstart/                                     ← /kickstart (one-time)
├── context.md
├── research.md
└── artifacts/
    ├── PRD.md
    ├── ERD.md
    ├── ARCHITECTURE.md
    └── FEATURE-ROADMAP.md

CHANGELOG.md                                    ← Phase 5 [5e]
CLAUDE.md                                       ← bootstrap + Phase 5 [5e]
```

---

## Templates & References

### Templates (used by agents to create artifacts)

| Template | Used By | Creates |
|----------|---------|---------|
| `context.md` | prd-discoverer | {NN}-CONTEXT.md |
| `secrets/_manifest-format.md` | secrets hook | {NN}-SECRETS.md |
| `design-summary.md` | prd-designer | {NN}-DESIGN.md |
| `tdd.md` | prd-planner | {NN}-TDD.md |
| `prd.md` | prd-planner | PRD-{NNN}-{name}.md |
| `review.md` | /review workflow | {NN}-REVIEW.md |
| `backlog.md` | /review workflow | {NN}-BACKLOG.md |
| `project.md` | /bootstrap | PRD-PROJECT.md |
| `requirements.md` | /bootstrap | PRD-REQUIREMENTS.md |
| `roadmap.md` | /bootstrap | PRD-ROADMAP.md |
| `state.md` | /bootstrap | PRD-STATE.md |

### References (consulted by agents for standards)

| Reference | Consulted By | During |
|-----------|-------------|--------|
| `design-patterns.md` | prd-designer | Phase 2 |
| `testing-strategy.md` | prd-discoverer, prd-verifier | Phase 1 [1f], Phase 3 [3e] |
| `uat-patterns.md` | prd-discoverer | Phase 1 [1g], Phase 3 [3f] |
| `verification-patterns.md` | prd-verifier | Phase 3 [3e] |
| `prd-template.md` | prd-planner | Phase 3 [3a] |
| `roadmap-format.md` | prd-planner | Phase 3 [3a] |
| `release-checklist.md` | deployer | Phase 5 [5a-5d] |
| `performance-testing.md` | deployer | Phase 5 [5c] |
| `security-checklist.md` | security-auditor | Phase 3 [3d], Phase 5 [5c] |

---

## Agent Roster

| Agent | Phase | Primary Output |
|-------|-------|---------------|
| prd-discoverer | Phase 1 | {NN}-CONTEXT.md |
| prd-designer | Phase 2 | {NN}-DESIGN.md + design/ directory |
| prd-planner | Phase 3 [3a-3b] | PLAN.md + TDD.md + PRD |
| prd-executor | Phase 3 [3c] | Source code + SUMMARY.md |
| reviewer | Phase 3 [3d] | Review findings |
| prd-verifier | Phase 3 [3e] | VERIFICATION.md |
| db-migration | Phase 3 [3c] / Phase 5 | Migration files |
| security-auditor | Phase 3 [3d] / Phase 5 [5c] | Security scan report |
| deployer | Phase 5 [5a-5d] | Deployment artifacts |
| prd-orchestrator | Autonomous | Orchestrates all agents |
| prd-researcher | Utility | Codebase/tech research |
| prd-refactorer | Utility | Refactoring with safety checks |
| retrospective | Phase 4 [4b] | .learnings/* |
| doc-generator | Phase 3 [3h] / Phase 5 [5e] | docs/* (API, architecture, components, onboarding) |
| deep-researcher | Utility | .research/* |
| no-code-specialist | Standalone | Workflow blueprints (n8n, Make, Workato, Zapier) |

---

## Valid Phase Statuses (STATE.md)

| Status | Meaning | Set By | Next Command |
|--------|---------|--------|-------------|
| `not_started` | Phase created | /new | `/cks:discover` |
| `discovering` | Phase 1 in progress | /discover | `/cks:discover` |
| `discovered` | Phase 1 complete | /discover | `/cks:design` |
| `designing` | Phase 2 in progress | /design | `/cks:design` |
| `designed` | Phase 2 complete | /design | `/cks:sprint` |
| `sprinting` | Phase 3 in progress | /sprint | `/cks:sprint` |
| `sprinted` | Phase 3 complete | /sprint | `/cks:review` |
| `reviewing` | Phase 4 in progress | /review | `/cks:review` |
| `reviewed` | Phase 4 complete | /review | `/cks:release` |
| `releasing` | Phase 5 in progress | /release | `/cks:release` |
| `released` | Phase 5 complete | /release | `/cks:new` |
| `iterating_discover` | Loop back to Phase 1 | /review [4d] | `/cks:discover` |
| `iterating_design` | Loop back to Phase 2 | /review [4d] | `/cks:design` |
| `iterating_sprint` | Loop back to Phase 3 | /review [4d] | `/cks:sprint` |

---

*Built during Cloud Starter Project — March 2026*
