# Code Review Checklist

The Sprint [3d] review checklist, output shape, and CONFIDENCE.md gate update. Ported from the
`reviewer` agent; used by the reviewer role in code-review mode.

## Inputs

- `pr_url` or `file_path` (or a diff range): what to review
- `focus_area` (optional): `security` | `performance` | `logic` | `design`
- Design specs from `.prd/phases/{NN}-{name}/{NN}-DESIGN.md` (if present)
- Acceptance criteria from `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md`

## Checklist

### Correctness
- [ ] Acceptance criteria met
- [ ] No logic bugs or missed edge cases
- [ ] Error handling covers expected failure modes
- [ ] Constraints and negative cases handled (Discovery Element 5)

### Security
- [ ] No hardcoded secrets or credentials
- [ ] Input validation on all user-facing endpoints
- [ ] SQL injection / XSS / CSRF protected
- [ ] Authentication/authorization checks in place
- [ ] No sensitive data in logs

Full security pass: `skills/security-hardening/references/audit-checklist.md`.

### Conventions
- [ ] Follows project conventions from `CLAUDE.md`
- [ ] Consistent naming, formatting, patterns
- [ ] No unnecessary dependencies added
- [ ] Tests follow the testing strategy (unit/integration/E2E)

### Design adherence (if Phase 2 completed)
- [ ] UI matches approved screen designs
- [ ] Component hierarchy follows component specs
- [ ] Design tokens used (not hardcoded values)
- [ ] Responsive behavior matches variants
- [ ] Accessibility requirements met

### Visual design (if HTML, CSS, or component files in the diff)
- [ ] `npx impeccable detect <changed-ui-files>` ran and output parsed
- [ ] Findings mapped per `skills/design-fluency/workflows/review.md`
- [ ] Prototype/Pilot: advisory only; Candidate/Production: blocking

### Documentation
- [ ] Public functions/methods have JSDoc/docstrings
- [ ] New API endpoints have docs (or `/cks:docs api` suggested)
- [ ] Complex logic has WHY comments, not WHAT
- [ ] README or onboarding guide still accurate
- [ ] No stale doc references to renamed/deleted code

### Performance
- [ ] No obvious N+1 queries
- [ ] No unnecessary re-renders (React/frontend)
- [ ] Appropriate caching where needed
- [ ] Bundle size not unnecessarily increased

### Structural quality
Apply the five dimensions of `skills/code-excellence/SKILL.md` — naming, boundaries, error
strategy, testability, idiom conformance — and `skills/karpathy-guidelines` simplicity.

## Output format

```
Review: {PR title or file name}

Summary: {2-sentence overview}

| Severity | Finding | Location | Why |
|---|---|---|---|
| BLOCKING | {issue} | {file:line} | {why it blocks merge} |
| WARNING | {issue} | {file:line} | {impact} |
| SUGGESTION | {suggestion} | {file:line} | {rationale} |

Design Adherence: {PASS / PARTIAL / FAIL} — {notes}
Visual Design: {PASS / ADVISORY / BLOCKING / N/A} — {impeccable summary}
Documentation: {PASS / PARTIAL / NEEDS UPDATE} — {notes}

Recommendation: {Approve / Request Changes}
Blocking findings: {count, named explicitly, or "none"}
```

Every finding carries a file and line. Review only what changed — no out-of-scope critique.
Never approve while a BLOCKING finding stands.

## CONFIDENCE.md gate update

The reviewer has no write tool. Return the gate values in the report; the chief of staff
routes them to the tester (who owns `CONFIDENCE.md`) or the builder:

1. **Gate 5 (code review: no blockers)** — `Approve` → `PASS`, evidence "No blocking issues
   found"; `Request Changes` → `FAIL`, evidence "{N} blocking issues". Timestamp.
2. **Gate 6 (security scan: no criticals)** — all security checks pass → `PASS`; any critical
   → `FAIL`.
3. **Failure log** — any FAIL gate is appended with attempt number and details.
4. **Anti-loop** — if a gate already has 2 FAIL entries, do not ask for a retry. Escalate via
   `AskUserQuestion`: "Fix manually", "Mark as known issue", "Skip this gate (with
   justification)".
5. **Confidence score** — `{passed}/{applicable} = {%}`.
