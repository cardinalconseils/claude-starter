# Workflow: Sprint Phase (Phase 3)

## Overview
Full sprint execution: planning → technical design → implementation → code review → QA → UAT → merge. Orchestrates multiple agents (prd-planner, prd-executor, prd-verifier) through sub-steps. All user interactions MUST use `AskUserQuestion` with selectable options.

## Pre-Conditions
- `.prd/phases/{NN}-{name}/{NN}-DESIGN.md` exists (if not, redirect to `/cks:design`)
- `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md` exists
- `.prd/` state files exist

## Steps

### Step 0: Auto Mode Tip

```
💡 Sprint runs many operations. For uninterrupted execution, enable Auto mode (Shift+Tab → "auto")
```

### Step 0b: Detect Iteration Mode

Read `.prd/PRD-STATE.md`. Check `phase_status`:

- `designed` or `not_started` → **First Sprint** (iteration = 0)
- `iterating_sprint` → **Iteration Sprint** — read `iteration_count` from STATE.md
- `iterating_design` → Redirect: "Design iteration needed first. Run `/cks:design {NN}`."
- `iterating_discover` → Redirect: "Re-discovery needed first. Run `/cks:discover {NN}`."

**If Iteration Sprint:**
1. Read `iteration_count` from STATE.md (default to 1 if not set)
2. Read `.prd/phases/{NN}-{name}/{NN}-BACKLOG.md` — this is the iteration's work scope
3. Read `.prd/phases/{NN}-{name}/{NN}-REVIEW.md` — feedback that triggered this iteration
4. Set `{iteration}` = iteration_count for use in banners and artifact names

### Load phase mode
Read `.prd/prd-config.json` — extract `phases.sprint.mode`.
If not set or file missing, default to `interactive`.
Set PHASE_MODE = the extracted value.

**Mode behavior for this phase:**
- `interactive` → Execute all sub-steps as written. Pause between major steps ([3a], [3c], [3d], [3e]).
- `auto` → Execute all sub-steps sequentially without pausing. Select recommended options automatically. This is the default for sprint — the plan was already approved in design.
- `gated` → Execute steps like auto, but after the final sub-step ([3f] UAT or merge), pause and ask: "Sprint complete. Review results and proceed to review? (Yes / Continue iterating)"

### Step 0c: Progress Banner

**First Sprint:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► Phase {NN}: {name} ► SPRINT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 [1] Discover    ✅ done
 [2] Design      ✅ done
 [3] Sprint      ▶ current
     [3a] Sprint Planning        ○ pending
     [3b] Design & Architecture  ○ pending
     [3c] Implementation         ○ pending
     [3c+] De-Sloppify           ○ pending
     [3d] Code Review            ○ pending
     [3e] QA Validation          ○ pending
     [3f] UAT                    ○ pending
     [3g] Merge to Main          ○ pending
     [3h] Documentation Check    ○ pending
 [4] Review      ○ pending
 [5] Release     ○ pending

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Iteration Sprint:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► Phase {NN}: {name} ► SPRINT — Iteration #{iteration}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Iteration reason: {iteration_reason from STATE.md}
 Backlog items:    {N} from BACKLOG.md

 [1] Discover    ✅ done
 [2] Design      ✅ done
 [3] Sprint      ✅ done (initial)
 [4] Review      ✅ done → iterate
 [3] Sprint      ▶ Iteration #{iteration}
     [3a] Iteration Planning     ○ pending  ← scoped to BACKLOG.md
     [3b] Design & Architecture  ○ pending  ← updates only
     [3c] Implementation         ○ pending  ← fixes from backlog
     [3c+] De-Sloppify           ○ pending
     [3d] Code Review            ○ pending
     [3e] QA Validation          ○ pending
     [3f] UAT                    ○ pending
     [3g] Merge to Main          ○ pending
     [3h] Documentation Check    ○ pending
 [4] Review      ○ pending
 [5] Release     ○ pending

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "phase.sprint.started" "{NN}-{name}" "Sprint phase started"`

### Step 1: Determine Target Phase

Read `.prd/PRD-STATE.md` to find the active phase, or use the phase number argument.

Verify that DESIGN.md exists:
```
Read .prd/phases/{NN}-{name}/{NN}-DESIGN.md
```

If no DESIGN.md → tell the user: "No design found. Run `/cks:design {NN}` first."

If DESIGN.md exists but no CONTEXT.md → error: "No discovery found. Run `/cks:discover {NN}` first."

### Step 2: Check Sprint Resume

**First Sprint** — check for existing artifacts to resume:
- `{NN}-PLAN.md` exists → resume from [3c] or later
- `{NN}-SUMMARY.md` exists → resume from [3d] or later
- `{NN}-VERIFICATION.md` exists → resume from [3f] or later

**Iteration Sprint** — always start fresh from [3a] (Iteration Planning). Previous artifacts are preserved with iteration suffixes. Do NOT resume from a previous iteration's artifacts.

If resuming (first sprint only), skip completed sub-steps and update the progress banner accordingly.

---

### Sub-step [3a]: Sprint Planning / Iteration Planning

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3a.started" "{NN}-{name}" "Sprint: planning started"`

