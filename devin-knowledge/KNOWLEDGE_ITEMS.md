# Devin Knowledge Items — CKS Principles

## How to Use

Add each knowledge item below to Devin's Knowledge system (Settings & Library → Knowledge → Create Knowledge). Set the trigger description as specified for each item.

---

## Knowledge Item 1: 5-Phase Lifecycle

**Trigger:** "When starting a new feature, building something, or planning work"

**Content:**

Every feature follows a 5-phase lifecycle: discover → design → sprint → review → release.

1. **Discover:** Gather 11 elements (problem, stories, scope, API, criteria, constraints, tests, UAT, DoD, KPIs, deps, architecture tier). Output: CONTEXT.md
2. **Design:** Create UX flows, screens, components, data models, API contracts. Output: DESIGN.md
3. **Sprint:** Plan → implement (TDD) → verify → merge. Output: PLAN.md, SUMMARY.md, VERIFICATION.md
4. **Review:** Sprint review, retrospective, iteration decision. Output: REVIEW.md
5. **Release:** Dev → Staging → RC → Production with quality gates. Output: RELEASE.md

State is tracked in `.phases/PRD-STATE.json`. All artifacts go in `.phases/{feature_id}/`.

Never skip phases. Never implement without design. Never deploy without verification.

---

## Knowledge Item 2: Engineering Discipline

**Trigger:** "When writing code, making changes, or implementing features"

**Content:**

Follow these engineering principles:

- **Minimal changes:** Prefer single-line fixes. Don't refactor code you weren't asked to change.
- **Root cause fixes:** Fix the root cause, not the symptom. Don't add workarounds.
- **TDD first:** Write failing tests before implementation. Make tests pass. Refactor.
- **Atomic commits:** One logical change per commit. Descriptive messages.
- **No silent assumptions:** State your assumptions explicitly. Ask when uncertain.
- **Don't over-engineer:** Use the simplest solution that works. YAGNI.
- **Verify before claiming done:** Run tests, lint, type checks. Provide evidence.
- **Never delete tests:** Tests are regression protection. Weaken them only with explicit direction.

---

## Knowledge Item 3: State Management

**Trigger:** "When working on a feature, checking progress, or resuming work"

**Content:**

Project state lives in `.phases/PRD-STATE.json`. This file is the source of truth.

Schema:
```json
{
  "feature_id": "F-01",
  "feature_name": "user-auth",
  "current_phase": "discover|design|sprint|review|release",
  "phase_status": "not_started|in_progress|complete|blocked|iterating_*",
  "iteration_count": 0,
  "max_iterations": 3,
  "artifacts": {
    "context": ".phases/F-01/CONTEXT.md",
    "design": null,
    "plan": null,
    "summary": null,
    "verification": null,
    "review": null,
    "release": null
  },
  "last_action": "Started discovery phase",
  "last_action_date": "2024-01-01",
  "next_action": "Complete problem statement",
  "suggested_command": "/discover"
}
```

Always read state before starting work. Always update state after completing a step. The filesystem is truth — re-scan artifacts, don't trust stale state.

---

## Knowledge Item 4: Quality Gates

**Trigger:** "When verifying, reviewing, deploying, or before declaring work done"

**Content:**

Quality gates are mandatory checkpoints:

**Sprint gates:**
- All acceptance criteria must pass
- All tests must pass (unit, integration, E2E)
- Lint and type checks must pass
- Code review must be approved

**Release gates:**
- Health checks pass at each environment
- E2E tests pass before RC
- Monitoring configured before production
- Rollback plan documented before production
- Production deployment requires explicit human confirmation

**Iteration gates:**
- Max 3 sprint iterations before escalating
- Max 1 review iteration in autonomous mode
- Failed gates trigger iteration, not skipping

Never skip a quality gate. If a gate fails, iterate to fix it.

---

## Knowledge Item 5: Intent Classification

**Trigger:** "When receiving a user message or instruction"

**Content:**

Classify every user message into one of three classes before acting:

