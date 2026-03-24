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

`/cks:new` runs the **entire lifecycle** without stopping:
```
initialize → discuss → plan → execute → verify → commit → push → PR → review → deploy
```

No confirmation prompts. No "what do you want to do next?" pauses. The flow runs to completion. State is persisted after every step so `/cks:next` can resume if interrupted.

## Architecture

```
Commands (entry points)          Workflows (logic)              Agents (specialists)
─────────────────────           ─────────────────              ──────────────────────
/cks:new ──────────────→ new-project + autonomous ──→ prd-orchestrator (all agents)
/cks:discuss ──────────→ discuss-phase.md ──────────→ prd-discoverer
/cks:plan ─────────────→ plan-phase.md ────────────→ prd-planner
/cks:execute ──────────→ execute-phase.md ──────────→ prd-executor
/cks:verify ───────────→ verify-phase.md ───────────→ prd-verifier
/cks:ship ─────────────→ ship.md ───────────────────→ (doctor → commit → PR → changelog → deploy)
/cks:progress ─────────→ progress.md ───────────────→ (read-only)
/cks:next ─────────────→ next.md ───────────────────→ (auto-chains via Skill())
/cks:autonomous ───────→ autonomous.md ─────────────→ (loops all + ships)
/cks:evaluate ─────────→ process-evaluator.md ───────→ (creates PRD + runs cycle)
/cks:status ───────────→ (inline) ──────────────────→ (read-only)
/cks:help ─────────────→ (inline) ──────────────────→ (display only)

Quick commands (PRD-aware daily actions):
/cks:go ───────────────→ go.md ────────────────────→ build → commit → push → PR
/cks:go commit|pr|dev|build → sub-actions (all read PRD state, hint next step)

Utility commands (integrated into lifecycle):
/cks:context ──────────→ context-research/SKILL.md ──→ (auto-runs in discuss phase)
/cks:doctor ───────────→ (inline diagnostics) ───────→ (auto-runs pre-ship)
/cks:changelog ────────→ (inline git analysis) ──────→ (auto-runs post-ship PR)

Hooks (automatic):
SessionStart ──────────→ Show PRD status if .prd/ exists
Stop ──────────────────→ Warn about uncommitted changes
```

## Commands

| Command | Description |
|---------|-------------|
| `/cks:new [brief]` | Initialize + run full autonomous cycle (no interruption) |
| `/cks:discuss [phase]` | Interactive discovery session |
| `/cks:plan [phase]` | Write PRD + execution plan |
| `/cks:execute [phase]` | Implement the next planned phase |
| `/cks:verify [phase]` | Verify acceptance criteria |
| `/cks:ship [phase\|all]` | Commit → push → PR → review → deploy |
| `/cks:progress` | Show progress + suggest next action |
| `/cks:next` | Auto-advance to next step (chains via Skill()) |
| `/cks:autonomous` | Run all remaining phases + ship (no interruption) |
| `/cks:evaluate [phase]` | Build the Process Evaluator feature (complete process cards) |
| `/cks:status` | Quick roadmap overview |
| `/cks:help` | Show available commands |
| `/cks:context [topic]` | Research a topic/library/API → save to `.context/` (auto-runs in discuss) |
| `/cks:doctor` | Project health diagnostic — env vars, TODOs, tests, git (auto-runs pre-ship) |
| `/cks:changelog [--since]` | Generate CHANGELOG.md from git history (auto-runs post-ship) |
| `/cks:research [topic]` | Deep multi-hop research → `.research/` (strategic intelligence) |
| `/cks:retro [--auto]` | Retrospective — extract learnings, propose conventions (auto-runs post-ship) |

## Agent Team

