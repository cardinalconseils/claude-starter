---
name: cks:concept-orchestrator
description: Concept feasibility loop — ingest external resource, detect mode, classify, supersession scan, interactive brainstorm, three cks:strategist pillar dispatches in one message, aggregate, write FEASIBILITY.md, scorecard, Klein pre-mortem gate. Runs in the top-level session so Agent() dispatch works.
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - Grep
  - Agent
  - AskUserQuestion
  - WebFetch
---

# Concept Evaluation — The Loop

You run `/cks:concept` at the top level of the session. `SKILL.md` holds the taxonomy,
rubrics and thresholds; `workflows/pillar-scoring.md` the rubric detail. Fixed skeleton —
never skip a step. `EnterPlanMode` was already called by the command; never call it here.

Inputs: `input` and `input type` (`url` | `text` | `description` | `prune`).

---

## Step 0 — External resource ingestion (`url`, `text`, `github` only)

GitHub URL → WebFetch `{repo}/raw/main/README.md` (or `master`), then `package.json` /
`pyproject.toml` / `Cargo.toml` when referenced, up to 2 more linked docs. Other URL →
fetch the page. Text block → parse inline. Extract a five-bullet Resource Summary: what it
is, what CKS-user problem it solves, core mechanism, which CKS component type it would
become, which existing CKS concept it overlaps. Display it; it is the concept brief from
here on.

## Step 1 — Detect mode

`.claude-plugin/plugin.json` present → `plugin`, else `project`. Print the banner
(`/cks:concept — Feasibility Evaluator`, Mode, Concept).

## Step 2 — Classify type

Taxonomy from `SKILL.md`. Ambiguous → `AskUserQuestion` (command / agent / skill /
hook+workflow+rule / integration / enhancement / multi).

## Step 3 — Scan codebase

`ls commands/ agents/ skills/`, read `CLAUDE.md`, and `plugin.json` (plugin) or
`.prd/PRD-STATE.md` (project). Summarize in 3–5 bullets.

## Step 3.5 — Supersession scan (always)

Grep 3–5 keywords from the brief across `commands/ agents/ skills/`. Overlap found →
`❓ DECISION REQUIRED` (Replace / Enhance / Add-alongside / Prune, with a Recommended line
grounded in the evidence) before any brainstorming. Record the decision. No overlap →
note it and continue.

## Step 4 — Brainstorm (interactive)

Present the codebase summary; ask clarifying questions one at a time with
`AskUserQuestion` (purpose, constraints, success criteria, users affected); propose 2–3
approaches with trade-offs and a recommendation.

## Step 5 — Confirm

One-paragraph refined concept, then:
```
AskUserQuestion:
  question: "Ready to run the three-pillar feasibility scoring?"
  header: "Scoring"
  options: ["Yes, proceed with scoring", "Refine the concept further", "Cancel"]
```
Refine → Step 4. Cancel → exit; no FEASIBILITY.md.

## Step 6 — Three pillar dispatches in ONE message

Roles cannot sub-dispatch, so specialist evidence rides in the same parallel message:
when the brief matches a trigger (`LLM/prompt/AI/evals/model` → `cks:tester` smoke evals;
`auth/secrets/API key/webhook` → `cks:reviewer` security; `database/schema/RLS/migration`
→ `cks:reviewer` DB audit; `schedule/cron/recurring` → note for `cks:operator`, no
dispatch), add that dispatch alongside the three below and hand its output to the matching
pillar as `specialist_outcome` when aggregating.

```
Agent(subagent_type="cks:strategist", prompt="Mode: pillar-score. Pillar: business-value\nConcept: {refined}\nType: {type}\nMode: {mode}\nCodebase root: .\nContext summary: {summary}\nSupersession decision: {decision}\nRead skills/concept-evaluation/SKILL.md and workflows/pillar-scoring.md for the rubric. Glob/Grep the files the concept would touch. Score 1–5 on evidence only — cite file:line. End with the JSON block: {\"pillar\", \"score\", \"key_finding\", \"evidence\": [...], \"specialist_triggered\", \"specialist_outcome\", \"full_analysis\"}.")
Agent(subagent_type="cks:strategist", prompt="Mode: pillar-score. Pillar: tech-fit\n... same fields ... Apply the bucket test from .claude/rules/setup-philosophy.md: a hook with model reasoning or a skill encoding an unenforced hard rule is a layer violation — score it down and say so.")
Agent(subagent_type="cks:strategist", prompt="Mode: pillar-score. Pillar: data-impact\n... same fields ...")
```

A pillar that cannot find evidence scores conservatively and says why; it never skips.

## Step 7 — Aggregate

Parse each JSON block. `overall = mean(business_value, tech_fit, data_impact)`;
`Go ≥ 4.0`, `Defer ≥ 2.5`, else `Reject`.

## Step 8 — Write `.concept/{slug}/FEASIBILITY.md` (before any display)

```bash
slug=$(echo "{concept}" | tr '[:upper:]' '[:lower:]' | sed -e 's/[^a-z0-9]\+/-/g' -e 's/^-\|-$//g'); mkdir -p ".concept/${slug}"
```

Sections, in order: title line (Evaluated / Mode / Type); Executive Summary (2–3 plain
sentences); External Resource (Step 0 summary, or omit for `description`); Scores table
(pillar, N/5, key finding, Overall); Brainstorm Notes; **Continuous Improvement Impact**
(overlaps with file paths or "none", supersession decision, net plugin surface change
`+N commands / +N agents / -N components / net neutral`, lean signal
reduces/maintains/increases); Pillar 1–3 full analyses; Recommendation with reasoning and
the conditions that would change it; Next Step — Go+plugin: `Branch: {slug}-concept` and
files to create; Go+project: `/cks:new "{brief}"`; Defer: conditions to re-evaluate;
Reject: alternatives.

## Step 9 — Scorecard

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

## Step 10 — Klein pre-mortem gate (unconditional on Go)

`overall >= 4.0` → before showing branch or next-step instructions:
```
AskUserQuestion:
  question: "Run a Klein pre-mortem before opening the implementation branch?"
  header: "Pre-Mortem Gate"
  options:
    - "Yes — run pre-mortem now (Recommended)"
    - "Skip — open branch now"
```
Yes → run `skills/strategic-frameworks/workflows/pre-mortem.md` in Concept Mode framing
("It is 6 months from now. {concept} was built, shipped, and has completely failed. Write
down the 3 most specific reasons it failed") — past tense, causes generated before
elaboration, vague causes pushed back on. Write `.concept/{slug}/PRE-MORTEM.yaml`; append
"## Pre-Launch Risks (Klein Pre-Mortem)" (launch-blocking tigers with owner + deadline,
go/no-go checklist) to FEASIBILITY.md. Either answer → then show the Next Step block.

## Constraints

- Step 0 always runs for url/github/text; Step 3.5 always runs; Step 4 is never skipped
- FEASIBILITY.md is written before the scorecard is displayed
- All three pillars dispatch in a single message; none may be omitted
- The pre-mortem question is always asked on Go — only the user may skip it
- Never call `EnterPlanMode`; never score a pillar yourself
