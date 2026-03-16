# Starter Repo Sync Reference

Complete git subtree workflows for keeping `claude-starter` and project `.claude/` folders in sync.

---

## Initial Setup (one time per project)

```bash
# Add claude-starter as a subtree source
git subtree add \
  --prefix .claude \
  https://github.com/YOU/claude-starter.git main \
  --squash

# Commit message suggestion:
# "chore: add claude-starter .claude/ subtree"
```

This pulls the entire `.claude/` folder from the starter repo into your project as a first-class part of the repo — no external dependency at runtime.

---

## Pull Updates FROM Starter INTO Project

Use when you've added new skills/agents/commands to `claude-starter` and want them in an existing project.

```bash
git subtree pull \
  --prefix .claude \
  https://github.com/YOU/claude-starter.git main \
  --squash
```

**What happens:**
- New files in starter are added to your project's `.claude/`
- Existing files updated in starter overwrite your project's version
- ⚠️ If you've adapted files locally (bootstrap), resolve conflicts manually — keep your project-specific wording

**Conflict resolution rule:**
- Keep your adapted `description:` frontmatter
- Accept upstream body changes (new instructions, better templates)

---

## Push New Components BACK to Starter

Use when you've built something new in a project that belongs in the starter library.

```bash
git subtree push \
  --prefix .claude \
  https://github.com/YOU/claude-starter.git main
```

**Before pushing, verify the file is generic:**
- [ ] No project-specific names in the body
- [ ] Description is generic, not project-scoped
- [ ] No hardcoded URLs, service names, or env var values
- [ ] Works as a template for any future project

If the file IS project-specific, strip it first:
1. Copy to `/tmp/` 
2. Revert project-specific wording to generic placeholders
3. Then push

---

## Recommended Repo Structure

```
claude-starter/                        ← GitHub repo
├── .claude/
│   ├── skills/
│   │   ├── docx.md                   ← Generic, reusable
│   │   ├── n8n-workflows.md
│   │   ├── supabase.md
│   │   └── cicd-claude.md            ← This skill
│   ├── agents/
│   │   ├── reviewer.md               ← Generic code reviewer
│   │   ├── deployer.md               ← Generic deployer
│   │   └── qa.md
│   ├── commands/
│   │   ├── bootstrap.md              ← /bootstrap trigger
│   │   ├── deploy.md                 ← Generic deploy flow
│   │   └── test.md
│   └── tools/
│       ├── railway.md
│       ├── github.md
│       └── supabase.md
├── CLAUDE.md.template                 ← NOT project-specific
└── README.md                          ← How to use the starter
```

**Rule:** `claude-starter` contains ZERO project-specific content. Everything is a template.

---

## Versioning Strategy

Tag starter repo releases to pin projects to a known-good version:

```bash
# In claude-starter repo — tag a release
git tag v1.2.0 -m "Add QA agent, update deploy command for Railway v2"
git push origin v1.2.0

# In a project — pull a specific tag instead of main
git subtree pull \
  --prefix .claude \
  https://github.com/YOU/claude-starter.git v1.2.0 \
  --squash
```

This lets mature projects stay stable while new projects get the latest.

---

## Quick Reference Card

| Goal | Command |
|------|---------|
| First time setup | `git subtree add --prefix .claude [repo] main --squash` |
| Pull latest starter updates | `git subtree pull --prefix .claude [repo] main --squash` |
| Push new generic component to starter | `git subtree push --prefix .claude [repo] main` |
| Pin to a specific starter version | `git subtree pull --prefix .claude [repo] v1.2.0 --squash` |
| Run /bootstrap after pulling | `/bootstrap` in Claude Code |

---

## After Pulling Updates — Always Re-bootstrap

After any `git subtree pull`, re-run `/bootstrap` to re-adapt the new/updated files to your project context:

```bash
git subtree pull --prefix .claude https://github.com/YOU/claude-starter.git main --squash
# Then in Claude Code:
/bootstrap
```

Bootstrap is idempotent — safe to run multiple times. It only overwrites CLAUDE.md and description fields, never deletes files.
