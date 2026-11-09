---
description: "Investigate an issue — find root cause, explain what's wrong, and propose a fix"
---

# Investigate Issue Workflow

## Purpose
Investigate a bug, error, or unexpected behavior. Find the root cause, explain it in plain English, and propose a fix.

## Steps

### 1. Understand the Problem

Ask the user (only if not already described):
- **What's happening?** (What's the unexpected behavior?)
- **What should be happening?** (What did you expect?)
- **When did it start?** (After what change?)
- **How often?** (Always, sometimes, specific conditions?)
- **Any error messages?** (Screenshots, logs, stack traces)

### 2. Gather Evidence

- **Read error logs:** Check log files, console output, error tracking (Sentry, etc.)
- **Read stack traces:** Identify the exact file, function, and line
- **Check recent changes:** `git log --oneline -20`, `git diff HEAD~5`
- **Check environment:** Different behavior in dev vs production?
- **Reproduce:** Try to reproduce the issue locally

### 3. Trace the Root Cause

Follow the evidence to find the root cause:

1. **Start from the error:** What file/line is the error on?
2. **Trace backwards:** What called that function? What passed the bad data?
3. **Find the origin:** Where does the bad data or logic start?
4. **Verify:** Can you reproduce the issue with this root cause?
5. **Check for related issues:** Is this pattern repeated elsewhere?

**Root cause categories:**
- **Logic error:** Wrong condition, wrong calculation, wrong order
- **Data error:** Null/undefined, wrong type, missing field, unexpected format
- **Integration error:** API changed, third-party service down, version mismatch
- **State error:** Race condition, stale cache, session expired
- **Configuration error:** Wrong env var, missing config, wrong URL
- **Security error:** Missing auth check, injection, permission bypass

### 4. Classify the Issue

- **Severity:**
  - **Critical:** Data loss, security breach, production down
  - **High:** Feature broken, affects many users
  - **Medium:** Feature partially broken, workaround exists
  - **Low:** Cosmetic, edge case, affects few users
- **Scope:** How many users/features are affected?
- **Urgency:** Does this need an immediate fix or can it wait?

### 5. Propose a Fix

For the root cause found:
1. **Describe the fix in plain English:** "The problem is X. The fix is to do Y."
2. **Estimate effort:** How complex is the fix? (1 line, 1 function, 1 file, multiple files)
3. **Identify risks:** Could the fix break anything else?
4. **Check for similar issues:** Is this pattern repeated elsewhere? Should we fix those too?
5. **Propose test:** What test would prevent this from happening again?

### 6. Generate Report

Write investigation report to `.phases/INVESTIGATION-REPORT.md`:

```markdown
# Investigation Report

**Date:** {date}
**Issue:** {plain English description}

## What's Happening

{plain English explanation of the problem}

## What Should Be Happening

{plain English explanation of expected behavior}

## Root Cause

{plain English explanation of why it's happening}

**Root cause category:** {logic/data/integration/state/configuration/security}
**Origin:** {file}:{line} — {function/variable}

## Evidence

1. {evidence item 1 — log, stack trace, code snippet}
2. {evidence item 2}
3. {evidence item 3}

## Severity

- **Level:** {Critical/High/Medium/Low}
- **Scope:** {how many users/features affected}
- **Urgency:** {immediate/can wait}

## Proposed Fix

{plain English description of the fix}

- **Effort:** {1 line / 1 function / 1 file / multiple files}
- **Risks:** {what could break}
- **Similar issues:** {yes/no — where}
- **Prevention test:** {what test to add}

## Next Steps

1. {first step}
2. {second step}
3. {third step}
```

### 7. Present to User

Show the user a plain-English summary:
- "I found the problem: {plain English root cause}"
- "It's happening because: {plain English explanation}"
- "The fix is: {plain English fix description}"
- "It's a {severity} issue affecting {scope}"
- "Want me to fix it? I can do that right now."

If the user says yes → automatically run the fix:
1. Write a test that reproduces the bug
2. Fix the root cause with minimal changes
3. Verify the test passes
4. Check for regressions
5. Create a PR
6. Show the user what was fixed

## Rules
- **Plain English only** — no jargon in user-facing messages
- **Always find the root cause** — don't stop at symptoms
- **Always provide evidence** — don't guess without proof
- **Always propose a fix** — don't just report the problem
- **Always offer to fix** — don't just investigate and leave
- **Minimal changes** — fix the root cause, don't refactor
- **Add a regression test** — prevent it from happening again
- **If you can't find the root cause** — say so honestly, explain what you checked, and suggest next steps