**Uses: prd-planner agent**

#### First Sprint — Full Planning

Dispatch the **prd-planner** agent with file paths (NOT embedded content):

```
Agent(
  subagent_type="prd-planner",
  prompt="
    Project root: {project_root}
    Phase: {phase_number} — {phase_name}

    Read these files for context (DO NOT embed contents in this prompt):
    - .prd/phases/{NN}-{name}/{NN}-CONTEXT.md — Discovery output
    - .prd/phases/{NN}-{name}/{NN}-DESIGN.md — Design specs
    - .prd/phases/{NN}-{name}/design/component-specs.md — Component specs
    - .prd/PRD-PROJECT.md — Project context
    - .prd/PRD-REQUIREMENTS.md — Existing requirements
    - Available domain context: {list .context/*.md filenames}

    Produce:
    1. PRD document at docs/prds/PRD-{NNN}-{name}.md
       Use template: .claude/skills/prd/templates/prd.md
    2. Execution plan at .prd/phases/{NN}-{name}/{NN}-PLAN.md
       Include a domains: line listing .context/ slugs the executor should load
       Include task estimates and sprint goal
    3. Updated .prd/PRD-REQUIREMENTS.md with new REQ-IDs
    4. Updated .prd/PRD-ROADMAP.md

    CRITICAL: Reference the design specs — implementation must match approved screens.
    CRITICAL: Use AskUserQuestion for scope confirmation, not plain text.
  "
)
```

Present sprint scope to user:
```
AskUserQuestion({
  questions: [{
    question: "Sprint plan ready. {N} tasks estimated at {effort}. Proceed?",
    header: "Sprint Planning",
    multiSelect: false,
    options: [
      { label: "Approve sprint scope", description: "Start technical design" },
      { label: "Reduce scope", description: "Too much for one sprint" },
      { label: "Expand scope", description: "Missing tasks" },
      { label: "Re-estimate", description: "Effort estimates seem off" }
    ]
  }]
})
```

```
  [3a] Sprint Planning        ✅ {N} tasks, goal: {sprint_goal}
```

#### Generate Newman Collection (if API feature)

After planning, if the feature has an API contract from Design phase [2b]:

1. Check if `.prd/phases/{NN}-{name}/design/api-contract.md` exists
2. If yes, generate a Postman/Newman collection from the contract:

```
mkdir -p .prd/phases/{NN}-{name}/testing/newman
```

Generate `api-contract.postman_collection.json` containing:
- One request per endpoint from `api-contract.md`
- Request body from example request in the contract
- Test assertions: status code, response schema fields, required headers
- Pre-request scripts for auth tokens (if auth is required)

Generate `env-dev.postman_environment.json` with:
- `base_url`: `http://localhost:{port}` (from project config or default 3000)
- `auth_token`: `{{auth_token}}` placeholder

