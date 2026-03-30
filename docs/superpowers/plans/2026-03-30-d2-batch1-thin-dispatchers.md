# D-2 Batch 1: Fat Command → Thin Dispatcher Conversion

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert 7 fat commands into thin dispatchers that route to existing agents, following the pattern established in D-1.

**Architecture:** Each command becomes a ~30-45 line orchestrator that: (1) parses arguments, (2) reads minimal state if needed, (3) dispatches the matching agent with a well-crafted prompt. All domain knowledge lives in the agent (via `skills:` frontmatter), not in the command.

**Tech Stack:** Claude Code plugin (markdown commands, YAML frontmatter agents)

---

## Chunk 1: Commands with Existing Agents (6 commands)

### Pattern Reference (from D-1)

The thin dispatcher pattern established by `discover.md`:
```yaml
---
description: "..."
argument-hint: "..."
allowed-tools:    # MINIMAL — only what the command itself uses
  - Read          # for state/context reads
  - Agent         # for dispatching
  - AskUserQuestion  # only if command itself asks (not agent)
---
```

Body structure:
1. One-line dispatch instruction
2. Agent() call with subagent_type + detailed prompt
3. Quick Reference section (what it does, argument handling)
4. NO inline workflow steps, report formats, or domain knowledge

**Key rule:** `allowed-tools` lists what the COMMAND needs, not what the agent needs. Agents declare their own tools in their frontmatter.

---

### Task 1: Thin `debug.md` (117 → ~40 lines)

**Files:**
- Modify: `commands/debug.md`

**Current anti-patterns:**
- Loads Skill inline (`Skill(skill="debug")`) — agent already has `skills: debug`
- Inline report format template (Steps 4) — agent owns output format
- Inline AskUserQuestion flow (Step 5) — agent has AskUserQuestion tool
- Inline logging command (Step 6) — should be in agent or hook
- `allowed-tools` includes Write, Edit, Skill — command doesn't use these

- [ ] **Step 1: Rewrite `commands/debug.md`**

```markdown
---
description: "Debug anything — trace app runtime errors or diagnose CKS skill/agent/command issues"
argument-hint: "[error message] [--cks [phase|command|agent]] or no arg for exploratory mode"
allowed-tools:
  - Read
  - Agent
---

# /cks:debug — Unified Debugger

Dispatch the **debugger** agent (which has `skills: debug` loaded at startup).

## Mode Detection

Parse `$ARGUMENTS` to determine mode, then dispatch:

| Pattern | Mode |
|---------|------|
| `--cks` present | `cks-self` — CKS plugin introspection |
| Error string (no `--cks`) | `app-error` — trace a specific error |
| No args | `app-exploratory` — ask what's wrong |

## Dispatch

```
Agent(subagent_type="debugger", prompt="Mode: {detected mode}. Context: {error message, or 'exploratory', or CKS component from --cks arg}. Project root: {cwd}. Arguments: $ARGUMENTS. Diagnose the issue, present a structured report, and ask before applying any fix.")
```

## Quick Reference

```
/cks:debug                              → Exploratory: ask what's wrong
/cks:debug "TypeError: cannot read..."  → Error-driven: trace a specific error
/cks:debug --cks                        → CKS self-debug: why did CKS just do that?
/cks:debug --cks discover               → CKS self-debug: specific phase/command
```

The debugger agent handles: diagnosis, evidence collection, report formatting, fix proposals, and user confirmation before applying changes.
```

- [ ] **Step 2: Verify agent has required capabilities**

Read `agents/debugger.md` frontmatter and confirm:
- `skills: debug` ✓ (already set)
- `tools` includes: Read, Bash, Glob, Grep, AskUserQuestion ✓
- Agent body handles report format, fix confirmation, logging ✓

No agent changes needed.

- [ ] **Step 3: Commit**

```bash
git add commands/debug.md
git commit -m "refactor(debug): thin dispatcher — delegate to debugger agent

Removes inline report format, Skill loading, AskUserQuestion flow, and
logging from command. Agent already has skills: debug and handles all of this.
allowed-tools: 9 → 2."
```

---

### Task 2: Thin `docs.md` (105 → ~35 lines)

