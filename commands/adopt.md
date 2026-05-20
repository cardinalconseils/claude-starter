---
description: "Adopt CKS into an existing codebase mid-development — scans git history, generates CLAUDE.md, creates feature entry at sprint phase, detects secrets"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:adopt — Adopt CKS Mid-Development

## Pre-Check

Read `.bootstrap/features-catalog.md` (if exists), `.prd/PRD-ROADMAP.md` (if exists), and list `.prd/phases/` subdirectories (if any).

**State A — No CKS artifacts exist:** run the phases below unchanged.

**State B — CLAUDE.md and .prd/PRD-STATE.md exist but no features-catalog or phases:**
```
AskUserQuestion: "CKS already set up. Run /cks:bootstrap --update instead?"
```

**State C — .bootstrap/features-catalog.md exists OR .prd/phases/ has entries:**
RE-ADOPT mode. Pass the existing catalog rows and roadmap rows into the prompts for Phase 1.5 and Phase 2 (see RE-ADOPT CONTEXT injection below).

## Phase 1: Scan & Intake (with adopt context)

```
Agent(subagent_type="cks:bootstrap-scanner", prompt="ADOPT MODE — scanning an existing codebase mid-development (not a fresh start). Scan the codebase AND git history (last 20 commits, current branch, recent file changes). Detect tech stack, current feature branch, recent work patterns, and .env secrets. Ask the user: (1) project profile (App/Website/Library/API), (2) what they're currently building. Write .bootstrap/scan-context.md with adopt-specific fields: current_feature, recent_commits, branch_name, detected_secrets.")
```

## Phase 1.5: Feature Cataloging

**State A/B:** Run as-is.

**State C (RE-ADOPT):**
```
Agent(subagent_type="cks:feature-cataloger", prompt="Scan the codebase and catalog all existing features. Analyze routes, directory structure, and git history to propose feature clusters. Use AskUserQuestion to confirm, clarify, and classify each feature (shipped/in-progress/planned). Allow the user to add features not detected. Write .bootstrap/features-catalog.md before completing.

RE-ADOPT MODE: .bootstrap/features-catalog.md already exists with these entries:
{paste existing catalog rows}
Do NOT re-confirm these features. Only surface and confirm net-new candidates. Append new rows to the existing catalog file — do not overwrite it.")
```

## Phase 1.6: PRE-FLIGHT Mapping

```
Agent(subagent_type="cks:agile-eagle", prompt="Run PRE-FLIGHT for an in-flight project being adopted into CKS. Read .bootstrap/scan-context.md to get the current_feature and branch_name. Read .bootstrap/features-catalog.md to understand what features are in-progress. Run the full P→R→E→F→L→I→G protocol focused on the in-progress feature. Write PREFLIGHT.md to .preflight/00-{slug}/ (use phase 00 since PRD slot not yet assigned). Report completion before exiting.")
```

## Phase 2: Generate (with adopt-specific outputs)

**State A/B:** Run as-is.

**State C (RE-ADOPT):**
```
Agent(subagent_type="cks:bootstrap-generator", prompt="ADOPT MODE — generate all bootstrap outputs from .bootstrap/scan-context.md. Additionally: (1) Create feature entry at sprint phase — skip discovery/design since work is already in progress, (2) Create lightweight CONTEXT.md and DESIGN.md markers noting adoption, (3) Create SECRETS.md from detected .env variables, (4) Set PRD-STATE.md to phase_status: designed so /cks:sprint picks it up directly. Do NOT overwrite existing CLAUDE.md with project-specific content.

RE-ADOPT MODE: .prd/PRD-ROADMAP.md already has these feature rows:
{paste existing roadmap rows}
Do NOT add duplicate rows. Only append rows for features not already present. Update status of existing rows if stale.")
```

## Phase 3: Assess (optional — does not block completion)

```
Agent(subagent_type="cks:assess-runner", prompt="Run the CKS assessment pipeline at pipelines/assess.dot. Args: --mode full. The pipeline is driven by the embedded graph in the agent — do NOT depend on an external attractor Python package.")
```

If the assess agent fails, continue to Completion. Note the skip in the completion
summary: `Report: skipped (run /cks:assess later)`

## Completion

Verify: `CLAUDE.md`, `.prd/PRD-STATE.md`, `.prd/phases/{NN}-*/` exist. Display summary:

```
CKS Adopted — {project name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Stack:   {detected}
  Feature: {NN} — {name} (sprint-ready)
  Created: CLAUDE.md, .claude/rules/, .prd/, feature entry
  Report:  .assess/ASSESSMENT.md

  Next: /cks:sprint {NN}
```

## Quick Reference

Use for existing codebases in active development. For fresh starts, use `/cks:bootstrap`.
