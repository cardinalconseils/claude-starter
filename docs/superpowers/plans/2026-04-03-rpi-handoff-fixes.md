# RPI Handoff Fixes — Close Research→Plan→Implement Gaps

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Wire research artifacts (`.research/`, `.context/`, `{NN}-RESEARCH.md`) into all downstream consumers (discoverer, planner, designer, sprint dispatch) and add automatic refresh on iteration loops.

**Architecture:** 6 targeted edits to existing agent/workflow files. No new files. Each edit adds 3-10 lines to an existing section. The pattern is consistent: add file paths to "read these" lists and add conditional dispatch logic for the researcher agent.

**Tech Stack:** Markdown (agent definitions, workflow files)

---

## Chunk 1: Wire Research Into Downstream Agents

### Task 1: Wire .research/ and .context/ into prd-discoverer

**Files:**
- Modify: `agents/prd-discoverer.md:68-80` (Step 0: Research the Codebase)

- [ ] **Step 1: Add research artifact reads to Step 0**

In the "Step 0: Research the Codebase" section, after the existing "Proactively investigate:" list, add reads for research artifacts:

```markdown
### Step 0: Research the Codebase (before asking anything)

Proactively investigate:
- Read relevant source files for current architecture
- Check existing PRDs in `docs/prds/` to avoid overlap
- Read `CLAUDE.md` for conventions
- Read `.prd/PROJECT-MANIFEST.md` if it exists — understand what sub-projects exist, their dependencies, shared concerns, and cross-project contracts. This context informs Element 11.
- Identify files that will need modification
- Look at data models, API patterns, component structure
- Read `.context/*.md` for existing technology briefs — these contain API patterns, gotchas, and code examples from prior research
- Scan `.research/` for deep research reports — if a report exists for a relevant technology or domain, read its `report.md` for findings and recommendations
- Read `.prd/phases/{NN}-{name}/{NN}-RESEARCH.md` if it exists — prior technical investigation for this feature
- Read reference files:
  - `${CLAUDE_PLUGIN_ROOT}/skills/prd/references/uat-patterns.md` — for writing UAT scenarios
  - `${CLAUDE_PLUGIN_ROOT}/skills/prd/references/testing-strategy.md` — for test plan
```

- [ ] **Step 2: Verify the edit is correct**

Read `agents/prd-discoverer.md` and confirm lines 68-80 now include the three new bullet points.

- [ ] **Step 3: Commit**

```bash
git add agents/prd-discoverer.md
git commit -m "feat(discoverer): read .context/, .research/, and RESEARCH.md in Step 0"
```

---

### Task 2: Wire .research/ and .context/ into prd-planner Step 1

**Files:**
- Modify: `agents/prd-planner.md:33-41` (Step 1: Read All Context)

- [ ] **Step 1: Add research artifacts to "Read these files" list**

In Step 1, add three new items after the existing list:

```markdown
### Step 1: Read All Context

Read these files:
- `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md` — Discovery output (your primary input)
- `.prd/phases/{NN}-{name}/{NN}-RESEARCH.md` — Technical research findings (if exists — contains codebase analysis, technology recommendations, and risk assessment)
- `.prd/PRD-PROJECT.md` — Project context
- `.prd/PRD-REQUIREMENTS.md` — Existing requirements (for REQ-ID numbering)
- `.prd/PRD-ROADMAP.md` — Current roadmap
- `CLAUDE.md` — Project conventions
- Scan `docs/prds/` for existing PRDs (for numbering)
- Scan `.context/*.md` for technology briefs — these inform implementation approach and flag known gotchas
- Scan `.research/` for deep research reports — if a report covers a technology or domain relevant to this feature, read its findings and recommendations
```

- [ ] **Step 2: Verify the edit is correct**

Read `agents/prd-planner.md` and confirm Step 1 now includes RESEARCH.md, .context/, and .research/.

- [ ] **Step 3: Commit**

```bash
git add agents/prd-planner.md
git commit -m "feat(planner): read RESEARCH.md, .context/, and .research/ in Step 1"
```

---

### Task 3: Wire .research/ and .context/ into prd-designer

**Files:**
- Modify: `agents/prd-designer.md:38-42` (Input You Receive section)

- [ ] **Step 1: Add research inputs to the "Input You Receive" section**

```markdown
## Input You Receive

- **Discovery context** ({NN}-CONTEXT.md) with user stories, acceptance criteria, scope
- **Research findings** ({NN}-RESEARCH.md, if exists) with technical investigation results and recommendations
- **Technology briefs** (.context/*.md) with API patterns, gotchas, and code examples for referenced technologies
- **Deep research** (.research/{slug}/report.md, if exists) with strategic findings for relevant domains
- **Project context** (PROJECT.md, CLAUDE.md)
- **Phase brief** from the roadmap
```

- [ ] **Step 2: Verify the edit is correct**

Read `agents/prd-designer.md` and confirm the "Input You Receive" section now lists research artifacts.

- [ ] **Step 3: Commit**

```bash
git add agents/prd-designer.md
git commit -m "feat(designer): read research artifacts in Input You Receive"
```

---

## Chunk 2: Add Researcher Trigger Conditions

### Task 4: Add prd-researcher dispatch triggers to discoverer and planner

**Files:**
- Modify: `agents/prd-discoverer.md` (after Step 0, before Step 1)
- Modify: `agents/prd-planner.md` (after Step 1, before Step 2)

- [ ] **Step 1: Add researcher dispatch to discoverer**

After Step 0 in `agents/prd-discoverer.md`, add a new Step 0b:

```markdown
### Step 0b: Dispatch Technical Research (if needed)

After reading the codebase, evaluate whether the feature involves:
- **Unfamiliar technology** — no `.context/` brief exists AND the technology is central to the feature
- **Complex architectural impact** — changes touch 5+ files across 3+ directories
- **Integration with external systems** — APIs, databases, or services not yet documented

If ANY of these conditions are true, dispatch the **prd-researcher** agent:

```
Agent(
  subagent_type="prd-researcher",
  prompt="
    Phase: {NN} — {name}
    Research question: {specific question from your codebase investigation}
    Save findings to: .prd/phases/{NN}-{name}/{NN}-RESEARCH.md
    Focus areas: {list the specific unknowns}
  "
)
```

Wait for the researcher to complete before proceeding to Step 1. Read the RESEARCH.md output — it will inform your discovery questions.

**Skip if:** All technologies have `.context/` briefs, the feature is straightforward, or RESEARCH.md already exists.
```

- [ ] **Step 2: Add researcher dispatch to planner**

After Step 1 in `agents/prd-planner.md`, add a new Step 1b:

```markdown
### Step 1b: Dispatch Technical Research (if needed)

After reading all context, evaluate whether planning requires deeper investigation:
- **Missing implementation details** — CONTEXT.md references a technology with no `.context/` brief and no RESEARCH.md
- **Ambiguous architecture** — multiple valid approaches exist and CONTEXT.md doesn't specify which
- **Risk assessment needed** — the feature touches critical paths (auth, payments, data migration)

If ANY condition is true AND no `{NN}-RESEARCH.md` exists, dispatch the **prd-researcher** agent:

```
Agent(
  subagent_type="prd-researcher",
  prompt="
    Phase: {NN} — {name}
    Research question: {specific question from context analysis}
    Save findings to: .prd/phases/{NN}-{name}/{NN}-RESEARCH.md
    Focus: {what the planner needs to decide}
  "
)
```

Read the output before proceeding to Step 2.

**Skip if:** RESEARCH.md already exists or CONTEXT.md + `.context/` briefs provide sufficient detail.
```

- [ ] **Step 3: Verify both edits**

Read both agent files and confirm the new steps exist in the right positions.

- [ ] **Step 4: Commit**

```bash
git add agents/prd-discoverer.md agents/prd-planner.md
git commit -m "feat(researcher): add dispatch triggers in discoverer Step 0b and planner Step 1b"
```

---

## Chunk 3: Iteration Refresh and Sprint Dispatch

### Task 5: Add --refresh on iteration in step-2-research.md

**Files:**
- Modify: `skills/prd/workflows/discover-phase/step-2-research.md`

- [ ] **Step 1: Add iteration detection and refresh logic**

Replace the existing "Skip this step if" block and add iteration-aware logic:

```markdown
## Iteration Detection

Read `.prd/PRD-STATE.md` and check `iteration_count`.

**If `iteration_count` > 0 (re-entering discovery from Phase 4 iteration):**
- Re-run context research for ALL technologies mentioned in the feature brief, even if `.context/<slug>.md` already exists
- This refreshes potentially stale briefs that may have caused the iteration
- Log: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.2.refresh" "{NN}-{name}" "Step 2: Refreshing all technology briefs (iteration #{iteration_count})"`

**Skip this step if:**
- No technologies are mentioned in the brief
- `.context/config.md` has `auto-research: false`
- All identified technologies already have context briefs **AND** `iteration_count` = 0
```

- [ ] **Step 2: Verify the edit**

Read `skills/prd/workflows/discover-phase/step-2-research.md` and confirm iteration detection is present.

- [ ] **Step 3: Commit**

```bash
git add skills/prd/workflows/discover-phase/step-2-research.md
git commit -m "feat(research): refresh .context/ briefs when re-entering discovery from iteration"
```

---

### Task 6: Wire research into sprint planning dispatch (step-3a)

**Files:**
- Modify: `skills/prd/workflows/sprint-phase/step-3a-planning.md:14-43` (prd-planner dispatch prompt)

- [ ] **Step 1: Add research artifacts to the planner dispatch prompt**

In the dispatch prompt's "Read these files for context" list, add research artifacts:

```markdown
Agent(
  subagent_type="prd-planner",
  prompt="
    Project root: {project_root}
    Phase: {phase_number} — {phase_name}

    Read these files for context (DO NOT embed contents in this prompt):
    - .prd/phases/{NN}-{name}/{NN}-CONTEXT.md — Discovery output
    - .prd/phases/{NN}-{name}/{NN}-DESIGN.md — Design specs
    - .prd/phases/{NN}-{name}/{NN}-RESEARCH.md — Technical research findings (if exists)
    - .prd/phases/{NN}-{name}/design/component-specs.md — Component specs
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

- [ ] **Step 2: Verify the edit**

Read `skills/prd/workflows/sprint-phase/step-3a-planning.md` and confirm research artifacts are in the dispatch prompt.

- [ ] **Step 3: Commit**

```bash
git add skills/prd/workflows/sprint-phase/step-3a-planning.md
git commit -m "feat(sprint): pass research artifacts to planner in step-3a dispatch"
```
