# Workflow: Autonomous Execution (5-Phase)

<purpose>
Drive all remaining phases autonomously through the 5-phase lifecycle. For each incomplete feature: discover → design → sprint → review → release. The iteration loop in Phase 4 auto-decides based on verification results.

Uses explicit Agent() dispatches for phase work and Skill() invocations for cross-cutting concerns.
</purpose>

## Pre-Conditions
- `.prd/` exists with PRD-ROADMAP.md and PRD-STATE.md
- At least one phase defined

## Process

### Step 0: Auto Mode Check

```
┌─────────────────────────────────────────────────┐
│ ⚡ TIP: Enable Auto mode for uninterrupted flow │
│                                                 │
│ Autonomous mode runs best with Claude Code's    │
│ Auto mode enabled — it auto-approves safe       │
│ actions (file edits, builds, git).              │
│                                                 │
│ To enable: press Shift+Tab to cycle to "auto"   │
│ or restart with: claude --auto                  │
└─────────────────────────────────────────────────┘
```

### Step 1: Initialize

Read project state:
```
Read .prd/PRD-STATE.md
Read .prd/PRD-ROADMAP.md
Read .prd/PRD-PROJECT.md
Read CLAUDE.md
```

Parse `$ARGUMENTS` for flags: `--from N`, `--skip-design`, `--skip-review`.

Display startup banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► AUTONOMOUS (5-Phase)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Project: {name}
 Phases: {total} total, {complete} complete
 Mode: Full autonomous
   discover → design → sprint → review → release
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 2: Discover Incomplete Phases

Scan `.prd/phases/` filesystem to derive status. Filter to incomplete phases. Apply `--from N` if provided.

### Step 3: Execute Each Phase Through 5-Phase Cycle

For each incomplete phase:

**3a. Progress Banner:**
```
━━━ Phase {NN}/{total}: {name} [████░░░░] {%}% ━━━
```

**3b. Phase 1: Discover (if no {NN}-CONTEXT.md):**

