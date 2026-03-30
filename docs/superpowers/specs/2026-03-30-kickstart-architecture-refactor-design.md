# Kickstart Architecture Refactor — Design Spec

## Context

The CKS plugin's kickstart process runs a 7-phase flow (intake → compose → research → monetize → brand → design → handoff) entirely in the main conversation context. This violates the Claude Code framework's intended architecture:

- **Commands** should be thin dispatchers, not workflow runners
- **Skills** should be expertise loaded into agents, not process scripts executed in main context
- **Agents** should do isolated phase work with skills pre-loaded via `skills:` frontmatter
- **Hooks** should automate bookkeeping, not be absent from the lifecycle

Today, kickstart has zero agents, zero lifecycle hooks, and a 490-line SKILL.md that acts as both orchestrator and expertise reference. By Phase 5, the main context window is saturated and Claude starts losing track.

This refactor establishes the **reference pattern** for the entire plugin. Once kickstart works correctly, the same pattern applies to all 52 commands.

## The `skills:` Frontmatter Field

Claude Code agents support a `skills:` field in YAML frontmatter that loads skill content into the subagent's context at startup:

```yaml
skills:
  - kickstart
  - cicd-starter
```

**Key behavior:**
- Full content of each referenced SKILL.md is injected into the subagent's context at startup
- Subagents do NOT inherit skills from the parent conversation — you must list them explicitly
- Skill names reference skill directory names (e.g., `kickstart` → `skills/kickstart/SKILL.md`)
- Uses YAML array format (one skill per line with leading dash)

This is the mechanism that makes agents self-sufficient — they start with domain expertise pre-loaded instead of reading files at runtime.

## Architecture

```
/cks:kickstart (command = thin orchestrator, ~40 lines)
    │
    ├── Read .kickstart/state.md (resume detection)
    │
    ├── Phase 1+1b: Dispatch kickstart-intake agent
    │   ├── skills: kickstart (loaded at startup)
    │   ├── Agent asks Q&A via AskUserQuestion
    │   ├── Agent asks optional phase gates (research? monetize? brand?)
    │   └── Agent writes: context.md, manifest.md, state.md
    │
    ├── Read state.md → research_opted?
    │   └── YES → Dispatch deep-researcher agent (skills: deep-research, kickstart)
    │
    ├── Read state.md → monetize_opted?
    │   └── YES → Dispatch monetize-discoverer agent (skills: monetize)
    │
    ├── Read state.md → brand_opted?
    │   └── YES → Dispatch kickstart-brand agent (skills: kickstart)
    │
    ├── Phase 5: Dispatch kickstart-designer agent (skills: kickstart)
    │   └── Reads context + manifest + research, writes 5 artifacts
    │
    └── Phase 6: Dispatch kickstart-handoff agent (skills: kickstart, cicd-starter)
        └── Scaffolds project, invokes /bootstrap, initializes .prd/
```

### Layer Responsibilities

| Layer | Role | What It Does | What It Does NOT Do |
|-------|------|-------------|-------------------|
| **Command** | Orchestrator | Reads state.md, dispatches agents in sequence, handles resume | Hold expertise, run workflows, ask domain questions |
| **Agents** | Phase workers | Execute one phase with pre-loaded skill knowledge | Orchestrate other agents, decide phase order |
| **Skills** | Expertise | Provide domain knowledge loaded at agent startup | Act as process scripts, run in main context |
| **Hooks** | Automation | Log phase completions, guard commits, capture learnings | Dispatch agents, make decisions, interact with user |

## New Agents

### kickstart-intake

```yaml
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
```

**Responsibilities:**
- Conduct guided Q&A using AskUserQuestion (one question at a time)
- Identify sub-projects and shared concerns (compose phase)
- Ask optional phase gates: "Want research?", "Want monetization?", "Want brand?"
- Write outputs: `.kickstart/context.md`, `.kickstart/manifest.md`, `.kickstart/state.md`

**Model:** Default (opus) — needs strong reasoning for strategic interviews and ambiguity handling.

**Progressive disclosure:** Reads `workflows/intake.md` and `workflows/compose.md` for step-by-step process when needed. Domain knowledge comes from the pre-loaded `kickstart` skill.

### kickstart-brand

```yaml
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
```

**Responsibilities:**
- Extract brand identity from available sources (Canva MCP, website, manual Q&A)
- Write output: `.kickstart/brand.md`
- Update `.kickstart/state.md`

**Model:** Sonnet — structured data extraction is mechanical.

### kickstart-designer