**Files:**
- Modify: `commands/docs.md`

**Current anti-patterns:**
- Inline scope detection logic (Step 2) — agent handles this
- Inline output structure template — agent owns this
- `allowed-tools` includes Write, Edit, Bash, Skill — command doesn't use these

- [ ] **Step 1: Rewrite `commands/docs.md`**

```markdown
---
description: "Generate or update project documentation — API docs, architecture, component docs, onboarding guide"
argument-hint: "[api | arch | components | onboarding | all | --diff]"
allowed-tools:
  - Read
  - Agent
---

# /cks:docs — Documentation Generator

Dispatch the **doc-generator** agent (which has `skills: api-docs` loaded at startup).

## Dispatch

Read `CLAUDE.md` and `.prd/PRD-STATE.md` (if they exist) for project context, then:

```
Agent(subagent_type="doc-generator", prompt="Generate project documentation. Scope: {$ARGUMENTS or 'all'}. Project root: {cwd}. Read CLAUDE.md for project conventions. Read .prd/PRD-STATE.md for current phase context. Detect existing docs in docs/. Arguments: $ARGUMENTS")
```

## Quick Reference

```
/cks:docs              → Generate/refresh all documentation types
/cks:docs api          → API endpoint documentation only
/cks:docs arch         → Architecture documentation only
/cks:docs components   → Component/module documentation only
/cks:docs onboarding   → Developer onboarding guide only
/cks:docs --diff       → Only document new/changed code since last tag
```

The doc-generator agent handles: scope detection, codebase scanning, generation of API/architecture/component/onboarding docs, staleness detection, and output to `docs/`.
```

- [ ] **Step 2: Verify agent has required capabilities**

Read `agents/doc-generator.md` frontmatter and confirm:
- `skills: api-docs` ✓
- `tools` includes: Read, Write, Glob, Grep, Bash ✓
- Agent body handles scope detection, scanning, generation, staleness ✓

No agent changes needed.

- [ ] **Step 3: Commit**

```bash
git add commands/docs.md
git commit -m "refactor(docs): thin dispatcher — delegate to doc-generator agent

Removes inline scope detection, output templates, and 'When to Run' section.
Agent already has skills: api-docs and handles all generation.
allowed-tools: 9 → 2."
```

---

### Task 3: Thin `security.md` (139 → ~40 lines)

**Files:**
- Modify: `commands/security.md`

**Current anti-patterns:**
- Massive inline OWASP table (duplicated in agent)
- Inline framework-specific checks (duplicated in agent)
- Inline dependency audit commands (duplicated in agent)
- Inline report format (duplicated in agent)
- `allowed-tools` includes TodoWrite — command doesn't use this

- [ ] **Step 1: Rewrite `commands/security.md`**

```markdown
---
description: "Security scan — audit app code AND pipeline config for vulnerabilities"
argument-hint: "[--app | --config | --full]"
allowed-tools:
  - Read
  - Agent
---

# /cks:security — Security Audit

Dispatch the **security-auditor** agent (which has `skills: prd` loaded at startup).

## Mode Detection

Parse `$ARGUMENTS`:

| Argument | Scan Mode |
|----------|-----------|
| `--app` | App code only (OWASP, secrets, dependencies) |
| `--config` | Claude/CKS config only (CLAUDE.md, hooks, MCP, .env) |
| `--full` or no args | Full scan (app + config + dependencies) |

## Dispatch

```
Agent(subagent_type="security-auditor", prompt="Run a {detected mode} security audit. Project root: {cwd}. Scan for OWASP Top 10, secrets, dependency vulnerabilities, and config issues. Present a graded report (A-F) and ask before applying any fixes. Arguments: $ARGUMENTS")
```

## Quick Reference

```
/cks:security              → Full scan (app + config + dependencies)
/cks:security --app        → App code only
/cks:security --config     → Claude/CKS config only
```

The security-auditor agent handles: OWASP scanning, secrets detection, framework-specific checks, dependency audit, config audit, graded reporting, and fix proposals with user confirmation.
```

- [ ] **Step 2: Verify agent has required capabilities**