These collections are reused by prd-verifier in [3e] QA and by release [5c] RC validation.

#### Iteration Sprint — Scoped to Backlog

**Do NOT re-plan from scratch.** The iteration is scoped to BACKLOG.md items from Phase 4.

1. Read `.prd/phases/{NN}-{name}/{NN}-BACKLOG.md` — the iteration's scope
2. Read `.prd/phases/{NN}-{name}/{NN}-REVIEW.md` — the feedback context
3. Read previous `{NN}-PLAN.md` and `{NN}-SUMMARY.md` — what was already built

Dispatch the **prd-planner** agent in iteration mode with file paths (NOT embedded content):

```
Agent(
  subagent_type="prd-planner",
  prompt="
    Project root: {project_root}
    Phase: {phase_number} — {phase_name}
    ITERATION MODE: Iteration #{iteration}

    Read these files (DO NOT embed contents in this prompt):
    - .prd/phases/{NN}-{name}/{NN}-BACKLOG.md — THIS IS THE SCOPE
    - .prd/phases/{NN}-{name}/{NN}-REVIEW.md — WHY we're iterating
    - .prd/phases/{NN}-{name}/{NN}-PLAN.md — what was already built
    - .prd/phases/{NN}-{name}/{NN}-SUMMARY.md — what files were changed
    - .prd/phases/{NN}-{name}/{NN}-DESIGN.md — design specs
    - .prd/phases/{NN}-{name}/{NN}-CONTEXT.md — discovery context

    Produce:
    1. Iteration plan at .prd/phases/{NN}-{name}/{NN}-PLAN-iter{iteration}.md
       - ONLY tasks from BACKLOG.md — do not re-plan completed work
       - Reference previous SUMMARY.md for files that need modification
       - Include iteration goal (fix/improve, not build from scratch)
    2. Updated PRD-ROADMAP.md — mark as 'Iterating (#{iteration})'

    CRITICAL: Scope is BACKLOG.md only. Do not expand scope beyond what Review identified.
    CRITICAL: Use AskUserQuestion for scope confirmation, not plain text.
  "
)
```

Present iteration scope to user:
```
AskUserQuestion({
  questions: [{
    question: "Iteration #{iteration} plan ready. {N} backlog items. Proceed?",
    header: "Iteration #{iteration} Planning",
    multiSelect: false,
    options: [
      { label: "Approve iteration scope", description: "Fix the {N} items from review" },
      { label: "Reduce scope", description: "Fix critical items only, defer the rest" },
      { label: "Add items", description: "Found more things to fix" },
      { label: "Cancel iteration", description: "Actually, release as-is" }
    ]
  }]
})
```

If "Cancel iteration" → update STATE.md to `reviewed`, exit sprint, suggest `/cks:release`.

```
  [3a] Iteration Planning     ✅ Iteration #{iteration} — {N} backlog items
```

---

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3a.completed" "{NN}-{name}" "Sprint: planning complete"`

### Sub-step [3a+]: Secrets Pre-Conditions

After planning completes, check for unresolved secrets and inject pre-conditions into PLAN.md:

```
Read ${SKILL_ROOT}/workflows/secrets/hook-plan.md
Execute its instructions.
```

This reads `{NN}-SECRETS.md`, identifies pending secrets, and prepends a "Pre-Conditions: Unresolved Secrets" section to PLAN.md mapping each secret to the tasks it blocks.

---

### Sub-step [3b]: Design & Architecture

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3b.started" "{NN}-{name}" "Sprint: design & architecture started"`

**Uses: prd-planner agent (technical design mode)**

Read the PLAN.md and produce a Technical Design Document. Determine complexity:

