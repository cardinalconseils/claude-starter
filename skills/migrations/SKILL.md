---
name: migrations
description: >
  Migrate CKS project state files across plugin versions. Detects version gaps, applies
  structural changes to .prd/, .learnings/, .monetize/, .context/ directories and state files.
  Use when: "migrate", "upgrade", "version mismatch", "state migration", "update project state",
  or when session-start hook reports a version gap.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
---

# CKS Migrations — Version-Aware State Upgrades

Ensures user project state files stay compatible as the CKS plugin evolves.

## Core Concepts

**Version stamp**: `.prd/.cks-version` — single-line file containing the CKS version that last touched this project's state.

**Migration direction**: Always forward. Compare project stamp against plugin version from `.claude-plugin/plugin.json`.

**Idempotent**: Every migration must be safe to re-run. Check before writing.

## State Files Managed by CKS

| Path | Created By | Purpose |
|------|-----------|---------|
| `.prd/PRD-STATE.md` | `/cks:new` | Active phase, status, next action |
| `.prd/prd-config.json` | `/cks:bootstrap` | Versioning strategy, profile |
| `.prd/logs/lifecycle.jsonl` | Hooks | Append-only event log |
| `.prd/logs/.current_session_id` | `session-start.sh` | Session correlation ID |
| `.prd/phases/{NN}-*.md` | Phase agents | Phase artifacts |
| `.learnings/session-*.md` | `session-learnings.sh` | Cross-session knowledge |
| `.learnings/conventions.md` | `/cks:sprint-close` | Pending convention proposals |
| `.kickstart/state.md` | `/cks:kickstart` | Kickstart phase tracking |
| `.monetize/*.md` | `/cks:monetize` | Monetization workflow state |
| `.context/config.md` | `/cks:bootstrap` | Research source config |
| `.bootstrap/scan-context.md` | `/cks:bootstrap` | Codebase scan results |

## Version History and Required Changes

Read `references/version-changes.md` for the complete changelog of structural changes per version.

## Migration Rules

1. **Always read `.prd/.cks-version` first** — if missing and `.prd/PRD-STATE.md` exists, treat as v0.0.0 (pre-migration project)
2. **Always ask before modifying** — show what will change, get user confirmation
3. **Backup before mutating** — copy any file being modified to `.prd/backups/{version}/` first
4. **Stamp after success** — write new version to `.prd/.cks-version` only after all changes succeed
5. **Log every migration** — append to `.prd/logs/lifecycle.jsonl`
6. **Never delete user content** — migrations add/restructure, never remove
7. **Report what changed** — show a summary of every file created, modified, or moved