Read `agents/security-auditor.md` frontmatter and confirm:
- `skills: prd` ✓
- `tools` includes: Read, Glob, Grep, Bash, AskUserQuestion, mcp__* ✓
- Agent body handles OWASP scanning, secrets, dependencies, config, grading ✓

No agent changes needed.

- [ ] **Step 3: Commit**

```bash
git add commands/security.md
git commit -m "refactor(security): thin dispatcher — delegate to security-auditor agent

Removes inline OWASP table, framework checks, dependency commands, and
report template. All duplicated in security-auditor agent.
allowed-tools: 7 → 2."
```

---

### Task 4: Thin `refactor.md` (48 → ~30 lines)

**Files:**
- Modify: `commands/refactor.md`

**Current anti-patterns:**
- Loads workflow file inline: `${CLAUDE_PLUGIN_ROOT}/skills/prd/workflows/refactor.md`
- `allowed-tools` includes Write, Edit, Bash, Skill, TodoRead, TodoWrite, mcp__* — command doesn't use these

- [ ] **Step 1: Rewrite `commands/refactor.md`**

```markdown
---
description: "Refactor a feature, layout, component, or pattern with safety checks and verification"
argument-hint: "<target> [--type layout|component|data-flow|api|pattern|performance]"
allowed-tools:
  - Read
  - Agent
---

# /cks:refactor — Safe Refactoring

Dispatch the **prd-refactorer** agent (which has `skills: prd` loaded at startup).

## Dispatch

```
Agent(subagent_type="prd-refactorer", prompt="Refactor: $ARGUMENTS. Read .prd/PRD-STATE.md for current phase context. Analyze impact, design a step-by-step plan, execute with build checks, and verify behavior is preserved. Arguments: $ARGUMENTS")
```

## Quick Reference

**Target required:** file path, component name, or description of what to refactor.

```
/cks:refactor ProcessFlow.tsx --type component
/cks:refactor "sidebar layout" --type layout
/cks:refactor "icon rendering across all node types" --type pattern
/cks:refactor BpmnNodes.tsx --type performance
```

The prd-refactorer agent handles: impact analysis, step-by-step planning, parallel worker dispatch, build checks, and behavior verification.
```

- [ ] **Step 2: Verify agent has required capabilities**

Read `agents/prd-refactorer.md` frontmatter and confirm:
- `skills: prd` ✓
- `tools` includes: Read, Write, Edit, Bash, Glob, Grep, Agent, AskUserQuestion, TodoRead, TodoWrite ✓
- Agent body handles impact analysis, planning, worker dispatch, verification ✓

No agent changes needed.

- [ ] **Step 3: Commit**

```bash
git add commands/refactor.md
git commit -m "refactor(refactor): thin dispatcher — delegate to prd-refactorer agent

Removes inline SKILL.md loading and workflow reference.
Agent already has skills: prd with refactor workflow as progressive disclosure.
allowed-tools: 12 → 2."
```

---

### Task 5: Thin `research.md` (64 → ~35 lines)

**Files:**
- Modify: `commands/research.md`

**Current anti-patterns:**
- Loads SKILL.md inline: `${CLAUDE_PLUGIN_ROOT}/skills/deep-research/SKILL.md`
- `allowed-tools` includes Write, Bash, WebSearch, WebFetch, Skill, mcp__* — command doesn't use these

- [ ] **Step 1: Rewrite `commands/research.md`**

```markdown
---
description: "Deep multi-hop research on any topic — recursive investigation with configurable sources"
argument-hint: '"topic" [--depth shallow|medium|deep] [--competitive] [--eval] [--refresh]'
allowed-tools:
  - Read
  - Agent
---

# /cks:research — Deep Multi-Hop Research

Dispatch the **deep-researcher** agent (which has `skills: deep-research` loaded at startup).

## Dispatch

```
Agent(subagent_type="deep-researcher", prompt="Research topic: $ARGUMENTS. Recursively investigate across available sources. Discover sub-topics, cross-reference findings, and produce a structured report with confidence scores. Save output to .research/{topic-slug}/. Arguments: $ARGUMENTS")
```

## Quick Reference

```
/cks:research "Next.js App Router patterns"
/cks:research --competitive "AI code review tools"
/cks:research --eval "Supabase vs Firebase vs PlanetScale"
/cks:research "topic" --depth deep
/cks:research "topic" --refresh
```

| Flag | Mode | Output |
|------|------|--------|
| (none) | Topic research | Report + sources |
| `--competitive` | Competitor analysis | Report + matrix |
| `--eval` | Tech evaluation | Scored matrix |
| `--depth` | Override depth | shallow=1 hop, medium=2, deep=3+ |
| `--refresh` | Force re-research | Archives old, runs fresh |

## vs /cks:context

| | /cks:context | /cks:research |
|---|---|---|
| **Purpose** | Quick coding reference | Strategic intelligence |
| **Depth** | Single-hop | Multi-hop recursive |
| **Output** | `.context/{slug}.md` | `.research/{slug}/report.md` |
```

