# Kickstart Validation Rules & State File Format

## Validation Check

Before advancing to the next phase, **validate the current phase produced its required output:**

| Phase | Required Output | Validation |
|-------|----------------|------------|
| Intake | `.kickstart/context.md` | File exists AND has `## Problem Statement` section |
| Compose | `.kickstart/manifest.md` | File exists AND has `## Sub-Projects` section with at least 1 SP entry |
| Research | `.kickstart/research.md` | File exists AND has `## Competitor Landscape` section |
| Monetize | `.monetize/context.md` | File exists |
| Brand | `.kickstart/brand.md` | File exists AND has `## Visual Identity` section |
| Design: ERD | `.kickstart/artifacts/ERD.md` | File exists with valid `erDiagram` block |
| Design: Schema | `.kickstart/artifacts/schema.sql` | File exists with `CREATE TABLE` statements |
| Design: PRD | `.kickstart/artifacts/PRD.md` | File exists with `## User Stories` section |
| Design: API | `.kickstart/artifacts/API.md` | File exists with `## Endpoints` section |
| Design: Architecture | `.kickstart/artifacts/ARCHITECTURE.md` | File exists with `## Stack Decision` table |
| Handoff/Bootstrap | `CLAUDE.md` updated | CLAUDE.md has project-specific content (not template tokens) |
| Handoff/Scaffold | `package.json` or equivalent | Project file exists with deps installed |
| Handoff/Observability | `.learnings/observability.md` | File exists |
| Handoff/PRD Init | `.prd/PRD-STATE.md` | File exists |

**If validation fails:**
```
  [N] {Phase Name}   ✗ validation failed
      Expected: {what should exist}
      Missing: {what's missing}
      Action: Re-running this phase...
```

Retry the phase once. If it fails again, ask the user what to do.

## Kickstart State File

Persist progress to `.kickstart/state.md` so `/kickstart` can resume on interruption:

```markdown
---
started: {ISO date}
last_phase: {phase number}
last_phase_name: {name}
last_phase_status: {done|in_progress|failed|skipped}
compose_sub_projects: {count|pending}
research_opted: {true|false|pending}
monetize_opted: {true|false|pending}
brand_opted: {true|false|pending}
---

# Kickstart Progress

| # | Phase | Status | Output | Completed |
|---|-------|--------|--------|-----------|
| 1 | Intake | {done/in_progress/pending} | .kickstart/context.md | {date or —} |
| 1b | Compose | {done/in_progress/pending} | .kickstart/manifest.md | {date or —} |
| 2 | Research | {done/skipped/pending} | .kickstart/research.md | {date or —} |
| 3 | Monetize | {done/skipped/pending} | .monetize/ | {date or —} |
| 4 | Brand | {done/skipped/pending} | .kickstart/brand.md | {date or —} |
| 5a | Design: ERD | {done/in_progress/pending} | .kickstart/artifacts/ERD.md | {date or —} |
| 5b | Design: Schema | {done/in_progress/pending} | .kickstart/artifacts/schema.sql | {date or —} |
| 5c | Design: PRD | {done/in_progress/pending} | .kickstart/artifacts/PRD.md | {date or —} |
| 5d | Design: API | {done/in_progress/pending} | .kickstart/artifacts/API.md | {date or —} |
| 5e | Design: Architecture | {done/in_progress/pending} | .kickstart/artifacts/ARCHITECTURE.md | {date or —} |
| 6a | Bootstrap | {done/in_progress/pending} | CLAUDE.md | {date or —} |
| 6b | Scaffold | {done/in_progress/pending} | package.json | {date or —} |
| 6c | Observability | {done/in_progress/pending} | .learnings/ | {date or —} |
| 6d | PRD Init | {done/in_progress/pending} | .prd/ | {date or —} |
```
