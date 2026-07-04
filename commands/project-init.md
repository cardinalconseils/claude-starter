---
description: "Set up GitHub Project Kanban board — wires plugin.json github_project so filed issues sync to a board"
allowed-tools: Read, Agent
---

# /cks:project-init — GitHub Project Kanban Setup

Wires `.claude-plugin/plugin.json`'s `github_project` block (owner/repo/number) so
issues filed by CKS agents (investigator, factory, debugger) actually land on a
GitHub Project Kanban board instead of silently no-oping.

## What It Does

1. Dispatches `cks:github-project-setup-agent`, which runs the wizard in
   `skills/github-project-setup/SKILL.md`: detects repo identity, creates a
   6-column GitHub Project, writes owner/repo/number to `plugin.json`, and
   seeds Backlog items from `.prd/PRD-ROADMAP.md` if present.
2. Verifies `isConfigured()` returns true after setup.

## Quick Reference

```
/cks:project-init
```

Requires `GITHUB_TOKEN` (or `gh auth status` logged in) with `project` + `repo` scopes,
and a GitHub-hosted `origin` remote.
