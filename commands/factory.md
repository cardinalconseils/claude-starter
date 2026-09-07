---
description: "AFK software factory — pull labeled GitHub Issues and run the full lifecycle pipeline for each one autonomously"
argument-hint: "[--label cks:factory] [--dry-run] [--limit N] [--auto]"
allowed-tools:
  - Read
  - Skill
---

# /cks:factory — AFK Software Factory

Pull labeled GitHub Issues from the backlog and run the full CKS sprint pipeline for each
one autonomously.

## Dispatch

This is an Orchestrator Exception command (`.claude/rules/commands.md`): each issue runs
the attractor pipeline, which dispatches roles, so the factory loads as a top-level skill.

```
Skill(skill="cks:github-issues")
```

Arguments: `$ARGUMENTS`. The skill's `SKILL-ORCHESTRATOR.md` fetches the queue, confirms
once, seeds a `CONTEXT.md` per issue, loads `Skill(skill="cks:attractor")` with `--auto`
for each, comments the PR back on the issue, and clears the label.

## Quick Reference

Default label filter: `cks:factory` (opt-in) and `cks:backlog` (punted scope)

```
/cks:factory                      Pick up all cks:factory + cks:backlog issues
/cks:factory --label cks:factory  Only pick up cks:factory issues
/cks:factory --dry-run            List matching issues, don't implement
/cks:factory --limit 3            Process at most 3 issues (oldest first)
/cks:factory --auto               Skip the one-time confirmation
```

## When to Use

- You have a backlog of known issues or enhancements from previous sprints
- You want Claude to drain the queue while you're AFK
- After a sprint-close, to implement the `cks:backlog` punts from that session
