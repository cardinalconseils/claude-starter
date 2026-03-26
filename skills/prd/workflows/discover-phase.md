# Workflow: Discover Phase (Phase 1)

## Overview
Structured requirements discovery for a feature using the **9 Elements of Discovery**. Produces a {NN}-CONTEXT.md file. Uses the **prd-discoverer** agent. All user interactions MUST use `AskUserQuestion` with selectable options.

## Pre-Conditions
- `.prd/` directory exists (if not, redirect to `/cks:new`)
- Phase directory may or may not exist yet

## Steps

### Step 0: Progress Banner

Read `.prd/PRD-STATE.md` and scan `.prd/phases/{NN}-{name}/` for existing artifacts.
Display the lifecycle progress banner:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► Phase {NN}: {name} ► DISCOVER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 [1] Discover    ▶ current
     [1a] Problem Statement      ○ pending
     [1b] User Stories            ○ pending
     [1c] Scope (In/Out)          ○ pending
     [1d] API Surface Map         ○ pending
     [1e] Acceptance Criteria     ○ pending
     [1f] Constraints             ○ pending
     [1g] Test Plan               ○ pending
     [1h] UAT Scenarios           ○ pending
     [1i] Definition of Done      ○ pending
     [1j] Success Metrics         ○ pending
 [2] Design      ○ pending
 [3] Sprint      ○ pending
 [4] Review      ○ pending
 [5] Release     ○ pending

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 1: Determine Target Phase

Read `.prd/PRD-STATE.md` and `.prd/PRD-ROADMAP.md` to determine the target.

**If phase number provided:**
- Use that phase (e.g., argument `1` → `.prd/phases/01-*/`)
- If phase directory doesn't exist, create it

**If no argument:**
- Check PRD-STATE.md for active phase
- If no active phase, check PRD-ROADMAP.md for next phase needing discovery
- If no phases exist, ask the user what they want to build

### Step 2: Auto-Research Technologies (Context)

Before discovery, identify technologies/libraries/APIs mentioned in the feature brief or phase description. If any are found and `.context/config.md` doesn't have `auto-research: false`:

1. Extract technology keywords from the feature brief
2. For each technology, check if `.context/<slug>.md` already exists
3. If not, run context research:

```
Skill(skill="context", args="\"${technology}\"")
```

**Skip this step if:**
- No technologies are mentioned in the brief
- `.context/config.md` has `auto-research: false`
- All identified technologies already have context briefs

### Step 3: Check for Existing Discovery

Read `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md` if it exists.

- If {NN}-CONTEXT.md exists and is complete → use AskUserQuestion:

```
AskUserQuestion({
  questions: [{
    question: "Discovery already exists for this phase. What would you like to do?",
    header: "Existing Discovery",
    multiSelect: false,
    options: [
      { label: "Re-do discovery", description: "Start fresh — overwrite existing context" },
      { label: "Resume discovery", description: "Continue from where it left off" },
      { label: "Proceed to Design", description: "Skip — move to Phase 2" }
    ]
  }]
})
```

- If {NN}-CONTEXT.md exists but is incomplete → resume from where it left off
- If no {NN}-CONTEXT.md → fresh discovery

### Step 4: Dispatch Discoverer Agent — The 9 Elements

Dispatch the **prd-discoverer** agent. The agent MUST gather all 9 elements using `AskUserQuestion` for every interaction.

