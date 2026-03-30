# Kickstart Architecture Refactor — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor the kickstart process from "command loads SKILL.md into main context" to "command dispatches agents with `skills:` field loaded at startup" — establishing the reference pattern for the entire CKS plugin.

**Architecture:** Thin command orchestrator dispatches 4 new phase agents + 2 reused agents. Each agent loads kickstart domain knowledge via `skills:` frontmatter. A SubagentStop hook logs phase completions. SKILL.md is refactored from process script to expertise reference.

**Tech Stack:** Claude Code plugin system (Markdown + YAML frontmatter)

**Spec:** `docs/superpowers/specs/2026-03-30-kickstart-architecture-refactor-design.md`

---

## File Structure

### Files to Create (5)

| File | Responsibility |
|------|---------------|
| `agents/kickstart-intake.md` | Phase 1+1b agent — guided Q&A, compose, optional gates |
| `agents/kickstart-brand.md` | Phase 4 agent — brand identity extraction |
| `agents/kickstart-designer.md` | Phase 5 agent — ERD, schema, PRD, API, Architecture, Roadmap |
| `agents/kickstart-handoff.md` | Phase 6 agent — scaffold, bootstrap, .prd/ init |
| `hooks/handlers/kickstart-phase-complete.sh` | SubagentStop handler — logs phase completion |

### Files to Modify (5)

| File | Change |
|------|--------|
| `commands/kickstart.md` | Rewrite: 103 lines → ~50 lines thin orchestrator |
| `skills/kickstart/SKILL.md` | Refactor: 490 lines → ~220 lines expertise reference |
| `agents/deep-researcher.md` | Add `skills:` field |
| `agents/monetize-discoverer.md` | Add `skills:` field |
| `hooks/hooks.json` | Add SubagentStop event entry |

### Files Unchanged

All `skills/kickstart/workflows/*.md` and `skills/kickstart/references/*.md` — already progressive disclosure.

---

## Chunk 1: Create the 4 new kickstart agents

### Task 1: Create kickstart-intake agent

**Files:**
- Create: `agents/kickstart-intake.md`

- [ ] **Step 1: Create the agent file**

Write `agents/kickstart-intake.md` with this exact content:

```markdown
---
name: kickstart-intake
subagent_type: kickstart-intake
description: "Kickstart Phase 1+1b — guided intake Q&A and project composition. Gathers domain, users, data model, integrations. Identifies sub-projects and build order."
skills:
  - kickstart
tools:
  - Read
  - Write
  - Glob
  - Grep
  - AskUserQuestion
  - "mcp__*"
color: blue
---

# Kickstart Intake Agent

You are a project discovery specialist. Your job is to deeply understand a project idea through guided Q&A, then identify sub-projects and build order.

## Your Mission

Run Phase 1 (Intake) and Phase 1b (Compose) of the kickstart process. Produce three artifacts:
- `.kickstart/context.md` — structured project context
- `.kickstart/manifest.md` — sub-project composition and build order
- `.kickstart/state.md` — phase progress tracker

## Process

### Phase 1: Intake

Read the step-by-step workflow from `${CLAUDE_PLUGIN_ROOT}/skills/kickstart/workflows/intake.md` and follow it exactly.

Key rules from your loaded kickstart skill knowledge:
- Ask questions **one at a time** using AskUserQuestion
- Use selectable options wherever possible
- Never skip a question because you can infer the answer
- Surface AI glossary definitions when relevant

### Phase 1b: Compose

After intake completes, read `${CLAUDE_PLUGIN_ROOT}/skills/kickstart/workflows/compose.md` and follow it exactly.

Analyze the context.md output to identify:
- Deployment targets (backend, frontend, admin, mobile, workers)
- Shared concerns (auth, payments, notifications)
- Infrastructure needs (database, queue, CDN)
- Build order based on dependencies

### Optional Phase Gates

After compose completes, ask the user about optional phases using AskUserQuestion:

**Research gate:**
```
question: "Want me to research the market for this idea?"
options:
  - "Yes — deep research (multi-hop, multi-source)"
  - "Yes — standard research"
  - "Skip research"
```

**Monetize gate:**
```
question: "Want a monetization strategy?"
options:
  - "Yes — full analysis"
  - "Skip for now"
