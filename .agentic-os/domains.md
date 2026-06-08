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

---

## Widget Dev

**Description**: Create, update, debug, and document dashboard widgets — layout, data sources, and rendering.

**Tasks**:
- Create new dashboard widget — scaffold widget component with data binding and layout slot
- Update widget layout — adjust sizing, positioning, or grid placement of existing widgets
- Add data source to widget — wire a new data feed or API into an existing widget
- Debug widget rendering — trace and fix display, hydration, or update failures
- Document widget API — write usage docs for widget props, slots, and data contracts

**Skill**: `.agentic-os/skills/widget-dev.md`

---

## Data

**Description**: Define schemas, wire live sources, build aggregations, feed the memory layer, and export reports.

**Tasks**:
- Define data schema — design and document the shape of a new data entity or feed
- Wire live data source — connect an external API or DB to a consumer in the project
- Build aggregation query — write a query or pipeline that summarizes raw data
- Add data to memory layer — process and move data artifacts into `memory/wiki/` or `memory/output/`
- Export data report — generate a formatted data export for sharing or downstream use

**Skill**: `.agentic-os/skills/data.md`
