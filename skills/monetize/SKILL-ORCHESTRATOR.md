---
name: cks:monetize-orchestrator
description: Monetization evaluation loop — discover → research → cost research → cost analysis → evaluate → report → roadmap, one v6 role per stage, resumable per stage via the stage argument. Runs in the top-level session so Agent() dispatch works.
allowed-tools:
  - Read
  - Bash
  - Glob
  - Grep
  - Agent
  - AskUserQuestion
---

# Monetize — The Loop

You run the monetization evaluation at the top level of the session. `SKILL.md` is the
doctrine (evidence-based tiers, assumption chains, mode detection); `workflows/<stage>.md`
holds each stage's procedure. You dispatch one role per stage with the workflow path in the
brief and check the artifact on disk before moving on.

Inputs: `arguments` (empty | local path | quoted description), optional `stage:`.

---

## 0. Mode detection

| `arguments` | Mode | Behaviour |
|---|---|---|
| empty | A — self-analyze | scan the current project codebase |
| local directory path | B — analyze target | scan that codebase (paths only, not URLs) |
| quoted text / description | C — business description | pure strategy, no code scan |

## 1. Entry: full run or single stage

`stage:` present → run only that stage (the `/cks:monetize-<stage>` commands). Check its
prerequisite first; missing → tell the user which command produces it and stop.

No `stage:` → full run. Read `.monetize/context.md`; if it exists:

```
AskUserQuestion:
  question: "Previous assessment found (dated {date}). How to proceed?"
  header: "Monetize Re-run"
  options:
    - "Archive and start fresh (Recommended)"
    - "Update — skip discovery, re-run from research"
    - "Cancel"
```
Archive → `mkdir -p .monetize/archive/{date} && mv .monetize/*.md .monetize/archive/{date}/`.
Update → start at stage 2.

## 2. Stage table

Dispatch stages in order. After each, verify the artifact exists and is non-empty — no
artifact, no next stage.

| # | Stage | Role | Workflow | Reads | Writes |
|---|---|---|---|---|---|
| 1 | discover | `cks:strategist` | `workflows/discover.md` | codebase (A/B) or description (C) | `.monetize/context.md` |
| 2 | research | `cks:researcher` | `workflows/research.md` | `context.md` | `.monetize/research.md` |
| 3a | cost research | `cks:researcher` | `workflows/cost-analysis.md` §research | `context.md` | `.monetize/cost-research-raw.md` |
| 3b | cost analysis | `cks:finops` | `workflows/cost-analysis.md` §analysis | `cost-research-raw.md`, `context.md` | `.monetize/cost-analysis.md` |
| 4 | evaluate | `cks:strategist` | `workflows/evaluate.md` | `context.md`, `research.md`, `cost-analysis.md` | `.monetize/evaluation.md` |
| 5 | report | `cks:strategist` | `workflows/report.md` + `references/report-template.md` | all `.monetize/` | `docs/monetization-assessment.md` |
| 6 | roadmap | `cks:strategist` | `workflows/roadmap.md` | `evaluation.md` | `.monetize/phases/`, `docs/ROADMAP.md` (+ `.prd/PRD-ROADMAP.md` if `.prd/` exists) |

Dispatch shape (fill from the row):

```
Agent(subagent_type="<role>", prompt="Mode: monetize <stage>. Input mode: {A|B|C}. Arguments: {arguments}. Follow skills/monetize/<workflow>. Read: <reads>. Write: <writes>. Cite a source for every number; flag legal or compliance blockers as first-class filters, not footnotes.")
```

Research (stage 2) is user-reviewed before evaluation: after it returns, show the findings
summary and ask `AskUserQuestion` "Proceed to cost analysis / Add sources / Redo research"
before stage 3a.

## 3. Completion

Print the stage checklist with artifact paths, the recommended model and tier from
`evaluation.md`, and the next step: `/cks:new "<recommended phase brief>"` (or
`/cks:monetize-roadmap` when stage 6 was skipped).

## Constraints

- One stage per dispatch, in order — never all stages in one message
- Never write a `.monetize/` artifact yourself; only the archive move
- Stage 4 never runs without `research.md` and `cost-analysis.md` on disk
- The report is honest: assumption chains stay visible, no polished numbers without sources
