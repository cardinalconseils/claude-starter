# PRD Requirements

Traceable functional requirements extracted from PRDs. Each REQ-ID links to its source PRD and phase.

| REQ-ID | Requirement | PRD | Phase | Priority | Status |
|--------|-------------|-----|-------|----------|--------|
| REQ-001 | 7-rung write-time minimalism ladder present and ordered in `.claude/rules/engineering-discipline.md` | PRD-001 | 04 | Must | Accepted |
| REQ-002 | Guards subsection names 4 guards (trust-boundary validation, security, error handling, accessibility), states never-eliminate, positioned before the rungs | PRD-001 | 04 | Must | Accepted |
| REQ-003 | ≥3 ladder-specific rows added to the rule file's Common Rationalizations table with actionable counters | PRD-001 | 04 | Must | Accepted |
| REQ-004 | Bootstrap catalog `skills/guardrails/catalogs/engineering-discipline.md` carries byte-identical ladder content | PRD-001 | 04 | Must | Accepted |
| REQ-005 | Idempotent (check-and-append) migration version-delta section in `skills/migrations/references/version-changes.md` | PRD-001 | 04 | Must | Accepted |
| REQ-006 | Embedded engineering-discipline copy (version-changes.md lines 379–438) updated with the ladder | PRD-001 | 04 | Must | Accepted |
| REQ-007 | All four content changes land in one commit; net-zero surface area; CLAUDE.md untouched | PRD-001 | 04 | Must | Accepted |
