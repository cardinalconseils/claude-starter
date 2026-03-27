# STATE.md Template

Use this template for `.prd/PRD-STATE.md`. This file enables session continuity — any new session reads this to know where things stand.

---

```markdown
# Session State

**Last Updated:** {YYYY-MM-DD}

## Current Position

- **Active Phase:** {NN or "none"}
- **Phase Name:** {name or "—"}
- **Phase Status:** {see valid statuses below}
- **Last Action:** {description of what was done}
- **Last Action Date:** {YYYY-MM-DD}
- **Next Action:** {what should be done next}
- **Suggested Command:** {/cks:command args}

## Iteration Tracking

- **Iteration Count:** {N — starts at 1, increments on each loop back}
- **Iteration Reason:** {why we're iterating, or "N/A"}

## Secrets Tracking

- **Secrets Manifest:** {.prd/phases/{NN}-{name}/{NN}-SECRETS.md or "none"}
- **Secrets Status:** {N}/{M} resolved
- **Blocking Secrets:** {list of SEC-IDs or "none"}

## Active PRD

- **PRD Path:** {docs/prds/PRD-NNN-name.md or "none"}
- **PRD Status:** {Draft | In Progress | Complete}
- **PR Number:** {#N or "none"}
- **PR URL:** {url or "none"}

## Session History

| Date | Phase | Action | Result |
|------|-------|--------|--------|
<!-- Append one row per significant action -->

## Notes

{Any context that helps the next session pick up smoothly.}
```

## Valid Phase Statuses

### Linear progression
| Status | Meaning | Next Command |
|--------|---------|-------------|
| `not_started` | Phase created, no work done | `/cks:discover` |
| `discovering` | Phase 1 in progress | `/cks:discover` (resume) |
| `discovered` | Phase 1 complete — 9 elements gathered | `/cks:design` |
| `designing` | Phase 2 in progress | `/cks:design` (resume) |
| `designed` | Phase 2 complete — screens + specs ready | `/cks:sprint` |
| `sprinting` | Phase 3 in progress | `/cks:sprint` (resume) |
| `sprinted` | Phase 3 complete — code merged, PR created | `/cks:review` |
| `reviewing` | Phase 4 in progress | `/cks:review` (resume) |
| `reviewed` | Phase 4 complete — approved for release | `/cks:release` |
| `releasing` | Phase 5 in progress | `/cks:release` (resume) |
| `released` | Phase 5 complete — deployed to production | `/cks:new` (next feature) |

### Iteration statuses (from Phase 4 [4d] decision)
| Status | Meaning | Next Command |
|--------|---------|-------------|
| `iterating_discover` | Phase 4 routed back to Phase 1 | `/cks:discover` |
| `iterating_design` | Phase 4 routed back to Phase 2 | `/cks:design` |
| `iterating_sprint` | Phase 4 routed back to Phase 3 | `/cks:sprint` |

## How to Update STATE.md

Every workflow step that changes project state MUST update STATE.md:

1. **Active Phase** — Which phase number is current
2. **Phase Status** — Where in the 5-phase lifecycle
3. **Last Action** — What just happened
4. **Next Action** — What should happen next
5. **Iteration Count** — Increment when looping back from Phase 4
6. **Session History** — Append a row

This ensures any new conversation can read STATE.md and immediately know where to pick up.
