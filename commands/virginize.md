---
description: "Strip project-specific content from .claude/ files to make them starter-ready"
allowed-tools:
  - Read
  - AskUserQuestion
  - Agent
---

# /virginize

## What It Does
Takes one or more project-specific `.claude/` files and strips all project-specific
content — replacing names, URLs, env vars, and stack references with generic tokens —
making them starter-ready for `claude-starter`. Shows a diff before saving anything.

## Usage
```
/virginize
```

No arguments. Claude will ask which files to process — a single skill, agent, command,
or tool, or a list of them in one session.

## Dispatch

Ask the user which files to virginize (paths or names), then:

```
Agent(subagent_type="cks:operator", prompt="Mode: virginize. Files: {list}. For each: read in full, report project-specific strings found, show a before/after diff and wait for confirmation, apply replacements (project names → [PROJECT_NAME], URLs → [PROJECT_URL], env values → placeholders, stack references → generic), verify zero project-specific content remains, write the copy to starter-ready/ preserving the subfolder structure. Never modify the originals. Finish by printing the git commands to add the files to claude-starter.")
```

## Output Location
```
starter-ready/
├── skills/    ← virginized skills
├── agents/    ← virginized agents
├── commands/  ← virginized commands
└── tools/     ← virginized tools
```

## Guarantees
- Never modifies original files — virginized copies go to `starter-ready/`
- Never saves without showing diff first
- Preserves full file structure — only content values change
- Quality check: zero project-specific strings in output

## Quick Reference
```
/virginize
→ Which files? .claude/agents/deployer.md, .claude/commands/deploy.md
→ Scanning… 7 + 3 project-specific strings found → [diff per file] → ✓ 2 files → starter-ready/
```