```
Agent(
  subagent_type="cks:prd-discoverer",
  prompt="
    AUTONOMOUS MODE: Do NOT ask questions. Infer all 11 discovery elements.
    Project root: {project_root}
    Phase: {NN} — {name}

    Read these files (lazy — do not embed contents):
    - .prd/PRD-PROJECT.md
    - .prd/PRD-ROADMAP.md
    - CLAUDE.md

    Flag all assumptions. Generate 3+ user stories, 3+ acceptance criteria per story,
    unit + integration + E2E test scenarios, 2+ UAT scenarios. Smaller scope preferred.
    Write to: .prd/phases/{NN}-{name}/{NN}-CONTEXT.md
  "
)
```
```

After CONTEXT.md is written, invoke secrets discovery:
```
Read ${SKILL_ROOT}/workflows/secrets/hook-discover.md
```
Execute its instructions to produce `.prd/phases/{NN}-{name}/{NN}-SECRETS.md`.

```
Phase {NN}: Discover ✅
```

**3c. Phase 2: Design (if no {NN}-DESIGN.md):**

Skip if `--skip-design` flag.

```
Agent(
  subagent_type="cks:prd-designer",
  prompt="
    AUTONOMOUS MODE: Generate screens without asking. Auto-approve.
    Project root: {project_root}
    Phase: {NN} — {name}

    Read: .prd/phases/{NN}-{name}/{NN}-CONTEXT.md for user stories and acceptance criteria.
    Create UX flows, generate screens (Stitch MCP if available), generate diagrams
    (user flow, state, sequence), extract component specs.
    Write to: .prd/phases/{NN}-{name}/{NN}-DESIGN.md
  "
)
```
```
Phase {NN}: Design ✅
```

**3d. Phase 3: Sprint (if no {NN}-SUMMARY.md or no {NN}-VERIFICATION.md):**

**[3a] Sprint Planning + Technical Design:**
```
Agent(
  subagent_type="cks:prd-planner",
  prompt="
    AUTONOMOUS MODE: Do NOT ask questions. Make decisions based on context. Auto-approve.
    Project root: {project_root}
    Phase: {NN} — {name}

    Read these files (lazy):
    - .prd/phases/{NN}-{name}/{NN}-CONTEXT.md
    - .prd/phases/{NN}-{name}/{NN}-DESIGN.md
    - .prd/PRD-PROJECT.md
    - .prd/PRD-REQUIREMENTS.md

    Produce PRD, PLAN.md, and TDD.md for this phase.
    If API feature: also generate Newman collection at
    .prd/phases/{NN}-{name}/testing/newman/api-contract.postman_collection.json
  "
)
```

**[3a+] Secrets Pre-Conditions:**
```
Read ${SKILL_ROOT}/workflows/secrets/hook-plan.md
```
Execute its instructions — inject unresolved secrets into PLAN.md.

**[3b+] Secrets Gate:**
```
Read ${SKILL_ROOT}/workflows/secrets/hook-sprint.md
```
Execute its instructions — verify secrets are available before implementation.

**[3c] Implementation** — executor handles team logic internally:
```
Agent(
  subagent_type="cks:prd-executor",
  prompt="
    AUTONOMOUS MODE: Do NOT ask questions. Implement all tasks without user interaction.
    Project root: {project_root}
    Phase: {NN} — {name}

    Read these files (lazy):
    - .prd/phases/{NN}-{name}/{NN}-PLAN.md
    - .prd/phases/{NN}-{name}/{NN}-TDD.md
    - .prd/phases/{NN}-{name}/{NN}-DESIGN.md
    - CLAUDE.md

    Implement all tasks. You decide: solo or team with workers.
    Write summary to: .prd/phases/{NN}-{name}/{NN}-SUMMARY.md
  "
)
```

**[3c+] De-Sloppify** — cleanup pass:
```
Read ${SKILL_ROOT}/workflows/sprint-phase/step-3c-desloppify.md
```
Execute its instructions — remove debug artifacts, dead code, console.log.

**[3d] Code Review:**
```
Read ${SKILL_ROOT}/workflows/sprint-phase/step-3d-review.md
```
Execute its instructions — guardrail adherence + peer review.

**[3e] QA Validation** — verifier handles team logic internally:
```
Agent(
  subagent_type="cks:prd-verifier",
  prompt="
    Project root: {project_root}
    Phase: {NN} — {name}

    Read these files (lazy):
    - .prd/phases/{NN}-{name}/{NN}-PLAN.md
    - .prd/phases/{NN}-{name}/{NN}-SUMMARY.md

    Run all tests. Verify acceptance criteria.
    If Newman collection exists at testing/newman/, run API contract tests.
    Write to: .prd/phases/{NN}-{name}/{NN}-VERIFICATION.md
  "
)
```

If verification FAIL (first attempt) → re-execute + re-verify once.
If verification FAIL (second attempt) → log and continue.

**[3g] Commit:**
```bash
git add -A
git commit -m "feat(phase-{NN}): {phase name}

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
```

**[3h] Documentation Check:**
```
Read ${SKILL_ROOT}/workflows/sprint-phase/step-3h-docs.md
```
Execute its instructions — auto-detect and update API/architecture docs if needed.

```
Phase {NN}: Sprint ✅ (plan ✓ implement ✓ review ✓ QA ✓)
```

**3e. Phase 4: Review (auto-decision):**

Skip if `--skip-review` flag.

In autonomous mode, the iteration decision is automatic:
- If ALL acceptance criteria passed → decision = "Release"
- If any criteria failed → decision = "Iterate: Sprint" (one iteration)
- After one iteration → force "Release" regardless

```
Phase {NN}: Review ✅ → {decision}
```

If iterating → loop back to 3d (Sprint) once, then proceed.

**3f. Phase 5: Release:**

Invoke the full release workflow:
```
Skill(skill="cks:release")
```

This runs Dev → Staging → RC → Production with quality gates.

In autonomous mode, quality gates auto-pass if tests pass. Manual gates use AskUserQuestion.

```
Phase {NN}: Release ✅
```

### Step 4: Phase Transition

Re-read PRD-ROADMAP.md. Re-scan `.prd/phases/` filesystem.

```
Phase {NN} ✅ — {X}/{total} complete
```

If more incomplete phases → loop back to Step 3.
If all complete → proceed to Final Report.

### Step 5: Final Report

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Feature: PRD-{NNN} — {name}
 Phases: {total}/{total} ✅
 PR: #{number} ({url})
 Production: {url}

 Results:
   Phase 01: {name} — ✅
   Phase 02: {name} — ✅

 discover ✅ → design ✅ → sprint ✅ → review ✅ → release ✅
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Context Management

- State persisted after every step — safe to `/clear` and resume with `/cks:autonomous`
- Agent dispatches are context-isolated
- Between phases, re-read state from disk

## Guardrails

1. **No interactive questions in discover/design** — infer from codebase
2. **No confirmation prompts** — execute immediately
3. **Max 1 iteration loop** — prevents infinite cycles
4. **Commit after each phase** — atomic, recoverable history
5. **State persistence** — PRD-STATE.md updated after every step
6. **Filesystem is truth** — re-scan between phases
7. **Skip on error** — log and continue after retry
8. **Build after implement** — always run dependency sync + build
9. **Quality gates in release** — these are NOT skipped even in autonomous mode
