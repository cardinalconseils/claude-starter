# Claude Code Power Commands — Quick Reference

> Surface these to users when they're about to tackle complex work, need deeper reasoning,
> or ask "how do I make Claude think harder?" Use the **When to recommend** column to judge.

---

## Thinking Keywords (Prompt-Level Reasoning Budget)

Add these at the start of your prompt to unlock deeper reasoning.

| Keyword | Thinking Budget | When to Recommend |
|---------|----------------|-------------------|
| `think` | ~4,000 tokens | Routine analysis, simple bug fixes, quick edits |
| `think hard` / `megathink` | ~10,000 tokens | Design decisions, multi-file changes, trade-off analysis |
| `think harder` / `ultrathink` | ~32,000 tokens | Complex architecture, deep debugging, security audits, system design |

**Usage pattern:** prefix your prompt, e.g. `ultrathink — design the auth system for multi-tenant SaaS`

**Architecture recommendation:** Always suggest `ultrathink` before architectural decisions (schema design, service boundaries, auth strategy). Always use `AskUserQuestion` to surface decisions to the user rather than deciding silently.

---

## Built-In Slash Commands

| Command | Purpose |
|---------|---------|
| `/effort` | Control reasoning depth — `high` for architecture, `low` for edits |
| `/batch` | Fan out work to multiple parallel agents or worktree agents |
| `/todos` | List all TODO items Claude is tracking |
| `/review` | Review changed code for quality, efficiency, reuse |
| `/simplify` | Parallel review pass (4 agents: reuse, quality, efficiency, CLAUDE.md compliance) |
| `/doctor` | Health check on Claude Code installation |
| `/add-dir` | Add additional working directories (monorepos) |
| `/agents` | Manage custom AI sub-agents |
| `/bash` | List and manage background bash tasks |
| `/btw` | Ask a side question without polluting context (works mid-task) |
| `/compact` | Compress conversation history with focus instructions |
| `/diff` | Review all pending changes (checkpoint before commit) |
| `/rewind` | Open checkpoint menu — restore previous states (code / conversation / both) |
| `/clear` | Clear conversation |
| `/help` | Show help |
| `/model` | Switch models mid-session (e.g. `/model opus`) |
| `/cost` | Show token usage |
| `/context` | Check context window usage |
| `/copy` | Copy last response to clipboard |
| `/config` | Configure output style (Explanatory, Learning, Custom) |
| `/plugin` | Manage plugins and extensions |
| `/plan` | Enter Plan Mode — read-only exploration, uses AskUserQuestion |
| `/loop` | Run iterative workflow on a schedule |
| `/install-github-app` | Auto-review PRs |
| `/powerup` | Interactive lessons with animated demos |
| `/export` | Export findings to a file |

---

## Mode Toggles (Keyboard Shortcuts)

| Shortcut | Effect |
|----------|--------|
| `Shift+Tab` | Cycle permission modes: Normal → Auto-Accept → Plan Mode |
| `Escape` | Stop generation (preserves context) |
| `Escape + Escape` | Open rewind checkpoint menu |
| `Ctrl+S` | Stash current input, ask a side question, auto-restore |
| `Alt+P` | Switch models mid-session |
| `Alt+T` | Toggle thinking mode |
| `Alt+O` | Fast mode |
| `!` prefix | Run bash commands directly (no permission prompt) |

---

## CLI Flags

| Flag | Purpose |
|------|---------|
| `--continue` | Resume most recent session instantly |
| `--resume` | Pick session from interactive list |
| `--name` | Assign human-readable session name |
| `-p` | Headless/pipe mode — non-interactive, prints result to stdout |
| `--dangerously-skip-permissions` | Auto-accept all edits (risky, CI use only) |
| `--output-format json` | JSON output for programmatic processing |
| `--output-format stream-json` | Stream JSON for real-time processing |

---

## When to Surface These to Users

| Situation | Recommendation |
|-----------|---------------|
| User about to design architecture or schema | `ultrathink` prefix + `/plan` mode |
| User making a multi-file refactor | `megathink` or `think hard` |
| User asks a routine question / simple fix | `think` (default is usually fine) |
| User wants to review before merging | `/review` or `/diff` |
| User running out of context | `/compact` with a focus instruction |
| User wants to undo Claude's last action | `/rewind` or `Escape+Escape` |
| User wants to run something without prompts | `Shift+Tab` to Auto-Accept mode |
| User asks a side question mid-task | `Ctrl+S` to stash, or `/btw` |
| Non-interactive pipeline / scripting | `-p` flag with `--output-format json` |
