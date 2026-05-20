# Definition of Done

"Done" means artifacts exist, quality bar is met, and evidence is shown. These three
conditions must all be true before any phase, task, or sprint is declared complete.

## Done = Artifacts + Quality Bar + Evidence, per Phase

### Phase 1 — Discover
- CONTEXT.md written with all 12 elements answered
- Acceptance criteria are verifiable: each one can be tested true/false
- DoD field [1i] contains measurable outcomes — not "users will be happy"
- If COMPLIANCE-SURFACE.md was generated: each required artifact is either accepted or explicitly deferred with a stated reason

### Phase 2 — Plan
- PLAN.md references specific files, functions, or APIs (not just "update the backend")
- Every step traces back to an acceptance criterion in CONTEXT.md
- DoD field filled with measurable outcomes, not "code complete"

### Phase 3 — Sprint
- PLAN.md → SUMMARY.md → VERIFICATION.md artifact chain all exist and are populated
- All unit/integration tests pass (with output shown)
- De-sloppify pass ran (debug artifacts removed)
- Code review passed (no blocking findings)
- Functional E2E verification ran and passed — or explicitly noted "prototype — skipped"

### Phase 4 — Review
- Sprint summary written covering what was built, what was skipped, and why
- Retrospective captured at least one learning
- Iteration decision made explicitly: release / iterate / re-discover
- No open blocking issues unless explicitly accepted with a stated reason

### Phase 5 — Release
- Deployed to target environment
- Health check confirmed green post-deploy
- Post-deploy monitoring shows no error rate spike
- If COMPLIANCE-SURFACE.md exists: all required (non-deferred) artifacts verified present

---

## Not Done — Rejection Scan

Any of these signals means work is **not done**, regardless of what was declared:

- Evidence is "looks good" or "should work" — speculation is not evidence
- Artifacts exist but contain placeholder text or empty sections
- Tests pass but the feature was never run against real inputs
- SUMMARY.md describes what was *intended*, not what was *actually built*
- A phase declared complete before prior phase's artifacts exist
- Acceptance criteria marked done without showing verification output
- Functional E2E track absent and no explicit "prototype — skipped" note

---

## Relationship to Other Rules

- `verification.md` → **HOW to check** (run these commands, show this output)
- `definition-of-done.md` → **WHAT done means** (artifacts + quality bar + evidence)
- `engineering-discipline.md` → **HOW to work** (simplicity, minimal impact, root cause)

These three are complementary. DoD defines the target. Verification enforces the check.
Discipline governs the work. None replaces the others.
