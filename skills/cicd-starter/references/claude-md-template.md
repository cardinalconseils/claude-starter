# CLAUDE.md Template Reference

Use this template when generating CLAUDE.md during `/cks:bootstrap`. Replace ALL tokens with project-specific content from the intake.

## Hard Rules

- **150 lines max.** This is a constitution, not a manual. Every line must earn its place.
- **Zero placeholders.** Every `[TOKEN]` must be replaced with real content. If unknown, omit the line.
- **No style rules here.** Language conventions, coding style, and formatting rules belong in `.claude/rules/` (generated automatically by bootstrap). CLAUDE.md covers *what* and *why*, rules cover *how*.
- **No agent/command docs.** Don't list every CKS command — just the 5-6 the user actually uses daily.
- **Update at sprint-close, not mid-sprint.** Changes mid-session cause drift.

## What Goes Where

| Content | Location | Why |
|---------|----------|-----|
| Project identity, stack, constraints | `CLAUDE.md` | Always loaded, sets global context |
| TypeScript/Python/Go coding rules | `.claude/rules/{lang}.md` | Loaded only when editing code files |
| Security patterns (auth, input validation) | `.claude/rules/security.md` | Loaded only when editing API/auth files |
| Test conventions | `.claude/rules/testing.md` | Loaded only when editing test files |
| Database safety | `.claude/rules/database.md` | Loaded only when editing DB/migration files |
| Documentation standards | `.claude/rules/docs.md` | Loaded only when editing markdown/docs |
| Coding behavior (Karpathy principles) | `.claude/rules/karpathy.md` | Always loaded — never embed in CLAUDE.md |

---

## Template

```markdown
# {PROJECT_NAME}

## What This Project Is
{2-4 sentences. What it does, who it's for, what stage it's in.}

## Stack
- **{Framework}** ({version}): {one-line convention, e.g. "App Router, server components by default"}
- **{Language}**: {version, strict mode}
- **{Database}**: {ORM, schema location, migration command}
- **{Auth}**: {provider, where config lives}
- **{Styling}**: {framework, config file}
- **{Deployment}**: {platform, deploy trigger}

## Project Structure
{Annotated tree of key directories — 10-15 lines max}

## Key Workflows

### Running the Project
- Dev: `{command}`
- Build: `{command}`
- Test: `{command}`
- Lint: `{command}`

### Adding a New Feature
{2-3 sentences: where to create files, what patterns to follow}

## Commands
- `/cks:go` — Build + commit + push + PR
- `/cks:new` — Plan a new feature
- `/cks:sprint-start` — Load context at session start
- `/cks:sprint-close` — Audit rules + capture learnings at session end
- `/cks:status` — Project dashboard
- `/cks:help` — All commands

## Critical Constraints
{Non-negotiables that apply everywhere. 3-7 bullets max.}
- Never expose API keys or secrets in code
- {stack-specific, e.g. "Never bypass RLS policies in Supabase"}
- {project-specific from user intake}

## Environment Variables
| Variable | Purpose | Required |
|----------|---------|----------|
| {VAR} | {purpose} | {yes/no} |

## Do Not
- Modify production database without explicit confirmation
- Commit secrets or env var values
- Deploy without passing health check
- {stack-specific, e.g. "Use `any` type in TypeScript"}
```

---

## Adaptation Notes

- If no constraints from user intake, use only the universal defaults (secrets, prod DB, health check)
- Stack section must name actual tools detected in scan, not generic categories
- "Key Workflows" should reflect detected scripts from package.json, not aspirational workflows
- If project has no tests yet, still include the test command line but note: `Test: (not configured — add with /cks:tdd)`
- The file must read as if written by someone who deeply understands this specific project
- Count lines before finishing — if over 150, cut the least critical section
- Guardrails (.claude/rules/) handle style, security, testing, database, and docs rules — do NOT duplicate them in CLAUDE.md
