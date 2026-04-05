---
name: product-maturity
description: >
  Product maturity stage management — defines quality gates for Prototype, Pilot,
  Candidate, and Production stages. Use when: starting a new project, during
  discovery phase, before deployment, when deciding what to test or secure, when
  promoting between environments, or when the user asks 'is this ready for
  production'.
allowed-tools: Read, Grep, Glob, AskUserQuestion
---

# Product Maturity

## Overview

Four maturity stages define what quality gates apply at each point in a product's lifecycle. This prevents both over-engineering prototypes and under-engineering production systems. Every project has a current stage — know it, enforce it, promote deliberately.

## When to Use

- Starting a new project (set the initial stage)
- Discovery or design phase (calibrate expectations)
- Before any deployment (check gates for current stage)
- Deciding what to test, secure, or monitor
- Promoting between environments
- User asks "is this ready for production?"

## When NOT to Use

- Internal tooling that will never face real users (apply judgment)
- One-off scripts or throwaway experiments

## Process

### 1. Identify Current Stage

Ask the user or infer from project state. When uncertain, ask:

> What stage is this project at? (Prototype / Pilot / Candidate / Production)

### 2. Apply Stage Gates

#### PROTOTYPE — Speed and Validation

| Requirement | Status |
|---|---|
| Happy path works end-to-end | Required |
| Basic error handling (no crashes) | Required |
| Hardcoded configs | Acceptable |
| Authentication | Optional (basic if needed) |
| Deep testing | Skip |
| Monitoring, CI/CD | Skip |
| Security hardening | Skip |

**Goal:** Prove the idea works. Nothing else matters yet.

#### PILOT — Real Users

| Requirement | Status |
|---|---|
| Authentication (min email/password) | Required |
| Input validation on all forms | Required |
| Error pages (404, 500, generic) | Required |
| HTTPS, no secrets in code, parameterized queries | Required |
| Environment separation (dev + prod minimum) | Required |
| Full test suite | Skip |
| Performance optimization | Skip |
| Accessibility audit | Skip |

**Goal:** Safe enough for real humans. Not polished, but not dangerous.

#### CANDIDATE — Release Candidate

| Requirement | Status |
|---|---|
| Full test suite (unit + integration + key E2E) | Required |
| Performance baseline (Core Web Vitals measured) | Required |
| Accessibility audit (WCAG 2.1 AA basics) | Required |
| CI/CD pipeline (build + test + deploy) | Required |
| Monitoring (error tracking + health endpoint) | Required |
| Database migrations tested | Required |
| API documentation | Required |

**Goal:** Could ship tomorrow. Gaps are known and tracked.

#### PRODUCTION — Live

| Requirement | Status |
|---|---|
| Security hardening (OWASP Top 10, dependency audit, CSP) | Required |
| Observability (structured logging, error tracking, uptime, alerting) | Required |
| Backup and recovery plan | Required |
| Rollback procedure documented and tested | Required |
| Load testing results | Required |
| Documentation (README, API docs, ADRs) | Required |
| Incident response plan | Required |

**Goal:** Survives failure, scales under load, recoverable by anyone on the team.

### 3. Stage Promotion

To promote from one stage to the next:
1. Run the gate checklist for the target stage
2. Flag any unmet requirements
3. Ask the user to confirm promotion or address gaps
4. Record the promotion decision and any accepted risks

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "We'll add tests before launch" | You will not. Test debt compounds. |
| "It's just a prototype, security doesn't matter" | Prototypes become pilots overnight. Build the habit early. |
| "Monitoring can wait" | You cannot fix what you cannot see. |
| "We don't need rollback for this" | Every deployment that cannot roll back is a bet against Murphy. |
| "Documentation is for later" | Later never comes. Document as you build. |

## Red Flags

- Deploying to real users without authentication
- No error handling beyond console.log
- Production system with no monitoring or alerting
- No environment separation (dev changes hit prod)
- Skipping all testing because "it's just a prototype" (basic smoke tests always apply)
- Promoting stages without checking gates

## Verification

- [ ] Current maturity stage is identified and agreed upon
- [ ] Only the gates for the current stage are enforced (not over-engineering)
- [ ] All gates for the current stage are met (not under-engineering)
- [ ] Promotion decisions are explicit, not accidental
- [ ] Accepted risks (if any) are documented