```
Agent prompt:
- Project root: {project_root}
- Phase: {phase_number} — {phase_name}
- Feature brief: {user's description or argument}
- Existing context: {PROJECT.md content}
- Existing requirements: {REQUIREMENTS.md content}
- Codebase conventions: {CLAUDE.md content}

Your job: Run structured discovery for all 9 Elements.

CRITICAL RULES:
1. Use AskUserQuestion tool for ALL questions — present selectable options, never plain text questions
2. Research the codebase FIRST so options are informed and specific
3. Cover ALL 9 elements in order:
   [1a] Problem Statement & Value Proposition
   [1b] User Stories (at least 3)
   [1c] Scope — In/Out boundaries
   [1d] API Surface Map — resources, operations, consumers (if feature has API)
   [1e] Acceptance Criteria (testable, per user story — reference API endpoints where applicable)
   [1f] Constraints & Negative Cases
   [1g] Test Plan — unit, integration, AND E2E test scenarios (include API endpoint tests)
   [1h] UAT Scenarios — end-to-end stakeholder validation flows
   [1i] Definition of Done
   [1j] Success Metrics / KPIs

4. For the API Surface Map [1d]:
   - Check CLAUDE.md and .kickstart/artifacts/ARCHITECTURE.md for project-level API conventions
   - Inherit the API style (REST/GraphQL/tRPC), error format, and auth pattern — do NOT re-decide them
   - Map which resources and operations THIS FEATURE needs
   - Note which endpoints are new vs. modifications to existing ones
   - If the feature has no API component, mark [1d] as "N/A — no API endpoints"

5. For the Test Plan [1g], explicitly define:
   - Unit test cases per acceptance criterion
   - Integration test cases for component interactions (include API endpoint tests where applicable)
   - End-to-end test scenarios covering full user journeys

5. Write the output to: .prd/phases/{NN}-{name}/{NN}-CONTEXT.md
   Use the template from: .claude/skills/prd/templates/context.md
```

Update sub-step status as the agent completes each element:
```
  [1a] Problem Statement      ✅ done
  [1b] User Stories            ✅ 4 stories
  [1c] Scope (In/Out)          ✅ done
  [1d] Acceptance Criteria     ▶ in progress
  ...
```

### Step 5: Validate Output

**Check that `{NN}-CONTEXT.md` exists and has all 9 elements:**
- File exists at `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md`
- Contains `## Problem Statement` or `## Value Proposition`
- Contains `## User Stories`
- Contains `## Scope`
- Contains `## API Surface` (or marked N/A if no API)
- Contains `## Acceptance Criteria`
- Contains `## Constraints`
- Contains `## Test Plan` with unit, integration, AND E2E sections
- Contains `## UAT Scenarios`
- Contains `## Definition of Done`
- Contains `## Success Metrics`

**If validation fails:**
```
  [1] Discover    ✗ validation failed
      Expected: .prd/phases/{NN}-{name}/{NN}-CONTEXT.md
      Missing: {which elements are missing}
      Retrying discovery for missing elements...
```
Re-dispatch the discoverer agent for ONLY the missing elements. If it fails again, ask the user.

### Step 6: Update State

After validation passes:

**Update PRD-STATE.md:**
```yaml
active_phase: {NN}
phase_name: {name}
phase_status: discovered
last_action: "Discovery complete — 10/10 elements gathered"
last_action_date: {today}
next_action: "Run /cks:design to create UI designs"
```

**Update PRD-ROADMAP.md:**
- Set the phase status to "Discovered"

### Step 7: Completion Banner

```
  [1] Discover    ✅ done
      Output: .prd/phases/{NN}-{name}/{NN}-CONTEXT.md
      Elements: 10/10 complete
        ✅ Problem Statement    ✅ User Stories (N)
        ✅ Scope                ✅ API Surface ({N} endpoints | N/A)
        ✅ Acceptance Criteria  ✅ Constraints
        ✅ Test Plan            ✅ UAT Scenarios (N)
        ✅ Definition of Done   ✅ Success Metrics (N)
      Next: /cks:design {NN}
```

### Step 8: Context Reset & Compaction

All state is persisted to disk. Suggest compaction before the next phase:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Discovery complete. All 10 elements saved to {NN}-CONTEXT.md.
Run /compact before design to free context for the next phase.

  ✅ CONTEXT.md      — all 9 discovery elements
  ✅ PRD-STATE.md    — phase tracking
  ✅ Working Notes   — session context (auto-captured)

  /compact
  /cks:next

Nothing is lost.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Do NOT chain to the next workflow via Skill().** Stop here.

## Post-Conditions
- `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md` exists with all 10 discovery elements
- PRD-STATE.md updated
- PRD-ROADMAP.md updated
