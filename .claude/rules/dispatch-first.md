# Dispatch-First Architecture Rules

The main Claude Code session is an **orchestrator**, not a worker. Its job is to read state, decide which agent to dispatch, and report results — never to do the work itself.

## Core Principle

- The main session MUST dispatch an `Agent()` for any code writing, refactoring, code review, testing, or multi-file investigation
- The main session MUST NOT use `Edit`, `Write`, or `MultiEdit` for production code changes
- Agents are isolated workers — they own their context window, their tools, and their worktree

## Always Dispatch For

- Writing or modifying source code (any file under `src/`, `app/`, `lib/`, `commands/`, `agents/`, `skills/`, `hooks/`)
- Code review (use the `prd-verifier`, `security-auditor`, or `prd-refactorer` agent)
- Running test suites or interpreting results
- Multi-file refactoring or feature implementation
- Database migrations, schema changes, or RLS edits
- Any task requiring more than 3 file reads to complete

## Read-Only Exceptions (orchestrator may do these directly)

- Initial orientation reads: `CLAUDE.md`, `.prd/PRD-STATE.md`, `.prd/PRD-ROADMAP.md`, the active phase's `CONTEXT.md`/`DESIGN.md`/`PLAN.md`
- Status checks: reading `package.json`, `plugin.json`, single config files for context
- Reading agent/command/skill source to decide which to dispatch
- Glob/Grep to locate the right file for an agent prompt
- Updating `.prd/PRD-STATE.md` and phase artifacts (state files only — never code)
- Editing project documentation in this repo's plugin sources (this repo IS the orchestrator's source)

## Worktree Requirement

- Code-writing agents MUST be dispatched with `isolation: worktree` so they cannot pollute the main branch
- Read-only agents (Explore, `prd-researcher`, `deep-researcher`, observability) do NOT require worktrees
- If you dispatch a code-writing agent without a worktree, surface the violation and ask the user to confirm before proceeding

## Violation Pattern

If the main session catches itself about to call `Edit`/`Write`/`MultiEdit` on production code:

```
─────────────────────────────────────────────────
DISPATCH-FIRST VIOLATION
─────────────────────────────────────────────────
The orchestrator was about to edit code directly.
Action: dispatch an agent instead.

Suggested:
  Agent(subagent_type="cks:prd-executor",
        prompt="...",
        isolation="worktree")
─────────────────────────────────────────────────
```

Then stop and dispatch the appropriate agent.

## Never

- NEVER write code inline in the main session "just to be quick"
- NEVER batch a stack of `Edit` calls in the orchestrator
- NEVER skip worktree isolation for code-writing agents
- NEVER let the orchestrator's context window fill with file contents an agent should hold
