---
name: cicd-starter
description: >
  Bootstrap an existing codebase for the CKS lifecycle — scans the project, runs guided intake,
  generates CLAUDE.md, and initializes .prd/ state. Use when: "bootstrap", "set up", "initialize",
  "configure for this project", "generate CLAUDE.md", "scan my codebase", or any variation of
  setting up CKS tooling in an existing project.
---

# CKS Bootstrap — Set Up Any Existing Codebase

Scans an existing project, asks smart questions based on what it finds, generates `CLAUDE.md`, and initializes the PRD lifecycle.

## Flow

```
/cks:bootstrap → scan codebase → guided intake → CLAUDE.md → .prd/ init → done
```

## When to Use

- **Existing codebase** → `/cks:bootstrap` (this skill)
- **New project from scratch** → `/cks:kickstart` (different skill)

## Workflow

Read and execute: `workflows/bootstrap.md`

## What It Produces

```
CLAUDE.md                    ← Project-specific instructions (no placeholders)
.prd/PRD-STATE.md            ← Lifecycle initialized (idle, ready for /cks:new)
.prd/PRD-PROJECT.md          ← Project context from scan + intake
.prd/PRD-ROADMAP.md          ← Empty, ready for features
.context/config.md           ← Research sources configured for detected stack
```

## Reference Files

| File | When to Read |
|------|-------------|
| `references/claude-md-template.md` | When generating CLAUDE.md |

## Rules

1. **Scan first, ask second** — detect everything you can before asking
2. **Pre-fill from scan** — user confirms, not types from scratch
3. **No placeholders** — every line in CLAUDE.md must be real content
4. **Idempotent** — safe to re-run (offers update/regenerate/cancel)
5. **Don't touch source code** — only generate CLAUDE.md and .prd/ files
