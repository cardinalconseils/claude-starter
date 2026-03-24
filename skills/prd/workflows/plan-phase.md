# Workflow: Plan Phase

## Overview
Takes the discovery output ({NN}-CONTEXT.md) and produces a PRD document + execution plan (PLAN.md). Uses the **prd-planner** agent.

## Pre-Conditions
- `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md` exists (if not, redirect to `/cks:discuss`)
- `.prd/` state files exist

## Steps

### Step 0: Progress Banner

Display the lifecycle progress banner:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► Phase {NN}: {name} ► PLAN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 [1] Discuss     ✅ done
 [2] Plan        ▶ current
 [3] Execute     ○ pending
 [4] Verify      ○ pending
 [5] Ship        ○ pending
 [6] Retro       ○ pending

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 1: Determine Target Phase

Read `.prd/PRD-STATE.md` to find the active phase, or use the phase number argument.

Verify that {NN}-CONTEXT.md exists for the target phase:
```
Read .prd/phases/{NN}-{name}/{NN}-CONTEXT.md
```

If no {NN}-CONTEXT.md → tell the user: "No discovery found. Run `/cks:discuss {NN}` first."

### Step 2: Gather Planning Inputs

Read all necessary context:
- `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md` — Discovery output
- `.prd/PRD-PROJECT.md` — Project context
- `.prd/PRD-REQUIREMENTS.md` — Existing requirements (for REQ-ID numbering)
- `.prd/PRD-ROADMAP.md` — Current roadmap state
- `CLAUDE.md` — Project conventions

### Step 3: Dispatch Planner Agent

Dispatch the **prd-planner** agent with:

```
Agent prompt:
- Project root: {project_root}
- Phase: {phase_number} — {phase_name}
- Discovery context: {{NN}-CONTEXT.md content}
- Project context: {PROJECT.md content}
- Existing requirements: {REQUIREMENTS.md content}
- Existing PRDs: {list of docs/prds/ files}

Available domain context (if .context/ exists):
{list .context/*.md filenames — these inform planning decisions}

Your job: Follow your agent instructions to produce:
1. A PRD document at docs/prds/PRD-{NNN}-{name}.md
   Use template: .claude/skills/prd/templates/prd.md
2. An execution plan at .prd/phases/{NN}-{name}/{NN}-PLAN.md
   IMPORTANT: Include a `domains:` line listing which .context/ briefs
   the executor should load. Use slugified names matching .context/*.md:
       domains: [nextjs, supabase, stripe]
3. Updated REQUIREMENTS.md with new REQ-IDs
4. Updated PRD-ROADMAP.md with phases and success criteria
   Use format: .claude/skills/prd/references/roadmap-format.md
```

### Step 4: Validate Output

**Check that both artifacts exist and have required content:**

1. `{NN}-PLAN.md` at `.prd/phases/{NN}-{name}/{NN}-PLAN.md`
   - Contains numbered tasks or `## Tasks` section
   - Contains `domains:` line (for context-research integration)

2. PRD document at `docs/prds/PRD-{NNN}-{name}.md`
   - Contains `## Acceptance Criteria` section
   - Contains `## User Stories` or `## Requirements`

**If validation fails:**
```
  [2] Plan        ✗ validation failed
      Expected: {missing file or section}
      Retrying planning...
```
Re-dispatch the planner agent once. If it fails again, ask the user.

### Step 5: Update State

After validation passes:

**Update PRD-STATE.md:**
```yaml
active_phase: {NN}
phase_name: {name}
phase_status: planned
last_action: "PRD and plan created"
last_action_date: {today}
next_action: "Run /cks:execute to implement"
prd_path: docs/prds/PRD-{NNN}-{name}.md
```

**Update PRD-ROADMAP.md:**
- Set the phase status to "Planned"
- Include success criteria from the PRD

### Step 6: Completion Banner + Review

```
  [2] Plan        ✅ done
      Output:
        docs/prds/PRD-{NNN}-{name}.md        — {N} acceptance criteria
        .prd/phases/{NN}-{name}/{NN}-PLAN.md  — {N} tasks

      Tasks:
        1. {task name} — {scope}
        2. {task name} — {scope}

      Key acceptance criteria:
        - {criterion 1}
        - {criterion 2}

      Ready to execute? /cks:execute {NN}
      Want to adjust? Tell me what to change.
```

### Step 7: Context Reset

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
- `docs/prds/PRD-{NNN}-{name}.md` exists
- `.prd/phases/{NN}-{name}/{NN}-PLAN.md` exists
- `.prd/PRD-REQUIREMENTS.md` updated with new REQ-IDs
- `.prd/PRD-ROADMAP.md` updated with phase details
- PRD-STATE.md updated
