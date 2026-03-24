# Workflow: Discuss Phase

## Overview
Interactive requirements discovery for a feature or phase. Produces a {NN}-CONTEXT.md file containing the structured discovery output. Uses the **prd-discoverer** agent.

## Pre-Conditions
- `.prd/` directory exists (if not, redirect to `/prd:new`)
- Phase directory may or may not exist yet

## Steps

### Step 1: Determine Target Phase

Read `.prd/PRD-STATE.md` and `.prd/PRD-ROADMAP.md` to determine the target.

**If phase number provided:**
- Use that phase (e.g., argument `1` → `.prd/phases/01-*/`)
- If phase directory doesn't exist, create it

**If no argument:**
- Check PRD-STATE.md for active phase
- If no active phase, check PRD-ROADMAP.md for next phase needing discussion
- If no phases exist, ask the user what they want to build

### Step 2: Check for Existing Discovery

Read `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md` if it exists.

- If {NN}-CONTEXT.md exists and is complete → ask: "Discovery already done. Re-do or proceed to planning?"
- If {NN}-CONTEXT.md exists but is incomplete → resume from where it left off
- If no {NN}-CONTEXT.md → fresh discovery

### Step 3: Dispatch Discoverer Agent

Dispatch the **prd-discoverer** agent with:

```
Agent prompt:
- Project root: {project_root}
- Phase: {phase_number} — {phase_name}
- Feature brief: {user's description or argument}
- Existing context: {PROJECT.md content}
- Existing requirements: {REQUIREMENTS.md content}
- Codebase conventions: {CLAUDE.md content}

Your job: Run interactive discovery following your agent instructions.
IMPORTANT: Use AskUserQuestion tool for ALL questions — present selectable options, never plain text questions. Research the codebase first so options are informed and specific.
Write the output to: .prd/phases/{NN}-{name}/{NN}-CONTEXT.md
Use the template from: .claude/skills/prd/templates/context.md
```

### Step 4: Update State

After discovery completes:

**Update PRD-STATE.md:**
```yaml
active_phase: {NN}
phase_name: {name}
phase_status: discussed
last_action: "Discovery complete"
last_action_date: {today}
next_action: "Run /prd:plan to create execution plan"
```

**Update PRD-ROADMAP.md:**
- Set the phase status to "Discussed"

### Step 5: Report

Show the user:
```
Discovery complete for Phase {NN}: {name}

Output: .prd/phases/{NN}-{name}/{NN}-CONTEXT.md

Key findings:
- {2-3 bullet summary from {NN}-CONTEXT.md}

Next: Run /prd:plan {NN} to create the execution plan
```

## Post-Conditions
- `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md` exists with structured discovery
- PRD-STATE.md updated
- PRD-ROADMAP.md updated
