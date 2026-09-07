# Workflow: Score Feasibility — three pillars, one verdict, FEASIBILITY.md

Score a refined concept on Business Value, Technology Fit, and Data Impact, aggregate,
write `.concept/{slug}/FEASIBILITY.md`, show the scorecard, then the Klein gate on Go.
One role scores all three pillars in sequence (no parallel workers, no sub-dispatch);
specialist checks a pillar would have triggered become dispatches the chief of staff
makes afterwards.

Precondition: brainstorming ran and the user confirmed the refined concept
(`.claude/rules/concept-evaluation.md` rule 1). Never score an un-brainstormed concept.

## 1. Score each pillar

For business-value, tech-fit, data-impact in turn:

1. Rubric: `SKILL.md` tables + `workflows/pillar-scoring.md`.
2. Glob/Grep the files the concept would touch; read `CLAUDE.md` for fit.
3. Apply the supersession decision from the scan (BV Lean & Clean modifier).
4. Specialist trigger matched (LLM/evals, auth/secrets, database/RLS, schedule)? Score
   inline and list the specialist dispatch under "Follow-up dispatches".
5. Assign 1–5 with file-level evidence. No evidence → score conservatively, say why.

Record per pillar: `score`, `key_finding` (one sentence), `evidence[]` (file:line or
observation), `full_analysis` (prose for the report).

## 2. Aggregate

```
overall = (business_value + tech_fit + data_impact) / 3
Go ≥ 4.0 · Defer 2.5–3.9 · Reject < 2.5
```

## 3. Write FEASIBILITY.md — before showing anything

```bash
slug=$(echo "{concept}" | tr '[:upper:]' '[:lower:]' | sed -e 's/[^a-z0-9]\+/-/g' -e 's/^-\|-$//g')
```

`.concept/{slug}/FEASIBILITY.md`:

```markdown
# Concept Feasibility: {name}
Evaluated: {ISO date} | Mode: {plugin|project} | Type: {type}

## Executive Summary
{2–3 sentences, plain language}

## External Resource
_Source: {URL | "inline text" | "N/A — concept provided directly"}_
{5-bullet resource summary, or omit when the input was a plain description}

## Scores
| Pillar | Score | Key Finding |
|---|---|---|
| Business Value | N/5 | … |
| Technology Fit | N/5 | … |
| Data Impact | N/5 | … |
| **Overall** | **N/5** | |

## Brainstorm Notes
{insights, angles, tradeoffs}

## Continuous Improvement Impact
- Overlaps with: {components with paths, or "none"}
- Supersession decision: {Replace | Enhance | Add-alongside | Prune | N/A}
- Net plugin surface change: {+N / -N / net neutral}
- Lean signal: this concept {reduces | maintains | increases} surface area

## Pillar 1 — Business Value
## Pillar 2 — Technology Fit
## Pillar 3 — Data Impact
{full_analysis each}

## Recommendation
**{Go | Defer | Reject}** — {why; what changes it}

## Next Step
{Go+plugin: branch `{slug}-concept` and files to create · Go+project: `/cks:new "{brief}"`
 · Defer: conditions to re-evaluate · Reject: alternatives}
```

## 4. Scorecard

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 FEASIBILITY SCORECARD
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Concept: {name}   Type: {type}   Mode: {mode}
 Business Value    {N}/5  {key_finding}
 Technology Fit    {N}/5  {key_finding}
 Data Impact       {N}/5  {key_finding}
 ─────────────────────────
 Overall           {N}/5  → {GO | DEFER | REJECT}
 Report: .concept/{slug}/FEASIBILITY.md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 5. Klein pre-mortem gate — unconditional on Go

`AskUserQuestion` "Run a Klein pre-mortem before opening the implementation branch?":
"Yes — run pre-mortem now (Recommended)" · "Skip — open branch now".

Yes → `skills/strategic-frameworks/workflows/pre-mortem.md` in Concept Mode framing
("It is 6 months from now. {concept} was built, shipped, and has completely failed. Write
the 3 most specific reasons it failed."), past tense only, push back on vague causes.
Output `.concept/{slug}/PRE-MORTEM.yaml`; append `## Pre-Launch Risks (Klein Pre-Mortem)`
(run date, output path, launch-blocking tigers with owner + deadline, go/no-go checklist)
to FEASIBILITY.md. Skip → straight to the Next Step block.

## Return

Path, overall score, verdict, next step, and the follow-up dispatches list.
