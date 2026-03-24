# Skills

Skill definitions with workflows, references, and templates. Each subdirectory is a self-contained skill with a `SKILL.md` entry point.

## Available Skills

| Skill | Purpose | Key Commands |
|-------|---------|-------------|
| `kickstart/` | Project enabler — idea to implementation-ready | `/cks:kickstart` |
| `cicd-starter/` | Bootstrap project architecture + Railway deploy | `/cks:bootstrap`, `/cks:virginize` |
| `prd/` | Feature lifecycle — discuss, plan, execute, verify, ship | `/cks:new`, `/cks:discuss`, `/cks:ship`, etc. |
| `monetize/` | Business model evaluation with Perplexity research | `/cks:monetize:*` |
| `aeo-geo/` | Answer Engine / Generative Engine Optimization | `/cks:seo-audit` |
| `seo-local/` | Local SEO for rank-and-rent sites | — |
| `deep-research/` | Multi-hop recursive research with configurable sources | `/cks:research` |
| `retrospective/` | Self-learning after ship — conventions, metrics, CLAUDE.md proposals | `/cks:retro` |

## Skill Structure

```
skill-name/
├── SKILL.md              Entry point — frontmatter + orchestration logic
├── workflows/            Phase-specific workflow definitions
│   ├── phase-1.md
│   └── phase-2.md
├── references/           Static reference data (templates, catalogs, glossaries)
│   └── reference.md
└── templates/            Output templates (optional)
    └── template.md
```

## How Skills Work

1. A command (e.g., `/cks:kickstart`) triggers a skill
2. `SKILL.md` is loaded — its frontmatter defines when the skill activates
3. The skill reads workflow files sequentially as phases execute
4. Each workflow produces artifacts (`.md` files in project directories)
5. Skills can invoke other skills (e.g., `/cks:kickstart` invokes `/cks:monetize`)

## Environment Variables

Some skills require API keys in `.env.local`:

| Variable | Used By |
|----------|---------|
| `PERPLEXITY_API_KEY` | `kickstart/` (research), `monetize/` (research) |
