---
description: "Guided migration from GSD plugin to CKS — safe, non-destructive, step-by-step"
allowed-tools:
  - Read
  - Bash
  - Glob
  - Grep
  - AskUserQuestion
  - Skill
---

# /cks:migrate — Migrate from GSD to CKS

Guide the user through replacing the GSD plugin with CKS. This is a **non-destructive** migration — no project files are deleted.

## Key Principle

The user's `.claude/` directory (agents, skills, commands, CLAUDE.md) belongs to **them**, not to GSD or CKS. Plugins are external and namespaced (`/gsd:*` or `/cks:*`). Migration means swapping the plugin, not replacing project files.

## Step 1: Assess Current State

Run these checks and report findings:

```bash
# Check if CKS is already installed
claude plugin list 2>/dev/null | grep -i cks || echo "CKS: not installed"

# Check if GSD is installed
claude plugin list 2>/dev/null | grep -i gsd || echo "GSD: not installed"
```

Check the project for:
- Existing `.claude/` directory (Glob for `.claude/**/*`)
- Existing `CLAUDE.md`
- GSD-specific artifacts (Glob for `.gsd/**/*`, or any `gsd` references in project files)
- Existing `.prd/` directory

Report a summary:

```
GSD → CKS Migration Assessment
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  CKS Plugin        [installed / not installed]
  GSD Plugin         [installed / not installed]
  Project .claude/   [exists — N agents, N skills, N commands / not found]
  CLAUDE.md          [exists / not found]
  GSD Artifacts      [.gsd/ found / none found]
  PRD State          [.prd/ exists / not found]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Step 2: Install CKS (if needed)

If CKS is not installed:

```
To install CKS globally, run:

  claude /plugin add cardinalconseils/claude-starter

This installs to ~/.claude/plugins/, not your project. Safe, additive, instant.
```

Ask the user if they want to proceed. Do NOT run this automatically.

## Step 3: Disable/Remove GSD (if installed)

If GSD is detected:

```
To prevent command conflicts, disable or remove GSD:

  claude plugin disable gsd@<name>
  # or remove entirely:
  claude plugin remove gsd@<name>
```

Ask the user which action they prefer (disable vs remove). Do NOT run this automatically.

## Step 4: Preserve Project Files

Confirm explicitly:

```
Your project files are SAFE:
  ✅ .claude/agents/    → untouched (your custom agents stay)
  ✅ .claude/skills/    → untouched (your custom skills stay)
  ✅ .claude/commands/  → untouched (your custom commands stay)
  ✅ CLAUDE.md          → will be updated (merge), not replaced
```

## Step 5: Handle GSD Artifacts

If `.gsd/` or other GSD-specific directories are found:

Ask the user:
1. **Archive** — `mv .gsd/ .gsd-archive/` (safe, reversible)
2. **Delete** — remove GSD artifacts (they've served their purpose)
3. **Keep** — leave them in place (no harm, just clutter)

## Step 6: Run Bootstrap

Tell the user:

```
Now run /cks:bootstrap to set up CKS for this project.

This will:
  1. Scan your codebase (read-only)
  2. Ask guided questions (pre-filled from scan)
  3. CLAUDE.md: merge CKS sections into your existing one (or generate fresh)
  4. Create .prd/ directory for lifecycle tracking

Ready? Run: /cks:bootstrap
```

Do NOT automatically invoke bootstrap — let the user decide when.

## Step 7: Verify

After bootstrap completes (or if the user skips it), show the verification checklist:

```
Migration Checklist
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  [ ] CKS installed          → claude plugin list
  [ ] GSD disabled/removed   → claude plugin list
  [ ] Project .claude/ intact → your agents, skills, commands still there
  [ ] CLAUDE.md updated      → /cks:bootstrap (when ready)
  [ ] .prd/ initialized      → /cks:status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Next steps:
  /cks:status        → see your project state
  /cks:help          → see all available commands
  /cks:new "brief"   → start your first CKS-managed feature
```

## Rules

1. **Never delete project files** without explicit user confirmation
2. **Never run plugin install/remove commands automatically** — always ask first
3. **Never replace CLAUDE.md** — only merge (via bootstrap)
4. **Report clearly** what will happen at each step before doing it
5. If in-flight GSD work exists, advise finishing it manually first

## Upgrading from CKS v1 (6-step) to CKS v2 (5-phase)

If you already have CKS installed but are using the old 6-step workflow (discuss → plan → execute → verify → ship → retro), run:

```
/cks:upgrade
```

This maps old statuses to new ones, adds Phase 2/4 markers for completed work, and preserves all existing artifacts. See `/cks:upgrade` for details.

## Reference

For the full migration guide, see `${CLAUDE_PLUGIN_ROOT}/docs/MIGRATION-GSD.md`.
