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

## v4.2.0 → v4.7.0 (Karpathy Coding Guardrails)

### Rule file backfill:
- **Create** `.claude/rules/karpathy.md` if missing, with the following content:

```markdown
# Coding Behavior Rules

Four principles that address the most common LLM coding failure modes.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

Before implementing anything non-trivial:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Test: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

Test: Every changed line should trace directly to the user's request.

## 4. Define Success, Then Verify

Before starting non-trivial work, transform the task into a verifiable goal:

\`\`\`
Task: "fix the bug"
→ Success: test that reproduces the bug passes; no other tests break
\`\`\`

For multi-step tasks, state a brief plan with a verify step for each:
\`\`\`
1. [Step] → verify: [check]
2. [Step] → verify: [check]
\`\`\`

Then loop until every verify step produces evidence. "Seems right" is not done.
```

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
