# Agentic OS — Domains & Tasks
# Project: CKS — Claude Code Starter Kit
# Generated: 2026-06-07

## Domains

## Plugin Dev

**Description**: All work to build, extend, and debug the CKS plugin itself — commands, agents, skills, and hooks.

**Tasks**:
- Add command — scaffold a new `/cks:*` slash command with correct frontmatter and thin-dispatcher pattern
- Wire agent — create or update an agent definition with tools, skills, and system prompt
- Debug hook — diagnose and fix SessionStart, PreToolUse, PostToolUse, or Stop hook failures
- Write skill — author domain expertise in `.claude/plugins/.../skills/` with correct YAML frontmatter
- TDD — write failing test first, implement until green, verify with output evidence

**Skill**: `.agentic-os/skills/plugin-dev.md`

---

## Release

**Description**: All steps to ship a new CKS version — version bump, changelog, PR, and publish.

**Tasks**:
- Bump version — run `scripts/bump-version.sh` and verify `plugin.json` reflects new semver
- Write CHANGELOG — draft entry manually with added/changed/fixed sections for the release
- Open PR — push branch, open PR with summary and test plan, link to relevant issues
- Tag and publish — tag the release commit and publish to cks-marketplace

**Skill**: `.agentic-os/skills/release.md`

---

## Docs

**Description**: Keep README, wiki, and changelogs accurate and current as the plugin evolves.

**Tasks**:
- Update README — sync command count, table, and quick-start instructions after each release
- Update wiki — add or revise pages in docs/ to reflect new agents, commands, or architecture decisions
- Update changelogs — ensure CHANGELOG.md matches released versions; no duplicates, no placeholders

**Skill**: `.agentic-os/skills/docs.md`

---

## Community

**Description**: Engage with users and contributors — triage issues, review PRs, and communicate updates.

**Tasks**:
- Triage issues — label, reproduce, and prioritize incoming GitHub issues
- Review PRs — read diff, check against CKS rules, leave actionable feedback or approve
- Write announcement — draft release announcement for community channels
- Respond to feedback — reply to user feedback with clarity and actionable next steps

**Skill**: `.agentic-os/skills/community.md`
