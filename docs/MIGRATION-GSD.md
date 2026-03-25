# Migrating from GSD Plugin to CKS — Safe Adoption Guide

## What Lives Where

There are **three separate things** to keep straight:

| Thing | Where it lives | Who owns it |
|-------|---------------|-------------|
| **GSD Plugin** | `~/.claude/plugins/cache/gsd-...` | The GSD plugin repo |
| **CKS Plugin** | `~/.claude/plugins/cache/cks-...` | The CKS plugin repo |
| **Your project's .claude/** | `your-project/.claude/` | **You** |

**Key insight:** Your project's `.claude/` directory (agents, skills, commands, CLAUDE.md) is **yours**. Neither GSD nor CKS owns it. Plugins are external — they add namespaced commands (`/gsd:*` or `/cks:*`) but don't modify your project files unless you explicitly run a command like `/cks:bootstrap`.

---

## Quick Migration (Per Project)

### 1. Install CKS (global, one-time)

```bash
claude /plugin add cardinalconseils/claude-starter
```

Installs to `~/.claude/plugins/`, not your project. Safe, additive, instant.

### 2. Disable GSD (global, one-time)

```bash
claude plugin disable gsd@<marketplace-name>
# or remove entirely:
claude plugin remove gsd@<marketplace-name>
```

Prevents command conflicts. Your project files are untouched.

### 3. Keep Your Project's .claude/ As-Is

Your existing `.claude/` directory with custom agents, skills, commands — **keep all of it**. CKS doesn't replace these. They coexist:

- Your project agents (e.g., `.claude/agents/my-agent.md`) stay as they are
- Your project skills stay as they are
- Your project commands stay as they are
- CKS adds its own commands under the `/cks:` namespace

### 4. Run `/cks:bootstrap` in Your Project

```
/cks:bootstrap
```

This does:
1. **Scans your codebase** (read-only analysis)
2. **Asks guided questions** (pre-filled from scan results)
3. **Handles CLAUDE.md carefully:**
   - If you already have one → offers **update** (merge CKS sections in) or **cancel** (skip)
   - If you don't → generates a fresh one
4. **Creates `.prd/` directory** with lifecycle state files

### 5. Clean Up GSD Artifacts (If Any)

If GSD created planning directories in your project (e.g., `.gsd/`):
- Archive them: `mv .gsd/ .gsd-archive/`
- Or delete them if you don't need the history

**Do NOT delete your `.claude/` directory** — that's your project setup, not GSD's.

### 6. Start Using CKS

```
/cks:new "feature brief"     → Full lifecycle: discuss → plan → execute → verify → ship
/cks:next                     → Auto-advance to next step
/cks:go commit                → Smart commit
/cks:go pr                    → Commit + push + PR
/cks:doctor                   → Health check
/cks:status                   → Where am I?
```

---

## In-Flight Work

If you have features mid-development under GSD's system:
- **Finish them manually** (commit, PR, merge) before switching
- Or start fresh with CKS — run `/cks:new` for your next feature

CKS doesn't know about GSD's state files. Any new work will be tracked in `.prd/PRD-STATE.md` from day one.

---

## What Gets Destroyed? Nothing.

| Component | What happens |
|-----------|-------------|
| Your `.claude/agents/` | **Untouched** |
| Your `.claude/skills/` | **Untouched** |
| Your `.claude/commands/` | **Untouched** |
| Your `CLAUDE.md` | **Updated** (merge) or **skipped** — your choice |
| GSD plugin | **Disabled/removed** from global plugins |
| CKS plugin | **Installed globally** — available via `/cks:*` |
| New `.prd/` directory | **Created** by bootstrap |

---

## Verification

After migration, verify everything works:

```bash
claude plugin list              # CKS shows up, GSD is gone
```

```
/cks:status                     # Shows project state
/cks:help                       # Lists all available commands
```

Your existing custom commands still work (no `/cks:` prefix needed for project-local commands).

---

## Automated Migration

Run `/cks:migrate` for a guided, interactive walkthrough that assesses your current state and walks you through each step safely.
