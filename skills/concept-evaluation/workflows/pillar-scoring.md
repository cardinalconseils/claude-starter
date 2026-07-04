# Pillar Scoring — Detailed Guide

Progressive disclosure reference for `concept-evaluation` pillar workers.
Read this when SKILL.md rubric tables need more depth.

## How to Score: The Evidence Protocol

For each pillar:
1. Run Glob/Grep to find files the concept would touch
2. Read CLAUDE.md to check philosophy/architecture fit
3. Map to the scoring table — match evidence to signal
4. State the score and the specific evidence that justified it

Never state a score without citing a file path, a command name, or a concrete observation.

## Pillar 1 — Business Value: Deeper Rubric

**Score 5 — Lifecycle Gap**
The feature is missing from the 5-phase lifecycle (Discover / Plan / Sprint / Review / Release) AND there is observable friction: users ask for it, workarounds are clunky, or a phase step currently has no tooling.
Evidence: show which phase is weak and what users do instead.

**Score 4 — Workflow Acceleration**
The concept shortens a repeated multi-step manual process. The time saved is estimable (e.g., "currently 4 manual steps → 1 command").
Evidence: trace the current steps in existing commands/agents.

**Score 3 — Friction Reduction**
The concept reduces friction but the current workaround works. Users would use it if it existed but aren't blocked.
Evidence: show the workaround and explain why it's suboptimal.

**Score 5 (replacement bonus) — Replaces a Weaker Concept**
The concept replaces an existing command/agent/skill with a clearly superior implementation — net neutral or net reduction in plugin surface area. Apply +0.5 on top of the base score (cap at 5).
Evidence: name the concept being replaced, show why the new one is superior, confirm the old one will be retired.

**Score 2 — Duplicate Capability**
The concept overlaps significantly with an existing command or agent. The delta is small. When the supersession decision was "Add-alongside" without strong justification, cap BV at 2 regardless of other signals.
Evidence: name the overlapping component and describe the delta. If supersession decision was Add-alongside, explain why coexistence is justified.

**Score 1 — No Demand Signal**
No existing command gap, no friction signal, no user request pattern. The concept solves a hypothetical problem.
Evidence: show the gap analysis came up empty.

## Pillar 2 — Technology Fit: Deeper Rubric

**Score 5 — Clean Pattern Fit**
The concept is a new Command + Agent + Skill combination that follows every existing convention:
- Command is a thin dispatcher (≤60 lines, no inline logic)
- Agent declares its own tools and skills
- Skill follows the SKILL.md format
- No new hook types, MCP servers, or tool definitions needed
Evidence: name the exact files to create and confirm they follow the pattern.

**Score 4 — Single Extension**
One new component type needed (a new agent, or a new skill directory) but it follows existing patterns. No architectural changes.
Evidence: name what's new and show it follows the pattern.

**Score 3 — Bounded Extension**
Requires a new hook event, a new workflow file, or a new rule file. These extend the system but don't change existing behavior.
Evidence: identify what changes and confirm it's additive only.

**Score 2 — External Dependency**
Requires a new MCP server, a new external API integration, or a new Claude Code tool type. Introduces a dependency that can fail independently.
Evidence: name the dependency, its reliability characteristics, and failure modes.

**Score 1 — Architectural Surgery**
The concept requires changing existing agents, commands, or hooks in ways that could break current behavior. Regression risk is high.
Evidence: name the files that would change and trace the regression path.

## Pillar 3 — Data Impact: Deeper Rubric

**Score 5 — Isolated Write**
Writes only to a new, isolated directory (e.g., `.concept/`) that no other command reads. Zero blast radius.
Evidence: confirm via Grep that no existing command reads the target directory.

**Score 4 — Additive State**
Writes to an existing directory (`.prd/`, `.assess/`) but only adds new files; never modifies or deletes existing ones.
Evidence: show the write pattern and confirm it's append-only.

**Score 3 — State Modification**
Modifies existing state files (PRD-STATE.md, phase artifacts). Requires migration notes so existing projects aren't broken.
Evidence: name the files, show the schema change, draft migration notes.

**Score 2 — Core File Touch**
Touches CLAUDE.md, plugin.json, hooks.json, or hook scripts. Any bug here affects every project using CKS.
Evidence: name what changes and describe the rollback path.

**Score 1 — Core State Rewrite**
Rewrites shared state that other commands depend on. High risk of regression across multiple commands.
Evidence: run Grep to find all consumers of the affected state and trace the impact.

## Decision Matrix

| Business | Tech Fit | Data Impact | Typical outcome |
|---|---|---|---|
| 5 | 5 | 5 | Go — strong candidate |
| 4 | 4 | 4 | Go — solid addition |
| 4 | 3 | 4 | Go — watch the hook/workflow addition |
| 3 | 5 | 5 | Defer — nice-to-have, low risk, add to backlog |
| 3 | 2 | 3 | Defer — external dependency makes it risky |
| 2 | 4 | 5 | Reject — not enough value to justify the work |
| 1 | * | * | Reject — no demand signal |
| * | 1 | * | Reject — architectural cost too high |
| * | * | 1 | Reject — blast radius too high |

## Evidence Source Quick Reference

| What you need | Where to look |
|---|---|
| Existing command gap | `commands/README.md`, `ls commands/` |
| Architecture pattern | `CLAUDE.md`, `.claude/rules/` |
| Agent tool list | `agents/{name}.md` frontmatter |
| Hook events | `hooks/hooks.json` |
| State file schema | `.prd/PRD-STATE.md` |
| Files concept would touch | `grep -r "{keyword}" commands/ agents/ skills/` |
| Plugin manifest | `.claude-plugin/plugin.json` |