| Agent | File | Role |
|-------|------|------|
| **prd-orchestrator** | `.claude/agents/prd-orchestrator.md` | Drives full lifecycle — dispatches all other agents |
| **prd-discoverer** | `.claude/agents/prd-discoverer.md` | Interactive requirements gathering + codebase research |
| **prd-planner** | `.claude/agents/prd-planner.md` | Writes PRD + execution plan + roadmap updates |
| **prd-executor** | `.claude/agents/prd-executor.md` | Implements code + writes summary |
| **prd-verifier** | `.claude/agents/prd-verifier.md` | Checks acceptance criteria + code quality |
| **prd-researcher** | `.claude/agents/prd-researcher.md` | Investigates codebase + technology options |

## Progress Tracker

**CRITICAL:** Every phase displays a progress banner before starting AND a completion banner after. The user must always know where they are, what completed, and what's next.

### Phase Progress Banner

Display this at the **start** of every phase workflow:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► Phase {NN}: {name} ► {PHASE_NAME}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 [1] Discuss     {✅ done | ▶ current | ○ pending}
 [2] Plan        {✅ done | ▶ current | ○ pending}
 [3] Execute     {✅ done | ▶ current | ○ pending}
 [4] Verify      {✅ done | ▶ current | ○ pending | ✗ failed}
 [5] Ship        {✅ done | ▶ current | ○ pending}
 [6] Retro       {✅ done | ▶ current | ○ pending}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Derive status from the filesystem — check which artifact files exist:
- Discuss done: `{NN}-CONTEXT.md` exists
- Plan done: `{NN}-PLAN.md` exists + `docs/prds/PRD-{NNN}.md` exists
- Execute done: `{NN}-SUMMARY.md` exists
- Verify done: `{NN}-VERIFICATION.md` exists with PASS verdict
- Verify failed: `{NN}-VERIFICATION.md` exists with FAIL verdict
- Ship done: PRD-STATE.md shows `shipped`
- Retro done: `.learnings/session-log.md` has entry for this phase

### Phase Completion Banner

Display after each phase completes:

```
  [{N}] {Phase}     ✅ done
        Output: {artifact path}
        {1-2 line summary of what was produced}
```

### Validation Before Advancing

Before marking a phase as done, validate that the required artifact:
1. **Exists** on disk
2. **Has required content** (key sections present)

| Phase | Artifact | Required Content |
|-------|----------|-----------------|
| Discuss | `{NN}-CONTEXT.md` | Has `## Functional Requirements` or `## User Stories` section |
| Plan | `{NN}-PLAN.md` | Has `## Tasks` or numbered implementation steps |
| Plan | `docs/prds/PRD-{NNN}.md` | Has `## Acceptance Criteria` section |
| Execute | `{NN}-SUMMARY.md` | Has `## Changes` or `## Files Modified` section |
| Verify | `{NN}-VERIFICATION.md` | Has `## Results` with PASS/FAIL verdict |
| Ship | PR created | PR URL captured in state |

**If validation fails:**
```
  [{N}] {Phase}     ✗ validation failed
        Expected: {artifact path}
        Missing: {what's missing}
        Retrying...
```

Retry the phase once. If it fails again, ask the user.

### Ship Sub-Steps

Ship is a multi-step phase. Track sub-steps within it:

```
 [5] Ship        ▶ current
     [5a] Doctor       {✅|▶|○}
     [5b] E2E Tests    {✅|▶|○|⊘ skipped}
     [5c] Commit       {✅|▶|○}
     [5d] Push + PR    {✅|▶|○}
     [5e] Review       {✅|▶|○|⊘ skipped}
     [5f] Deploy       {✅|▶|○|⊘ skipped}
     [5g] Changelog    {✅|▶|○}
     [5h] Retro        {✅|▶|○}
```

## Lifecycle Flow

