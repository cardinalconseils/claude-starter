---
description: "Project enabler — idea to scaffolded project"
argument-hint: "[idea pitch]"
allowed-tools:
  - Read
  - Agent
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

### Phase 1+1b: Intake & Compose

```
Agent(subagent_type="kickstart-intake", prompt="Idea pitch: $ARGUMENTS. Run the full intake Q&A and compose phases. Read workflows/intake.md and workflows/compose.md for step-by-step process. Write outputs to .kickstart/. Ask the user about optional phases (research, monetize, brand) and record decisions in state.md.")
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

```
Agent(subagent_type="monetize-discoverer", prompt="Evaluate monetization for this project. Read .kickstart/context.md for project context and .kickstart/research.md if it exists. Save to .monetize/. Update .kickstart/state.md: set monetize phase status to done with today's date.")
```

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
