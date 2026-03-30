# Bootstrap & Monetize Architecture Refactor — Design Spec

## Context

Following the v4.0 kickstart refactor, bootstrap and monetize need the same transformation:
- **Command** = thin orchestrator (dispatch agents, read state)
- **Agents** = isolated phase workers with `skills:` loaded at startup
- **Skills** = expertise reference (not process script)
- **Hooks** = automation (logging — existing SubagentStop hook already handles this)

**Bootstrap** has zero agents and loads SKILL.md into main context (same anti-pattern kickstart had).
**Monetize** is 80% correct — 6 agents already exist — but the command still loads SKILL.md, and 5 of 6 agents are missing `skills:` field.

## Part 1: Bootstrap Refactor

### Current State

```
/cks:bootstrap → loads skills/cicd-starter/SKILL.md into main context → runs 8 steps inline
```

- Zero dedicated agents
- 8-step process runs entirely in main conversation
- Command says: `Load the skill from ${CLAUDE_PLUGIN_ROOT}/skills/cicd-starter/SKILL.md`

### New Architecture

```
/cks:bootstrap (command = thin orchestrator)
    │
    ├── Read .prd/PRD-STATE.md (re-run detection)
    │
    ├── Phase 1: Dispatch bootstrap-scanner agent
    │   ├── skills: cicd-starter
    │   ├── Scans codebase, detects stack/framework/patterns
    │   ├── Asks guided questions via AskUserQuestion (pre-filled from scan)
    │   └── Writes: .bootstrap/scan-context.md
    │
    └── Phase 2: Dispatch bootstrap-generator agent
        ├── skills: cicd-starter, language-rules, guardrails
        ├── Reads scan-context.md + kickstart artifacts (if exist)
        ├── Generates: CLAUDE.md, .prd/, .context/, .claude/rules/, MCP config, deploy config
        └── Writes: all output files
```

### New Agents

#### bootstrap-scanner

```yaml
---
name: bootstrap-scanner
subagent_type: bootstrap-scanner
description: "Bootstrap Phase 1 — scans codebase, detects stack, runs guided intake with pre-filled answers from scan results."
skills:
  - cicd-starter
tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
  - "mcp__*"
color: blue
---
```

**Model:** Default (opus) — needs reasoning to interpret diverse codebases and ask smart follow-up questions.

**Responsibilities:**
- Scan codebase: detect languages, frameworks, test runners, DB clients, auth patterns, API routes
- Pre-fill answers from scan results
- Ask guided questions via AskUserQuestion (confirm detections, fill gaps)
- Read kickstart artifacts if they exist (`.kickstart/context.md`, `.kickstart/artifacts/ARCHITECTURE.md`)
- Write `.bootstrap/scan-context.md` with all findings

**Progressive disclosure:** Reads workflow steps from `${CLAUDE_PLUGIN_ROOT}/skills/cicd-starter/assets/` for scan patterns and intake questions.

#### bootstrap-generator

```yaml
---
name: bootstrap-generator
subagent_type: bootstrap-generator
description: "Bootstrap Phase 2 — generates CLAUDE.md, .prd/, .claude/rules/, .context/, MCP config, and deploy config from scan context and kickstart artifacts."
skills:
  - cicd-starter
  - language-rules
  - guardrails
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

**Model:** Sonnet — mechanical file generation from templates. Loads 3 skills for the knowledge needed to generate rules.

**Responsibilities:**
- Read `.bootstrap/scan-context.md` + kickstart artifacts (if exist)
- Generate `CLAUDE.md` from template (`references/claude-md-template.md`)
- Initialize `.prd/PRD-STATE.md`, `PRD-PROJECT.md`, `PRD-ROADMAP.md`
- Import feature roadmap from `.kickstart/artifacts/FEATURE-ROADMAP.md` (if exists)
- Research stack technologies via `Skill(skill="cks:context", args="{technology}")`
- Generate `.claude/rules/` files (language rules from `language-rules` skill + domain guardrails from `guardrails` skill)
- Configure MCP servers (`.mcp.json` or project-level config)
- Set up deploy config (Railway/Vercel based on detected platform)

### Command Rewrite

```markdown
---
description: "Scaffold project — .claude/, CLAUDE.md, .prd/, rules, deploy config"
argument-hint: "[--update]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:bootstrap

Orchestrate project bootstrapping by dispatching phase agents.

## Re-run Detection

Read `CLAUDE.md` and `.prd/PRD-STATE.md`:
- Both exist → ask: "Project already bootstrapped. Update, regenerate, or cancel?"
  - Update (--update flag): dispatch bootstrap-scanner with update mode
  - Regenerate: archive and start fresh
  - Cancel: exit
- Neither exists → fresh run

## Phase Execution

### Phase 1: Scan & Intake

```
Agent(subagent_type="bootstrap-scanner", prompt="Scan the codebase and run guided intake. Read kickstart artifacts from .kickstart/ if they exist. Write scan results to .bootstrap/scan-context.md. Arguments: $ARGUMENTS")
```

### Phase 2: Generate

