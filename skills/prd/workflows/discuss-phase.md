# Workflow: Discuss Phase

## Overview
Interactive requirements discovery for a feature or phase. Produces a {NN}-CONTEXT.md file containing the structured discovery output. Uses the **prd-discoverer** agent.

## Pre-Conditions
- `.prd/` directory exists (if not, redirect to `/cks:new`)
- Phase directory may or may not exist yet

## Steps

### Step 0: Progress Banner

Read `.prd/PRD-STATE.md` and scan `.prd/phases/{NN}-{name}/` for existing artifacts.
Display the lifecycle progress banner (see SKILL.md "Progress Tracker" section):

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► Phase {NN}: {name} ► DISCUSS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 [1] Discuss     ▶ current
 [2] Plan        ○ pending
 [3] Execute     ○ pending
 [4] Verify      ○ pending
 [5] Ship        ○ pending
 [6] Retro       ○ pending

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 1: Determine Target Phase

Read `.prd/PRD-STATE.md` and `.prd/PRD-ROADMAP.md` to determine the target.

**If phase number provided:**
- Use that phase (e.g., argument `1` → `.prd/phases/01-*/`)
- If phase directory doesn't exist, create it

**If no argument:**
- Check PRD-STATE.md for active phase
- If no active phase, check PRD-ROADMAP.md for next phase needing discussion
- If no phases exist, ask the user what they want to build

### Step 2: Auto-Research Technologies (Context)

Before discovery, identify technologies/libraries/APIs mentioned in the feature brief or phase description. If any are found and `.context/config.md` doesn't have `auto-research: false`:

1. Extract technology keywords from the feature brief (e.g., "Stripe", "Supabase RLS", "React Server Components")
2. For each technology, check if `.context/<slug>.md` already exists
3. If not, run context research:

```
Skill(skill="context", args="\"${technology}\"")
```

This pre-loads relevant documentation so the discoverer agent has better context.

**Skip this step if:**
- No technologies are mentioned in the brief
- `.context/config.md` has `auto-research: false`
- All identified technologies already have context briefs

### Step 3: Check for Existing Discovery

Read `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md` if it exists.

- If {NN}-CONTEXT.md exists and is complete → ask: "Discovery already done. Re-do or proceed to planning?"
- If {NN}-CONTEXT.md exists but is incomplete → resume from where it left off
- If no {NN}-CONTEXT.md → fresh discovery

### Step 4: Dispatch Discoverer Agent

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

### Step 5: Validate Output

**Check that `{NN}-CONTEXT.md` exists and has required content:**
- File exists at `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md`
- Contains `## Functional Requirements` or `## User Stories` or `## Requirements`
- Contains `## Scope` or `## Feature Description`

**If validation fails:**
```
  [1] Discuss     ✗ validation failed
      Expected: .prd/phases/{NN}-{name}/{NN}-CONTEXT.md
      Missing: {what section is missing}
      Retrying discovery...
```
Re-dispatch the discoverer agent once. If it fails again, ask the user.

### Step 6: Update State

After validation passes:

**Update PRD-STATE.md:**
```yaml
active_phase: {NN}
phase_name: {name}
phase_status: discussed
last_action: "Discovery complete"
last_action_date: {today}
next_action: "Run /cks:plan to create execution plan"
```

**Update PRD-ROADMAP.md:**
- Set the phase status to "Discussed"

### Step 7: Completion Banner

```
  [1] Discuss     ✅ done
      Output: .prd/phases/{NN}-{name}/{NN}-CONTEXT.md
      Requirements: {N} identified | Scope: {summary}
```

### Step 8: Context Reset

All state is persisted to disk. Instruct the user to clear the context window before continuing:

```
━━━ Context Reset ━━━
Phase artifacts saved. Clear context and continue:

  /clear
  /cks:next

State is on disk — nothing is lost.
━━━━━━━━━━━━━━━━━━━━━
```

**Do NOT chain to the next workflow via Skill().** Stop here. The user runs `/clear` then `/cks:next` to continue with a fresh context window.

## Post-Conditions
- `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md` exists with structured discovery
- PRD-STATE.md updated
- PRD-ROADMAP.md updated
