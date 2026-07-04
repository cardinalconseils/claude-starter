# Sub-step [3a]: Sprint Planning / Iteration Planning

<context>
Phase: Sprint (Phase 3)
Requires: Design artifacts exist
Produces: PLAN.md, PRD document, updated REQUIREMENTS.md
Agent: prd-planner
</context>

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3a.started" "{NN}-{name}" "Sprint: planning started"`

> **Expertise:** Read the `product-maturity` skill to confirm the project's maturity stage and adjust quality gates accordingly.

## Legibility Gate (Commit Mode)

Refer to the loaded **legibility skill** for the full Commit Mode framework and bucket definitions.

Before dispatching prd-planner, run a 15-minute reality check on whether the illegible side of this sprint is sound.

Read `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md` to extract the feature description and user context as framing for the questions.

Walk through all 5 Commit Mode buckets. For each, ask via `AskUserQuestion` (free text):

**Bucket 1 — Customer Reality**
```
AskUserQuestion:
  question: "Customer Reality check: Have you watched a real user interact with this problem (or a prototype)? What specifically did you observe — not what they said they'd do, but what their face did and what they did after you left the room?"
```

**Bucket 2 — Sales Motion**
```
AskUserQuestion:
  question: "Sales Motion check: What's the unwritten rule in this industry or org that you might be about to break? Who in the buyer's org would quietly sink this, and why?"
```

**Bucket 3 — Stack & Speed**
```
AskUserQuestion:
  question: "Stack & Speed check: What part of this build are you avoiding because it's boring or scary? Name it. That's the part most likely to kill the project."
```

**Bucket 4 — My Energy**
```
AskUserQuestion:
  question: "My Energy check: When you think about working on this tomorrow morning, is it pull (you want to) or push (you feel you should)? Be honest."
```

**Bucket 5 — Exit Reality**
```
AskUserQuestion:
  question: "Exit Reality check: Has anything changed about whether your intended exit (sell direct / license / credibility) actually exists for this thing? Are you building toward a real path, or lying to yourself?"
```

**Apply the Commit Mode decision rule from the legibility skill:**

Count red cells (illegible answer reveals the plan is wrong or the energy is gone).

- 🟢 **Proceed** (0-1 red cells, My Energy is green) → note any risks inline, continue to API Contract Gate
- 🟡 **Pivot** (1-2 red cells, opportunity still real) → surface the specific cells driving the pivot:

```
AskUserQuestion:
  question: "Commit Mode flagged cells that suggest the plan needs adjusting before building. Which cells do you want to address?"
  options:
    - "Update CONTEXT.md or DESIGN.md to reflect the new direction — then re-run planning"
    - "Acknowledge the gap and proceed anyway — document it as a known risk in PLAN.md"
    - "Go back to Discovery — the feature needs more research"
```

- 🔴 **Kill signal** (3+ red cells, especially My Energy + Customer Reality) → show:

```
─────────────────────────────────────────────────
❓ DECISION REQUIRED
─────────────────────────────────────────────────
Commit Mode flagged 3+ illegible cells as red.
My Energy and/or Customer Reality are signaling
this sprint is not ready.

  1. Stop and park — save the cells, come back later
  2. Pivot the scope — what would make the illegible side turn green?
  3. Proceed anyway — I understand what I'm overriding

Recommended: {1 or 2} — {one sentence identifying which cells are red and why proceeding now risks wasted build cycles}.

Reply with the number or describe what you want.
─────────────────────────────────────────────────
```

If user chooses to proceed (options 2 or 3 override) → document override in PLAN.md risk section and continue.

```
  [3a-pre] Legibility Gate   ✅ {Green/Yellow/Red} — {decision}
```

## API Contract Gate (runs before planning)

Before generating PLAN.md, check whether this feature has an API surface:

1. Read `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md` Section 4 (API Surface Map)
2. If Section 4 is **N/A or empty** → no contract needed, proceed to planning
3. If Section 4 lists endpoints or an API surface:
   - Check if `.prd/phases/{NN}-{name}/design/api-contract.md` exists
   - Check if `.prd/phases/{NN}-{name}/design/review-signoff.md` exists and contains approval for [2b]
   - **If api-contract.md is missing or unapproved → STOP**
     ```
     AskUserQuestion({
       question: "API contract not found or not approved. Parallel implementation workers cannot proceed without a frozen contract — they will make incompatible assumptions and cause merge conflicts.\n\nOptions:",
       options: [
         { label: "Go back to Design [2b]", description: "Generate and approve the API contract first" },
         { label: "This feature has no API surface", description: "Override gate — feature is UI-only or static" }
       ]
     })
     ```
   - If user selects "Go back to Design [2b]" → dispatch prd-designer agent for [2b] only, then re-run this gate
   - If user selects override → note the override in the plan and proceed

