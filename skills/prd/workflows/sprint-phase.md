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

### Step 0b: Progress Banner

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
     [3d] Code Review            ○ pending
     [3e] QA Validation          ○ pending
     [3f] UAT                    ○ pending
     [3g] Merge to Main          ○ pending
 [4] Review      ○ pending
 [5] Release     ○ pending

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 1: Determine Target Phase

Read `.prd/PRD-STATE.md` to find the active phase, or use the phase number argument.

Verify that DESIGN.md exists:
```
Read .prd/phases/{NN}-{name}/{NN}-DESIGN.md
```

If no DESIGN.md → tell the user: "No design found. Run `/cks:design {NN}` first."

If DESIGN.md exists but no CONTEXT.md → error: "No discovery found. Run `/cks:discover {NN}` first."

### Step 2: Check Sprint Resume

Check if sprint was previously started by looking for existing artifacts:
- `{NN}-PLAN.md` exists → resume from [3c] or later
- `{NN}-SUMMARY.md` exists → resume from [3d] or later
- `{NN}-VERIFICATION.md` exists → resume from [3f] or later

If resuming, skip completed sub-steps and update the progress banner accordingly.

---

### Sub-step [3a]: Sprint Planning

**Uses: prd-planner agent**

Dispatch the **prd-planner** agent:

```
Agent prompt:
- Project root: {project_root}
- Phase: {phase_number} — {phase_name}
- Discovery context: {CONTEXT.md content}
- Design specs: {DESIGN.md content + component-specs.md}
- Project context: {PROJECT.md content}
- Existing requirements: {REQUIREMENTS.md content}
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

---

### Sub-step [3b]: Design & Architecture

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

### Sub-step [3c]: Implementation

**Uses: prd-executor agent**

Load execution context:
- `{NN}-PLAN.md` — tasks
- `{NN}-TDD.md` — technical design
- `{NN}-DESIGN.md` — UI specs
- `{NN}-CONTEXT.md` — requirements
- `.context/*.md` — domain knowledge (matching PLAN.md domains: tags)

Dispatch the **prd-executor** agent:

```
Agent prompt:
- Project root: {project_root}
- Phase: {phase_number} — {phase_name}
- Plan: {PLAN.md content}
- Technical Design: {TDD.md content}
- Design Specs: {DESIGN.md + component-specs.md content}
- Context: {CONTEXT.md content}
- Conventions: {CLAUDE.md content}
- Domain context: {.context/*.md briefs matching this phase's domains}

Implement all tasks from the plan. Follow:
1. Technical design document for architecture decisions
2. Design specs for UI implementation — match approved screens
3. Test strategy for test placement and coverage
4. Project conventions from CLAUDE.md

Write summary to: .prd/phases/{NN}-{name}/{NN}-SUMMARY.md
```

```
  [3c] Implementation         ✅ {N} files changed
```

---

### Sub-step [3d]: Code Review

Invoke code review tools in order of preference:

```
1. Skill(skill="pr-review-toolkit:review-pr")
3. Skill(skill="code-review:code-review")
4. Skill(skill="coderabbit:review")
```

Use whichever is available. If blocking issues found:
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
  [3d] Code Review            ✅ {status} ({tool_used})
```

---

### Sub-step [3e]: QA Validation

**Uses: prd-verifier agent**

Dispatch the **prd-verifier** agent:

```
Agent prompt:
- Project root: {project_root}
- Phase: {phase_number} — {phase_name}
- Plan: {PLAN.md content — for acceptance criteria}
- Summary: {SUMMARY.md content — for what was implemented}
- Test Plan: {from CONTEXT.md — unit, integration, E2E test cases}
- PRD acceptance criteria: {from PRD document}

Your job:
1. Run ALL unit tests — report pass/fail
2. Run ALL integration tests — report pass/fail
3. Run ALL end-to-end tests — report pass/fail
4. Verify each acceptance criterion
5. Verify constraints and negative cases
6. Write results to .prd/phases/{NN}-{name}/{NN}-VERIFICATION.md
```

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
  [3e] QA Validation          ✅ {X}/{Y} criteria passed
```

---

### Sub-step [3f]: UAT (User Acceptance Testing)

Use browser testing if frontend feature:

```
Skill(skill="browse", args="Navigate to {app_url}. Execute UAT scenarios from discovery:
- {UAT scenario 1}
- {UAT scenario 2}
Take screenshots. Report PASS/FAIL per scenario.")
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

### Sub-step [3g]: Merge to Main

The sprint produces a **potentially shippable increment**.

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

```
  [3g] Merge to Main          ✅ PR #{number} — {url}
```

---

### Step 3: Update State

**Update PRD-STATE.md:**
```yaml
active_phase: {NN}
phase_name: {name}
phase_status: sprinted
last_action: "Sprint complete — merged via PR #{number}"
last_action_date: {today}
next_action: "Run /cks:review for sprint review and iteration decision"
pr_number: {number}
pr_url: {url}
```

**Update PRD-ROADMAP.md:**
- Set phase status to "Sprinted — Pending Review"

### Step 4: Completion Banner

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► Phase {NN}: {name} ► SPRINT COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 [3a] Sprint Planning        ✅ {N} tasks
 [3b] Design & Architecture  ✅ TDD: {level}
 [3c] Implementation         ✅ {N} files changed
 [3d] Code Review            ✅ {status}
 [3e] QA Validation          ✅ {X}/{Y} criteria
 [3f] UAT                    ✅ {N}/{M} scenarios
 [3g] Merge to Main          ✅ PR #{number}

 Next: /cks:review {NN}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 5: Context Reset

```
━━━ Context Reset ━━━
Sprint artifacts saved. Clear context and continue:

  /clear
  /cks:next

State is on disk — nothing is lost.
━━━━━━━━━━━━━━━━━━━━━
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