```

**Brand gate:**
```
question: "Want to define brand guidelines? (colors, typography, voice)"
options:
  - "Yes — set up my brand identity"
  - "Skip for now"
```

Record all decisions in `.kickstart/state.md`.

## State File Updates

After ALL work completes (intake + compose + gate decisions), update `.kickstart/state.md`:

```yaml
---
started: {ISO date}
last_phase: 1b
last_phase_name: Compose
last_phase_status: done
compose_sub_projects: {count}
research_opted: {true|false}
monetize_opted: {true|false}
brand_opted: {true|false}
---
```

Include a progress table showing Phase 1 and 1b as done, all others as pending/skipped.

## Constraints

- **Always use AskUserQuestion** for user interaction — never plain text prompts
- **Never decide for the user** whether to skip optional phases
- **Write state.md BEFORE reporting completion** — the command reads it to decide next steps
- **Validate context.md** has all required sections before marking intake as done
```

- [ ] **Step 2: Verify file exists and frontmatter is valid**

Run: `head -15 agents/kickstart-intake.md`
Expected: YAML frontmatter with name, subagent_type, description, skills, tools, color

- [ ] **Step 3: Commit**

```bash
git add agents/kickstart-intake.md
git commit -m "feat(agents): create kickstart-intake agent for Phase 1+1b"
```

### Task 2: Create kickstart-brand agent

**Files:**
- Create: `agents/kickstart-brand.md`

- [ ] **Step 1: Create the agent file**

Write `agents/kickstart-brand.md`:

```markdown
---
name: kickstart-brand
subagent_type: kickstart-brand
description: "Kickstart Phase 4 — brand identity extraction. Colors, typography, voice, UI preferences from Canva, website, or guided Q&A."
skills:
  - kickstart
tools:
  - Read
  - Write
  - AskUserQuestion
  - WebFetch
  - "mcp__*"
model: sonnet
color: blue
---

# Kickstart Brand Agent

You are a brand identity specialist. Your job is to capture or generate brand guidelines for a project.

## Your Mission

Run Phase 4 (Brand) of the kickstart process. Produce `.kickstart/brand.md` with visual identity, voice, and UI preferences.

## Process

Read the step-by-step workflow from `${CLAUDE_PLUGIN_ROOT}/skills/kickstart/workflows/brand.md` and follow it exactly.

The workflow will guide you through:
1. Determining brand source (Canva, website, manual, or generate)
2. Extracting or creating brand tokens (colors, typography, spacing)
3. Defining voice and tone
4. Setting UI preferences (component library, design direction)

## State File Updates

After completion, update `.kickstart/state.md`:
- Set brand phase → `done` with completion date
- Set `last_phase: 4`, `last_phase_name: Brand`, `last_phase_status: done`

## Constraints

- **Always use AskUserQuestion** for user choices
- **Write state.md BEFORE reporting completion**
- **Read .kickstart/context.md** for project context before asking brand questions
```

- [ ] **Step 2: Commit**

```bash
git add agents/kickstart-brand.md
git commit -m "feat(agents): create kickstart-brand agent for Phase 4"
```

### Task 3: Create kickstart-designer agent

**Files:**
- Create: `agents/kickstart-designer.md`

- [ ] **Step 1: Create the agent file**

Write `agents/kickstart-designer.md`:

