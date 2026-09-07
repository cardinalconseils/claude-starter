# Workflow: Improvement Proposals

Analyze session patterns, gotchas, RAID log, learnings, and per-role dispatch traces to
generate structured improvement proposals for rules, personas, workflows, and role bodies.
Ported from the `improvement-agent` agent. Run by the historian role. Proposals are drafts
in `.cks/control-plane/improvements/pending/`; applying one is the builder's job after
explicit approval — the historian never edits `agents/`, `skills/`, or `.claude/rules/`.

## Mode: analyze

1. `Glob(".cks/control-plane/improvements/pending/*.md")` — target files already covered
2. `Glob(".cks/control-plane/improvements/accepted/*.md")` — targets already applied
3. Read sources with targeted grep, never whole files, in priority order:
   `.prd/logs/agents/*.jsonl` (outcome per role — cluster `error` lines by role first),
   `.learnings/gotchas.md`, `.learnings/session-log.md`, `.learnings/knowledge/`,
   `memory/wiki/learnings/`, the RAID log, `.cks/control-plane/memory/project/*.md`
4. Scans: frequency (the same failure three times), gap (a rule with no enforcement),
   stale RAID entries, convention backlog (Proposed conventions never applied), persona
   drift, **role drift** (a role whose traces show repeated `error` on one mode)
5. For each pattern with confidence ≥ 60 and no existing proposal on the same target and
   topic: id `$(date +%Y-%m-%d)-NNN` (next free in `pending/`), write
   `pending/{id}.md`:

```markdown
---
id: {id}
type: rule | persona | workflow | role | skill
status: pending
confidence: {0-100}
impact: low | medium | high
target: {file path}
---
# [{id}] {title}

## Evidence
{sources and counts — file paths, trace counts per role}

## Proposed Change
```diff
{before → after}
```

## Expected Effect
{what improves, how it would be measured — role evals delta for role/skill targets}
```

6. Report: sources read, proposals written, skipped (and why)

## Mode: list

Table of `pending/*.md`: `ID | Type | Confidence | Impact | Title`. Empty → "No pending
proposals. Run `/cks:improve --analyze` to scan."

## Mode: apply (approval only)

Read the proposal; show the diff; return a `❓ DECISION REQUIRED` block — "Apply this
improvement to {target}?" Yes / No / See full proposal first — for the chief of staff to put
to the founder (the historian holds no `AskUserQuestion`). On an explicit Yes in the dispatch:
set `status: accepted`, move to `accepted/`, and return the diff for a builder dispatch (agent
and skill targets additionally require role evals with a non-negative delta before merge).
No → reject flow.

## Mode: reject

Append `## Rejection Reason\n{reason}`, set `status: rejected`, move to `rejected/`, report.

## Constraints

- Confidence < 60 is not written
- No duplicate proposal for an already-pending target
- Never modify a target file from this workflow
- Never expose a raw `supabase_service_key`
