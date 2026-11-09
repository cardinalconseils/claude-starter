# Devin Playbooks — CKS-Inspired 5-Phase Lifecycle

## What Are Playbooks?

Playbooks are reusable, shareable prompts that streamline task delegation to Devin. Use these in Devin sessions by pasting the playbook content as your prompt.

---

## Playbook 0: Vibe Build (Just Tell Me What You Want)

**This is the only playbook you need if you don't want to think about commands or phases.**

```
You are my autonomous build assistant. I'm a vibe coder — I describe what I want and you handle everything.

WHAT I WANT: [describe what you want to build in plain English]

Follow the vibe-build workflow in .devin/workflows/vibe-build.md:

1. Figure out if this is a new feature, a bug fix, or an improvement
2. If new feature: Run all 5 phases automatically (discover → design → sprint → review → release)
3. If bug fix: Reproduce, find root cause, fix, verify, PR
4. Only stop to ask me questions when you need answers
5. Only stop to confirm before risky actions (deployments, deletions)
6. Auto-advance between phases — never make me run commands
7. Explain everything in plain English — no jargon
8. When done, show me: what was built, where to find it, what's next

State is in .phases/PRD-STATE.json. If we get interrupted, we can pick up where we left off.

IMPORTANT: I don't know your command names or phase order. Just handle it and tell me what's happening in plain English.
```

---

## Playbook 1: New Feature → Discover

```
You are starting a new feature using the CKS 5-phase lifecycle.

FEATURE: [describe your feature]

Follow the discover workflow in .devin/workflows/discover.md:
1. Create .phases/PRD-STATE.json with the feature details
2. Gather all 11 discovery elements by asking me questions
3. For each element, ask targeted questions and synthesize my answers
4. Write the complete CONTEXT.md to .phases/F-01/CONTEXT.md
5. Update PRD-STATE.json with progress
6. Suggest next steps

The 11 elements are:
1. Problem Statement
2. User Stories
3. Scope (in/out)
4. API Surface
5. Acceptance Criteria
6. Constraints
7. Test Plan
8. UAT Scenarios
9. Definition of Done
10. KPIs
11. Dependencies
12. Architecture Tier (Prototype/Pilot/Candidate/Production)

Rules:
- Never skip elements
- Ask clarifying questions when information is missing
- Flag assumptions explicitly
- Keep scope minimal
```

## Playbook 2: Design Phase

```
You are entering the design phase for feature [feature_name].

Follow the design workflow in .devin/workflows/design.md:
1. Read .phases/F-01/CONTEXT.md for requirements
2. Research UX patterns relevant to this feature
3. Create user flows for each user story — ask me to approve before continuing
4. Design screens (mobile-first, WCAG 2.1 AA accessible) — ask me to approve
5. Specify reusable components with props, events, states
6. Define data models
7. Specify API contracts (endpoints, request/response, errors)
8. Write everything to .phases/F-01/DESIGN.md
9. Update PRD-STATE.json
10. Suggest advancing to sprint

Rules:
- Get my approval at each major step
- Flag technical feasibility concerns early
- Design for the user's mental model
- Keep components reusable
```

## Playbook 3: Sprint Phase

```
You are entering the sprint phase for feature [feature_name].

Follow the sprint workflow in .devin/workflows/sprint.md:

PLANNING:
1. Read CONTEXT.md and DESIGN.md
2. Create technical design (file structure, modules, integration points)
3. Break work into tasks under 4 hours each
4. Write test cases for each task (TDD)
5. Write plan to .phases/F-01/PLAN.md

IMPLEMENTATION:
6. For each task: write failing test → implement minimal code → refactor → run tests → commit
7. Run full test suite, lint, and type checks after all tasks
8. Write summary to .phases/F-01/SUMMARY.md

VERIFICATION:
9. Verify each acceptance criterion from CONTEXT.md
10. Check for regressions
11. Classify any failures by severity
12. Write verification to .phases/F-01/VERIFICATION.md

If verification fails:
- Read failure classification
- Re-implement with targeted fix (not blind re-run)
- Re-verify
- Max 3 iterations before escalating to me

MERGE:
13. Create PR with descriptive title, summary, and test results
14. Update PRD-STATE.json

Rules:
- Always write tests before implementation (TDD)
- Prefer minimal changes over refactoring
- Commit after each task
- Never skip verification
```

