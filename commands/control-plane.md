---
description: "Manage the CKS v6 control plane — init, health status, backup, restore, drain sync queue, reset"
allowed-tools:
  - Bash
  - Agent
  - AskUserQuestion
---

# /cks:control-plane — Control Plane Management

Parse `$ARGUMENTS` for the subcommand. Default to `--status` if no argument provided.

## init

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/control-plane-init.sh"
```

## --status (default)

```
Agent(
  subagent_type="cks:control-plane-agent",
  prompt="Mode: --status"
)
```

## --backup

```
Agent(
  subagent_type="cks:control-plane-agent",
  prompt="Mode: --backup"
)
```

## --restore \<file\>

```
Agent(
  subagent_type="cks:control-plane-agent",
  prompt="Mode: --restore\nFile: {parsed file argument}"
)
```

## --drain

```
Agent(
  subagent_type="cks:control-plane-agent",
  prompt="Mode: --drain"
)
```

## --reset

```
Agent(
  subagent_type="cks:control-plane-agent",
  prompt="Mode: --reset"
)
```

## Quick Reference

| Command | What it does |
|---------|-------------|
| `/cks:control-plane init` | One-time scaffold — safe to run, will not overwrite existing config |
| `/cks:control-plane --status` | Full health report, component by component |
| `/cks:control-plane --backup` | Tar control-plane dir → .cks/backups/ |
| `/cks:control-plane --restore <file>` | Restore from a named backup (shows warning, requires confirmation) |
| `/cks:control-plane --drain` | Retry failed Supabase syncs from the queue |
| `/cks:control-plane --reset` | Nuclear re-init (backs up first, requires confirmation) |
