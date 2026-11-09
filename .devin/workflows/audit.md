---
description: "Audit a codebase for quality, security, performance, and maintainability issues"
---

# Codebase Audit Workflow

## Purpose
Find problems in an existing codebase — security vulnerabilities, performance issues, code smells, missing tests, and maintainability problems.

## Steps

### 1. Scan the Codebase

Read the project structure and identify:
- Language and framework
- File count and structure
- Dependencies (package.json, requirements.txt, etc.)
- Test coverage (if any)
- Existing linting/formatting config

### 2. Security Audit

Check for:
- **Exposed secrets:** API keys, passwords, tokens in code
- **Input validation:** Missing validation on user inputs
- **Authentication issues:** Weak auth, missing auth checks
- **Authorization issues:** Missing permission checks
- **Dependency vulnerabilities:** Known CVEs in dependencies
- **SQL injection:** Unparameterized queries
- **XSS:** Unescaped user content in templates
- **CSRF:** Missing CSRF tokens on forms
- **Hardcoded credentials:** In config files or code

For each finding:
- **Severity:** critical / high / medium / low
- **File and line number**
- **What's wrong** (plain English)
- **How to fix it** (plain English)

### 3. Performance Audit

Check for:
- **N+1 queries:** Database queries in loops
- **Missing indexes:** Slow database queries
- **Large bundles:** Unnecessary dependencies, missing tree-shaking
- **No caching:** Repeated expensive operations
- **Memory leaks:** Event listeners not cleaned up, intervals not cleared
- **Blocking operations:** Synchronous I/O on main thread
- **Missing pagination:** Loading all records at once
- **Unoptimized images:** No lazy loading, no compression

### 4. Code Quality Audit

Check for:
- **Dead code:** Unused functions, imports, variables
- **Duplicate code:** Copy-pasted logic
- **Long functions:** Functions over 50 lines
- **Deep nesting:** More than 4 levels of indentation
- **Poor naming:** Unclear variable/function names
- **Missing error handling:** Unhandled promises, empty catch blocks
- **God objects:** Files/classes doing too many things
- **Tight coupling:** Components that should be independent

### 5. Test Audit

Check for:
- **Missing tests:** Critical paths without tests
- **Weak tests:** Tests that don't actually assert anything meaningful
- **No edge cases:** Missing tests for error states, empty inputs, boundary values
- **No integration tests:** Only unit tests, no integration
- **No E2E tests:** No tests for user flows
- **Flaky tests:** Tests that pass/fail randomly

### 6. Maintainability Audit

Check for:
- **Missing documentation:** No README, no inline docs for complex logic
- **Inconsistent patterns:** Different approaches to the same problem
- **No error tracking:** No Sentry, no logging
- **No monitoring:** No health checks, no uptime monitoring
- **No CI/CD:** No automated tests on PR
- **Outdated dependencies:** Major versions behind

### 7. Generate Report

Write audit report to `.phases/AUDIT-REPORT.md`:

```markdown
# Codebase Audit Report

**Date:** {date}
**Project:** {project name}

## Summary

- **Critical issues:** {count}
- **High issues:** {count}
- **Medium issues:** {count}
- **Low issues:** {count}
- **Overall health:** {Critical/Poor/Fair/Good/Excellent}

## Critical Issues (Fix Immediately)

### 1. {issue title}
- **File:** {file}:{line}
- **Category:** Security
- **What's wrong:** {plain English}
- **How to fix:** {plain English}

## High Issues (Fix Soon)

### 1. {issue title}
...

## Medium Issues (Fix When Convenient)

...

## Low Issues (Nice to Have)

...

## Recommendations (Prioritized)

1. {most important thing to fix first}
2. {second most important}
3. {third}

## What's Working Well

- {positive findings}
```

### 8. Present to User

Show the user a plain-English summary:
- "I found {N} issues in your codebase"
- "{N} critical, {N} high, {N} medium, {N} low"
- "The most important thing to fix is: {top issue}"
- "Want me to fix any of these? Just tell me which ones."

## Rules
- **Plain English only** — no jargon in user-facing messages
- **Every finding has evidence** — file, line, and explanation
- **Every finding has a fix suggestion** — don't just report problems
- **Prioritize by impact** — critical first, low last
- **Note what's working well** — not just problems
- **Offer to fix** — don't just report, offer to act