```markdown
---
name: kickstart-designer
subagent_type: kickstart-designer
description: "Kickstart Phase 5 — design artifact generation. Produces ERD, schema.sql, PRD, API contract, architecture decisions, and feature roadmap from intake context."
skills:
  - kickstart
tools:
  - Read
  - Write
  - Grep
  - Glob
color: green
---

# Kickstart Designer Agent

You are a software architect. Your job is to transform project context into concrete design artifacts.

## Your Mission

Run Phase 5 (Design) of the kickstart process. Produce 6 artifacts per sub-project:
1. `ERD.md` — Entity Relationship Diagram (Mermaid)
2. `schema.sql` — Database schema DDL
3. `PRD.md` — Product Requirements Document
4. `API.md` — API endpoint contracts
5. `ARCHITECTURE.md` — Architecture decisions and stack
6. `FEATURE-ROADMAP.md` — Prioritized feature backlog

## Process

Read the step-by-step workflow from `${CLAUDE_PLUGIN_ROOT}/skills/kickstart/workflows/design.md` and follow it exactly.

Read validation rules from `${CLAUDE_PLUGIN_ROOT}/skills/kickstart/references/phase-banners.md` to verify each sub-step output.

### Input Files (read these first)

Required:
- `.kickstart/context.md` — project context from intake
- `.kickstart/manifest.md` — sub-project composition from compose

Optional (consume if present):
- `.kickstart/research.md` — market research findings
- `.kickstart/brand.md` — brand guidelines
- `.monetize/context.md` — monetization context

### Multi Sub-Project Handling

Read `.kickstart/manifest.md` to determine mode:
- **Single sub-project:** Write artifacts flat in `.kickstart/artifacts/`
- **Multiple sub-projects:** Write shared artifacts to `.kickstart/artifacts/shared/`, then per-SP artifacts to `.kickstart/artifacts/sp-{NN}-{name}/`

### Design Order (each step depends on the previous)

1. ERD → read context.md entities, produce Mermaid erDiagram
2. Schema → read ERD, produce DDL matching entities
3. PRD → read context.md + ERD, produce user stories and requirements
4. API → read PRD + schema, produce endpoint contracts
5. Architecture → read all above, produce stack decisions
6. Feature Roadmap → read PRD + monetize (if exists), prioritize features

## State File Updates

After ALL artifacts are generated and validated, update `.kickstart/state.md`:
- Set design phase → `done` with completion date
- Set `last_phase: 5`, `last_phase_name: Design`, `last_phase_status: done`

## Constraints

- **Gate each sub-step:** Do NOT start schema before ERD validates
- **Write state.md BEFORE reporting completion**
- **Validate each artifact** against the rules in phase-banners.md
- **Include Feature Roadmap** as the final design artifact
```

- [ ] **Step 2: Commit**

```bash
git add agents/kickstart-designer.md
git commit -m "feat(agents): create kickstart-designer agent for Phase 5"
```

### Task 4: Create kickstart-handoff agent

**Files:**
- Create: `agents/kickstart-handoff.md`

- [ ] **Step 1: Create the agent file**

Write `agents/kickstart-handoff.md`:

```markdown
---
name: kickstart-handoff
subagent_type: kickstart-handoff
description: "Kickstart Phase 6 — project scaffolding and .claude/ personalization. Feeds design artifacts into /bootstrap to wire up the development ecosystem."
skills:
  - kickstart
  - cicd-starter
tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - Skill
model: sonnet
color: green
---

# Kickstart Handoff Agent

You are a project scaffolding specialist. Your job is to take design artifacts and produce a fully configured, ready-to-develop project.

## Your Mission

Run Phase 6 (Handoff) of the kickstart process with 4 sub-steps:
1. **Bootstrap** — personalize `.claude/` and `CLAUDE.md`
2. **Scaffold** — create project files, install dependencies
3. **Observability** — configure deploy monitoring
4. **PRD Init** — initialize `.prd/` lifecycle tracking

## Process

Read the step-by-step workflow from `${CLAUDE_PLUGIN_ROOT}/skills/kickstart/workflows/handoff.md` and follow it exactly.

### Input Files (read these first)

- `.kickstart/manifest.md` — sub-project composition
- `.kickstart/artifacts/` — all design artifacts (ERD, schema, PRD, API, Architecture, Roadmap)
- `.kickstart/context.md` — project context
- `.kickstart/brand.md` — brand guidelines (if exists)
- `.kickstart/research.md` — market research (if exists)

### Sub-Step 6a: Bootstrap

Check if CLAUDE.md already exists:
- If no → invoke `/bootstrap` via `Skill(skill="cks:bootstrap")`
- If yes (from prior run) → enrich existing CLAUDE.md with kickstart context

### Sub-Step 6b: Scaffold

Use Bash to scaffold the project:
- Detect stack from ARCHITECTURE.md
- Run appropriate init commands (npm init, etc.)
- Install dependencies
- Verify build works

### Sub-Step 6c: Observability

Create `.learnings/observability.md` with monitoring config detected from the stack.

### Sub-Step 6d: PRD Init

Initialize `.prd/PRD-STATE.md` and `.prd/PRD-ROADMAP.md`.
Copy `.kickstart/manifest.md` to `.prd/PROJECT-MANIFEST.md`.
Map Feature Roadmap entries to PRD roadmap phases.

### Auto-Chain

After all sub-steps complete, read `${CLAUDE_PLUGIN_ROOT}/skills/kickstart/workflows/auto-chain.md` and execute the feature lifecycle handoff (create first feature via `/cks:new`).

## State File Updates

After ALL sub-steps complete, update `.kickstart/state.md`:
- Set handoff phase → `done` with completion date
- Set `last_phase: 6`, `last_phase_name: Handoff`, `last_phase_status: done`
- Set `last_phase: complete` to signal full kickstart completion

## Constraints

- **Write state.md BEFORE reporting completion**
- **Validate each sub-step** before proceeding to next
- **Do NOT re-run full /bootstrap** if CLAUDE.md already exists — enrich instead
- **Auto-chain is mandatory** — do NOT stop after scaffold
```