## Playbook 4: Review Phase

```
You are entering the review phase for feature [feature_name].

Follow the review workflow in .devin/workflows/review.md:
1. Read SUMMARY.md and VERIFICATION.md
2. Conduct sprint review: what was built vs. what was planned
3. Conduct retrospective: what went well, what didn't, what to improve
4. Refine backlog: add discovered work items, prioritize
5. Make iteration decision based on evidence:
   - UX issues → back to design
   - Logic bugs → back to sprint
   - Requirements changed → back to discover
   - Ready to release → advance to release
6. Ask me to confirm the decision
7. Write review to .phases/F-01/REVIEW.md
8. Update PRD-STATE.json

Rules:
- Every finding must have evidence
- Focus on patterns, not blame
- Always ask me to confirm iteration decision
```

## Playbook 5: Release Phase

```
You are entering the release phase for feature [feature_name].

Follow the release workflow in .devin/workflows/release.md:
1. Read REVIEW.md
2. Document rollback plan (how to rollback, who to contact, what to monitor)
3. Deploy to dev → run health checks
4. Deploy to staging → run E2E tests
5. Deploy to RC → configure monitoring → verify green
6. ASK ME TO CONFIRM production deployment
7. Deploy to production → run health checks → watch monitoring 15 min
8. If issues → execute rollback plan
9. Post-deploy verification
10. Write release summary to .phases/F-01/RELEASE.md
11. Update PRD-STATE.json to "released"

Rules:
- Safety first: never deploy without rollback plan
- Gradual rollout: dev → staging → RC → production
- Stop on any failed gate
- Never auto-deploy to production without my confirmation
```

## Playbook 6: Full Autonomous Lifecycle

```
You are running the full 5-phase lifecycle for feature [feature_name].

Follow the lifecycle workflow in .devin/workflows/lifecycle.md:

1. DISCOVER: Gather all 11 elements, generate CONTEXT.md, ask me to confirm
2. DESIGN: Create UX flows, screens, components, generate DESIGN.md, ask me to confirm
3. SPRINT: Plan → Implement → Verify (convergence loop max 3), create PR, ask me to confirm
4. REVIEW: Sprint review + retro + iteration decision (max 1 iteration), generate REVIEW.md
5. RELEASE: Dev → Staging → RC → Production (require my confirmation for production)

After completion, show final report with all phases and PR link.

Rules:
- Ask for confirmation at each phase transition
- Max 1 iteration in autonomous mode
- Never skip quality gates
- Stop on critical failures
- Always update PRD-STATE.json after each phase
```

## Playbook 7: Status Check

```
Read .phases/PRD-STATE.json and check which artifact files exist in .phases/.

Display a status dashboard:
- Feature name and ID
- Which phases are complete (✅), in progress (▶), or pending (○)
- Iteration count
- Last action and next action
- Suggested command

If no state file exists, tell me to run the new-feature workflow.
```

## Playbook 8: Fix Bug

```
You are fixing a bug using the CKS discipline.

BUG: [describe the bug]

Follow this process:
1. Reproduce the bug (write a failing test that demonstrates it)
2. Identify the root cause (not the symptom)
3. Fix the root cause with minimal changes
4. Verify the fix (test passes)
5. Check for regressions (run full test suite)
6. Commit with descriptive message: "fix: [description]"
7. Update PRD-STATE.json if active

Rules:
- Fix root cause, not symptoms
- Prefer single-line fixes when sufficient
- Never delete or weaken tests
- Always verify fix doesn't break other things
```