```
Manual mode (/cks:next + /cks:go for daily actions):

  [SessionStart hook → auto-status if .prd/ exists]

  /cks:next → Discuss → context research → CONTEXT.md → Context Reset → /clear
  /cks:next → Plan ───→ PLAN.md ───→ Context Reset → /clear
  /cks:next → Execute → SUMMARY.md → Context Reset → /clear
    ├── /cks:go dev         ← dev server while coding
    ├── /cks:go commit      ← save checkpoints (updates PRD state)
    └── /cks:go pr          ← quick PR for review (hints: /cks:verify)
  /cks:next → Verify ─→ VERIFY.md ─→ Context Reset → /clear
  /cks:next → Ship ───→ doctor → PR → changelog → Deploy → Context Reset → /clear

  [Stop hook → uncommitted changes reminder]
  (repeat for next phase)

Autonomous mode (/cks:autonomous):

  FOR EACH PHASE (agents run in isolated context):
    ├── Context ──→ .context/*.md   (auto-research technologies)
    ├── Discuss ──→ CONTEXT.md      (prd-discoverer)
    ├── Plan ─────→ PLAN.md + PRD   (prd-planner)
    ├── Execute ──→ SUMMARY.md      (prd-executor)
    ├── Verify ───→ VERIFICATION.md (prd-verifier)
    │     ├── PASS → commit, advance
    │     └── FAIL → retry once, continue
    └── git commit (atomic per phase)

  SHIP:
    ├── Doctor → E2E → commit → push → PR → changelog → review → deploy → update CLAUDE.md
    └── Context Reset → /clear
```

## Context Reset Between Phases

Each phase workflow ends with a **Context Reset** banner instructing the user to `/clear` then `/cks:next`. This ensures every phase starts with a fresh context window — no dead tokens from previous phases.

```
Phase completes → state saved to .prd/ → Context Reset banner
  ↓
User: /clear
  ↓
User: /cks:next → reads state from disk → invokes next phase → ...
```

**Why this works:** All state lives on disk in `.prd/PRD-STATE.md`, `.prd/PRD-ROADMAP.md`, and phase artifact files. Nothing is lost on `/clear`. The next invocation of `/cks:next` re-reads everything from disk and picks up exactly where it left off.

**Manual commands also reset:** `/cks:discuss`, `/cks:plan`, `/cks:execute`, `/cks:verify`, and `/cks:ship` all end with the Context Reset banner. The user clears and continues.

**Autonomous mode exception:** `/cks:autonomous` runs continuously because it uses Agent() dispatches with isolated context. If interrupted, the user can `/clear` then re-run `/cks:autonomous` — it re-scans the filesystem and resumes.

## Auto-Advance Mechanism

`/cks:next` reads STATE.md, determines the next step, and invokes it via `Skill(skill="{command}")`. It runs **one phase**, then the phase workflow outputs the Context Reset banner and stops.

- `/cks:autonomous` loops through all phases using Agent() dispatches (isolated context per agent).
- `/cks:new` initializes then falls into the autonomous loop.

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

.context/                           # Persistent research briefs
├── config.md                       # Source priority + preferences (optional)
├── stripe-subscriptions.md         # Auto-researched or manual
└── supabase-rls-policies.md

docs/                               # Public artifacts
├── ROADMAP.md                      # Living roadmap
└── prds/
    └── PRD-001-feature.md          # Individual PRD documents

CHANGELOG.md                        # Auto-generated from git history
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

## Hooks

The plugin includes two automatic hooks (defined in `.claude/hooks/hooks.json`):

| Hook | Event | Behavior |
|------|-------|----------|
| **Session Status** | `SessionStart` | If `.prd/PRD-STATE.md` exists, shows current phase, status, and next action. Silent otherwise. |
| **Commit Reminder** | `Stop` | If `git status` shows uncommitted changes, reminds user to commit. Silent otherwise. |

Both hooks use `type: "prompt"` — Claude reads the instruction, checks conditions, and either displays a brief status or stays silent. No blocking, no shell scripts.

## Session Start Behavior

When this skill is triggered at session start (or via the SessionStart hook):
1. Check if `.prd/PRD-STATE.md` exists
2. If yes → read it, show current position, suggest `/cks:next`
3. If no `.prd/` → suggest `/cks:new`

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
- **State after every step.** STATE.md updated constantly. `/cks:next` can always resume.
- **Agents stay in their lane.** Discoverer doesn't write PRDs. Planner doesn't code. Executor doesn't redesign. Verifier doesn't fix.
