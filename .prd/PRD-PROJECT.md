# Project: Claude Starter

**Initialized:** 2026-03-23
**Last Updated:** 2026-03-23

## Overview

Claude Starter is a reusable project scaffold that provides the complete `.claude/` architecture (skills, agents, commands, CLAUDE.md) as a starter kit for new projects. It includes PRD lifecycle management, monetization evaluation, SEO tools, CI/CD deployment, and code review workflows.

## Users

| User Type | Goals | Context |
|-----------|-------|---------|
| Developer | Bootstrap new projects with Claude Code tooling | Needs ready-to-use skills, agents, and commands |
| Project Lead | Standardize AI-assisted development across projects | Needs consistent workflow patterns |

## Tech Stack

| Layer | Technology | Notes |
|-------|-----------|-------|
| CLI | Claude Code | Skills, agents, commands |
| Deployment | Railway | Via deploy command |
| Version Control | Git + GitHub | PR workflows via ship command |

## Project Goals

1. Provide a turnkey `.claude/` architecture for any new project
2. Include PRD lifecycle management (discuss → plan → execute → verify → ship)
3. Include monetization evaluation workflows
4. Include SEO and AEO/GEO tooling
5. Support bootstrapping and virginizing for repo reuse

## Constraints

- Must remain project-agnostic (no hardcoded project references)
- Skills must work across different tech stacks
- Commands must be self-contained

## Conventions

See `CLAUDE.md` for full conventions.

## Key Files

- `.claude/skills/prd/SKILL.md` — PRD lifecycle skill
- `.claude/skills/monetize/SKILL.md` — Monetization evaluation skill
- `.claude/skills/cicd-starter/SKILL.md` — Bootstrap/deploy skill
- `.claude/agents/` — All agent definitions
- `.claude/commands/` — All slash commands