1. **Converse:** Questions, advice, explanations, chat. Answer directly. Don't dispatch workflows or force clarifications.
2. **Dispatch:** Clear lifecycle action (create, build, deploy, fix, review). Route to the appropriate workflow.
3. **Clarify:** Action intended but ambiguous. Ask for clarification with specific options.

Routing table:
- "create|start|new|build" → discover workflow
- "plan|design|architect" → design workflow
- "sprint|implement|code" → sprint workflow
- "review|retro" → review workflow
- "deploy|release|ship" → release workflow
- "fix|debug|broken|bug" → fix bug playbook
- "status|progress" → status workflow

If confidence < 80%, ask for clarification. Never guess.

---

## Knowledge Item 6: Product Maturity Stages

**Trigger:** "When determining architecture tier, planning testing, or setting quality standards"

**Content:**

Every feature has a maturity stage with escalating quality gates:

- **Prototype:** Happy path works. Speed and validation. Skip deep testing and monitoring.
- **Pilot:** Real users touching it. Add auth, error handling, basic security, validation.
- **Candidate:** Release candidate. Full testing, performance, accessibility, CI/CD, monitoring.
- **Production:** Live and maintained. Security hardening, observability, rollback plans.

Determine the tier during discovery (element 12). The tier controls what quality gates apply. Don't over-engineer a Prototype with Production-level gates. Don't skip Production gates on a Production-tier feature.

---

## Knowledge Item 7: Code Review Standards

**Trigger:** "When reviewing code, checking PRs, or verifying implementation"

**Content:**

Code review checklist:

1. **Correctness:** Does the code do what it's supposed to? Are edge cases handled?
2. **Security:** Any vulnerabilities? Secrets exposed? Input validated? Auth checked?
3. **Performance:** N+1 queries? Unnecessary re-renders? Memory leaks? Large bundles?
4. **Maintainability:** Readable code? Clear names? Simple logic? Single responsibility?
5. **Test coverage:** Are edge cases covered? Are tests meaningful (not just smoke tests)?
6. **Style:** Follows project conventions? Consistent formatting?

For each finding: cite specific file and line, explain the issue, suggest a specific fix. Classify as critical / high / medium / low. Be constructive, not critical.

---

## Knowledge Item 8: Deployment Safety

**Trigger:** "When deploying, releasing, or pushing to production"

**Content:**

Deployment safety rules:

1. **Always have a rollback plan** before deploying. Document: how to rollback, who to contact, what to monitor.
2. **Gradual rollout:** dev → staging → RC → production. Never skip environments.
3. **Health checks at each stage:** If any check fails, stop. Don't proceed to next environment.
4. **Monitoring before production:** Configure error tracking, performance monitoring, uptime checks before deploying to production.
5. **Explicit confirmation for production:** Never auto-deploy to production. Always ask the user to confirm.
6. **Watch after deploy:** Monitor for 15 minutes after production deploy. If issues, rollback immediately.
7. **Atomic deployments:** One feature per deployment. Don't bundle changes.

---

## Knowledge Item 9: Anti-Patterns

**Trigger:** "When writing code, planning architecture, or making design decisions"

**Content:**

Avoid these anti-patterns:

1. **Fat commands/workflows:** Don't embed domain logic in dispatchers. Keep workflows thin.
2. **God agents:** Don't create one component that does everything. Specialist components with clear responsibilities.
3. **Context bloat:** Don't let context grow unbounded. Use state on disk, reset between phases.
4. **Auto-proceed:** Don't assume intent and proceed without confirmation on critical decisions.
5. **Skipping gates:** Don't bypass quality gates for speed. Gates exist to prevent bugs.
6. **Solution-first:** Don't start with the solution. Start with the problem.
7. **Over-scoping:** Don't include nice-to-haves in first iteration. Keep scope minimal.
8. **Silent assumptions:** Don't assume without stating. Ask when uncertain.
9. **Blind re-runs:** Don't re-run failed implementations without understanding why. Fix the root cause.
10. **Deleting tests:** Don't delete or weaken tests to make them pass. Fix the code instead.
