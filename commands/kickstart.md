---
description: "Project enabler — idea to scaffolded project"
argument-hint: "[idea pitch]"
allowed-tools:
  - Read
  - Agent
  - Skill
  - AskUserQuestion
---

# /cks:kickstart

Orchestrate the kickstart lifecycle by dispatching phase agents in sequence.
Each agent has `skills: kickstart` loaded at startup — it carries the domain expertise.

## Resume Detection

Read `.kickstart/state.md` if it exists.
- If found → display progress table, then ask:
  ```
  AskUserQuestion:
    question: "Previous kickstart found. How to proceed?"
    options:
      - "Resume from where I left off (Recommended)"
      - "Start fresh (archive existing)"
      - "Update intake answers then continue"
  ```
  - Resume: continue from the first incomplete phase below
  - Start fresh: `mkdir -p .kickstart/archive/$(date +%Y%m%d) && mv .kickstart/*.md .kickstart/archive/$(date +%Y%m%d)/`
  - Update: re-dispatch kickstart-intake, then continue from design
- If not found → proceed with fresh run

## Phase Execution

### Phase 0: Ideate (optional)

If no `.kickstart/ideation.md` exists and no `$ARGUMENTS` pitch was provided:

```
AskUserQuestion:
  question: "Do you have a clear idea ready, or would you like to brainstorm first?"
  options:
    - "I have a clear idea — skip to intake"
    - "Help me brainstorm and refine my idea first"
```

If brainstorm selected:

```
Agent(subagent_type="kickstart-ideator", prompt="Run Phase 0: Ideation. mode=kickstart. Help the user brainstorm and refine their project idea. Read workflows/ideate.md for step-by-step process. Write output to .kickstart/ideation.md. Update .kickstart/state.md.")
```

Wait for completion. Read `.kickstart/state.md`.

If skip selected → mark ideation as skipped in `.kickstart/state.md`, proceed to Phase 1.
If `$ARGUMENTS` provided → skip ideation gate, proceed directly to Phase 1.
If `.kickstart/ideation.md` already exists → skip ideation gate, proceed to Phase 1.

### Phase 1+1b: Intake & Compose

```
Agent(subagent_type="kickstart-intake", prompt="Idea pitch: $ARGUMENTS. If .kickstart/ideation.md exists, read it for the refined pitch from ideation phase — use it as the idea context. Run the full intake Q&A, compose, and stack selection phases. Read workflows/intake.md, workflows/compose.md, and workflows/stack-selection.md for step-by-step process. Write outputs to .kickstart/. Ask the user about optional phases (research, monetize, brand) and record decisions in state.md.")
```

Wait for completion. Read `.kickstart/state.md` for gate decisions.

### Phase 2: Research (optional)

Read `.kickstart/state.md`. If `research_opted: true`:

```
Agent(subagent_type="deep-researcher", prompt="Research the competitive landscape for this project. Read .kickstart/context.md for the project description. Save findings to .kickstart/research.md. Update .kickstart/state.md: set research phase status to done with today's date.")
```

If `research_opted: false` or `skipped` → skip to Phase 3.

### Phase 3: Monetize (optional)

Read `.kickstart/state.md`. If `monetize_opted: true`:

Run the full monetize pipeline — discover context, research models, evaluate fit, produce report.
This MUST ask the user interactive business questions (not auto-generate from kickstart context alone).

```
Agent(subagent_type="monetize-discoverer", prompt="Discover monetization context for this project. Read .kickstart/context.md for project context (especially ## Business & Monetization section) and .kickstart/research.md if it exists. Save discovery to .monetize/context.md.")
```

```
Agent(subagent_type="monetize-researcher", prompt="Research monetization models for this project. Read .kickstart/context.md and .monetize/context.md. Save research to .monetize/research.md.")
```

```
Agent(subagent_type="monetize-evaluator", prompt="Evaluate monetization strategies for this project. Read .monetize/context.md and .monetize/research.md. Save evaluation to .monetize/evaluation.md.")
```

```
Agent(subagent_type="monetize-reporter", prompt="Generate monetization report for this project. Read all .monetize/ artifacts. Save final report to .monetize/report.md. Update .kickstart/state.md: set monetize phase status to done with today's date.")
```

The `/cks:monetize` command orchestrates 6 agents in sequence:
discover (interactive) → research → cost-research → cost-analysis → evaluate → report.

Wait for completion. Verify `.monetize/context.md` and `docs/monetization-assessment.md` exist.
Update `.kickstart/state.md`: set monetize phase status to done with today's date.

If `monetize_opted: false` or `skipped` → skip to Phase 4.

### Phase 4: Brand (optional)

Read `.kickstart/state.md`. If `brand_opted: true`:

```
Agent(subagent_type="kickstart-brand", prompt="Extract brand identity. Read .kickstart/context.md for project context. Save to .kickstart/brand.md. Update .kickstart/state.md: set brand phase status to done with today's date.")
```

If `brand_opted: false` or `skipped` → skip to Phase 5.

### Phase 5: Design

```
Agent(subagent_type="kickstart-designer", prompt="Generate design artifacts. Read .kickstart/context.md, .kickstart/manifest.md, and any research/brand/monetize files that exist. Read workflows/design.md for step-by-step process. Write artifacts to .kickstart/artifacts/. Update .kickstart/state.md: set design phase status to done with today's date.")
```

### Phase 6: Handoff

```
Agent(subagent_type="kickstart-handoff", prompt="Scaffold the project and personalize .claude/. Read all .kickstart/ artifacts. Read workflows/handoff.md for step-by-step process. Invoke /bootstrap if needed. Initialize .prd/. Execute auto-chain (workflows/auto-chain.md). Update .kickstart/state.md: set handoff phase status to done with today's date.")
```

### Completion

Read `.kickstart/state.md`. Verify `last_phase_status: done` and `last_phase: complete`.
Display final summary with all phase statuses.
