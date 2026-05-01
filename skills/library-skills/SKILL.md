---
name: library-skills
description: "Library-skills integration — installs official AI skills from Python/JS packages into .claude/skills/ for always-current library patterns. Use when: FastAPI detected, Streamlit detected, setting up a Python project, or keeping library skills up to date after a package upgrade."
allowed-tools: Bash, Read
---

# Library Skills

Official AI skills embedded in packages like FastAPI and Streamlit — installed as symlinks into `.claude/skills/` so Claude Code always has current library patterns without training-cutoff lag.

## What It Is

`library-skills` ([github.com/tiangolo/library-skills](https://github.com/tiangolo/library-skills)) is a CLI that scans your installed Python or JS/TS packages, finds packages with embedded AI skills, and installs those skills as symlinks in `.claude/skills/`. Claude Code auto-loads everything in `.claude/skills/` at session start, so agents always work from the version-accurate patterns that ship with the library itself.

Created by Tiangolo (creator of FastAPI). The underlying format is the open Agent Skills standard (agentskills.io), adopted by Claude Code, Cursor, GitHub Copilot, Gemini CLI, and others.

## Supported Libraries

**Python (known):**
- FastAPI
- Streamlit

Check [agentskills.io](https://agentskills.io) for the full and growing registry.

## Commands

**Python:**
```bash
uvx library-skills --claude
```

**JS/TypeScript:**
```bash
npx library-skills --claude
```

The `--claude` flag installs skills into `.claude/skills/` instead of the default `.agents/` directory.

## When to Run

- During `/cks:bootstrap` when FastAPI or Streamlit is detected in the Python stack
- After `pip install fastapi` or `pip install streamlit` in a project not yet bootstrapped
- After upgrading FastAPI to a major version (symlinks auto-update on minor updates; re-run for fresh installs)

## What Gets Installed

Skills install to `.claude/skills/{library-name}/` as **symlinks** that point to the skill files inside the installed package. This means:
- Upgrading the library (`pip install --upgrade fastapi`) automatically updates the skill
- No separate maintenance — the skill version always matches the library version
- The symlink target lives in your Python environment's site-packages

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "context7 already has FastAPI docs" | context7 may lag; library-skills is the official skill from the FastAPI team, always in sync with the *installed* version |
| "Our agents already know FastAPI" | Training data has a cutoff; new FastAPI features (dependency overrides, lifespan, response models) may post-date training |
| "We can skip this for small projects" | It's a one-line install with zero ongoing maintenance — always worth running |
| "uvx isn't installed on this machine" | Install with `pip install uv`; note it in CLAUDE.md so the next developer knows to run it |

## Verification

- [ ] `ls .claude/skills/` shows the installed library folder
- [ ] `.claude/skills/fastapi/` exists (as a directory or symlink)
- [ ] New Claude Code session log mentions the FastAPI skill loaded at startup
