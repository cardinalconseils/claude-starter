---
description: "Open-ended brainstorming — ideas, features, pivots, business models — seeded from current project context. Enters plan mode after ideation so output can be reviewed before routing to kickstart or feature lifecycle."
argument-hint: "[topic or question]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
  - EnterPlanMode
---

# /cks:brainstorm — Context-Aware Brainstorming

Seed open-ended brainstorming from the current project directory, then surface the output in plan mode for review before routing to `/cks:kickstart` (new project) or `/cks:new` (new feature in existing project).

Works from any directory — a CardinalConseils project, a CKS-powered app, or a blank folder.

## Dispatch

```
# Step 1: Read project context (best-effort — missing files are fine)
context_lines = []
if CLAUDE.md exists: read it → extract project name and domain → append to context_lines
if .prd/PRD-STATE.md exists: read it → extract active phase/feature → append to context_lines
if memory/index.md exists: read it → note recent learnings → append to context_lines

project_context = join(context_lines) or "No project context detected — starting fresh."

# Step 2: Dispatch ideator in brainstorm mode
Agent(
  subagent_type="cks:kickstart-ideator",
  prompt="Run brainstorming session. mode=brainstorm. Project context: {project_context}. Topic: {$ARGUMENTS or empty}. Follow workflows/ideate.md. Output to .brainstorm/{YYYY-MM-DD}-{slug}/IDEATION.md. Do NOT write .kickstart/state.md."
)

# Step 3: Enter plan mode so user reviews ideation output before routing
EnterPlanMode
```

## Quick Reference

```
/cks:brainstorm                        # open-ended — agent asks what to brainstorm
/cks:brainstorm new revenue stream     # seeds brainstorming with topic
/cks:brainstorm feature ideas for auth # project context narrows the space
```

## Output

- `.brainstorm/{date}-{slug}/IDEATION.md` — refined pitch, brainstorming journey, angle variations, stress-test, Klein pre-mortem
- Plan mode view — review before deciding next step

## Routing After Brainstorm

After reviewing in plan mode:
- New project from scratch → `/cks:kickstart`
- New feature in existing project → `/cks:new "{pitch}"`
- Needs feasibility scoring first → `/cks:concept "{pitch}"`
- Discard → close plan mode, nothing committed
