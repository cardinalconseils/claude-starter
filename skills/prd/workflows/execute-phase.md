# Workflow: Execute Phase

## Overview
Implements code changes for a planned phase. Uses the **prd-executor** agent. Produces a SUMMARY.md with results.

## Pre-Conditions
- `.prd/phases/{NN}-{name}/{NN}-PLAN.md` exists (if not, redirect to `/cks:plan`)
- PRD document exists in `docs/prds/`

## Steps

### Step 0: Auto Mode Tip

If the user will be stepping away or this phase involves many file edits and bash commands, display this tip once before the progress banner:

```
💡 For uninterrupted execution, enable Auto mode (Shift+Tab → "auto" or claude --auto)
```

Then proceed immediately — do not wait for a response.

### Step 0b: Progress Banner

Display the lifecycle progress banner:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► Phase {NN}: {name} ► EXECUTE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 [1] Discuss     ✅ done
 [2] Plan        ✅ done
 [3] Execute     ▶ current
 [4] Verify      ○ pending
 [5] Ship        ○ pending
 [6] Retro       ○ pending

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 1: Determine Target Phase

Read `.prd/PRD-STATE.md` to find the active phase, or use the phase number argument.

Verify that PLAN.md exists:
```
Read .prd/phases/{NN}-{name}/{NN}-PLAN.md
```

If no PLAN.md → tell the user: "No plan found. Run `/cks:plan {NN}` first."

### Step 1b: Execution Strategy (Superpowers)

Before coding, set up the execution approach. Try these in order — skip silently if not installed:

**Isolate the work (if complex feature):**
```
Skill(skill="superpowers:using-git-worktrees")
```

**Test-driven development (if tests are feasible):**
```
Skill(skill="superpowers:test-driven-development")
```

**Parallel execution (if plan has independent tasks):**
```
Skill(skill="superpowers:subagent-driven-development")
```

Pick the most appropriate strategy based on the PLAN.md structure:
- Independent tasks → parallel agents
- Sequential tasks → TDD
- Large feature → git worktree for isolation

### Step 2: Load Execution Context

Read all necessary files:
- `.prd/phases/{NN}-{name}/{NN}-PLAN.md` — Execution plan
- `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md` — Discovery context
- PRD document (path from PRD-STATE.md or find in `docs/prds/`)
- `CLAUDE.md` — Project conventions
- `.prd/PRD-PROJECT.md` — Project context

### Step 2b: Load Domain Context

If `.context/` directory exists:

1. Read `domains:` from PLAN.md (e.g., `domains: [nextjs, supabase, stripe]`)
2. For each domain, check if `.context/{domain}*.md` exists (glob match)
3. If it exists, read it — this will be included in the executor agent prompt
4. If a domain has no matching brief, auto-research it:
   ```
   Skill(skill="context", args="\"${domain}\"")
   ```

Also scan the plan text for technology keywords not in the domains list.
If the plan mentions "Stripe webhook" but domains doesn't include stripe,
check `.context/stripe*.md` anyway.

Collect all matched briefs as `{domain_context}` for Step 4.

### Step 3: Confirm Scope

Before dispatching the executor, present to the user:
```
Phase {NN}: {name}
Goal: {from PLAN.md}
Files to modify: {list}
Acceptance criteria:
  - {criterion 1}
  - {criterion 2}

Proceed? [y/n]
```

### Step 4: Dispatch Executor Agent

Dispatch the **prd-executor** agent with:

```
Agent prompt:
- Project root: {project_root}
- Phase: {phase_number} — {phase_name}
- Plan: {PLAN.md content}
- PRD: {PRD content}
- Context: {CONTEXT.md content}
- Conventions: {CLAUDE.md content}
- Domain context: {domain_context from Step 2b — .context/*.md briefs matching this phase's domains}

Your job: Follow your agent instructions to:
1. Implement all tasks from the plan
2. Follow project conventions
3. Write a summary to .prd/phases/{NN}-{name}/{NN}-SUMMARY.md
```

### Step 5: Validate Output

**Check that `{NN}-SUMMARY.md` exists and has required content:**
- File exists at `.prd/phases/{NN}-{name}/{NN}-SUMMARY.md`
- Contains `## Changes` or `## Files Modified` section
- Contains at least one file path reference

**If validation fails:**
```
  [3] Execute     ✗ validation failed
      Expected: .prd/phases/{NN}-{name}/{NN}-SUMMARY.md
      Missing: {what's missing}
      Retrying execution...
```
Re-dispatch the executor agent once. If it fails again, invoke systematic debugging:

```
Skill(skill="superpowers:systematic-debugging")
```

This diagnoses the root cause before retrying. Skip silently if superpowers not installed. If still failing after debug, ask the user.

### Step 6: Update State

After validation passes:

**Update PRD-STATE.md:**
```yaml
active_phase: {NN}
phase_name: {name}
phase_status: executed
last_action: "Implementation complete"
last_action_date: {today}
next_action: "Run /cks:verify to check acceptance criteria"
```

**Update PRD-ROADMAP.md:**
- Set the phase status to "Executed — Pending Verification"

**Update PRD:**
- Add implementation notes to the relevant phase section

### Step 7: Completion Banner

```
  [3] Execute     ✅ done
      Output: .prd/phases/{NN}-{name}/{NN}-SUMMARY.md
      Files changed: {N}
        - {file1} — {what changed}
        - {file2} — {what changed}
      Next: /cks:verify {NN}
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
- Code changes implemented
- `.prd/phases/{NN}-{name}/{NN}-SUMMARY.md` exists
- PRD-STATE.md updated
- PRD-ROADMAP.md updated
- PRD updated with implementation notes
