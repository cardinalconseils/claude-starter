# Sub-step [3a]: Sprint Planning / Iteration Planning

<context>
Phase: Sprint (Phase 3)
Requires: Design artifacts exist
Produces: PLAN.md, PRD document, updated REQUIREMENTS.md
Agent: prd-planner
</context>

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3a.started" "{NN}-{name}" "Sprint: planning started"`

> **Expertise:** Read the `product-maturity` skill to confirm the project's maturity stage and adjust quality gates accordingly.

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