```
AskUserQuestion({
  questions: [{
    question: "What level of technical design does this sprint need?",
    header: "Design & Architecture",
    multiSelect: false,
    options: [
      { label: "Standard", description: "Data model + API design + test strategy (recommended for most features)" },
      { label: "Comprehensive", description: "Standard + data flow + architecture review + security + NFRs" },
      { label: "Full", description: "All 11 sections (for complex/critical features)" },
      { label: "Minimal", description: "Test strategy only (for simple bug fixes or tweaks)" }
    ]
  }]
})
```

Based on selection, produce the relevant TDD sections and write to `.prd/phases/{NN}-{name}/{NN}-TDD.md`.

```
  [3b] Design & Architecture  ✅ TDD: {level} ({N} sections)
```

---

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3b.completed" "{NN}-{name}" "Sprint: design & architecture complete"`

### Sub-step [3b+]: Secrets Gate

Before implementation, ensure all required secrets are resolved or explicitly deferred:

```
Read ${SKILL_ROOT}/workflows/secrets/hook-sprint.md
Execute its instructions.
```

This re-checks `.env.local` for newly added secrets, then presents a blocking `AskUserQuestion` for any remaining pending secrets with "go fetch" instructions. The user can also skip with mock values (deferred to release).

---

### Sub-step [3c]: Implementation

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3c.started" "{NN}-{name}" "Sprint: implementation started"`

**Uses: prd-executor agent (team lead) — internally dispatches workers when needed**

The executor is now a **team lead** that autonomously decides whether to implement solo or dispatch parallel workers. Pass it file paths, not content.

#### First Sprint — Full Implementation

```
Agent(
  subagent_type="prd-executor",
  prompt="
    Project root: {project_root}
    Phase: {phase_number} — {phase_name}

    Read these files (lazy — load only what you need per step):
    - .prd/phases/{NN}-{name}/{NN}-PLAN.md — your task list
    - .prd/phases/{NN}-{name}/{NN}-TDD.md — technical design
    - .prd/phases/{NN}-{name}/{NN}-DESIGN.md — UI specs (for frontend tasks)
    - .prd/phases/{NN}-{name}/design/component-specs.md — component specs
    - CLAUDE.md — project conventions
    - Domain context: {list .context/*.md filenames matching PLAN.md domains:}

    Implement all tasks from the plan.
    Write summary to: .prd/phases/{NN}-{name}/{NN}-SUMMARY.md

    You decide: solo (≤ 2 task groups) or team (3+ independent groups).
    Use model='sonnet' for workers if dispatching a team.
  "
)
```

```
  [3c] Implementation         ✅ {N} files changed {team ? "— team ("+N+" workers)" : ""}
```

#### Iteration Sprint — Targeted Fixes

```
Agent(
  subagent_type="prd-executor",
  prompt="
    Project root: {project_root}
    Phase: {phase_number} — {phase_name}
    ITERATION MODE: Iteration #{iteration}

    Read these files (lazy — load only what you need):
    - .prd/phases/{NN}-{name}/{NN}-PLAN-iter{iteration}.md — iteration tasks
    - .prd/phases/{NN}-{name}/{NN}-SUMMARY.md — previous implementation
    - .prd/phases/{NN}-{name}/{NN}-REVIEW.md — feedback context
    - .prd/phases/{NN}-{name}/{NN}-TDD.md — technical design
    - .prd/phases/{NN}-{name}/{NN}-DESIGN.md — design specs
    - CLAUDE.md — conventions

    Fix/improve ONLY what the iteration plan specifies.
    Write summary to: .prd/phases/{NN}-{name}/{NN}-SUMMARY-iter{iteration}.md
  "
)
```

```
  [3c] Implementation         ✅ Iteration #{iteration} — {N} files changed, {N} backlog items addressed
```

---

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3c.completed" "{NN}-{name}" "Sprint: implementation complete"`

### Sub-step [3c+]: De-Sloppify Pass

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3c+.started" "{NN}-{name}" "Sprint: de-sloppify started"`

**Cleanup before review — remove implementation artifacts without constraining generation.**

Load the de-sloppify workflow from `${CLAUDE_PLUGIN_ROOT}/skills/prd/workflows/de-sloppify.md`.

