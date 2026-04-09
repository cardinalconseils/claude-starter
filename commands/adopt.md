---
description: "Adopt CKS into an existing codebase mid-development — scans git history, generates CLAUDE.md, creates feature entry at sprint phase, detects secrets"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:adopt — Adopt CKS Mid-Development

Adds CKS lifecycle management to an existing codebase that's already in active development. Unlike `/cks:bootstrap` (fresh start), adopt meets you where you are.

## Pre-Check

If `CLAUDE.md` AND `.prd/PRD-STATE.md` both exist with project-specific content:
```
AskUserQuestion: "CKS already set up. Run /cks:bootstrap --update instead?"
```

## Phase 1: Scan & Intake (with adopt context)

```
Agent(subagent_type="cks:bootstrap-scanner", prompt="ADOPT MODE — scanning an existing codebase mid-development (not a fresh start). Scan the codebase AND git history (last 20 commits, current branch, recent file changes). Detect tech stack, current feature branch, recent work patterns, and .env secrets. Ask the user: (1) project profile (App/Website/Library/API), (2) what they're currently building. Write .bootstrap/scan-context.md with adopt-specific fields: current_feature, recent_commits, branch_name, detected_secrets.")
```

## Phase 2: Generate (with adopt-specific outputs)

```
Agent(subagent_type="cks:bootstrap-generator", prompt="ADOPT MODE — generate all bootstrap outputs from .bootstrap/scan-context.md. Additionally: (1) Create feature entry at sprint phase — skip discovery/design since work is already in progress, (2) Create lightweight CONTEXT.md and DESIGN.md markers noting adoption, (3) Create SECRETS.md from detected .env variables, (4) Set PRD-STATE.md to phase_status: designed so /cks:sprint picks it up directly. Do NOT overwrite existing CLAUDE.md with project-specific content.")
```

## Completion

Verify: `CLAUDE.md`, `.prd/PRD-STATE.md`, `.prd/phases/{NN}-*/` exist. Display summary:

```
CKS Adopted — {project name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Stack:   {detected}
  Feature: {NN} — {name} (sprint-ready)
  Created: CLAUDE.md, .claude/rules/, .prd/, feature entry

  Next: /cks:sprint {NN}
```

## When to Use

- Existing codebase with code already written
- Mid-feature development
- Want CKS without full discovery ceremony

## vs /cks:bootstrap

| | /cks:bootstrap | /cks:adopt |
|---|---|---|
| **Starting point** | Fresh or near-fresh project | Active development |
| **Discovery** | Not included | Inferred from codebase |
| **Feature entry** | None — starts at idle | Created at sprint phase |
| **Secrets** | Not scanned | Detected from .env files |
