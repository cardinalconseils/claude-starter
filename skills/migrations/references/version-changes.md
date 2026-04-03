# CKS Version Changes — Migration Reference

## How to Use This File

When migrating a project, find the project's current version (from `.prd/.cks-version` or `0.0.0` if missing).
Apply all changes from that version forward to the current plugin version.

---

## v0.0.0 → v4.0.0 (Pre-CKS to v4 Architecture)

Projects that existed before the migration system. These have `.prd/` but no `.cks-version` stamp.

### Structural changes:
- **Create** `.prd/.cks-version` (version stamp file)
- **Create** `.prd/logs/` directory if missing
- **Create** `.prd/phases/` directory if missing
- **Create** `.learnings/` directory if missing

### PRD-STATE.md field additions:
- **Add** `Iteration Count: 0` if field missing
- **Add** `Iteration Reason: —` if field missing
- **Add** `Secrets Tracking: not scanned` if field missing

### Config backfill:
- **Create** `.prd/prd-config.json` with defaults if missing:
  ```json
  {
    "versioning": { "enabled": true, "strategy": "auto-patch", "changelog": true },
    "profile": "default",
    "migrated_from": "pre-4.0"
  }
  ```

### Log initialization:
- **Create** `.prd/logs/lifecycle.jsonl` if missing, with migration event entry

---

## v4.0.0 → v4.2.0 (Directory Expansion)

### Structural changes:
- **Create** `.monetize/phases/` directory if missing
- **Create** `.context/` directory if missing

### Gitignore updates:
- **Add** `.prd/logs/.current_session_id` to `.gitignore` if not already present

---

## Adding Future Migrations

When CKS introduces breaking changes to state file structure, add a new section here:

```markdown
## vX.Y.Z → vA.B.C (Short Description)

### Structural changes:
- What directories are created/moved

### Field changes:
- What fields are added/renamed/removed in state files

### Config changes:
- What changes to prd-config.json or other config files
```

The migrate agent reads this file to know exactly what to check and apply.
