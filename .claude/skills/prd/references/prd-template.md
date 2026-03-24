# PRD Template

Use this template when creating a new PRD. Fill in all sections — for simple features,
some sections can be brief (1-2 sentences). For complex features, go deep.

Replace everything in `{curly braces}` with actual content. Remove the guidance comments
after filling in.

---

```markdown
# PRD-{NNN}: {Feature Title}

**Status:** {Draft | In Progress | Complete | On Hold | Cancelled}
**Author:** {who requested/wrote this}
**Created:** {YYYY-MM-DD}
**Last Updated:** {YYYY-MM-DD}
**Priority:** {P0-Critical | P1-High | P2-Medium | P3-Low}

## Problem Statement

{What problem does this solve? Who has this problem? What happens today without this feature?
Be specific — "users can't do X, which causes Y" is better than "we need better X."}

## Motivation

{Why now? What's the business case, user feedback, or strategic reason for building this?
Include any data, user quotes, or competitive pressure that justifies the work.}

## Personas

{Who uses this feature? Include role, goals, and relevant context.}

| Persona | Role | Goal | Context |
|---------|------|------|---------|
| {Name/Type} | {Their role} | {What they want to achieve} | {Relevant details} |

## Solution Overview

{High-level description of what we're building. Include a brief architectural sketch if
helpful — which components change, what's new, how data flows.}

## Detailed Requirements

### Functional Requirements

{What the feature does — observable behaviors from the user's perspective.}

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-1 | {Requirement description} | {Must/Should/Could} |
| FR-2 | {Requirement description} | {Must/Should/Could} |

### Non-Functional Requirements

{Performance, security, accessibility, scalability constraints.}

| ID | Requirement | Target |
|----|-------------|--------|
| NFR-1 | {e.g., Page load time} | {e.g., < 2 seconds} |
| NFR-2 | {e.g., Data encryption} | {e.g., AES-256 at rest} |

## User Stories

{Key user flows written as: "As a [persona], I want to [action] so that [outcome]."}

1. As a {persona}, I want to {action} so that {outcome}.
2. As a {persona}, I want to {action} so that {outcome}.

## Acceptance Criteria

{Testable conditions that must be true for the feature to be considered complete.
Write these as clear yes/no statements.}

- [ ] {When X happens, Y should occur}
- [ ] {User can perform Z without errors}
- [ ] {Data is persisted correctly to Firestore}
- [ ] {UI renders correctly on mobile and desktop}

## Out of Scope

{What this PRD explicitly does NOT cover. Be specific — if someone might reasonably
expect it, list it here with a brief reason why it's excluded.}

- {Feature/behavior} — {why excluded, e.g., "deferred to Phase 2" or "separate PRD"}

## Technical Design

### Architecture Impact

{Which existing files/components change? What new files are needed?}

**Files to modify:**
- `{file path}` — {what changes}

**New files:**
- `{file path}` — {purpose}

### Data Model Changes

{Any new Firestore collections, fields, or schema changes.}

### API Changes

{New endpoints, modified endpoints, or third-party API integrations.}

### Dependencies

{External libraries, services, or other features this depends on.}

## Implementation Phases

{Break the work into independently shippable phases. Each phase should deliver user value.}

### Phase 1: {Phase Title}
**Goal:** {What this phase delivers}
**Estimated Scope:** {Small / Medium / Large}

Tasks:
- [ ] {Task description}
- [ ] {Task description}

Acceptance Criteria:
- [ ] {Testable condition}

### Phase 2: {Phase Title}
**Goal:** {What this phase delivers}
**Estimated Scope:** {Small / Medium / Large}

Tasks:
- [ ] {Task description}

Acceptance Criteria:
- [ ] {Testable condition}

## Success Metrics

{How do we measure if this feature achieved its goal after launch?}

| Metric | Current | Target | How to Measure |
|--------|---------|--------|----------------|
| {e.g., Process creation time} | {e.g., 15 min} | {e.g., 5 min} | {e.g., Analytics event} |

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| {What could go wrong} | {Low/Med/High} | {Low/Med/High} | {How to prevent or handle} |

## Open Questions

{Unresolved decisions that need answers before or during implementation.}

- [ ] {Question} — {who can answer, or what we need to find out}

## Implementation Notes

{Added during execution — lessons learned, scope changes, decisions made during build.}

---
*PRD created: {YYYY-MM-DD}*
```
