---
name: docs
domain: Docs
description: "Docs skill for CKS — Claude Code Starter Kit — defines how Claude keeps README, wiki, and changelogs accurate and current"
---

# Docs — Skill

## Purpose

Keeps the CKS plugin documentation accurate: README command count, wiki pages in `docs/`, and CHANGELOG entries. Documentation drifts silently — this domain catches and fixes that.

## Recurring Tasks

### Task: Update README

**When**: After any release that adds, renames, or removes commands or agents — or when the command count in README.md is wrong.

**Output**: `README.md` with correct command count, updated table, and current quick-start instructions.

**Instructions**:
1. Run `ls commands/*.md | wc -l` to get the true command count
2. Read `README.md` — find the command count reference and the command table
3. Update count and table to match actual `commands/*.md` files
4. Verify quick-start instructions still work (plugin install command, example commands)
5. Do not add prose or restructure — minimal impact only

**Quality bar**: Command count matches `ls commands/*.md | wc -l`; table has no stale or missing entries; no placeholder text.

---

### Task: Update wiki

**When**: A new agent, command, skill, or architecture decision was introduced that isn't documented in `docs/`.

**Output**: New or revised `.md` file in `docs/` covering the new concept.

**Instructions**:
1. Read `docs/` directory listing to find the relevant existing file or confirm a new file is needed
2. Write or update the doc — one file per concept, not one mega-doc
3. Keep under 200 lines — link to skill files for deep detail
4. No TODO stubs — every section must be complete prose

**Quality bar**: Doc exists for the new concept; no placeholder text; links to relevant skill or agent files.

---

### Task: Update changelogs

**When**: CHANGELOG.md has duplicates, placeholder entries, or missing version entries after a release.

**Output**: Clean `CHANGELOG.md` with accurate entries for all released versions.

**Instructions**:
1. Read `CHANGELOG.md` top to bottom — flag duplicates and `[PLACEHOLDER]` markers
2. Read git tags to confirm which versions exist: `git tag --sort=-v:refname | head -20`
3. For each gap: draft the missing entry from `git log {prev-tag}..{tag} --oneline`
4. Remove duplicates — keep the more detailed entry
5. Remove all placeholder markers — replace with real prose or delete the line

**Quality bar**: No duplicate version headers; no placeholder text; every tagged release has a CHANGELOG entry.

---

## Context Sources

- `memory/wiki/` — past decisions about doc structure
- `docs/` — existing wiki pages
- `commands/*.md` — source of truth for command count and table
- `CHANGELOG.md` — source for version history

## Output Destinations

- Updated README/CHANGELOG → committed to branch, PR opened
- New wiki pages → `docs/` committed to branch
- Reusable doc patterns → `memory/wiki/`
