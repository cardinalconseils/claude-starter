# PRD Document Template

Use this template when creating a new PRD in `docs/prds/`. Replace all `{placeholders}`.

---

```markdown
# PRD-{NNN}: {Feature Title}

**Status:** {Draft | In Progress | Complete | On Hold | Cancelled}
**Created:** {YYYY-MM-DD}
**Last Updated:** {YYYY-MM-DD}
**Priority:** {P0-Critical | P1-High | P2-Medium | P3-Low}
**Phase:** {NN}

## Problem Statement

{What problem does this solve? Who has this problem? What happens today without this feature?
Be specific — "users can't do X, which causes Y" is better than "we need better X."}

## Motivation

{Why now? Business case, user feedback, or strategic reason for building this.}

## Users

| Persona | Role | Goal |
|---------|------|------|
| {type} | {role} | {what they want} |

## Solution Overview

{High-level description of what we're building. Include architectural sketch if helpful.}

## Requirements

### Functional Requirements

| ID | Requirement | Priority | REQ-ID |
|----|-------------|----------|--------|
| FR-1 | {description} | Must | REQ-{NNN} |
| FR-2 | {description} | Should | REQ-{NNN} |

### Non-Functional Requirements

| ID | Requirement | Target |
|----|-------------|--------|
| NFR-1 | {e.g., Response time} | {e.g., < 200ms} |

## Acceptance Criteria

{Testable conditions — each is a yes/no question.}

- [ ] {When X happens, Y should occur}
- [ ] {User can perform Z without errors}
- [ ] {Data persists correctly}

## Out of Scope

- {Feature/behavior} — {why excluded}

## Technical Design

### Files to Modify
- `{path}` — {what changes}

### New Files
- `{path}` — {purpose}

### Data Model Changes
{Schema changes, new collections, modified fields.}

### Dependencies
{External libraries, services, other features.}

## Implementation Phases

### Phase 1: {Title}
**Goal:** {what this delivers}
**Scope:** {Small | Medium | Large}

Tasks:
- [ ] {task}
- [ ] {task}

Phase Acceptance Criteria:
- [ ] {testable condition}

### Phase 2: {Title}
**Goal:** {what this delivers}
**Scope:** {Small | Medium | Large}

Tasks:
- [ ] {task}

Phase Acceptance Criteria:
- [ ] {testable condition}

## Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| {risk} | {L/M/H} | {L/M/H} | {mitigation} |

## Open Questions

- [ ] {question}

## Implementation Notes

{Added during execution — decisions made, scope changes, lessons learned.}

---
*PRD created: {YYYY-MM-DD} | Managed by PRD plugin*
```
