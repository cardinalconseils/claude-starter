---
name: plugin-dev
domain: Plugin Dev
description: "Plugin Dev skill for CKS — Claude Code Starter Kit — defines how Claude executes recurring Plugin Dev tasks"
---

# Plugin Dev — Skill

## Purpose

Covers all work to extend and maintain the CKS plugin: adding commands, wiring agents, debugging hooks, writing skills, and driving development test-first.

## Recurring Tasks

### Task: Add command

**When**: User requests a new `/cks:*` slash command or a command is missing from `commands/help.md`.

**Output**: `commands/{name}.md` with correct YAML frontmatter, thin dispatcher body, and Quick Reference section. `commands/README.md` count and table updated.

**Instructions**:
1. Read `commands/README.md` and an existing thin-dispatcher command for reference pattern
2. Create `commands/{name}.md` — YAML frontmatter with `description` and `allowed-tools` (only tools the command itself uses: Read, Agent, AskUserQuestion)
3. Write the body as a thin dispatcher: parse args, dispatch `Agent(subagent_type=...)`, show Quick Reference
4. Keep under 60 lines — if longer, logic belongs in an agent
5. Update `commands/README.md` count and table row
6. Update `commands/help.md` command list entry

**Quality bar**: Command dispatches an agent; contains no inline workflow logic; `allowed-tools` lists only command-level tools; under 60 lines.

---

### Task: Wire agent

**When**: A new agent is needed or an existing agent needs tools, skills, or prompt changes.

**Output**: `agents/{name}.md` with complete YAML frontmatter and system prompt body.

**Instructions**:
1. Read `agents/README.md` and one nearby agent for the frontmatter pattern
2. Create `agents/{name}.md` — frontmatter: `name`, `subagent_type`, `description`, `tools`, `model`, `color`, `skills`
3. Write the body as a system prompt (instructions to the agent, not documentation)
4. Declare all tools the agent needs — agents do not inherit parent tools
5. List all skills the agent loads — agents do not inherit parent skills
6. Use `model: sonnet` for mechanical tasks, `model: opus` for reasoning-heavy tasks

**Quality bar**: All frontmatter fields present; `subagent_type` matches `Agent(subagent_type=...)` call site; body is imperative instructions.

---

### Task: Debug hook

**When**: A SessionStart, PreToolUse, PostToolUse, or Stop hook is not firing, erroring, or blocking the user.

**Output**: Fixed handler script in `hooks/handlers/`. Root cause documented as a comment if non-obvious.

**Instructions**:
1. Read `hooks/hooks.json` to confirm the hook entry and script path
2. Read the handler script — check for `set -e`, unquoted variables, missing `2>/dev/null` on file checks
3. Reproduce the failure by reading the hook trigger conditions
4. Fix the root cause — never add `|| true` to silence an error without understanding it
5. Verify exit code is 0 on success path; verify non-zero only blocks when intended
6. Keep handler under 30 lines — complex logic belongs in `scripts/`

**Quality bar**: Hook fires without blocking unintended actions; exit 0 on happy path; no `set -e`; all variables quoted.

---

### Task: Write skill

**When**: An agent needs domain expertise that isn't captured yet, or an existing skill needs updating.

**Output**: `skills/{domain}/SKILL.md` with YAML frontmatter and domain knowledge sections.

**Instructions**:
1. Read an existing skill for structure reference (e.g. `skills/prd/SKILL.md`)
2. Create `skills/{domain}/SKILL.md` — frontmatter: `name`, `description`, `allowed-tools`
3. Write as domain expertise (WHAT to know), not step-by-step process (HOW to execute)
4. Keep under 300 lines — extract workflows to `skills/{domain}/workflows/`
5. Include `## Common Rationalizations` table and `## Verification` checklist

**Quality bar**: Under 300 lines; `description` is keyword-rich for auto-triggering; no sequential execution logic in SKILL.md body.

---

### Task: TDD

**When**: Implementing any feature or fix where a test can be written first.

**Output**: Passing test file + implementation. Test output shown as evidence.

**Instructions**:
1. Write the failing test first — describe the expected behavior, not the implementation
2. Run the test and confirm it fails for the right reason
3. Implement the minimum code to make it pass
4. Run the full test suite and show output
5. Refactor only if the test stays green

**Quality bar**: Test was failing before implementation; test passes after; full suite output shown inline.

---

## Context Sources

- `memory/wiki/` — architecture decisions, pattern references, past debugging notes
- `memory/raw/` — feature notes, issue descriptions, scratch context
- `CLAUDE.md` — project constraints and architecture pattern
- `.claude/rules/` — glob-scoped guardrails that govern this domain

## Output Destinations

- Finished commands/agents/skills/hooks → committed to branch, PR opened
- Architecture decisions → `memory/wiki/`
- Work in progress → `memory/raw/`
