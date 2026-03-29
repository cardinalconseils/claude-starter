---
description: "Scaffold project from kickstart artifacts — .claude/, CLAUDE.md, .prd/ with feature roadmap, .context/, deploy config"
argument-hint: "[--update]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - AskUserQuestion
  - Skill
  - "mcp__*"
---

# /cks:bootstrap — Set Up Project from Kickstart Artifacts

Load the skill from `${CLAUDE_PLUGIN_ROOT}/skills/cicd-starter/SKILL.md` and follow it exactly.

## Quick Reference

Takes `/kickstart` outputs and makes them real:

```
/cks:bootstrap          Fresh setup (or update if CLAUDE.md exists)
/cks:bootstrap --update Re-scan and merge into existing CLAUDE.md
```

## What Bootstrap Does

```
Kickstart Artifacts
    ↓
1. SCAFFOLD — Create project structure from architecture decisions
    ↓
2. CLAUDE.MD — Generate project-specific CLAUDE.md from PRD + stack
    ↓
3. .PRD/ — Initialize lifecycle state files
    ↓
4. FEATURE ROADMAP → PRD-ROADMAP.md — Import features from kickstart
    ↓
5. .CONTEXT/ — Research stack technologies for domain context
    ↓
6. LANGUAGE RULES — Generate .claude/rules/ for detected stack
    ↓
7. MCP CONFIG — Configure MCP servers (Stitch SDK, Supabase, etc.)
    ↓
8. DEPLOY CONFIG — Set up deployment target (Railway, Vercel)
    ↓
Ready for /cks:new
```

## Language Rules Generation

After detecting the stack, generate language-specific coding rules:

```
For each detected language/framework:
  Load rule catalog from skills/language-rules/SKILL.md
  Generate .claude/rules/{language}.md
  Report: "Generated coding rules for: {languages}"
```

Rules ensure Claude follows language-specific best practices (strict types,
error handling patterns, import conventions) for all code in the project.

## Kickstart → Bootstrap Handoff

Bootstrap reads these kickstart artifacts:

| Kickstart Output | Bootstrap Action |
|---|---|
| `.kickstart/context.md` | → Project description in CLAUDE.md |
| `.kickstart/artifacts/PRD.md` | → `.prd/PRD-PROJECT.md` |
| `.kickstart/artifacts/ERD.md` | → `docs/ERD.md` |
| `.kickstart/artifacts/ARCHITECTURE.md` | → Stack section in CLAUDE.md |
| `.kickstart/artifacts/FEATURE-ROADMAP.md` | → `.prd/PRD-ROADMAP.md` (feature backlog with MVP + post-MVP) |
| `.monetize/*` | → Monetization notes in PRD-PROJECT.md |

## Feature Roadmap Import

The feature roadmap from kickstart becomes the `.prd/PRD-ROADMAP.md`:

```
Each feature from FEATURE-ROADMAP.md →
  - Entry in PRD-ROADMAP.md with status "Planned"
  - Phase directory created: .prd/phases/{NN}-{kebab-name}/
  - Ready for /cks:new to pick up and run through 5-phase cycle
```

## Stack Research

Using the stack from kickstart's architecture decisions:

```
For each technology in the stack:
  If .context/{slug}.md doesn't exist:
    Skill(skill="context", args="\"${technology}\"")
```

## MCP Server Configuration

If the project uses tools with MCP servers, configure them:

| Technology | MCP Server |
|---|---|
| Stitch SDK | `@google/stitch-sdk` (for Phase 2: Design) |
| Supabase | Supabase MCP |
| Firebase | Firebase MCP |
| Chrome DevTools | Chrome DevTools MCP (for browser testing) |

## For New Projects from Scratch

Use `/cks:kickstart` first to generate the artifacts, then run `/cks:bootstrap`.

## AskUserQuestion Requirement

ALL user interactions during bootstrap MUST use `AskUserQuestion` with selectable options.
