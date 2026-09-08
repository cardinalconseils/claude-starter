# Workflow: Codebase Research — technical investigation that informs a plan

Answer a specific technical question about this codebase (architecture, impact, options)
and produce findings the architect can plan from. Findings, not decisions; no code.

## 1. Understand the question

From the brief: the question(s), the relevant area of the codebase, and which decision
depends on the answer.

## 2. Investigate the codebase

**Architecture mapping** — read key files, trace data flows and component relationships,
name the patterns and conventions in use.

**Impact analysis** — which files the proposed change touches, what depends on them, what
could break.

**Pattern recognition** — how similar features are already implemented, which conventions
to follow, which abstractions can be reused.

## 3. External research (only if needed)

Library documentation (Context7 first), API specifications, best practices, known issues.
Run the signal layer (`references/last30days.md`) only when the question carries a
market or adoption signal — not for pure API lookups.

## 4. Write the findings

```markdown
# Research: {Topic}

**Date:** {YYYY-MM-DD}
**Question:** {what was investigated}
**For:** {phase NN — name, or "project-level"}

## Findings

### {Finding 1}
{description with file references}

## Recommendation
{approach to take, based on findings — for the architect to decide on}

## Files Referenced
- `{path}` — {why it matters}

## Risks Identified
- {risk} — {mitigation}
```

## 5. Save and return

Save to `.research/{slug}/report.md` (slug from the phase: `phase-{NN}-{name}` when the
brief names one). `.prd/phases/` is not this role's write scope: return the path so the
architect links it from PLAN.md, or the project-manager records it in PRD-STATE.md.

## Constraints

- No code, no decisions — findings and a recommendation.
- Always show sources: file paths, URLs, evidence.
- Concise: what matters for the decision at hand.
- Flag uncertainty plainly.
