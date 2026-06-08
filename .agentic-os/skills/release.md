---
name: release
domain: Release
description: "Release skill for CKS — Claude Code Starter Kit — defines how Claude executes version bump, changelog, PR, and publish tasks"
---

# Release — Skill

## Purpose

Covers the full CKS release pipeline: bumping the version, writing the CHANGELOG entry, opening a PR, and tagging for publish. Every release must follow this sequence — no shortcuts.

## Recurring Tasks

### Task: Bump version

**When**: A release is ready to ship and the version in `plugin.json` still reflects the previous release.

**Output**: Updated `plugin.json` with new semver. `scripts/bump-version.sh` run and output shown.

**Instructions**:
1. Read `plugin.json` to confirm current version
2. Determine new semver: patch for bug fixes, minor for new features, major for breaking changes
3. Run `scripts/bump-version.sh {major|minor|patch}` and show output
4. Verify `plugin.json` reflects the new version

**Quality bar**: `plugin.json` version matches intended semver; `bump-version.sh` output shown as evidence.

---

### Task: Write CHANGELOG

**When**: A version bump is done and the CHANGELOG entry is missing or incomplete.

**Output**: New entry in `CHANGELOG.md` with Added / Changed / Fixed sections. No duplicates, no placeholders.

**Instructions**:
1. Read `CHANGELOG.md` to check for existing entries for this version (avoid duplicates — see feedback memory)
2. Read recent commits since last tag: `git log {last-tag}..HEAD --oneline`
3. Write the entry manually: `## [X.Y.Z] — YYYY-MM-DD` with subsections Added / Changed / Fixed
4. Be specific — each line cites a command, agent, skill, or hook by name
5. No `[PLACEHOLDER]` markers — every line must be final prose

**Quality bar**: Entry exists for the new version; no duplicates in the file; no placeholder text; written manually (not auto-generated).

---

### Task: Open PR

**When**: Branch is ready, version bumped, CHANGELOG written — time to open the PR for review.

**Output**: GitHub PR opened with title, summary, and test plan. PR URL returned.

**Instructions**:
1. Verify branch is pushed: `git status` and `git log --oneline main..HEAD`
2. Run pre-commit verification: grep staged files for TODO/FIXME/commented-out code
3. Open PR via `gh pr create` with a clear title (under 70 chars) and body (Summary + Test plan)
4. Link related issues in the PR body
5. Return the PR URL

**Quality bar**: PR title under 70 chars; body has Summary and Test plan sections; no placeholder text; pre-commit scan clean.

---

### Task: Tag and publish

**When**: PR is merged and the release is confirmed ready to ship to cks-marketplace.

**Output**: Git tag pushed. Publish command run. Release confirmed on marketplace.

**Instructions**:
1. Confirm PR is merged and main is up to date: `git pull origin main`
2. Read `plugin.json` to get the version to tag
3. Create and push tag: `git tag v{version} && git push origin v{version}`
4. Run publish command per marketplace docs
5. Confirm the new version appears on the marketplace

**Quality bar**: Tag exists on remote; version visible on cks-marketplace; publish command output shown.

---

## Context Sources

- `memory/wiki/` — past release notes, versioning decisions
- `CHANGELOG.md` — existing entries to avoid duplication
- `plugin.json` — current version
- `scripts/bump-version.sh` — version bump automation

## Output Destinations

- Bumped `plugin.json` + CHANGELOG entry → committed to release branch
- PR URL → shared in community announcement
- Tag → pushed to origin