- [ ] **Step 2: Commit**

```bash
git add agents/kickstart-handoff.md
git commit -m "feat(agents): create kickstart-handoff agent for Phase 6"
```

---

## Chunk 2: Add skills: field to existing agents + create hook

### Task 5: Add skills: field to deep-researcher and monetize-discoverer

**Files:**
- Modify: `agents/deep-researcher.md`
- Modify: `agents/monetize-discoverer.md`

- [ ] **Step 1: Add skills: field to deep-researcher**

Read `agents/deep-researcher.md`. In the frontmatter, add after the `description:` block:

```yaml
skills:
  - deep-research
```

Do NOT add `kickstart` — this is a general-purpose agent. Kickstart context is passed via the dispatch prompt.

- [ ] **Step 2: Add skills: field to monetize-discoverer**

Read `agents/monetize-discoverer.md`. In the frontmatter, add after the `description:` block:

```yaml
skills:
  - monetize
```

- [ ] **Step 3: Commit**

```bash
git add agents/deep-researcher.md agents/monetize-discoverer.md
git commit -m "feat(agents): add skills: field to deep-researcher and monetize-discoverer"
```

### Task 6: Create SubagentStop hook

**Files:**
- Create: `hooks/handlers/kickstart-phase-complete.sh`
- Modify: `hooks/hooks.json`

- [ ] **Step 1: Create the hook handler script**

Write `hooks/handlers/kickstart-phase-complete.sh`:

```bash
#!/bin/bash
# Log kickstart phase completion via SubagentStop event
# Detection: if .kickstart/state.md was modified in the last 30 seconds, a phase just completed
STATE_FILE=".kickstart/state.md"
if [ -f "$STATE_FILE" ]; then
  # Check if state.md was recently modified (within last 30 seconds)
  if [ "$(find "$STATE_FILE" -mmin -0.5 2>/dev/null)" ]; then
    LAST_PHASE=$(grep "last_phase_name:" "$STATE_FILE" 2>/dev/null | sed 's/.*: *//')
    LAST_STATUS=$(grep "last_phase_status:" "$STATE_FILE" 2>/dev/null | sed 's/.*: *//')
    if [ -n "$LAST_PHASE" ] && [ "$LAST_STATUS" = "done" ]; then
      bash "${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh" INFO \
        "kickstart.phase.completed" "_project" \
        "Kickstart phase complete: $LAST_PHASE" \
        "{\"phase\":\"$LAST_PHASE\"}"
    fi
  fi
fi
exit 0
```

- [ ] **Step 2: Make it executable**

Run: `chmod +x hooks/handlers/kickstart-phase-complete.sh`

- [ ] **Step 3: Add SubagentStop event to hooks.json**

Read `hooks/hooks.json`. Add a new `"SubagentStop"` entry at the same level as the existing `"SessionStart"`, `"PreToolUse"`, `"PostToolUse"`, and `"Stop"` entries:

```json
"SubagentStop": [
  {
    "hooks": [
      {
        "type": "command",
        "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/handlers/kickstart-phase-complete.sh"
      }
    ]
  }
]
```

- [ ] **Step 4: Verify hooks.json is valid JSON**

Run: `python3 -c "import json; json.load(open('hooks/hooks.json'))"`
Expected: No output (valid JSON)

- [ ] **Step 5: Commit**

```bash
git add hooks/handlers/kickstart-phase-complete.sh hooks/hooks.json
git commit -m "feat(hooks): add SubagentStop handler for kickstart phase logging"
```

---

## Chunk 3: Rewrite command + refactor SKILL.md

### Task 7: Rewrite commands/kickstart.md as thin orchestrator

