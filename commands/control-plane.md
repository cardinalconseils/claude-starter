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

## Dispatch

Read-side goes to the observer; anything that writes the control plane goes to the
operator.

| Subcommand | Dispatch |
|---|---|
| `--status` (default) | `Agent(subagent_type="cks:observer", prompt="Mode: control-plane --status. Full health report, component by component (skills/control-plane). Read only.")` |
| `--backup` | `Agent(subagent_type="cks:operator", prompt="Mode: control-plane --backup. Tar the control-plane dir into .cks/backups/ and report the archive path.")` |
| `--restore <file>` | `Agent(subagent_type="cks:operator", prompt="Mode: control-plane --restore\nFile: {parsed file argument}. Show the destructive-action warning and require confirmation before restoring.")` |
| `--drain` | `Agent(subagent_type="cks:operator", prompt="Mode: control-plane --drain. Retry failed Supabase syncs from the queue; report retried / still failing.")` |
| `--reset` | `Agent(subagent_type="cks:operator", prompt="Mode: control-plane --reset. Back up first, show the destructive-action warning, require confirmation, then re-init.")` |

## Quick Reference

| Command | What it does |
|---------|-------------|
| `/cks:control-plane init` | One-time scaffold — safe to run, will not overwrite existing config |
| `/cks:control-plane --status` | Full health report, component by component |
| `/cks:control-plane --backup` | Tar control-plane dir → .cks/backups/ |
| `/cks:control-plane --restore <file>` | Restore from a named backup (shows warning, requires confirmation) |
| `/cks:control-plane --drain` | Retry failed Supabase syncs from the queue |
| `/cks:control-plane --reset` | Nuclear re-init (backs up first, requires confirmation) |