Run a focused cleanup agent on all files listed in `{NN}-SUMMARY.md`:

```
Agent(
  model="sonnet",
  prompt="
    You are a code cleanup specialist.
    Read: .prd/phases/{NN}-{name}/{NN}-SUMMARY.md — get the file list
    Then review each file and remove ONLY:
      1. Debug artifacts (console.log, print(), commented-out code, debug imports)
      2. Tests that test the framework/language, not the application
      3. Over-defensive null checks where the type system guarantees non-null
      4. Wrapper functions used exactly once that add no logic
      5. Unused imports and variables

    Do NOT: refactor working code, change public APIs, remove error handling
    at system boundaries, remove WHY comments, or add new code.
  "
)
```

```
  [3c+] De-Sloppify           ✅ removed {N} artifacts
```

---

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3c+.completed" "{NN}-{name}" "Sprint: de-sloppify complete"`

### Sub-step [3d]: Code Review

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3d.started" "{NN}-{name}" "Sprint: code review started"`

#### Guardrail Adherence Check (pre-review)

Before code review, run the guardrails audit on changed files:

```
Skill(skill="cks:review-rules", args="--quick")
```

This checks changed files against `.claude/rules/*.md` (security, testing, database, docs, language).

- If grade is **D or F** on any rule file: fix violations before proceeding to code review. Re-run [3c] for fixes, then re-run the adherence check.
- If grade is **A-C**: note findings in the review but proceed. Warnings are included in the code review report.

If no `.claude/rules/` exists, skip this check and proceed to code review.

#### Decision: Single reviewer vs. Parallel review agents

Read SUMMARY.md to count files changed:
- **≤ 15 files** → single code review tool
- **> 15 files or multi-layer (frontend + backend + DB)** → dispatch 3 parallel review agents

#### Single Review (default)

Invoke code review tools in order of preference:

```
1. Skill(skill="pr-review-toolkit:review-pr")
2. Skill(skill="code-review:code-review")
3. Skill(skill="coderabbit:review")
```

Use whichever is available. If NONE are available, fall back to self-review:
```
No external code review tool available. Performing self-review:
- Read all changed files (from git diff)
- Check for: security issues, error handling gaps, naming inconsistencies, dead code
- Report findings in the same format as external tools
Note: Self-review is less thorough. Consider installing a review tool for production use.
```

#### Parallel Review (> 15 files or multi-layer)

Dispatch 3 review agents in a SINGLE message (parallel):

```
Agent(model="sonnet", prompt="
  You are a correctness reviewer. Check files from {NN}-SUMMARY.md for logic errors,
  bugs, missing edge cases, and adherence to acceptance criteria.
  Read: .prd/phases/{NN}-{name}/{NN}-SUMMARY.md for file list
  Read: .prd/phases/{NN}-{name}/{NN}-PLAN.md for acceptance criteria
  Report: [BLOCKING] or [WARNING] with file:line references.
")

Agent(model="sonnet", prompt="
  You are a security reviewer. Check API routes, auth, and data handling files from
  {NN}-SUMMARY.md for OWASP Top 10, injection risks, auth bypass, secrets exposure.
  Read: .prd/phases/{NN}-{name}/{NN}-SUMMARY.md for file list
  Report: [BLOCKING] or [WARNING] with file:line references.
")

Agent(model="sonnet", prompt="
  You are a conventions reviewer. Check files from {NN}-SUMMARY.md for adherence to
  CLAUDE.md conventions and design spec match.
  Read: CLAUDE.md, .prd/phases/{NN}-{name}/{NN}-DESIGN.md
  Read: .prd/phases/{NN}-{name}/{NN}-SUMMARY.md for file list
  Report: [BLOCKING] or [WARNING] with file:line references.
")
```

After all 3 complete: deduplicate findings, classify blocking vs. warnings, present to user.

#### Handle Review Results