```yaml
---
name: kickstart-designer
subagent_type: kickstart-designer
description: "Kickstart Phase 5 — design artifact generation. Produces ERD, schema.sql, PRD, API contract, and architecture decisions from intake context."
skills:
  - kickstart
tools:
  - Read
  - Write
  - Grep
  - Glob
color: green
---
```

**Responsibilities:**
- Read `.kickstart/context.md`, `.kickstart/manifest.md`, `.kickstart/research.md` (if exists), `.kickstart/brand.md` (if exists)
- Generate 5 artifacts per sub-project: ERD.md, schema.sql, PRD.md, API.md, ARCHITECTURE.md
- Handle multi-sub-project mode (shared artifacts first, then per-SP)
- Update `.kickstart/state.md`

**Model:** Default (opus) — architecture decisions and ERD design need strong reasoning.

**Progressive disclosure:** Reads `workflows/design.md` for detailed generation steps and `references/phase-banners.md` for validation.

### kickstart-handoff

```yaml
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
```

**Responsibilities:**
- Synthesize all kickstart artifacts into bootstrap context
- Invoke `/bootstrap` (or enrich existing CLAUDE.md if bootstrap already ran)
- Scaffold project files (npm init, etc.)
- Initialize `.prd/` and PRD-STATE.md
- Initialize `.learnings/`
- Update `.kickstart/state.md`

**Model:** Sonnet — mechanical scaffolding following templates.

**Skills:** Loads both `kickstart` (for artifact knowledge) and `cicd-starter` (for bootstrap/scaffold patterns).

### Reused Existing Agents

**deep-researcher** — already has `skills: deep-research`. Do NOT add `kickstart` to its skills — it's a general-purpose agent used across the plugin. Instead, pass kickstart-specific context via the `prompt` argument when dispatching for Phase 2 research.

**monetize-discoverer** — add `skills: monetize` to frontmatter (scoped to monetization, so this is appropriate). Already exists with correct tools.

## Command Changes

### commands/kickstart.md (rewrite)

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

## Resume Detection

Read `.kickstart/state.md` if it exists:
- If found → show progress, ask: resume / start fresh / update intake
- If not found → fresh run

## Phase Execution

### Phase 1+1b: Intake & Compose

```
Agent(subagent_type="kickstart-intake", prompt="Idea pitch: $ARGUMENTS. Run the full intake Q&A and compose phases. Read workflows/intake.md and workflows/compose.md for step-by-step process. Write outputs to .kickstart/. Ask the user about optional phases (research, monetize, brand) and record decisions in state.md.")
```

Wait for completion. Read `.kickstart/state.md` for gate decisions.

### Phase 2: Research (optional)

Read state.md. If `research_opted: true`:
```
Agent(subagent_type="deep-researcher", prompt="Research the competitive landscape for this project. Read .kickstart/context.md for the project description. Save findings to .kickstart/research.md. Update .kickstart/state.md: research phase → done.")
```

### Phase 3: Monetize (optional)

Read state.md. If `monetize_opted: true`:
```
Agent(subagent_type="monetize-discoverer", prompt="Evaluate monetization for this project. Read .kickstart/context.md for project context and .kickstart/research.md if it exists. Save to .monetize/. Update .kickstart/state.md: monetize phase → done.")
```

### Phase 4: Brand (optional)

Read state.md. If `brand_opted: true`:
```
Agent(subagent_type="kickstart-brand", prompt="Extract brand identity. Read .kickstart/context.md for project context. Save to .kickstart/brand.md. Update .kickstart/state.md: brand phase → done.")
```

### Phase 5: Design

```
Agent(subagent_type="kickstart-designer", prompt="Generate design artifacts. Read .kickstart/context.md, .kickstart/manifest.md, and any research/brand files. Read workflows/design.md for step-by-step process. Write artifacts to .kickstart/artifacts/. Update .kickstart/state.md: design phase → done.")
```

### Phase 6: Handoff

```
Agent(subagent_type="kickstart-handoff", prompt="Scaffold the project and personalize .claude/. Read all .kickstart/ artifacts. Read workflows/handoff.md for step-by-step process. Invoke /bootstrap if needed. Update .kickstart/state.md: handoff phase → done.")
```

### Completion
Read `.kickstart/state.md` to verify all phases complete.
Display final summary.
```

**Key properties:**
- ~40 lines of routing logic
- No domain expertise — all knowledge is in agents via skills
- Only needs: Read (state.md), Agent (dispatch), AskUserQuestion (resume detection only)
- Does NOT write state.md — agents own state writes at phase completion
- Does NOT read SKILL.md or workflow files

## Skill Changes

### skills/kickstart/SKILL.md (refactored role)

SKILL.md stops being a process script. It becomes **domain expertise** that agents load at startup via `skills: kickstart`.

**Structural outline of the new SKILL.md (~200-250 lines):**

```markdown
---
name: kickstart
description: >
  [same description — keeps auto-activation working]
