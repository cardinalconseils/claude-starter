---
name: retro
description: "Run a retrospective — analyze what worked, extract learnings, propose CLAUDE.md updates"
argument-hint: "[--auto] [--metrics] or no args for interactive"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Agent
  - AskUserQuestion
---

# /cks:retro — Retrospective & Learning

Load the skill from `.claude/skills/retrospective/SKILL.md` and follow it exactly.

## Quick Reference

Analyzes completed work to extract conventions, patterns, gotchas, and velocity metrics.
Every ship cycle makes the next one better.

```
/cks:retro               # Interactive — guided reflection + review proposals
/cks:retro --auto        # Auto — lightweight post-ship analysis (no interaction)
/cks:retro --metrics     # Metrics — show velocity dashboard
```

## Modes

| Flag | Mode | Interaction |
|------|------|-------------|
| (none) | Interactive | Asks reflection questions, reviews pending proposals |
| `--auto` | Auto | No interaction — gathers data, saves learnings |
| `--metrics` | Metrics | Display-only — shows velocity dashboard |

## Output

All learnings saved to `.learnings/`:
- `session-log.md` — Append-only retro history
- `conventions.md` — Proposed and applied CLAUDE.md rules
- `gotchas.md` — Project-specific pitfalls
- `metrics.md` — Velocity tracking with trends

## CLAUDE.md Updates

The retro proposes conventions but **never auto-edits CLAUDE.md**.
In interactive mode, you review and approve each proposal.
In auto mode, proposals are saved for later review.