If blocking issues found:
```
AskUserQuestion({
  questions: [{
    question: "Code review found {N} blocking issues. How to proceed?",
    header: "Code Review Results",
    multiSelect: false,
    options: [
      { label: "Fix issues", description: "Address blocking issues before QA" },
      { label: "Defer non-critical", description: "Fix blockers only, defer warnings" },
      { label: "Override", description: "Proceed to QA despite review findings" }
    ]
  }]
})
```

If "Fix issues" → re-run [3c] implementation for fixes, then re-run [3d].

```
  [3d] Code Review            ✅ {status} {team ? "— team review (correctness + security + conventions)" : "(" + tool_used + ")"}
```

---

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3d.completed" "{NN}-{name}" "Sprint: code review complete"`

### Sub-step [3e]: QA Validation

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3e.started" "{NN}-{name}" "Sprint: QA validation started"`

**Uses: prd-verifier agent (team lead) — internally dispatches parallel test workers when needed**

The verifier autonomously decides solo vs. team based on test layers present. Pass file paths, not content.

```
Agent(
  subagent_type="prd-verifier",
  prompt="
    Project root: {project_root}
    Phase: {phase_number} — {phase_name}

    Read these files (lazy — load only what you need):
    - .prd/phases/{NN}-{name}/{NN}-PLAN.md — acceptance criteria
    - .prd/phases/{NN}-{name}/{NN}-SUMMARY.md — what was implemented
    - PRD document: docs/prds/PRD-{NNN}-{name}.md — broader criteria

    Run all test layers, verify all acceptance criteria.
    Write results to: .prd/phases/{NN}-{name}/{NN}-VERIFICATION.md

    If API feature: check for Newman collection at
    .prd/phases/{NN}-{name}/testing/newman/api-contract.postman_collection.json
    If found, include API contract tests as a verification track (npx newman run).

    You decide: solo (1 test type) or team (2+ test types in parallel).
    Use model='sonnet' for test workers if dispatching a team.
  "
)
```

#### Handle QA Results

Process results:
- **All pass** → proceed to [3f]
- **Some fail** →
```
AskUserQuestion({
  questions: [{
    question: "QA found {N} failures. How to proceed?",
    header: "QA Validation Results",
    multiSelect: false,
    options: [
      { label: "Fix and re-test", description: "Go back to implementation, fix failures" },
      { label: "Accept partial", description: "Proceed with known failures documented" },
      { label: "Re-scope", description: "Remove failing criteria from this sprint" }
    ]
  }]
})
```

If "Fix and re-test" → re-run [3c] for fixes, then re-run [3e].

```
  [3e] QA Validation          ✅ {X}/{Y} criteria passed {team ? "— parallel QA team" : ""}
```

---

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3e.completed" "{NN}-{name}" "Sprint: QA validation complete"`

### Sub-step [3f]: UAT (User Acceptance Testing)

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3f.started" "{NN}-{name}" "Sprint: UAT started"`

Use browser testing if frontend feature. First check if the browse skill is available:

```
IF browse skill exists (.claude/skills/browse/ or commands/browse.md):
  Skill(skill="browse", args="Navigate to {app_url}. Execute UAT scenarios from discovery:
  - {UAT scenario 1}
  - {UAT scenario 2}
  Take screenshots. Report PASS/FAIL per scenario.")
ELSE:
  Skip automated browser testing. Present manual UAT checklist:
  "Browser automation not available. Please manually verify these scenarios:
   - {UAT scenario 1}
   - {UAT scenario 2}
  Then confirm results below."
```

Present results:
```
AskUserQuestion({
  questions: [{
    question: "UAT results: {N}/{M} scenarios passed. Approve?",
    header: "User Acceptance Testing",
    multiSelect: false,
    options: [
      { label: "Approve — proceed to merge", description: "Feature delivers expected value" },
      { label: "Reject — fix issues", description: "Go back to implementation" },
      { label: "Reject — design issues", description: "Go back to Phase 2 (Design)" },
      { label: "Partial approve", description: "Accept with documented limitations" }
    ]
  }]
})
```