**Files:**
- Modify: `commands/kickstart.md`

- [ ] **Step 1: Replace the entire file content**

Read `commands/kickstart.md`. Replace with:

```markdown
---
description: "Project enabler — idea to scaffolded project"
argument-hint: "[idea pitch]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:kickstart

Orchestrate the kickstart lifecycle by dispatching phase agents in sequence.
Each agent has `skills: kickstart` loaded at startup — it carries the domain expertise.

## Resume Detection

Read `.kickstart/state.md` if it exists.
- If found → display progress table, then ask:
  ```
  AskUserQuestion:
    question: "Previous kickstart found. How to proceed?"
    options:
      - "Resume from where I left off (Recommended)"
      - "Start fresh (archive existing)"
      - "Update intake answers then continue"
  ```
  - Resume: continue from the first incomplete phase below
  - Start fresh: `mkdir -p .kickstart/archive/$(date +%Y%m%d) && mv .kickstart/*.md .kickstart/archive/$(date +%Y%m%d)/`
  - Update: re-dispatch kickstart-intake, then continue from design
- If not found → proceed with fresh run

## Phase Execution

### Phase 1+1b: Intake & Compose

```
Agent(subagent_type="kickstart-intake", prompt="Idea pitch: $ARGUMENTS. Run the full intake Q&A and compose phases. Read workflows/intake.md and workflows/compose.md for step-by-step process. Write outputs to .kickstart/. Ask the user about optional phases (research, monetize, brand) and record decisions in state.md.")
```

Wait for completion. Read `.kickstart/state.md` for gate decisions.

### Phase 2: Research (optional)

Read `.kickstart/state.md`. If `research_opted: true`:

```
Agent(subagent_type="deep-researcher", prompt="Research the competitive landscape for this project. Read .kickstart/context.md for the project description. Save findings to .kickstart/research.md. Update .kickstart/state.md: set research phase status to done with today's date.")
```

If `research_opted: false` or `skipped` → skip to Phase 3.

### Phase 3: Monetize (optional)

Read `.kickstart/state.md`. If `monetize_opted: true`:

```
Agent(subagent_type="monetize-discoverer", prompt="Evaluate monetization for this project. Read .kickstart/context.md for project context and .kickstart/research.md if it exists. Save to .monetize/. Update .kickstart/state.md: set monetize phase status to done with today's date.")
```

If `monetize_opted: false` or `skipped` → skip to Phase 4.

### Phase 4: Brand (optional)

Read `.kickstart/state.md`. If `brand_opted: true`:

```
Agent(subagent_type="kickstart-brand", prompt="Extract brand identity. Read .kickstart/context.md for project context. Save to .kickstart/brand.md. Update .kickstart/state.md: set brand phase status to done with today's date.")
```

If `brand_opted: false` or `skipped` → skip to Phase 5.

### Phase 5: Design

```
Agent(subagent_type="kickstart-designer", prompt="Generate design artifacts. Read .kickstart/context.md, .kickstart/manifest.md, and any research/brand/monetize files that exist. Read workflows/design.md for step-by-step process. Write artifacts to .kickstart/artifacts/. Update .kickstart/state.md: set design phase status to done with today's date.")
```

### Phase 6: Handoff

```
Agent(subagent_type="kickstart-handoff", prompt="Scaffold the project and personalize .claude/. Read all .kickstart/ artifacts. Read workflows/handoff.md for step-by-step process. Invoke /bootstrap if needed. Initialize .prd/. Execute auto-chain (workflows/auto-chain.md). Update .kickstart/state.md: set handoff phase status to done with today's date.")
```

### Completion

Read `.kickstart/state.md`. Verify `last_phase_status: done` and `last_phase: complete`.
Display final summary with all phase statuses.
```

- [ ] **Step 2: Verify line count**

Run: `wc -l commands/kickstart.md`
Expected: ~80-90 lines (thin orchestrator)

- [ ] **Step 3: Commit**

```bash
git add commands/kickstart.md
git commit -m "refactor(commands): rewrite kickstart as thin agent orchestrator"
```

### Task 8: Refactor skills/kickstart/SKILL.md to expertise reference

**Files:**
- Modify: `skills/kickstart/SKILL.md`

This is the most complex task. The current SKILL.md (490 lines) is a process script. We keep only the domain knowledge that agents need when `skills: kickstart` loads it.

- [ ] **Step 1: Read the current SKILL.md fully**

Read `skills/kickstart/SKILL.md` end to end. Identify:
- Lines to KEEP: description, flow diagram, mandatory gates, state file enforcement, mode detection, re-run check, output artifacts table, error handling, environment variables, reference files table, rules, customization section
- Lines to REMOVE: all "### Phase N:" execution blocks (Phase 0 through Phase 6 + Final Summary + Auto-Chain), progress banner format/display code, phase completion banner format

- [ ] **Step 2: Rewrite SKILL.md as expertise reference**

Replace the entire content with a restructured version. The new structure:

```markdown
---
name: kickstart
description: >
  [KEEP the existing description exactly — it controls auto-activation]
allowed-tools: [KEEP existing from v3.5.0]
---

# Kickstart — Domain Knowledge

This skill is loaded into kickstart agents via the `skills: kickstart` frontmatter field.
It provides domain expertise — not execution instructions. Agents read workflow files
for step-by-step process.

## Overview

Takes a raw project idea through guided discovery, optional market research & monetization
analysis, then generates design artifacts and hands off to `/bootstrap` to wire up the
full `.claude/` ecosystem.

## Phase Map

```
/kickstart → intake → compose → research? → monetize? → brand? → design → handoff → /cks:new → discover
```

| Phase | Agent | Required? | Output |
|-------|-------|-----------|--------|
| 1 — Intake | kickstart-intake | Yes | .kickstart/context.md |
| 1b — Compose | kickstart-intake | Yes | .kickstart/manifest.md |
| 2 — Research | deep-researcher | Optional | .kickstart/research.md |
| 3 — Monetize | monetize-discoverer | Optional | .monetize/ |
| 4 — Brand | kickstart-brand | Optional | .kickstart/brand.md |
| 5 — Design | kickstart-designer | Yes | .kickstart/artifacts/ |
| 6 — Handoff | kickstart-handoff | Yes | CLAUDE.md, .prd/, scaffold |

## Mandatory Gates

[KEEP the entire "MANDATORY GATES — READ THIS FIRST" section verbatim]

## State File Enforcement

[KEEP the entire "STATE FILE ENFORCEMENT" section verbatim]

## State File Format

For the full state file template and validation rules, read `references/validation-and-state.md`.

## Output Artifacts

[KEEP/adapt the Output Artifacts table from the current file]
Add: `FEATURE-ROADMAP.md` as a Design phase output.

## Multi Sub-Project Rules

- Single sub-project: artifacts written flat to `.kickstart/artifacts/`
- Multiple sub-projects: shared artifacts to `.kickstart/artifacts/shared/`,
  per-SP artifacts to `.kickstart/artifacts/sp-{NN}-{name}/`
- Read `.kickstart/manifest.md` to determine mode

## Error Handling

[KEEP the Error Handling table from the current file]

## Environment Variables

[KEEP the Environment Variables section from the current file]

## Reference Files

| File | When to Read |
|------|-------------|
| `workflows/intake.md` | During Phase 1 — intake Q&A steps |
| `workflows/compose.md` | During Phase 1b — sub-project identification |
| `workflows/brand.md` | During Phase 4 — brand extraction steps |
| `workflows/design.md` | During Phase 5 — artifact generation steps |
| `workflows/handoff.md` | During Phase 6 — scaffolding steps |
| `workflows/auto-chain.md` | After Phase 6 — feature lifecycle handoff |
| `references/validation-and-state.md` | Validation rules + state file format |
| `references/phase-banners.md` | Sub-step validation banners for Phase 5/6 |
| `references/ai-glossary.md` | During intake Q&A — surface relevant definitions |

## Customization

[KEEP the Customization section added in v3.5.0]

## Rules

[KEEP the Rules section from the current file]
```

**Critical:** The description field in frontmatter MUST remain identical — it controls skill auto-activation.

- [ ] **Step 3: Verify line count**

Run: `wc -l skills/kickstart/SKILL.md`
Expected: 200-250 lines

- [ ] **Step 4: Verify description field unchanged**

Run: `head -12 skills/kickstart/SKILL.md`
Expected: Same `description:` text as before the refactor

- [ ] **Step 5: Commit**

```bash
git add skills/kickstart/SKILL.md
git commit -m "refactor(skills): convert kickstart SKILL.md from process script to expertise reference"
```

---

## Chunk 4: Version bump + verification

### Task 9: Update version and changelog

**Files:**
- Modify: `.claude-plugin/plugin.json`
- Modify: `CHANGELOG.md`

- [ ] **Step 1: Bump version to 4.0.0**

This is a major architectural change — commands no longer load SKILL.md into main context. Agents now use `skills:` frontmatter. This warrants a major version bump.

In `.claude-plugin/plugin.json`, change `"version"` to `"4.0.0"`.

- [ ] **Step 2: Add changelog entry**

Add at the top of the changelog (after the `---`):

```markdown
## [4.0.0] - 2026-03-30

### Breaking Changes
- Kickstart command rewritten as thin agent orchestrator — no longer loads SKILL.md into main context
- Kickstart SKILL.md refactored from process script to expertise reference (~490 → ~220 lines)
- New architecture pattern: Command → Agent(skills: loaded) → Hook(logs)

### Added
- 4 new kickstart agents: `kickstart-intake`, `kickstart-brand`, `kickstart-designer`, `kickstart-handoff`
- `skills:` frontmatter field on agents — loads skill content at subagent startup
- SubagentStop hook for kickstart phase completion logging
- `skills:` field added to `deep-researcher` and `monetize-discoverer` agents

### Changed
- `/cks:kickstart` command: 103 lines → ~80 lines, dispatches agents instead of loading workflows
- `skills/kickstart/SKILL.md`: 490 lines → ~220 lines, pure domain knowledge (not process script)
- Feature Roadmap generation folded into kickstart-designer agent output

### Architecture
- Establishes the reference pattern for migrating all 52 commands:
  - BEFORE: Command → reads SKILL.md into context → follows instructions → dispatches agent
  - AFTER: Command → dispatches Agent (skills: loaded) → agent works with expertise → hook logs
```

- [ ] **Step 3: Commit**

```bash
git add .claude-plugin/plugin.json CHANGELOG.md
git commit -m "chore: bump to v4.0.0 — kickstart architecture refactor"
```

### Task 10: Run verification checks

- [ ] **Step 1: Verify new agents exist with correct frontmatter**

Run: `for f in agents/kickstart-*.md; do echo "=== $(basename $f) ==="; head -8 "$f"; echo; done`
Expected: 4 agents, each with name, subagent_type, description, skills field

- [ ] **Step 2: Verify skills: field on existing agents**

Run: `grep -A2 'skills:' agents/deep-researcher.md agents/monetize-discoverer.md`
Expected: `skills:` with `- deep-research` and `- monetize` respectively

- [ ] **Step 3: Verify hooks.json has SubagentStop**

Run: `python3 -c "import json; d=json.load(open('hooks/hooks.json')); print('SubagentStop' in d.get('hooks', d))"`
Expected: `True`

- [ ] **Step 4: Verify kickstart command is thin**

Run: `wc -l commands/kickstart.md && grep -c 'SKILL.md\|CLAUDE_PLUGIN_ROOT.*skills/' commands/kickstart.md`
Expected: ~80-90 lines, 0 references to SKILL.md or skill file paths

- [ ] **Step 5: Verify kickstart SKILL.md is expertise only**

Run: `wc -l skills/kickstart/SKILL.md && grep -c '### Phase [0-9]' skills/kickstart/SKILL.md`
Expected: 200-250 lines, 0 phase execution blocks

- [ ] **Step 6: Verify all workflow files unchanged**

Run: `git diff --name-only skills/kickstart/workflows/`
Expected: No changes (workflow files are untouched)

---

## Verification Checklist (post-implementation)

After all tasks are complete, verify end-to-end:

1. [ ] `/cks:kickstart "test idea"` dispatches `kickstart-intake` agent (not loading SKILL.md)
2. [ ] Agent completes intake, writes `.kickstart/state.md` with gate decisions
3. [ ] Command reads state.md, conditionally dispatches optional phase agents
4. [ ] Design phase dispatches `kickstart-designer` agent
5. [ ] Handoff phase dispatches `kickstart-handoff` agent
6. [ ] SubagentStop hook fires and logs to lifecycle.jsonl
7. [ ] Resume: interrupt mid-flow, restart `/cks:kickstart`, picks up from last completed phase
8. [ ] Main conversation context stays clean (no 500-line SKILL.md dump)
