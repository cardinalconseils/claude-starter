---
name: prd
description: >
  Product Requirement Document creation and feature lifecycle management — from interactive
  discovery through planning, execution, verification, and shipping with a living roadmap.
  Use this skill whenever: creating a new feature, starting a new piece of work, building a PRD,
  planning implementation, discussing requirements, updating the project roadmap, checking project
  progress, or when the user says "new feature", "add feature", "I want to build", "let's plan",
  "create a PRD", "what's the roadmap", "what's next", "update progress", "discuss this feature",
  or any variation of feature planning and tracking. Also trigger when the user references existing
  PRDs, wants to modify scope, reprioritize work, or asks about project status.
---

# PRD — Product Requirement Document & Feature Lifecycle

This skill manages the full feature lifecycle: **Discuss → Plan → Execute → Verify → Ship**, with a living roadmap and state tracking that persists across sessions.

## Key Design: Uninterrupted Flow

`/prd:new` runs the **entire lifecycle** without stopping:
```
initialize → discuss → plan → execute → verify → commit → push → PR → review → deploy
```

No confirmation prompts. No "what do you want to do next?" pauses. The flow runs to completion. State is persisted after every step so `/prd:next` can resume if interrupted.

## Architecture

```
Commands (entry points)          Workflows (logic)              Agents (specialists)
─────────────────────           ─────────────────              ──────────────────────
/prd:new ──────────────→ new-project + autonomous ──→ prd-orchestrator (all agents)
/prd:discuss ──────────→ discuss-phase.md ──────────→ prd-discoverer
/prd:plan ─────────────→ plan-phase.md ────────────→ prd-planner
/prd:execute ──────────→ execute-phase.md ──────────→ prd-executor
/prd:verify ───────────→ verify-phase.md ───────────→ prd-verifier
/prd:ship ─────────────→ ship.md ───────────────────→ (commit → PR → deploy)
/prd:progress ─────────→ progress.md ───────────────→ (read-only)
/prd:next ─────────────→ next.md ───────────────────→ (auto-chains via Skill())
/prd:autonomous ───────→ autonomous.md ─────────────→ (loops all + ships)
/prd:evaluate ─────────→ process-evaluator.md ───────→ (creates PRD + runs cycle)
/prd:status ───────────→ (inline) ──────────────────→ (read-only)
/prd:help ─────────────→ (inline) ──────────────────→ (display only)
```

## Commands

| Command | Description |
|---------|-------------|
| `/prd:new [brief]` | Initialize + run full autonomous cycle (no interruption) |
| `/prd:discuss [phase]` | Interactive discovery session |
| `/prd:plan [phase]` | Write PRD + execution plan |
| `/prd:execute [phase]` | Implement the next planned phase |
| `/prd:verify [phase]` | Verify acceptance criteria |
| `/prd:ship [phase\|all]` | Commit → push → PR → review → deploy |
| `/prd:progress` | Show progress + suggest next action |
| `/prd:next` | Auto-advance to next step (chains via Skill()) |
| `/prd:autonomous` | Run all remaining phases + ship (no interruption) |
| `/prd:evaluate [phase]` | Build the Process Evaluator feature (complete process cards) |
| `/prd:status` | Quick roadmap overview |
| `/prd:help` | Show available commands |

## Agent Team

| Agent | File | Role |
|-------|------|------|
| **prd-orchestrator** | `.claude/agents/prd-orchestrator.md` | Drives full lifecycle — dispatches all other agents |
| **prd-discoverer** | `.claude/agents/prd-discoverer.md` | Interactive requirements gathering + codebase research |
| **prd-planner** | `.claude/agents/prd-planner.md` | Writes PRD + execution plan + roadmap updates |
| **prd-executor** | `.claude/agents/prd-executor.md` | Implements code + writes summary |
| **prd-verifier** | `.claude/agents/prd-verifier.md` | Checks acceptance criteria + code quality |
| **prd-researcher** | `.claude/agents/prd-researcher.md` | Investigates codebase + technology options |

## Lifecycle Flow

