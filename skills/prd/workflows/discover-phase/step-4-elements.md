# Step 4: Dispatch Discoverer Agent — The 10 Elements

<context>
Phase: Discover (Phase 1)
Requires: {NN}, {name}, feature brief available
Produces: {NN}-CONTEXT.md with all 10 discovery elements
</context>

## Inputs

- Variables: `{NN}`, `{name}`, `{project_root}`, `{feature_brief}`
- Files (passed as paths to agent, not embedded):
  - `.prd/PRD-PROJECT.md`
  - `.prd/PRD-REQUIREMENTS.md`
  - `CLAUDE.md`

## Instructions

Dispatch the **prd-discoverer** agent:

```
Agent(
  subagent_type="prd-discoverer",
  prompt="
    MODE: INTERACTIVE (you MUST use AskUserQuestion — this is NOT autonomous mode)
    Project root: {project_root}
    Phase: {NN} — {name}
    Feature brief: {feature_brief}

    Read these files (lazy — do not embed contents):
    - .prd/PRD-PROJECT.md — project context
    - .prd/PRD-REQUIREMENTS.md — existing requirements
    - CLAUDE.md — conventions

    Your job: Run structured discovery for all 10 Elements.

CRITICAL RULES:
1. You MUST call AskUserQuestion for ALL questions — present selectable options, never plain text.
2. Research the codebase FIRST so options are informed and specific.
3. HARD GATE — Do NOT write CONTEXT.md until the user has explicitly confirmed:
   - User Stories (minimum 3, each with 'so that' clause)
   - Acceptance Criteria (minimum 2 per story, testable)
   - Test Plan (unit + integration + E2E scenarios)
   - UAT Scenarios (minimum 3 Given/When/Then scenarios)
4. Cover ALL 10 elements in order:
   [1a] Problem Statement & Value Proposition
   [1b] User Stories (at least 3)
   [1c] Scope — In/Out boundaries
   [1d] API Surface Map (N/A if no API)
   [1e] Acceptance Criteria (testable, per user story)
   [1f] Constraints & Negative Cases
   [1g] Test Plan — unit, integration, AND E2E
   [1h] UAT Scenarios — end-to-end validation flows
   [1i] Definition of Done
   [1j] Success Metrics / KPIs
5. Write output to: .prd/phases/{NN}-{name}/{NN}-CONTEXT.md
   Use template from: skills/prd/templates/context.md
  "
)
```

Update sub-step status as the agent completes each element:
```
  [1a] Problem Statement      ✅ done
  [1b] User Stories            ✅ 4 stories
  [1c] Scope (In/Out)          ✅ done
  [1d] Acceptance Criteria     ▶ in progress
  ...
```

## Success Condition

- `{NN}-CONTEXT.md` written by the agent
- Agent called AskUserQuestion at least 4 times

## On Failure

- If agent fails to produce CONTEXT.md: report failure, suggest running `/cks:discover` again
