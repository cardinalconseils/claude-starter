---
description: "Show installed CKS plugin version, project state version, and migration status"
allowed-tools: Bash, Read
---

# /cks:version — CKS Version Info

Show the installed CKS plugin version and the version stamped on this project's state files.

## Steps

1. **Plugin version** — Run: `grep '"version"' "${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json" | head -1 | sed 's/.*: *"//;s/".*//'`
2. **Project version** — Read `.prd/.cks-version` if it exists; if `.prd/` is absent, note "not initialized"
3. **Repository URL** — Run: `grep '"repository"' "${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json" | sed 's/.*: *"//;s/".*//'`
4. **Compare and display** using the format below

## Output Format

```
CKS Version
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Plugin:   v[VERSION]
  Project:  v[VERSION]  ✓ in sync

  Update:   claude plugin update cks@cks-marketplace
  Changes:  [REPO_URL]/blob/main/CHANGELOG.md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Variants:
- If project version differs from plugin version: `v[PROJECT_VER]  ⬆ run /cks:migrate`
- If `.prd/` exists but `.prd/.cks-version` is missing: `not stamped  ⬆ run /cks:migrate`
- If no `.prd/` at all: `not initialized  (run /cks:bootstrap or /cks:new)`
