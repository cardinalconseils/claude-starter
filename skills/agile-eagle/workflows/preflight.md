# Workflow: Pre-flight (P→R→E→F→L→I→G)

Read by `cks:architect` in `Mode: preflight`. Produces one `.preflight/{NN}-{slug}/PREFLIGHT.md`
per feature and returns the `Cleared for takeoff` verdict. Every letter is a mandatory section
— an empty section means the pre-flight is not finished.

## Inputs

- Feature brief, or `active_phase` from `.prd/PRD-STATE.md` and its `CONTEXT.md` when present.
- `{NN}` = phase number; `00` when no PRD slot exists yet (`/cks:adopt`, a brief with no phase).
- `{slug}` = kebab-case feature name.
- Map the codebase with `Read`, `Grep`, `Glob` before every question. Ask the user only what the
  code cannot answer, one `AskUserQuestion` per letter at most.

## Steps

### P — Position

Where does this feature live, and what does it touch?

- Which tables/collections does it read, write, create, delete?
- Which API routes does it add, modify, or call?
- Which third-party services does it touch (payments, auth, email, storage)?
- Which existing features share these surfaces?

Output: a one-paragraph system position statement + a bullet list of touched surfaces.

### R — Risk the Dependencies

Three labeled lists:

- **Must-exist-first** (blockers): tables, auth setup, API keys, or features that must already be
  in place. A missing blocker is a BLOCK gotcha in F — build it first.
- **Will-break** (side effects): features that could regress, queries that slow down after the
  schema change, webhooks that could fire twice.
- **Can-run-in-parallel**: independent parts that can be built simultaneously.

### E — Establish Done

- 3–5 acceptance criteria as testable true/false statements.
- 2–3 edge cases that must also pass — not only the happy path.
- The manual verification steps (what the user clicks or calls).

Output: acceptance criteria block + edge case block. `/cks:uat` and the BrowserUAT node read this
section verbatim.

### F — Flag Gotchas

Each item labeled with category and severity (`INFO` / `WARN` / `BLOCK`):

- **Security boundaries**: auth on the route, RLS on new tables, data that must never leak
  across users.
- **Schema changes**: NOT NULL columns against existing rows, dropped columns against every query.
- **Auth implications**: role-dependent behavior, token expiry mid-flow.
- **Error propagation**: what the user sees when a third-party call fails, and whether it is
  recoverable.

Evaluate BLOCK explicitly even when none is found — write `none found`.

### L — Lock Phase Order

Sequence the build so phases do not step on each other; every phase gets a verify step:

```
Phase 1: DB migration (table + RLS)          → verify: migration runs clean, RLS blocks wrong users
Phase 2: API endpoint (server side only)     → verify: curl returns correct shape
Phase 3: Client hook + UI                    → verify: happy path works end to end
Phase 4: Edge cases + error states           → verify: each flagged gotcha from F is handled
```

No phase starts until the previous one is verified.

### I — Instrument First

Before feature logic, plan the observability layer:

- Checkpoints that need a log entry (request received, third-party call made, result returned,
  error caught).
- Fields — at minimum `event_type`, `user_id`, `payload`, `status`, `error_message`, `source`.
- Destination (Supabase `app_logs` table, console, external service).
- Logging stubs are wired first — empty functions that log but do not act.

Output: log checkpoint list (at least one per phase) + stub schema if a new table is needed.

### G — Go: the verdict

`Cleared for takeoff: YES` only when every section is complete AND no gotcha carries `BLOCK`.
Any `BLOCK` → `Cleared for takeoff: NO — {gotcha}` and `Status: blocked ({reason})`. Never soften
a BLOCK to WARN to obtain a YES; the blocker is the deliverable.

## Write the artifact

Write `.preflight/{NN}-{slug}/PREFLIGHT.md` with `Write` (it creates the directory):

```markdown
# PRE-FLIGHT: {Feature Name}

**Date:** {date}
**Phase:** {NN} — {slug}
**Status:** ready | blocked (reason)

## P — Position
{system position statement}

### Touched Surfaces
- Tables: ...
- Routes: ...
- Services: ...
- Shared with: ...

## R — Dependencies

### Must Exist First
- ...

### Will Break
- ...

### Can Run in Parallel
- ...

## E — Done Criteria

### Acceptance Criteria
1. [ ] ...
2. [ ] ...
3. [ ] ...

### Edge Cases
1. [ ] ...
2. [ ] ...

## F — Gotchas

| Category | Item | Severity |
|----------|------|----------|
| Security | ... | WARN |
| Schema | ... | BLOCK |
| Auth | ... | INFO |

## L — Phase Order

| Phase | Work | Verify |
|-------|------|--------|
| 1 | ... | ... |
| 2 | ... | ... |
| 3 | ... | ... |

## I — Instrumentation

| Checkpoint | event_type | Fields | Destination |
|------------|-----------|--------|-------------|
| ... | ... | ... | ... |

## G — Status

- [ ] Position mapped
- [ ] Dependencies risked
- [ ] Done established
- [ ] Gotchas flagged
- [ ] Phase order locked
- [ ] Instrumentation planned

**Cleared for takeoff:** YES / NO — {reason if NO}
```

## Return

The DESIGN block from `agents/architect.md`, with:

- `ARTIFACTS` — the PREFLIGHT.md path.
- `RISKS / GAPS` — `Cleared for takeoff: YES` or `NO`, then every BLOCK gotcha verbatim
  (category, item). A `NO` is returned as a `▶ ACTION REQUIRED` block per
  `.claude/rules/human-intervention.md`: `Run:` the fix for the blocker, `Then:` re-run
  `/cks:preflight {NN}`.
- `NEXT DISPATCH` — `none` on NO; on YES, the phase the caller was gating (Discovery or Sprint).
