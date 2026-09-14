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

Map dependencies before writing a single line of code. Every failed feature can be traced to
something that wasn't mapped upfront.

Owner: `cks:architect` in `Mode: preflight`. Procedure, questions, template and verdict rule:
`workflows/preflight.md`. Enforcement (when the artifact is required, the gate, who stops the
chain): `.claude/rules/preflight.md`.

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

`.preflight/{NN}-{slug}/PREFLIGHT.md` — one file per feature, `00-{slug}` when no phase number is
known yet. The file is the dependency contract for the sprint: the planner reads it before
PLAN.md, the tester and `/cks:uat` read §E for acceptance criteria, the reviewer reads §F for
the gotchas that must be handled.

```
.preflight/
  01-stripe-webhooks/
    PREFLIGHT.md
  02-user-dashboard/
    PREFLIGHT.md
```

The last line is the verdict: `**Cleared for takeoff:** YES / NO — {reason if NO}`.

## What Each Letter Guards

| Letter | Guards against | Why it comes at this point |
|---|---|---|
| **P — Position** | Building in the wrong place; touching a surface another feature owns | Every later section is scoped by the surfaces named here. Unmapped surfaces are the bugs nobody owns. |
| **R — Risk** | Starting before a blocker exists; regressing a neighbor; serializing work that could run in parallel | Blockers become BLOCK gotchas; regressions become edge cases; parallel work becomes the phase order. |
| **E — Establish** | "Done" defined after the code, by the person who wrote it | Acceptance criteria written first are testable; written last they describe whatever shipped. |
| **F — Flag** | Auth, RLS, schema and error-propagation landmines discovered in production | Severity is the contract: `INFO` noted, `WARN` handled in L, `BLOCK` stops takeoff. |
| **L — Lock** | Phases stepping on each other; a UI built against an API that does not exist | Order with a verify step per phase is what makes 11pm debugging a lookup, not a guess. |
| **I — Instrument** | Logs added after the bug, describing what was assumed rather than what happened | Stubs before logic cost minutes; forensics without them cost the incident. |
| **G — Go** | A sprint that starts on an unfinished map | The verdict is binary. A `BLOCK` gotcha is a `NO`, never a softened `WARN`. |

## The Verdict Rule

- `Cleared for takeoff: YES` — every section complete, no `BLOCK` gotcha.
- `Cleared for takeoff: NO — {reason}` — any `BLOCK`, or any section empty. The blocker is the
  deliverable; the chain stops with a `▶ ACTION REQUIRED` naming it, and the pre-flight is
  re-run after the fix.

There is no third value and no "proceed without" path: `.claude/rules/preflight.md` requires a
`YES` before Phase 1 Discovery and before any sprint pipeline run.

## Not to be confused with

`anthropic-skills:preflight-discipline` — a synced user skill that governs per-edit behavior
(check before each change) and writes no artifact. It runs inside a task; this skill runs before
the task exists and produces the contract the task is measured against. Both can be active in the
same session without conflict: that one does not gate phases, this one does not police edits.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "This feature is simple — I don't need a map" | Simple features in complex systems create complex bugs. Map takes 10 minutes. Debugging takes hours. |
| "I already know what it touches" | Knowing ≠ written. Unwritten assumptions are the source of every "I thought that was handled" bug. |
| "I'll instrument later" | Later never comes. Logs written after the fact are guesses. Instrument before the bug exists. |
| "The database schema is obvious" | Run the migration on a table with existing rows first. Then say obvious. |
| "Phase order doesn't matter — I'll figure it out" | Phase order matters exactly when something goes wrong at 11pm. Lock it now. |
| "The happy path is enough for done criteria" | The edge cases ARE the product. Every user who hits an edge case and gets a blank screen is a churned user. |
| "It's a BLOCK on paper but we can work around it" | A workaround is a WARN with a named mitigation in L. If you cannot name the mitigation, it stays BLOCK and the verdict is NO. |
| "The discovery phase will surface all this anyway" | Discovery asks what the user wants. Pre-flight asks what the codebase allows. Different questions, different artifacts, different owners. |

## Verification

- [ ] PREFLIGHT.md written to `.preflight/{NN}-{slug}/PREFLIGHT.md`
- [ ] All 7 sections complete (no empty sections)
- [ ] At least one BLOCK-severity gotcha evaluated (even if none found — note "none found")
- [ ] Phase order has a verify step per phase (not just a description)
- [ ] Instrumentation has at least one checkpoint per phase
- [ ] Verdict line present and binary: `Cleared for takeoff: YES` or `NO — {reason}`
- [ ] `YES` only when no gotcha is `BLOCK`; a `NO` was returned as `▶ ACTION REQUIRED`