```
Agent(subagent_type="bootstrap-generator", prompt="Generate all bootstrap outputs from .bootstrap/scan-context.md. Read kickstart artifacts from .kickstart/ if they exist. Generate: CLAUDE.md, .prd/, .context/, .claude/rules/, MCP config, deploy config.")
```

### Completion

Verify CLAUDE.md exists with project-specific content (no template placeholders).
Display summary of generated files.
```

### .bootstrap/ Directory Lifecycle

`.bootstrap/scan-context.md` is an intermediate artifact produced by bootstrap-scanner and consumed by bootstrap-generator. After successful completion:
- Keep `.bootstrap/` — it serves as a record of what was detected and answered during bootstrap
- Add `.bootstrap/` to the re-run detection: if `.bootstrap/scan-context.md` exists but `CLAUDE.md` does not, offer to resume from Phase 2 (generator) without re-scanning

### Skill Changes

`skills/cicd-starter/SKILL.md` — already 51 lines of expertise. Minimal changes needed:
- Remove the "Read and execute: `workflows/bootstrap.md`" line (agents handle this via progressive disclosure)
- Add phase map showing the 2 agents
- Keep everything else (it's already expertise, not process script)

---

## Part 2: Monetize Refactor

### Current State

```
/cks:monetize → loads SKILL.md via @${CLAUDE_PLUGIN_ROOT}/skills/monetize/SKILL.md → follows flow → dispatches agents
```

- 6 agents already exist (monetize-discoverer, monetize-researcher, cost-researcher, cost-analyzer, monetize-evaluator, monetize-reporter)
- BUT command loads SKILL.md into main context first
- AND 5 of 6 agents missing `skills:` field
- 6 sub-commands also load SKILL.md

### New Architecture

```
/cks:monetize (command = thin orchestrator)
    │
    ├── Detect mode (self-analyze / target / description)
    ├── Re-run check (.monetize/ exists?)
    │
    ├── Phase 1: Dispatch monetize-discoverer (skills: monetize)
    ├── Phase 2: Dispatch monetize-researcher (skills: monetize)
    ├── Phase 3a: Dispatch cost-researcher (skills: monetize)
    ├── Phase 3b: Dispatch cost-analyzer (skills: monetize)
    ├── Phase 4: Dispatch monetize-evaluator (skills: monetize)
    ├── Phase 5: Dispatch monetize-reporter (skills: monetize)
    └── Phase 6: Roadmap generation (inline — small, writes .monetize/phases/)
```

### Agent Changes (add skills: field to 5 agents)

| Agent | Add | Current model | Change model? |
|-------|-----|--------------|---------------|
| `monetize-discoverer` | Already has `skills: monetize` | default | No |
| `monetize-researcher` | `skills: monetize` | sonnet | No |
| `cost-researcher` | `skills: monetize` | sonnet | No |
| `cost-analyzer` | `skills: monetize` | default | No |
| `monetize-evaluator` | `skills: monetize` | default | Keep default (opus) — evaluator does strategic reasoning (compliance gating, stack composition, assumption chains) |
| `monetize-reporter` | `skills: monetize` | default | Add `model: sonnet` — template-following |

**Note on monetize-evaluator:** The current agent has no model set. Looking at its role (scoring 12 models against criteria from `references/models-catalog.md`), this is structured evaluation — sonnet with the catalog loaded via skill is sufficient. Changed from default → sonnet.

**Note on monetize-reporter:** Same logic — combines artifacts into a report using a template. Sonnet is sufficient.

### Command Rewrite — /cks:monetize

```markdown
---
description: "Run full monetization evaluation: discover → research → cost → evaluate → report → roadmap"
argument-hint: "[path | \"description\"] (optional)"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:monetize

Orchestrate the full monetization evaluation by dispatching agents in sequence.

## Mode Detection

Parse `$ARGUMENTS`:
- No arguments → Mode A (self-analyze current project)
- Local path → Mode B (analyze target project)
- Quoted text → Mode C (business description, no code)

## Re-run Check

Read `.monetize/context.md`. If exists:
  Ask: "Previous assessment found. Archive and start fresh, or update?"
  - Archive: `mkdir -p .monetize/archive/$(date +%Y%m%d) && mv .monetize/*.md .monetize/archive/$(date +%Y%m%d)/`
  - Update: skip discover, re-run from research

## Phase Execution

### Phase 1: Discover
Agent(subagent_type="monetize-discoverer", prompt="Gather business context. Mode: {mode}. Arguments: $ARGUMENTS. Write to .monetize/context.md.")

### Phase 2: Research
Agent(subagent_type="monetize-researcher", prompt="Research market for this project. Read .monetize/context.md. Write to .monetize/research.md.")

### Phase 3a: Cost Research
Agent(subagent_type="cost-researcher", prompt="Research tech stack costs. Read .monetize/context.md. Write to .monetize/cost-research-raw.md.")

### Phase 3b: Cost Analysis
Agent(subagent_type="cost-analyzer", prompt="Build unit economics from cost research. Read .monetize/cost-research-raw.md and .monetize/context.md. Write to .monetize/cost-analysis.md.")

