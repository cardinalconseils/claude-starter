---
description: "View and manage the CKS v6 control plane team roster — list personas, add new ones, or edit existing entries"
allowed-tools: Agent
---

# /cks:personas — Team Roster

Manage the CKS v6 control plane persona library.

## Usage

```
/cks:personas                      # List full roster from manifest
/cks:personas --add                # Guided interview → new persona file
/cks:personas --edit <role-slug>   # Re-interview and update a persona
```

## Dispatch

```
Agent(subagent_type="cks:personas-agent")
```

Pass the raw user arguments so the agent can detect the subcommand (`--add`, `--edit <slug>`, or no args → list).

## Quick Reference

| Command | What it does |
|---------|-------------|
| `/cks:personas` | List all personas from manifest with title, domain, benchmark |
| `/cks:personas --add` | Interview → write new `{slug}.md` → regenerate manifest |
| `/cks:personas --edit senior-designer` | Re-interview → update `.md` → regenerate manifest |

Persona files live in `.cks/control-plane/personas/` (project-local) or fall back to the plugin defaults at `skills/control-plane/personas/`.
