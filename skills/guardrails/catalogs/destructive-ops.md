# Destructive Operations Guardrail Catalog

## Trigger

Always generated — applies to every project regardless of stack.

## Template

Write the following to `.claude/rules/destructive-ops.md`:

```markdown
# Destructive Operations Rules

## Mandatory Warning Format

Before suggesting OR running any destructive operation, output this block in your response:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔ DESTRUCTIVE ACTION — REVIEW BEFORE PROCEEDING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Action:     [what will happen, in plain English]
Target:     [exact files, tables, branches, resources]
Reversible: YES / NO / MAYBE (with condition)
You lose:   [what is gone if this runs and is wrong]
Safer alt:  [a safer option, or "none"]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

This block must appear BEFORE the tool call — never silently run a destructive command.

## What Counts as Destructive

**File system**
- `rm -rf`, `rm -r`, `rm -f`, `find ... -delete`, `find ... -exec rm`
- Overwriting `.env`, `credentials.json`, `*.pem`, `*.key` files

**Git**
- `git push --force` or `git push -f`
- `git reset --hard`
- `git clean -f`, `git clean -fd`
- `git checkout -- .`, `git restore .`
- `git branch -D`

**Database**
- `DROP TABLE`, `DROP DATABASE`, `DROP SCHEMA`
- `TRUNCATE TABLE`
- `DELETE FROM` without a `WHERE` clause
- `ALTER TABLE ... DROP COLUMN`

**Infrastructure**
- `terraform destroy`
- `kubectl delete`
- `aws ... delete`, `gcloud ... delete`
- Any cloud resource deletion or shutdown

## Required Behavior

- NEVER batch multiple destructive operations silently — each one gets its own warning block
- NEVER use phrases like "I'll just clean this up" or "let me remove the old files" without the block
- If the user asks to "clean up", "remove", or "delete" something, confirm the exact targets first
- For irreversible actions: state "This cannot be undone" explicitly
- Always suggest a safer alternative when one exists:
  - Hard delete → soft delete (deleted_at flag)
  - `rm -rf` → move to a temp directory first
  - Force push → create a new branch instead
  - Drop column → deprecate with a rename first

## On Confirmation

When the user says "yes, proceed" or similar after seeing the warning:
- Confirm you understood what was approved: "Running: [exact command]"
- Run only the exact operation that was approved — do not expand scope
- After completion, state what was done: "Deleted: [specific targets]"
```

## Customization Notes

- This catalog has no placeholders — it is stack-agnostic and always applies as-is
- No `globs:` frontmatter needed — these rules apply to all files and all contexts
- The warning block format uses plain ASCII dashes (not unicode box chars) for terminal compatibility
