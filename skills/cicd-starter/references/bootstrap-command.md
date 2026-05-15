# /bootstrap Command Reference

Quick reference for the 9-step bootstrap workflow. Full details in `workflows/bootstrap.md`.

---

## Pre-flight (Step 1)

Two checks before starting:

1. **Kickstart detection** — if `.kickstart/state.md` exists and is in progress, offer to resume kickstart instead
2. **CLAUDE.md check** — if it exists, offer Update / Regenerate / Cancel

---

## Codebase Scan (Step 2)

Silent detection via bash commands. Store findings for Steps 4-6.

| Category | How Detected | Examples |
|----------|-------------|----------|
| Framework | `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod` | Next.js, FastAPI, Express |
| Auth | grep for `clerk`, `supabase-auth`, `next-auth`, `passport`, `jwt`, `lucia` | Clerk, NextAuth |
| Database | grep for `prisma`, `drizzle`, `mongoose`, `supabase`, `knex` | Prisma, Drizzle |
| API style | directory listing + grep for GraphQL/tRPC patterns | REST, GraphQL, tRPC |
| Testing | config file detection (`jest.config*`, `vitest.config*`, `pytest.ini`) | Jest, Vitest |
| Styling | grep for `tailwind`, `styled-components`, `emotion` | Tailwind |
| Linting | config file detection (`.eslintrc*`, `biome.json`) | ESLint, Biome |
| Deploy | config file detection (`railway.toml`, `vercel.json`, `Dockerfile`) | Railway, Vercel |
| Env vars | grep for `process.env.*`, `os.environ[]` in source + scan `.env*` files | — |

---

## Guided Intake (Step 3)

5 questions max. Skip if `.kickstart/bootstrap-context.md` provides pre-filled answers.

| Question | Purpose | Auto-detect |
|----------|---------|-------------|
| Q0: Profile | `app / website / library / api` | `.claude-plugin/` → App, `index.html` no server → Website |
| Q1: Confirm scan | Present scan results for validation | All from Step 2 |
| Q2: Name + desc | Project identity | From `package.json` name or directory |
| Q3: Workflows | What user mainly works on | From detected API, UI, DB patterns |
| Q4: Rules | Custom always-follow rules | Defaults provided |

---

## CLAUDE.md Generation (Step 4)

**Hard rules:**
- 150 lines max
- Zero placeholders — every line must be real, project-specific content
- No style rules (those go in `.claude/rules/`)
- No agent/command listings (just 5-6 daily-use commands)
- Template: `references/claude-md-template.md`

---

## Project Structure (Step 5)

Creates all CKS infrastructure:

| File / Directory | Notes |
|-----------------|-------|
| `.prd/PRD-STATE.md` | Must include `Iteration Count`, `Iteration Reason`, `Secrets Tracking` fields |
| `.prd/PRD-PROJECT.md` | Boilerplate → enriched in Step 7 |
| `.prd/PRD-ROADMAP.md` | Empty or from kickstart artifacts |
| `.prd/PRD-REQUIREMENTS.md` | Empty table |
| `.prd/.cks-version` | Plugin version string — stamped at bootstrap time |
| `.prd/logs/` | Directory |
| `.prd/logs/lifecycle.jsonl` | Bootstrap event entry |
| `.prd/phases/` | Directory |
| `.prd/backups/` | Directory |
| `.prd/prd-config.json` | `{"versioning":{"enabled":true,"strategy":"auto-patch","changelog":true},"profile":"default","migrated_from":"bootstrap"}` |
| `.learnings/` | Empty directory |
| `.monetize/phases/` | Directory |
| `.context/` | Directory |
| `.context/config.md` | Auto-detects preferred research sites |
| `.claude/settings.local.json` | Agent teams enabled |
| `.env.example` | From env var scan |
| `.gitignore` | Stack-appropriate + `.prd/logs/.current_session_id` entry |

---

## Rule Generation (Step 6)

| Sub-step | Skill | Output | Condition |
|----------|-------|--------|-----------|
| 6a | `language-rules` | `.claude/rules/{language}.md` | Per detected language |
| 6b | `guardrails` | `.claude/rules/security.md` | If API routes or auth |
| 6b | `guardrails` | `.claude/rules/testing.md` | If test framework |
| 6b | `guardrails` | `.claude/rules/database.md` | If ORM/DB client |
| 6b | `guardrails` | `.claude/rules/docs.md` | Always |

---

## Auto-Chain (Step 9)

After completion report, automatically:
1. Ask for first feature → `AskUserQuestion`
2. Invoke `/cks:new` with answer
3. Validate `.prd/phases/01-{name}/` exists (retry once if not)
4. Invoke `/cks:next` → auto-triggers `/cks:discover`