4. If contract exists and is approved → include its path in the prd-planner prompt so tasks reference it

## First Sprint — Full Planning

Dispatch the **prd-planner** agent with file paths (NOT embedded content):

```
Agent(
  subagent_type="cks:prd-planner",
  model="{resolved_model}",
  prompt="
    Project root: {project_root}
    Phase: {phase_number} — {phase_name}

    Read these files for context (DO NOT embed contents in this prompt):
    - .prd/phases/{NN}-{name}/{NN}-CONTEXT.md — Discovery output
    - .prd/phases/{NN}-{name}/{NN}-DESIGN.md — Design specs
    - .prd/phases/{NN}-{name}/{NN}-RESEARCH.md — Technical research findings (if exists)
    - .prd/phases/{NN}-{name}/design/component-specs.md — Component specs
    - .prd/phases/{NN}-{name}/design/api-contract.md — API contract (if exists — FROZEN, tasks must reference it)
    - .prd/PRD-PROJECT.md — Project context
    - .prd/PRD-REQUIREMENTS.md — Existing requirements
    - Available domain context: {list .context/*.md filenames}
    - Deep research: {list .research/*/report.md filenames, if any}

    Produce:
    1. PRD document at docs/prds/PRD-{NNN}-{name}.md
       Use template: skills/prd/templates/prd.md
    2. Execution plan at .prd/phases/{NN}-{name}/{NN}-PLAN.md
       Include a domains: line listing .context/ slugs the executor should load
       Include task estimates and sprint goal
    3. Updated .prd/PRD-REQUIREMENTS.md with new REQ-IDs
    4. Updated .prd/PRD-ROADMAP.md

    CRITICAL: Reference the design specs — implementation must match approved screens.
    CRITICAL: Reference research findings — implementation must follow recommended approaches.
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

## Loop Architecture Check (before prd-planner dispatch)

Before dispatching prd-planner, check whether a loop architecture design already exists:

1. Check `.prd/phases/{NN}-{name}/design/loop-design.md` (Phase 2 output)
2. Also check `.loops/{name}/LOOP-DESIGN.md` (direct loop command output)

**If LOOP-DESIGN.md found:** include its path in the prd-planner prompt (alongside api-contract.md).
No dispatch of loop-designer needed — artifact already exists.

**If NOT found AND loop signals detected in CONTEXT.md:**
Per `.claude/rules/loops.md`, dispatch `cks:loop-designer` before writing PLAN.md.
First verify that `{phase_dir}/{NN}-CONTEXT.md` exists. If it does not, surface DECISION REQUIRED
to start the full lifecycle before continuing.

**If NOT found AND no loop signals:** proceed to prd-planner normally.

## Generate Newman Collection (if API feature)

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

## Iteration Sprint — Scoped to Backlog

**Do NOT re-plan from scratch.** The iteration is scoped to BACKLOG.md items from Phase 4.

1. Read `.prd/phases/{NN}-{name}/{NN}-BACKLOG.md` — the iteration's scope
2. Read `.prd/phases/{NN}-{name}/{NN}-REVIEW.md` — the feedback context
3. Read previous `{NN}-PLAN.md` and `{NN}-SUMMARY.md` — what was already built

Dispatch the **prd-planner** agent in iteration mode with file paths (NOT embedded content):

```
Agent(
  subagent_type="cks:prd-planner",
  model="{resolved_model}",
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
    - .prd/phases/{NN}-{name}/{NN}-RESEARCH.md — Technical research findings (if exists)
    - Available domain context: {list .context/*.md filenames}
    - Deep research: {list .research/*/report.md filenames, if any}

    Produce:
    1. Iteration plan at .prd/phases/{NN}-{name}/{NN}-PLAN-iter{iteration}.md
       - ONLY tasks from BACKLOG.md — do not re-plan completed work
       - Reference previous SUMMARY.md for files that need modification
       - Include iteration goal (fix/improve, not build from scratch)
    2. Updated PRD-ROADMAP.md — mark as 'Iterating (#{iteration})'

    CRITICAL: Scope is BACKLOG.md only. Do not expand scope beyond what Review identified.
    CRITICAL: Reference research findings — iteration fixes must follow recommended approaches.
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

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3a.completed" "{NN}-{name}" "Sprint: planning complete"`