```
/prd:new (or /prd:autonomous)
    │
    ├── FOR EACH PHASE:
    │   │
    │   ├── Discuss ──→ CONTEXT.md      (prd-discoverer, autonomous mode)
    │   ├── Plan ─────→ PLAN.md + PRD   (prd-planner)
    │   ├── Execute ──→ SUMMARY.md      (prd-executor)
    │   ├── Verify ───→ VERIFICATION.md (prd-verifier)
    │   │     │
    │   │     ├── PASS → commit phase, advance
    │   │     └── FAIL → retry once, then continue
    │   │
    │   └── git commit (atomic per phase)
    │
    └── SHIP:
        ├── Create feature branch
        ├── Push to remote
        ├── Create PR (auto-generated body)
        ├── Run code review
        ├── Deploy (if configured)
        └── Update roadmap + state
```

## Auto-Chaining Mechanism

Commands chain automatically via `Skill()` invocations (same pattern as GSD):

- `/prd:next` reads STATE.md, determines the next step, and immediately invokes it via `Skill(skill="prd:{command}")`. No user confirmation.
- `/prd:autonomous` loops through all phases, invoking each sub-workflow in sequence.
- `/prd:new` initializes then falls into the autonomous loop.

This means: **invoke once, the flow runs to completion.**

## CD Integration

After shipping, use the ralph-loop plugin for continuous deployment monitoring:
```
/ralph-loop:ralph-loop "monitor PR #{number} — deploy when merged"
```

This creates a polling loop that watches the PR and triggers deployment on merge.

## File System

```
.prd/                               # Planning state
├── PRD-PROJECT.md                  # Project context
├── PRD-REQUIREMENTS.md             # Tracked requirements with REQ-IDs
├── PRD-STATE.md                    # Session continuity + progress
├── PRD-ROADMAP.md                  # Phase structure + status
└── phases/
    ├── 01-feature-name/
    │   ├── CONTEXT.md              # Discovery output
    │   ├── PLAN.md                 # Execution plan
    │   ├── SUMMARY.md             # Post-execution summary
    │   └── VERIFICATION.md        # Verification results
    └── 02-feature-name/
        └── ...

docs/                               # Public artifacts
├── ROADMAP.md                      # Living roadmap
└── prds/
    └── PRD-001-feature.md          # Individual PRD documents
```

## State Machine

STATE.md tracks position. Valid transitions:

```
not_started → discussing → discussed → planned → executing →
executed → verifying → verified → shipped → (next phase or complete)
                          ↑
verification_failed ──────┘ (re-execute, max 1 retry)
```

## Agent Dispatch Pattern

When dispatching agents, provide:
1. Phase artifacts (CONTEXT.md, PLAN.md, etc.)
2. Project root path
3. Project context (PROJECT.md, CLAUDE.md)
4. Current STATE.md

Agents hand off in sequence:
- **Discoverer** → CONTEXT.md → **Planner**
- **Planner** → PLAN.md + PRD → **Executor**
- **Executor** → SUMMARY.md → **Verifier**
- **Verifier** → VERIFICATION.md → **Ship** (or next phase)

## Session Start Behavior

When this skill is triggered at session start:
1. Check if `.prd/PRD-STATE.md` exists
2. If yes → read it, show current position, suggest `/prd:next`
3. If no `.prd/` → suggest `/prd:new`

## Reference Files

| File | When to Read |
|------|-------------|
| `templates/*.md` | When initializing planning documents |
| `references/roadmap-format.md` | When updating roadmap structure |
| `references/verification-patterns.md` | When verifier checks criteria |

## Rules

- **No interruptions in autonomous mode.** Discoverer uses autonomous mode (no questions).
- **Commit after each phase.** Atomic history, recoverable on interruption.
- **Max 1 retry on failure.** Prevents infinite loops.
- **State after every step.** STATE.md updated constantly. `/prd:next` can always resume.
- **Agents stay in their lane.** Discoverer doesn't write PRDs. Planner doesn't code. Executor doesn't redesign. Verifier doesn't fix.
