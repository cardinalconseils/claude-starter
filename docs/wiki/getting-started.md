# Getting Started

## Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/cardinalconseils/claude-starter/main/install.sh)
```

Restart Claude Code after the install completes. All commands are available immediately under the `/cks:` prefix.

## What Happens After Install

On the first session in any project, CKS detects that it hasn't been configured there and shows:

```
CKS — First time in this project
  /cks:adopt       → Mid-development? Adopt CKS into your current work
  /cks:bootstrap   → Fresh start with CKS lifecycle for this project
  /cks:kickstart   → Got an idea? Go from idea to scaffolded project
```

Pick the entry point that matches where you are.

## Three Entry Points

### `/cks:kickstart` — Starting from an idea

Use this when you have an idea but no code yet. It walks you through:

1. Idea brainstorming and refinement
2. Market research and monetization evaluation
3. Brand identity and positioning
4. Technical design — ERD, schema, API contract, architecture
5. Project scaffold — creates the codebase structure

At the end you have a scaffolded project ready to develop.

### `/cks:bootstrap` — Setting up an existing scaffold

Use this when you have a fresh codebase (from any scaffold) and want to initialize the CKS lifecycle. It generates:

- `CLAUDE.md` — project context file Claude Code reads on every session
- `.prd/` — state files that track feature progress
- `.claude/rules/` — guardrail files scoped to your tech stack

### `/cks:adopt` — Joining mid-development

Use this when you already have working code and want CKS to help you ship what you're building. It:

- Scans your git history and existing code
- Generates a `CLAUDE.md` from what it finds
- Detects secrets and environment variables
- Drops you directly into the sprint phase

Skips discovery and design — you're already past that.

## The 5-Phase Lifecycle at a Glance

Every feature follows the same path. Start with `/cks:new`, advance with `/cks:next`:

| Phase | Command | What Happens |
|-------|---------|-------------|
| 1 — Discovery | `/cks:discover` | Gather requirements: problem statement, user stories, scope, API surface, acceptance criteria, test plan |
| 2 — Design | `/cks:design` | UX flows, API contract, screen generation, component specs |
| 3 — Sprint | `/cks:sprint` | Plan, build, code review, QA, UAT, merge |
| 4 — Review | `/cks:review` | Feedback and iteration decision — fix bugs, adjust UX, or proceed to release |
| 5 — Release | `/cks:release` | Environment promotion: Dev → Staging → RC → Production |

```
/cks:new "add user login"
  → /cks:discover    (define what it means)
  → /cks:design      (how it looks and works)
  → /cks:sprint      (build it)
  → /cks:review      (verify it)
  → /cks:release     (ship it)
```

If review reveals issues, CKS routes you back to the right phase automatically — back to design for UX problems, back to sprint for bugs, back to discovery if scope changed.

## Daily Work

Once a project is set up, most work uses just a few commands:

```
/cks:go          build → commit → push → open PR
/cks:next        advance to the next phase
/cks:sprint-start  load full context at the start of a session
/cks:sprint-close  capture learnings at the end of a session
```

See [Commands Reference](commands.md) for the full list.
