# Workflow: Autonomous Execution

<purpose>
Drive all remaining phases autonomously. For each incomplete phase: discuss → plan → execute → verify → commit. After all phases: ship (e2e test → commit → push → PR → review → deploy → update roadmap). Pauses only for true blockers (verification failure after retry).

Uses explicit Agent() dispatches for phase work and Skill() invocations for ship workflow.
</purpose>

## Pre-Conditions
- `.prd/` exists with PRD-ROADMAP.md and PRD-STATE.md
- At least one phase defined

## Process

### Step 1: Initialize

Read project state:
```
Read .prd/PRD-STATE.md
Read .prd/PRD-ROADMAP.md
Read .prd/PRD-PROJECT.md
Read CLAUDE.md
```

Parse `$ARGUMENTS` for `--from N` flag (start from specific phase) and `--skip-verify` flag.

Display startup banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► AUTONOMOUS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Project: {name}
 Phases: {total} total, {complete} complete
 Mode: Full autonomous (discuss → plan → execute → verify → ship)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 2: Discover Incomplete Phases

Scan `.prd/phases/` filesystem to derive status (don't trust PRD-STATE.md):

```bash
for dir in .prd/phases/*/; do
  phase=$(basename "$dir")
  nn=$(echo "$phase" | grep -oE '^[0-9]+')
  has_context=$(ls "$dir"*-CONTEXT.md 2>/dev/null | wc -l)
  has_plan=$(ls "$dir"*-PLAN.md 2>/dev/null | wc -l)
  has_summary=$(ls "$dir"*-SUMMARY.md 2>/dev/null | wc -l)
  has_verification=$(ls "$dir"*-VERIFICATION.md 2>/dev/null | wc -l)
done
```

Filter to incomplete phases. Apply `--from N` filter if provided. Sort ascending.

If no incomplete phases → jump to Step 5 (Ship).

Display phase plan:
```
Phase Plan:
| # | Phase | Needs |
|---|-------|-------|
| 08 | icon-picker-edge-labels | discuss → plan → execute → verify |
| 09 | {name} | Not started |
```

### Step 3: Execute Each Phase

For each incomplete phase:

**3a. Progress Banner:**
```
━━━ Phase {NN}/{total}: {name} [████░░░░] {%}% ━━━
```

**3b. Auto-Research (if technologies identified):**

Extract technology keywords from the phase description in PRD-ROADMAP.md. For each technology that doesn't already have a `.context/<slug>.md`:

```
Skill(skill="context", args="\"${technology}\"")
```

Skip if `.context/config.md` has `auto-research: false`.

**3c. Discuss (if no {NN}-CONTEXT.md):**

```
Agent(
  subagent_type="prd-discoverer",
  prompt="Project root: {project_root}
Phase: {NN} — {phase_name}
Feature brief: {from PRD-ROADMAP.md description}
Existing context: {PRD-PROJECT.md content}
Existing requirements: {PRD-REQUIREMENTS.md content}
Codebase conventions: {CLAUDE.md content}

AUTONOMOUS MODE: Do NOT ask questions. Infer requirements from codebase research.
Write output to: .prd/phases/{NN}-{name}/{NN}-CONTEXT.md
Use template: .claude/skills/prd/templates/context.md"
)
```

Verify output exists. If not → log error, skip to next phase.

```
Phase {NN}: Discuss ✓
```

**3d. Plan (if no {NN}-PLAN.md):**

```
Agent(
  subagent_type="prd-planner",
  prompt="Project root: {project_root}
Phase: {NN} — {phase_name}
Discovery context: {.prd/phases/{NN}-{name}/{NN}-CONTEXT.md content}
Project context: {.prd/PRD-PROJECT.md content}
Existing requirements: {.prd/PRD-REQUIREMENTS.md content}
Existing PRDs: {list of docs/prds/ files}
Available domain context: {list .context/*.md filenames}

Produce:
1. PRD document at docs/prds/PRD-{NNN}-{name}.md (use template: .claude/skills/prd/templates/prd.md)
2. Execution plan at .prd/phases/{NN}-{name}/{NN}-PLAN.md
   Include a domains: line listing .context/ slugs the executor should load
3. Updated .prd/PRD-REQUIREMENTS.md with new REQ-IDs
4. Updated .prd/PRD-ROADMAP.md with phases and success criteria (use format: .claude/skills/prd/references/roadmap-format.md)"
)
```

Verify output exists. If not → log error, skip to next phase.

```
Phase {NN}: Plan ✓
```

**3e. Execute (if no {NN}-SUMMARY.md):**

```
Agent(
  subagent_type="prd-executor",
  prompt="Project root: {project_root}
Phase: {NN} — {phase_name}
Plan: {.prd/phases/{NN}-{name}/{NN}-PLAN.md content}
Context: {.prd/phases/{NN}-{name}/{NN}-CONTEXT.md content}
PRD: {docs/prds/PRD-{NNN}.md content}
Conventions: {CLAUDE.md content}
Domain context: {.context/*.md briefs matching PLAN.md domains: tags}

Implement all tasks from the plan. Follow project conventions.
Use the domain context briefs for API patterns, gotchas, and code style.
Write summary to: .prd/phases/{NN}-{name}/{NN}-SUMMARY.md"
)
```

Verify output exists. If not → log error, skip to next phase.

After execution, run dependency sync:
```bash
if [ -f "package.json" ]; then
  npm install && npm run build
elif [ -f "requirements.txt" ]; then
  pip install -r requirements.txt
elif [ -f "pyproject.toml" ]; then
  pip install -e .
fi
```

If build fails → log error, attempt fix, retry once.

```
Phase {NN}: Execute ✓
```

**3f. Verify (unless --skip-verify):**

```
Agent(
  subagent_type="prd-verifier",
  prompt="Project root: {project_root}
Phase: {NN} — {phase_name}
Plan: {.prd/phases/{NN}-{name}/{NN}-PLAN.md content}
Summary: {.prd/phases/{NN}-{name}/{NN}-SUMMARY.md content}
PRD acceptance criteria: {from PRD document}
Verification patterns: {from .claude/skills/prd/references/verification-patterns.md}

Check each acceptance criterion. Run tests if available. Verify code quality.
Write results to: .prd/phases/{NN}-{name}/{NN}-VERIFICATION.md"
)
```

Read verdict from {NN}-VERIFICATION.md:

**PASS:**
```
Phase {NN}: Verify ✓ — All criteria passed
```
Proceed to 3f.

**FAIL (first attempt):**
```
Phase {NN}: Verify ✗ — Retrying...
```
Delete {NN}-SUMMARY.md. Re-dispatch executor agent. Re-dispatch verifier agent.

**FAIL (second attempt):**
```
Phase {NN}: Verify ✗ — {N} criteria failed
  - {criterion}: {reason}
Continuing to next phase.
```
Proceed to 3f anyway (log the failure).

**3g. Commit Phase:**

```bash
git add -A
git commit -m "$(cat <<'EOF'
feat(phase-{NN}): {phase name}

Phase {NN} of PRD-{NNN}
- {key changes from SUMMARY.md}

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```

**3h. Update State:**

Update PRD-STATE.md:
```yaml
active_phase: {NN}
phase_status: verified
last_action: "Phase {NN} complete"
last_action_date: {today}
```

Update PRD-ROADMAP.md: mark phase as "Complete" with date.

### Step 4: Phase Transition

Re-read PRD-ROADMAP.md (catches dynamically inserted phases).
Re-scan `.prd/phases/` filesystem for actual status.

```
Phase {NN} ✓ — {X}/{total} complete
```

If more incomplete phases → loop back to Step 3.
If all complete → proceed to Step 5.

### Step 5: Ship

Invoke the full ship workflow via Skill:

```
Skill(skill="ship")
```

This runs the complete ship workflow from `.claude/skills/prd/workflows/ship.md` which includes:

1. **Preflight checks** — git status, branch, remote, gh CLI
2. **Dependency sync** — `npm install` / `pip install`, build verification
3. **E2E testing** — `Skill(skill="browse")` for frontend features, screenshot evidence
4. **Commit** — one commit per phase with structured message
5. **Branch** — create feat/ branch if on main
6. **Push** — `git push -u origin {branch}`
7. **PR** — `gh pr create` with body from planning artifacts + E2E results
8. **Code review** — tries in order:
   - `Skill(skill="pr-review-toolkit:review-pr")`
   - `Skill(skill="code-review:code-review")`
   - `Skill(skill="coderabbit:review")`
9. **Deploy** — `Skill(skill="deploy")` or `Skill(skill="vercel:deploy")`
10. **Update state** — PRD-ROADMAP.md, PRD-STATE.md, PRD document
11. **Auto-retrospective** — `Skill(skill="retro", args="--auto")` captures learnings

### Step 6: Final Report

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Feature: PRD-{NNN} — {name}
 Phases: {total}/{total} ✓
 PR: #{number} ({url})
 E2E: {PASS/SKIP}
 Deploy: {status}

 Results:
   Phase 05: {name} — ✓
   Phase 06: {name} — ✓
   Phase 07: {name} — ✓
   Phase 08: {name} — ✓

 discuss ✓ → plan ✓ → execute ✓ → verify ✓ → ship ✓ → retro ✓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Tip: Run /ralph-loop:ralph-loop "monitor PR #{number}" for CD
Tip: Run /cks:retro to review learnings and convention proposals
```

## Context Management

Autonomous mode runs continuously — agents handle heavy work in their own isolated context. However:

- **State is persisted after every step.** If the orchestrator's context gets large or is interrupted, the user can safely:
  ```
  /clear
  /cks:autonomous
  ```
  The workflow will re-scan `.prd/phases/` filesystem, skip completed work, and resume from the next incomplete phase.

- **Agent dispatches are context-isolated.** Each Agent() call runs in its own context, so the orchestrator's window only holds summaries, not full agent output.

- **Between phases**, re-read state from disk (Step 4) rather than relying on in-memory context from previous phases.

## Guardrails

1. **No interactive questions** — Discoverer uses autonomous mode. No AskUserQuestion calls.
2. **No confirmation prompts** — Execute immediately. The user invoked autonomous mode.
3. **Max 1 retry per step** — Prevents infinite loops.
4. **Commit after each phase** — Atomic history, recoverable on interruption.
5. **State persistence** — PRD-STATE.md updated after every step. `/cks:next` can resume.
6. **Filesystem is truth** — Re-scan `.prd/phases/` between phases, don't trust stale state.
7. **Skip on error** — If a step fails after retry, log and continue. Don't block the whole run.
8. **Build after execute** — Always run dependency sync + build after executor finishes.
9. **Ship delegates** — Step 5 invokes `Skill(skill="ship")` which handles E2E, deps, commit, PR, review, deploy as a single workflow.