If "Reject — fix issues" → back to [3c].
If "Reject — design issues" → exit Sprint, route to Phase 2 (update STATE.md accordingly).

```
  [3f] UAT                    ✅ {N}/{M} scenarios passed — stakeholder approved
```

---

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3f.completed" "{NN}-{name}" "Sprint: UAT complete"`

### Sub-step [3g]: Merge to Main

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3g.started" "{NN}-{name}" "Sprint: merge to main started"`

The sprint produces a **potentially shippable increment**.

#### First Sprint — Standard Commit

1. Stage and commit changes:
```bash
git add -A
git commit -m "$(cat <<'EOF'
feat(phase-{NN}): {phase name}

Phase {NN} of PRD-{NNN}: {feature name}
- {key change 1}
- {key change 2}

Acceptance: {X}/{Y} criteria verified
QA: unit ✓ integration ✓ E2E ✓
UAT: {N}/{M} scenarios passed

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```

2. Create PR (but do NOT deploy — that's Phase 5):
```bash
gh pr create --title "PRD-{NNN}: {Feature Title}" --body "$(cat <<'EOF'
## Summary
{from SUMMARY.md}

## Verification
- [x] QA: {X}/{Y} acceptance criteria passed
- [x] UAT: {N}/{M} scenarios passed
- [x] Code review: {status}

## Design Reference
Screens: .prd/phases/{NN}-{name}/design/screens/

---
*Sprint complete — awaiting Phase 4 (Review) before release*
EOF
)"
```

#### Iteration Sprint — Iteration Commit

1. Stage and commit changes:
```bash
git add -A
git commit -m "$(cat <<'EOF'
fix(phase-{NN}): {phase name} — Iteration #{iteration}

Phase {NN} of PRD-{NNN}: {feature name} — Iteration #{iteration}
Reason: {iteration_reason from STATE.md}
- {backlog item 1 addressed}
- {backlog item 2 addressed}

Backlog: {N}/{M} items resolved
QA: unit ✓ integration ✓ E2E ✓

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```

2. Create PR:
```bash
gh pr create --title "PRD-{NNN}: {Feature Title} — Iteration #{iteration}" --body "$(cat <<'EOF'
## Summary — Iteration #{iteration}
{from SUMMARY-iter{iteration}.md}

**Iteration reason:** {iteration_reason}

## Backlog Items Addressed
{from PLAN-iter{iteration}.md — checklist of items}

## Verification
- [x] QA: {X}/{Y} acceptance criteria passed
- [x] Backlog: {N}/{M} items resolved
- [x] Code review: {status}

## Iteration History
| # | Reason | Items | Status |
|---|--------|-------|--------|
{for each iteration: number, reason, item count, resolved/partial}

---
*Iteration #{iteration} complete — awaiting Phase 4 (Review)*
EOF
)"
```

```
  [3g] Merge to Main          ✅ PR #{number} — {url} {iteration ? "(Iteration #"+iteration+")" : ""}
```

---

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3g.completed" "{NN}-{name}" "Sprint: merge to main complete"`

### Sub-step [3h]: Documentation Check

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3h.started" "{NN}-{name}" "Sprint: documentation check started"`

**Auto-detect if documentation needs updating.**

Check if the sprint touched API routes or architecture-affecting files:

```bash
# Check for API route changes in the files listed in SUMMARY.md
git diff --name-only HEAD~1 | grep -E "(api/|routes/|endpoints/|controllers/)" || true
```

If API routes were added or changed:
```
━━━ Doc Check ━━━
New or modified API endpoints detected.
Suggesting documentation update...
━━━━━━━━━━━━━━━━━
```

Run a quick doc refresh scoped to changed files:
```
Agent(subagent_type="doc-generator", prompt={
  scope: "api",
  diff_only: true,
  project_root: {project_root}
})
```

If no API changes detected, check for architecture-level changes (new directories, new service layers, major refactors):
```bash
git diff --name-only HEAD~1 | grep -E "(src/lib/|src/services/|src/infrastructure/)" || true
```

If architecture changes found → suggest `/cks:docs arch` but don't auto-run.

If no documentation-relevant changes → skip silently.

```
  [3h] Documentation Check     ✅ {api docs updated | no doc changes needed}
```

---

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3h.completed" "{NN}-{name}" "Sprint: documentation check complete"`

### Step 3: Update State

**Update PRD-STATE.md:**

First Sprint:
```yaml
active_phase: {NN}
phase_name: {name}
phase_status: sprinted
iteration_count: 0
last_action: "Sprint complete — merged via PR #{number}"
last_action_date: {today}
next_action: "Run /cks:review for sprint review and iteration decision"
pr_number: {number}
pr_url: {url}
```

Iteration Sprint:
```yaml
active_phase: {NN}
phase_name: {name}
phase_status: sprinted
iteration_count: {iteration}
last_action: "Iteration #{iteration} complete — merged via PR #{number}"
last_action_date: {today}
next_action: "Run /cks:review to evaluate iteration #{iteration}"
pr_number: {number}
pr_url: {url}
```

**Update PRD-ROADMAP.md:**
- Set phase status to "Sprinted — Pending Review"

### Step 4: Completion Banner

**First Sprint:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► Phase {NN}: {name} ► SPRINT COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 [3a] Sprint Planning        ✅ {N} tasks
 [3b] Design & Architecture  ✅ TDD: {level}
 [3c] Implementation         ✅ {N} files changed
 [3c+] De-Sloppify           ✅ cleaned
 [3d] Code Review            ✅ {status}
 [3e] QA Validation          ✅ {X}/{Y} criteria
 [3f] UAT                    ✅ {N}/{M} scenarios
 [3g] Merge to Main          ✅ PR #{number}
 [3h] Documentation Check    ✅ {status}

 Next: /cks:review {NN}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Iteration Sprint:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► Phase {NN}: {name} ► ITERATION #{iteration} COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Iteration reason: {iteration_reason}

 [3a] Iteration Planning     ✅ {N} backlog items scoped
 [3b] Design & Architecture  ✅ {updated | no changes needed}
 [3c] Implementation         ✅ {N} files changed, {N}/{M} backlog items resolved
 [3c+] De-Sloppify           ✅ cleaned
 [3d] Code Review            ✅ {status}
 [3e] QA Validation          ✅ {X}/{Y} criteria
 [3f] UAT                    ✅ {N}/{M} scenarios
 [3g] Merge to Main          ✅ PR #{number} (Iteration #{iteration})
 [3h] Documentation Check    ✅ {status}

 Iteration History:
   Sprint (initial)     ✅ → Review → Iterate
   {for each past iteration:}
   Iteration #{N}       ✅ → Review → {Iterate | current}

 Next: /cks:review {NN}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "phase.sprint.completed" "{NN}-{name}" "Sprint phase completed"`

### Step 5: Context Reset & Compaction

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Sprint artifacts saved to disk. Run /compact before review
to free context — all state is persisted:

  ✅ PRD-STATE.md    — phase tracking
  ✅ PLAN.md         — sprint plan
  ✅ SUMMARY.md      — implementation record
  ✅ VERIFICATION.md — test results
  ✅ Working Notes   — session context (auto-captured)

  /compact
  /cks:next

Nothing is lost.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Do NOT chain to the next workflow via Skill().** Stop here.

## Post-Conditions
- `docs/prds/PRD-{NNN}-{name}.md` exists
- `.prd/phases/{NN}-{name}/{NN}-PLAN.md` exists
- `.prd/phases/{NN}-{name}/{NN}-TDD.md` exists
- `.prd/phases/{NN}-{name}/{NN}-SUMMARY.md` exists
- `.prd/phases/{NN}-{name}/{NN}-VERIFICATION.md` exists
- Code committed and PR created
- PRD-STATE.md and PRD-ROADMAP.md updated
- API docs updated if endpoints changed (auto via [3h])