- [ ] **Step 2: Verify agent has required capabilities**

Read `agents/deep-researcher.md` frontmatter and confirm:
- `skills: deep-research` ✓
- `tools` includes: Read, Write, Bash, Glob, Grep, WebSearch, WebFetch, Agent, mcp__* ✓
- Agent body handles recursive multi-hop research, source discovery, report generation ✓

No agent changes needed.

- [ ] **Step 3: Commit**

```bash
git add commands/research.md
git commit -m "refactor(research): thin dispatcher — delegate to deep-researcher agent

Removes inline SKILL.md loading. Agent already has skills: deep-research.
Keeps comparison table as useful quick-reference for users.
allowed-tools: 11 → 2."
```

---

### Task 6: Thin `retro.md` + Create retrospective agent (50 → ~30 lines + new agent)

**Files:**
- Create: `agents/retrospective.md`
- Modify: `commands/retro.md`

**Current anti-patterns:**
- Loads SKILL.md inline: `${CLAUDE_PLUGIN_ROOT}/skills/retrospective/SKILL.md`
- No matching agent exists — needs creation
- `allowed-tools` includes Write, Edit, Bash — command doesn't use these

- [ ] **Step 1: Check what the retrospective skill contains**

Read `skills/retrospective/SKILL.md` to understand what the agent needs to handle.

- [ ] **Step 2: Create `agents/retrospective.md`**

```markdown
---
name: retrospective
description: >
  Post-ship learning analyst — analyzes completed work to extract conventions,
  patterns, gotchas, and velocity metrics. Proposes CLAUDE.md updates based on
  high-confidence findings. Creates compound improvement across development cycles.
subagent_type: retrospective
tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - WebFetch
  - AskUserQuestion
  - "mcp__*"
model: sonnet
color: yellow
skills:
  - retrospective
---

# Retrospective Agent

You are a learning analyst. Your job is to extract actionable insights from completed work cycles and propose improvements that compound over time.

## Your Mission

Analyze recent work (git history, lifecycle logs, PRD state) and produce learnings that improve future cycles. Three modes: interactive, auto, and metrics.

## Modes

### Interactive (default, no flags)

1. Read recent git log, lifecycle.jsonl, and PRD state
2. Ask reflection questions via AskUserQuestion:
   - "What went well?"
   - "What was harder than expected?"
   - "What would you do differently?"
3. Cross-reference answers against code changes
4. Generate convention proposals for CLAUDE.md
5. Present proposals for user approval (never auto-edit CLAUDE.md)
6. Save to `.learnings/`

### Auto (`--auto`)

1. Read same sources as interactive — NO user questions
2. Extract patterns: repeated code patterns, common commit prefixes, recurring file changes
3. Generate proposals silently
4. Save to `.learnings/` for later review

### Metrics (`--metrics`)

1. Compute velocity metrics from git history + lifecycle logs
2. Display dashboard: commits/day, phase durations, iteration counts
3. Save to `.learnings/metrics.md`

## Output

All learnings saved to `.learnings/`:
- `session-log.md` — Append-only retro history
- `conventions.md` — Proposed and applied CLAUDE.md rules
- `gotchas.md` — Project-specific pitfalls
- `metrics.md` — Velocity tracking with trends

## Constraints

- **Never auto-edit CLAUDE.md** — only propose, user approves
- **Evidence-based** — every proposal cites a specific commit, log entry, or pattern
- **Compound improvement** — reference previous retros to track trend
```

