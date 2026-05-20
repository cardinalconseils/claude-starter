---
name: agile-eagle
description: >
  PRE-FLIGHT dependency mapping before feature builds. Use when: starting any feature,
  mid-flight on an existing codebase, planning a sprint, adopting CKS into a running project,
  or any time an agent is about to write code without first mapping what it touches, what it
  breaks, and what done means. Enforces position-in-system, dependency risks, done criteria,
  security gotchas, phase sequencing, and instrumentation before any code is written.
allowed-tools: Read, Write, AskUserQuestion, Bash, Glob, Grep
---

# Agile Eagle — PRE-FLIGHT Protocol

Map dependencies before writing a single line of code. Every failed feature can be traced to something that wasn't mapped upfront.

## The PRE-FLIGHT Acronym

```
P — Position      Where does this feature live? What does it touch?
R — Risk          What breaks? What must exist first? What runs in parallel?
E — Establish     What does done look like, including edge cases?
F — Flag          Security? Schema changes? Auth boundaries? Error propagation?
L — Lock          What order must phases happen in?
I — Instrument    What gets logged? Where? Before feature logic is written.
G — Go            Only after P–I are confirmed.
```

## Output Artifact

Write to `.preflight/{NN}-{slug}/PREFLIGHT.md` — one file per feature. If no phase number is known, use `00-{slug}`. The file becomes the dependency contract for the sprint.

```
.preflight/
  01-stripe-webhooks/
    PREFLIGHT.md
  02-user-dashboard/
    PREFLIGHT.md
```

## Process

### P — Position

Ask: what system does this feature belong to? Map it.

- Which tables/collections does it read? Write? Create? Delete?
- Which API routes does it add, modify, or call?
- Which third-party services does it touch (Stripe, Auth, email, storage)?
- Which existing features share these surfaces?

Output: a one-paragraph system position statement + bullet list of touched surfaces.

### R — Risk the Dependencies

Identify the three dependency categories:

**Must-exist-first** (blockers): What database tables, auth setup, API keys, or existing features must already be in place before this can be built? If any are missing, stop here and build those first.

**Will-break** (side effects): Which existing features could regress? Which queries will slow down after the schema change? Which webhooks could fire twice?

**Can-run-in-parallel**: Which parts of this feature are independent and can be built simultaneously?

Output: three labeled lists.

### E — Establish Done

Define done before the first line of code, not after.

- Write 3–5 acceptance criteria as testable true/false statements
- Write 2–3 edge cases that must also pass (not just the happy path)
- Identify the manual verification steps (what the user clicks or calls)

Output: acceptance criteria block + edge case block.

### F — Flag Gotchas

Surface the landmines before stepping on them.

- **Security boundaries**: Does this route need auth? Is RLS configured on new tables? Any data that must never be exposed to other users?
- **Schema changes**: Adding a NOT NULL column? Check existing rows. Dropping a column? Check all queries.
- **Auth implications**: Does this feature work differently for different roles? What happens when the token expires mid-flow?
- **Error propagation**: If a third-party call fails, what does the user see? Is it recoverable?

Output: a flagged list — each item labeled with its category and severity (INFO / WARN / BLOCK).

### L — Lock Phase Order

Sequence the build so phases don't step on each other.

Example:
```
Phase 1: DB migration (table + RLS)          → verify: migration runs clean, RLS blocks wrong users
Phase 2: API endpoint (server side only)     → verify: curl returns correct shape
Phase 3: Client hook + UI                    → verify: happy path works end to end
Phase 4: Edge cases + error states           → verify: each flagged gotcha from F is handled
```

No phase starts until the previous is verified. Write the phase list in locked order.

### I — Instrument First

Before building feature logic, stub the observability layer.

- Which checkpoints need a log entry? (request received, third-party call made, result returned, error caught)
- What gets logged? At minimum: `event_type`, `user_id`, `payload`, `status`, `error_message`, `source`
- Where do logs go? (Supabase `app_logs` table, console, external service)
- Wire the logging stubs first — empty functions that log but don't act. Feature logic fills them in later.

Output: log checkpoint list + stub schema (if new table needed).

### G — Go

PRE-FLIGHT is complete when:
- [ ] Position statement written
- [ ] All three dependency categories mapped
- [ ] Acceptance criteria + edge cases defined
- [ ] All gotchas flagged with severity
- [ ] Phase order locked with verify steps
- [ ] Instrumentation plan confirmed

Only then: start Phase 1 of the locked phase order.

## PREFLIGHT.md Template

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

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "This feature is simple — I don't need a map" | Simple features in complex systems create complex bugs. Map takes 10 minutes. Debugging takes hours. |
| "I already know what it touches" | Knowing ≠ written. Unwritten assumptions are the source of every "I thought that was handled" bug. |
| "I'll instrument later" | Later never comes. Logs written after the fact are guesses. Instrument before the bug exists. |
| "The database schema is obvious" | Run the migration on a table with existing rows first. Then say obvious. |
| "Phase order doesn't matter — I'll figure it out" | Phase order matters exactly when something goes wrong at 11pm. Lock it now. |
| "The happy path is enough for done criteria" | The edge cases ARE the product. Every user who hits an edge case and gets a blank screen is a churned user. |

## Verification

- [ ] PREFLIGHT.md written to `.preflight/{NN}-{slug}/PREFLIGHT.md`
- [ ] All 7 sections complete (no empty sections)
- [ ] At least one BLOCK-severity gotcha evaluated (even if none found — note "none found")
- [ ] Phase order has a verify step per phase (not just a description)
- [ ] Instrumentation has at least one checkpoint per phase
- [ ] Status = "Cleared for takeoff: YES" before sprint starts
