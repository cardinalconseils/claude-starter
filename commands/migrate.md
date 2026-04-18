---
description: "Migrate project state files to match current CKS plugin version"
allowed-tools:
  - Read
  - Agent
---

# /cks:migrate

Dispatch the migrator agent to upgrade project state files.

```
Agent(subagent_type="cks:migrator", prompt="Detect the CKS version gap for this project and migrate state files to the current plugin version. Read .claude-plugin/plugin.json for the target version and .prd/.cks-version for the current project version. Read references/version-changes.md from your migrations skill for the migration specifications. Apply all pending migrations with user confirmation. Arguments: $ARGUMENTS")
```

If `$ARGUMENTS` does not contain `--check`, run assess after migration completes:

```
Agent(subagent_type="cks:assess-runner", prompt="Run the CKS assessment pipeline at pipelines/assess.dot. Args: --mode health")
```

## Quick Reference

```
/cks:migrate           → migrate + health check
/cks:migrate --check   → show what would change without applying (no assess)
```