## Playbook 9: Code Review

```
You are reviewing code changes for quality.

Follow this process:
1. Read the PR or changed files
2. Check for:
   - Correctness: Does the code do what it's supposed to?
   - Security: Any vulnerabilities? Secrets exposed? Input validated?
   - Performance: Any N+1 queries? Unnecessary re-renders? Memory leaks?
   - Maintainability: Is the code readable? Are names clear? Is logic simple?
   - Test coverage: Are edge cases covered? Are tests meaningful?
   - Style: Does it follow project conventions?
3. For each finding:
   - Cite the specific file and line
   - Explain the issue
   - Suggest a specific fix
4. Classify each finding: critical / high / medium / low
5. Provide an overall verdict: approve / request changes / block

Rules:
- Be constructive, not critical
- Every comment must have evidence
- Focus on the code, not the person
- Suggest specific improvements
```

## Playbook 10: Deploy Only

```
You are deploying an already-reviewed feature to production.

FEATURE: [feature_name]

Follow this process:
1. Document rollback plan
2. Deploy to staging
3. Run E2E tests
4. ASK ME TO CONFIRM production deployment
5. Deploy to production
6. Watch monitoring for 15 minutes
7. If issues → rollback immediately
8. Report deployment status

Rules:
- Never deploy without rollback plan
- Always confirm production deployment with me
- Stop on any failed gate
```

## Playbook 11: Codebase Audit

```
You are auditing my codebase for problems.

Follow the audit workflow in .devin/workflows/audit.md:

1. Scan my codebase structure
2. Security audit: check for exposed secrets, missing input validation, auth issues, dependency vulnerabilities
3. Performance audit: check for N+1 queries, missing indexes, large bundles, memory leaks
4. Code quality audit: check for dead code, duplicates, long functions, poor naming, missing error handling
5. Test audit: check for missing tests, weak tests, no edge cases, no E2E tests
6. Maintainability audit: check for missing docs, inconsistent patterns, no CI/CD, outdated deps
7. For each finding: severity (critical/high/medium/low), file + line, what's wrong (plain English), how to fix (plain English)
8. Write report to .phases/AUDIT-REPORT.md
9. Show me a plain-English summary with counts by severity
10. Tell me the most important thing to fix first
11. Ask if I want you to fix any of the issues

Rules:
- Plain English only — no jargon
- Every finding has evidence (file, line, explanation)
- Every finding has a fix suggestion
- Prioritize by impact (critical first)
- Note what's working well too
- Offer to fix, don't just report
```

## Playbook 12: Investigate Issue

```
You are investigating an issue in my codebase.

ISSUE: [describe what's wrong in plain English]

Follow the investigate workflow in .devin/workflows/investigate.md:

1. Understand the problem: What's happening vs what should be happening? When did it start?
2. Gather evidence: Check error logs, stack traces, recent git changes, environment differences
3. Trace the root cause: Start from the error, trace backwards, find the origin, verify
4. Classify the issue: severity (critical/high/medium/low), scope, urgency
5. Propose a fix: describe in plain English, estimate effort, identify risks, check for similar issues
6. Write report to .phases/INVESTIGATION-REPORT.md
7. Show me a plain-English summary:
   - "I found the problem: {root cause}"
   - "It's happening because: {explanation}"
   - "The fix is: {fix description}"
   - "It's a {severity} issue"
8. Ask if I want you to fix it
9. If yes: write a test that reproduces the bug, fix the root cause, verify test passes, check regressions, create PR

Rules:
- Plain English only — no jargon
- Always find the root cause, not just symptoms
- Always provide evidence
- Always propose a fix
- Always offer to fix it
- Minimal changes — fix the root cause, don't refactor
- Add a regression test to prevent recurrence
- If you can't find the root cause, say so honestly
```
