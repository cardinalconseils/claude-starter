---
description: "Initialize the CKS v6 control plane in the current project — scaffolds .cks/control-plane/ with config, personas, and RAID log"
allowed-tools: Bash
---

# /cks:control-plane — Control Plane Management

Manage the CKS v6 control plane layer for the current project.

## Usage

```
/cks:control-plane init    # Scaffold .cks/control-plane/ in current project
```

## Dispatch

For `init`, run the scaffold script directly (no agent needed — it's a one-shot shell operation):

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/control-plane-init.sh"
```

## What `init` creates

```
.cks/control-plane/
  config.yaml          ← edit to set org name and enable features
  personas/            ← copy of default persona .md files + manifest.yaml
  raid/
    raid.md            ← RAID log (append-only)
  heartbeat/
    state/             ← per-agent heartbeat state (Phase 1+)
```

## Quick Reference

| Command | What it does |
|---------|-------------|
| `/cks:control-plane init` | One-time scaffold — safe to run, will not overwrite existing config |

After `init`: edit `.cks/control-plane/config.yaml` to set your `org:` name, then start a new session to see the control plane banner.
