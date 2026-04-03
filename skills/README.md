# Skills

Skill definitions with workflows, references, and templates. Each subdirectory is a self-contained skill with a `SKILL.md` entry point.

## Available Skills

| Skill | Purpose | Key Commands |
|-------|---------|-------------|
| `kickstart/` | Project enabler — idea → research → monetize → brand → design (ERD, schema.sql, PRD, API, architecture) → scaffold | `/cks:kickstart` |
| `cicd-starter/` | Bootstrap project architecture + Railway deploy | `/cks:bootstrap`, `/cks:virginize` |
| `prd/` | 5-phase feature lifecycle — discover, design, sprint, review, release | `/cks:new`, `/cks:discover`, `/cks:sprint`, etc. |
| `api-docs/` | Auto-generate API documentation from codebase analysis | `/cks:docs` |
| `context-research/` | Quick coding reference lookup — research a library/API → `.context/` | `/cks:context` |
| `deep-research/` | Multi-hop recursive research with configurable sources | `/cks:research` |
| `language-rules/` | Stack-specific coding rules — generated at bootstrap time | `/cks:bootstrap` |
| `monetize/` | Business model evaluation (Perplexity API or WebSearch fallback) | `/cks:monetize:*` |
| `retrospective/` | Self-learning after ship — conventions, metrics, CLAUDE.md proposals | `/cks:retro` |
| `guardrails/` | Domain guardrail rules — scoped `.claude/rules/` files for security, testing, DB, docs | `/cks:bootstrap` |
| `no-code/` | No-code automation — build/debug/migrate/optimize workflows (n8n, Make, Workato, Zapier) | `/cks:no-code` |
| `aeo-geo/` | Answer Engine / Generative Engine Optimization | `/cks:seo-audit` |
| `seo-local/` | Local SEO for rank-and-rent sites | — |
| `ideation/` | Brainstorming frameworks — SCAMPER, problem-first, solution-first, stress testing | `/cks:ideate` |
| `migrations/` | Version-aware state file migration — detects version gaps, applies structural changes | `/cks:migrate` |
| `debug/` | Debugging methodology — structured diagnosis for app errors and CKS self-debug | `/cks:debug` |

## Skill Structure

```
skill-name/
├── SKILL.md              Entry point — frontmatter + orchestration logic
├── workflows/            Phase-specific workflow definitions
│   ├── phase.md          Orchestrator — thin router to sub-steps (<80 lines)
│   ├── phase/            Sub-step directory
│   │   ├── _shared.md    Shared context (banner template, variables)
│   │   ├── step-0-*.md   Individual steps (<100 lines each)
│   │   └── step-N-*.md
│   └── secrets/          Cross-cutting hooks (secrets lifecycle)
├── references/           Static reference data (templates, catalogs, glossaries)
│   └── reference.md
└── templates/            Output templates (optional)
    └── template.md
```

## How Skills Work

1. A command (e.g., `/cks:kickstart`) triggers a skill
2. `SKILL.md` is loaded — its frontmatter defines when the skill activates
3. The skill reads an **orchestrator** workflow file
4. The orchestrator reads sub-step files one at a time via `Read + execute`
5. Each sub-step produces artifacts (`.md` files in project directories)
6. Cross-cutting hooks (e.g., secrets) are invoked at defined integration points
7. Skills can invoke other skills (e.g., `/cks:kickstart` invokes `/cks:monetize`)

## Chunked Workflow Pattern

Workflows follow a **thin orchestrator + sub-step** pattern. The orchestrator is under 80 lines and routes through sub-steps:

```markdown
### Step 4: Dispatch Agent
Read ${SKILL_ROOT}/workflows/discover-phase/step-4-elements.md
Execute its instructions.
```

Each sub-step follows a standard format:
- `<context>` block: phase, requires, produces
- `## Inputs`: file paths to read
- `## Instructions`: actual logic (<100 lines)
- `## Success Condition`: how to verify
- `## On Failure`: retry, ask user, or skip

## Environment Variables

Some skills require API keys in `.env.local`:

| Variable | Used By | Required? |
|----------|---------|-----------|
| `PERPLEXITY_API_KEY` | `kickstart/` (research), `monetize/` (research), `deep-research/` | Optional — falls back to WebSearch |

## Review & Customize

Skills are opinionated starting points, not immutable rules. After installing CKS, review and adapt them to your needs:

1. **SKILL.md frontmatter** — Each skill has `allowed-tools` (tool restrictions) and `model` (cost/quality trade-off) that you can adjust
2. **## Customization section** — Every SKILL.md lists what you can change and where to find it
3. **Workflow files** (`workflows/`) — Edit process steps, gate criteria, and phase logic
4. **Reference files** (`references/`, `catalogs/`) — Tune domain knowledge, templates, and rule catalogs
5. **Templates** (`templates/`) — Change output document formats

After installation, these files are yours. Customize freely.