- [ ] **Step 3: Rewrite `commands/retro.md`**

```markdown
---
description: "Run a retrospective — analyze what worked, extract learnings, propose CLAUDE.md updates"
argument-hint: "[--auto] [--metrics] or no args for interactive"
allowed-tools:
  - Read
  - Agent
---

# /cks:retro — Retrospective & Learning

Dispatch the **retrospective** agent (which has `skills: retrospective` loaded at startup).

## Dispatch

```
Agent(subagent_type="retrospective", prompt="Run a retrospective. Mode: {interactive if no flags, auto if --auto, metrics if --metrics}. Read recent git log, .prd/ state, and .prd/logs/lifecycle.jsonl. Extract learnings and save to .learnings/. Arguments: $ARGUMENTS")
```

## Quick Reference

```
/cks:retro               → Interactive — guided reflection + review proposals
/cks:retro --auto        → Auto — lightweight post-ship analysis (no interaction)
/cks:retro --metrics     → Metrics — show velocity dashboard
```

The retrospective agent handles: git/log analysis, reflection Q&A (interactive mode), convention extraction, CLAUDE.md proposals (never auto-edits), and `.learnings/` output.
```

- [ ] **Step 4: Commit**

```bash
git add agents/retrospective.md commands/retro.md
git commit -m "refactor(retro): create retrospective agent + thin dispatcher

New agent: retrospective (skills: retrospective, model: sonnet).
Command no longer loads SKILL.md inline.
allowed-tools: 8 → 2."
```

---

## Chunk 2: Verify Bootstrap (already near-thin)

### Task 7: Verify `bootstrap.md` is already compliant

**Files:**
- Verify: `commands/bootstrap.md` (no changes expected)

`bootstrap.md` was already rewritten as a thin dispatcher (52 lines, dispatches bootstrap-scanner + bootstrap-generator). Verify it follows the pattern.

- [ ] **Step 1: Audit `bootstrap.md` against the thin pattern**

Check:
- `allowed-tools` minimal: Read, Agent, AskUserQuestion ✓
- No inline workflow logic ✓
- No `${CLAUDE_PLUGIN_ROOT}` references ✓
- No Skill loading ✓
- Dispatches to agents with skills loaded at startup ✓

Expected: No changes needed. If compliant, skip to final commit.

---

## Chunk 3: Final Verification + Batch Commit

### Task 8: Verify all conversions and create branch PR

- [ ] **Step 1: Verify line counts**

Run `wc -l` on all 7 commands. Expected:
- `debug.md` ≤ 45 lines
- `docs.md` ≤ 40 lines
- `security.md` ≤ 45 lines
- `refactor.md` ≤ 35 lines
- `research.md` ≤ 45 lines
- `retro.md` ≤ 35 lines
- `bootstrap.md` unchanged (~52 lines)

- [ ] **Step 2: Verify no `${CLAUDE_PLUGIN_ROOT}/skills/` references remain**

```bash
grep -r 'CLAUDE_PLUGIN_ROOT.*skills/' commands/debug.md commands/docs.md commands/security.md commands/refactor.md commands/research.md commands/retro.md
```

Expected: No matches.

- [ ] **Step 3: Verify no `Skill(skill=` calls remain in converted commands**

```bash
grep -r 'Skill(skill=' commands/debug.md commands/docs.md commands/security.md commands/refactor.md commands/research.md commands/retro.md
```

Expected: No matches.

- [ ] **Step 4: Verify `allowed-tools` is minimal (≤3 tools) in each converted command**

Check each command's frontmatter — should only list tools the command itself uses (Read, Agent, AskUserQuestion at most).

- [ ] **Step 5: Verify new retrospective agent is well-formed**

Check `agents/retrospective.md`:
- Has `skills: retrospective` in frontmatter
- Has `subagent_type: retrospective`
- Has appropriate `tools` list
- Has `model: sonnet`

- [ ] **Step 6: Create PR branch and push**

```bash
git checkout -b refactor/d2-batch1-thin-dispatchers
git push -u origin refactor/d2-batch1-thin-dispatchers
gh pr create --title "refactor: D-2 batch 1 — thin dispatchers for 6 commands + new retro agent"
```