allowed-tools: [already set in v3.5.0]
---

# Kickstart — Domain Knowledge

## Overview
[3-5 line summary of what kickstart produces and why]

## Phase Map
[The flow diagram — what phases exist and their order]

## Mandatory Gates
[The rules: always ask user, never skip questions, never infer]

## State File Format
[Reference to references/validation-and-state.md]

## Output Artifacts
[Table of what each phase produces and where files go]
[Include Feature Roadmap as part of Design phase output]

## Multi Sub-Project Rules
[How to handle single vs multi sub-project from manifest]

## Error Handling
[What to do on failure, retry logic, user escalation]

## Customization
[Already added in v3.5.0]
```

**Remove from SKILL.md:**
- Sequential execution logic ("Phase 1 → Phase 2 → ...") — now in the command
- Progress banner display code — now in agent prompts
- Phase-specific step-by-step instructions — stay in `workflows/` as progressive disclosure
- Auto-chain logic — now in `workflows/auto-chain.md` (already extracted in v3.5.0)

**Feature Roadmap note:** The current `commands/kickstart.md` mentions a "Phase 5: Feature Roadmap" phase that generates `FEATURE-ROADMAP.md`. This is folded into the **kickstart-designer** agent's responsibilities as part of Design output. The designer agent produces ERD, schema, PRD, API, Architecture, AND Feature Roadmap — all as design artifacts.

Workflow files (`workflows/intake.md`, `workflows/design.md`, etc.) stay as progressive disclosure — agents read them when they need step-by-step instructions.

## Hook Changes

### New: hooks/handlers/kickstart-phase-complete.sh

Uses file modification time to detect kickstart phase completion (avoids dependency on env vars that may not be available in SubagentStop context):

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

### Updated: hooks/hooks.json

Add SubagentStop entry:
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

Existing hooks (SessionStart, PreToolUse, PostToolUse, Stop) remain unchanged — they already handle kickstart state detection.

## Files to Create

| File | Purpose |
|------|---------|
| `agents/kickstart-intake.md` | Phase 1+1b agent |
| `agents/kickstart-brand.md` | Phase 4 agent |
| `agents/kickstart-designer.md` | Phase 5 agent |
| `agents/kickstart-handoff.md` | Phase 6 agent |
| `hooks/handlers/kickstart-phase-complete.sh` | SubagentStop hook |

## Files to Modify

| File | Change |
|------|--------|
| `commands/kickstart.md` | Rewrite as thin orchestrator |
| `skills/kickstart/SKILL.md` | Refactor from process script to expertise reference (~490 → ~200-250 lines) |
| `agents/deep-researcher.md` | Add `skills:` field with `deep-research` (no kickstart — context passed via prompt) |
| `agents/monetize-discoverer.md` | Add `skills:` field with `monetize` |
| `hooks/hooks.json` | Add SubagentStop event |

## Files Unchanged

All workflow files (`skills/kickstart/workflows/*.md`) stay as-is. They're already progressive disclosure files — agents read them when needed. The reference files (`skills/kickstart/references/*.md`) also stay as-is.

## Known Limitations

**Mid-agent interruption:** If the user interrupts during an agent's work (e.g., after 5 of 10 intake questions), state.md will show the phase as "pending" because the agent did not complete. On resume, the entire phase restarts. This is acceptable for v1 — agents are designed to be fast enough that interruption is rare. Future enhancement: agents could write incremental progress to state.md (e.g., `intake: in_progress, questions_completed: 5`).

## Verification

1. Run `/cks:kickstart "test idea"` end-to-end
2. Verify each phase runs in an isolated agent (check agent dispatch in output)
3. Verify `.kickstart/state.md` is updated after each phase
4. Verify lifecycle.jsonl has phase completion entries
5. Verify context window stays clean (no 500+ line skill dump in main conversation)
6. Verify resume works: interrupt mid-flow, restart, should pick up from last completed phase
7. Verify optional phases: decline research/monetize/brand, verify they're skipped correctly

## Migration Pattern

This refactor establishes the reference pattern for all commands:

```
BEFORE (anti-pattern):
  Command → reads SKILL.md into main context → follows instructions → dispatches agent → agent reads more files

AFTER (correct):
  Command → dispatches Agent (skills: loaded at startup) → agent works with expertise → hook logs
```

Once kickstart works, apply the same pattern to:
1. The 5-phase lifecycle commands (discover, design, sprint, review, release)
2. Standalone tool commands (debug, research, monetize, etc.)
3. Session management commands (sprint-start, sprint-close, etc.)
