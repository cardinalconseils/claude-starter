---
name: shipping-checklist
description: >
  Pre-launch readiness checklist for production deployment. Use when: preparing to
  deploy, promoting to production, running release quality gates, or when the user
  asks 'are we ready to launch'. Covers code quality, security, performance,
  accessibility, infrastructure, and documentation gates.
allowed-tools: Read, Glob, Grep, Bash
---

# Shipping Checklist

## Overview

Six quality gates between your code and production. Every gate has pass/fail criteria. Skip gates deliberately based on your product maturity stage (see product-maturity skill), never based on gut feeling. A failed gate is a conversation, not a blocker — but shipping with known failures must be an explicit decision.

## When to Use

- Preparing to deploy to production
- Promoting from staging to production
- Running release quality gates in the CKS lifecycle
- User asks "are we ready to launch?"
- Pre-release audit before a version tag

## When NOT to Use

- Deploying to development or staging (lighter checks apply)
- Prototype stage (use product-maturity gates instead)
- Hotfix deployment (prioritize the fix, audit after)

## Process

### Gate 1: Code Quality

| Check | Status |
|---|---|
| All tests pass | [ ] |
| Build succeeds without warnings | [ ] |
| No TODO/FIXME/HACK in shipping code | [ ] |
| No console.log/print statements in production code | [ ] |
| No commented-out code blocks | [ ] |
| Lint passes with zero errors | [ ] |

**How to verify:** Run test suite, build command, and lint. Grep for TODO/FIXME/HACK and console.log/print in source directories.

### Gate 2: Security

| Check | Status |
|---|---|
| Dependency audit clean (no high/critical) | [ ] |
| No secrets in code or git history | [ ] |
| Authentication working (login, logout, session expiry) | [ ] |
| Input validation on all user-facing endpoints | [ ] |
| HTTPS enforced | [ ] |
| Security headers configured (CSP, HSTS, X-Frame-Options) | [ ] |

**How to verify:** Run `npm audit` / `pip-audit`. Search for hardcoded keys. Test auth flows manually. Check response headers.

### Gate 3: Performance

| Check | Status |
|---|---|
| Core Web Vitals meeting targets (LCP < 2.5s, INP < 200ms, CLS < 0.1) | [ ] |
| No N+1 queries (check with query logging) | [ ] |
| Images optimized (WebP, lazy loading, sized correctly) | [ ] |
| Bundle size reasonable (< 200KB initial JS for web apps) | [ ] |

**How to verify:** Run Lighthouse audit. Enable query logging and check counts. Analyze bundle with bundlesize tool.

### Gate 4: Accessibility

| Check | Status |
|---|---|
| Keyboard navigation works for all interactive elements | [ ] |
| Screen reader compatibility (test with VoiceOver/NVDA) | [ ] |
| Color contrast meets WCAG AA (4.5:1 text, 3:1 large) | [ ] |
| All form inputs have visible labels | [ ] |

**How to verify:** Tab through the entire app. Run axe-core or Lighthouse a11y audit. Check contrast with devtools.

### Gate 5: Infrastructure

| Check | Status |
|---|---|
| Environment variables set in production | [ ] |
| Database migrations applied | [ ] |
| Health endpoint responding (/health) | [ ] |
| Error tracking configured (Sentry/similar) | [ ] |
| Backup/recovery procedure documented | [ ] |

**How to verify:** Check platform env vars. Run migration status command. Curl health endpoint. Trigger a test error in Sentry.

### Gate 6: Documentation

| Check | Status |
|---|---|
| README current and accurate | [ ] |
| Changelog updated | [ ] |
| API documentation current (if applicable) | [ ] |
| Environment setup documented for new developers | [ ] |

**How to verify:** Read the README as a new developer. Check changelog has the latest version. Review API docs against actual endpoints.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "We can fix it after launch" | Post-launch fixes happen under pressure with users watching. Fix it now. |
| "Most of this doesn't apply to us" | Skip gates based on maturity stage (product-maturity skill), not gut feeling. |
| "Users won't notice" | Users notice broken images, slow loads, and inaccessible forms. They just don't report them — they leave. |
| "We've tested it locally" | Local testing misses environment config, network latency, and real-world data volumes. |
| "It's just a small change" | Small changes cause the majority of production incidents. The checklist is fast for small changes. |

## Red Flags

- Skipping all gates because "we need to ship today"
- No one can explain what the health endpoint checks
- Last dependency audit was months ago
- Zero accessibility testing ever performed
- README describes a different version of the app
- Production env vars copied from development

## Verification

- [ ] All 6 gates evaluated (pass, fail, or explicitly skipped with reason)
- [ ] No critical/high security vulnerabilities in dependencies
- [ ] Tests pass and build succeeds
- [ ] Skipped gates are justified by product maturity stage
- [ ] Known failures are documented as accepted risks
- [ ] Ship/no-ship decision is explicit, not assumed