### Phase 4: Evaluate
Agent(subagent_type="monetize-evaluator", prompt="Score monetization models. Read .monetize/context.md, research.md, cost-analysis.md. Write to .monetize/evaluation.md.")

### Phase 5: Report
Agent(subagent_type="monetize-reporter", prompt="Generate business case report. Read .monetize/evaluation.md and all .monetize/ artifacts. Write to docs/monetization-assessment.md.")

### Phase 6: Roadmap
Read .monetize/evaluation.md. Create phase briefs in .monetize/phases/. Update PRD-ROADMAP.md if it exists.

### Completion
Display summary with recommended model, revenue projection, and next steps.
```

### Sub-Command Rewrites (6 commands)

Each sub-command becomes a single-agent dispatcher:

**commands/monetize-discover.md:**
```markdown
---
description: "Monetization discovery — gather business context"
allowed-tools: [Read, Agent, AskUserQuestion]
---
Agent(subagent_type="monetize-discoverer", prompt="Gather business context. $ARGUMENTS. Write to .monetize/context.md.")
```

**commands/monetize-research.md:**
```markdown
---
description: "Monetization market research"
allowed-tools: [Read, Agent]
---
Agent(subagent_type="monetize-researcher", prompt="Research market. Read .monetize/context.md. Write to .monetize/research.md.")
```

**commands/monetize-cost-analysis.md:**
```markdown
---
description: "Monetization cost analysis — tech stack costs and unit economics"
allowed-tools: [Read, Agent]
---
Dispatch cost-researcher then cost-analyzer in sequence. Read .monetize/context.md for input.
```

**commands/monetize-evaluate.md:**
```markdown
---
description: "Monetization model evaluation"
allowed-tools: [Read, Agent]
---
Agent(subagent_type="monetize-evaluator", prompt="Score models. Read all .monetize/ artifacts. Write to .monetize/evaluation.md.")
```

**commands/monetize-report.md:**
```markdown
---
description: "Generate monetization assessment report"
allowed-tools: [Read, Agent]
---
Agent(subagent_type="monetize-reporter", prompt="Generate report. Read all .monetize/ artifacts. Write to docs/monetization-assessment.md.")
```

**commands/monetize-roadmap.md:**
```markdown
---
description: "Generate monetization roadmap and PRD handoff"
allowed-tools: [Read, Write]
---
Read .monetize/evaluation.md. Create phase briefs. Update PRD-ROADMAP.md.
```

### Skill Changes

`skills/monetize/SKILL.md` — already 135 lines, mostly expertise. Changes:
- Remove "Read the SKILL.md and execute the full flow" pattern from command references
- The "Full Flow Execution" section (lines 66-78) describes the dispatch sequence — this moves to the command. SKILL.md keeps the phase map table and expertise.
- Keep everything else (mode detection rules, re-run check logic, phase validation, reference files, error handling, customization)

---

## Files Summary

### Files to Create (2)

| File | Purpose |
|------|---------|
| `agents/bootstrap-scanner.md` | Bootstrap Phase 1 — scan + intake |
| `agents/bootstrap-generator.md` | Bootstrap Phase 2 — generate all files |

### Files to Modify (15)

| File | Change |
|------|--------|
| `commands/bootstrap.md` | Rewrite as thin orchestrator |
| `commands/monetize.md` | Rewrite as thin orchestrator |
| `commands/monetize-discover.md` | Rewrite as single-agent dispatcher |
| `commands/monetize-research.md` | Rewrite as single-agent dispatcher |
| `commands/monetize-cost-analysis.md` | Rewrite as single-agent dispatcher |
| `commands/monetize-evaluate.md` | Rewrite as single-agent dispatcher |
| `commands/monetize-report.md` | Rewrite as single-agent dispatcher |
| `commands/monetize-roadmap.md` | Rewrite as thin dispatcher |
| `skills/cicd-starter/SKILL.md` | Minor: add phase map, remove execution line |
| `skills/monetize/SKILL.md` | Remove orchestration logic, keep expertise |
| `agents/monetize-researcher.md` | Add `skills: monetize` |
| `agents/cost-researcher.md` | Add `skills: monetize` |
| `agents/cost-analyzer.md` | Add `skills: monetize` |
| `agents/monetize-evaluator.md` | Add `skills: monetize` (keep default model — strategic reasoning) |
| `agents/monetize-reporter.md` | Add `skills: monetize` + `model: sonnet` |

### Files Unchanged

All workflow files in `skills/cicd-starter/` and `skills/monetize/workflows/` — already progressive disclosure.
All reference files — unchanged.
Existing monetize agents' system prompts — unchanged (they already describe their roles correctly).

## Verification

1. `/cks:bootstrap` dispatches bootstrap-scanner then bootstrap-generator (not loading SKILL.md)
2. `/cks:monetize "test business"` dispatches 6 agents in sequence (not loading SKILL.md)
3. `/cks:monetize-discover` dispatches monetize-discoverer directly
4. All 8 monetize agents have `skills:` field
5. Both bootstrap agents have `skills:` field
6. Commands have minimal `allowed-tools` (Read, Agent, AskUserQuestion only)
7. SubagentStop hook logs completions (already works from kickstart refactor)
