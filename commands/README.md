# Commands

Slash commands available via the CKS plugin. All commands use the `/cks:` prefix.

## Available Commands

| Command | Purpose |
|---------|---------|
| `/cks:kickstart` | Project enabler — idea to artifacts to bootstrap |
| `/cks:bootstrap` | Adapt project files and generate CLAUDE.md |
| `/cks:deploy` | Deploy to Railway |
| `/cks:test` | Run test suite |
| `/cks:review` | Code review a PR or file |
| `/cks:virginize` | Strip project-specific content for starter repo |
| `/cks:status` | Project health overview |
| `/cks:browse` | Browser automation |
| `/cks:decide` | Stop asking, diagnose and act |
| `/cks:seo-audit` | Full SEO audit |
| `/cks:monetize` | Full monetization evaluation |
| `/cks:research` | Deep multi-hop research on any topic |
| `/cks:retro` | Retrospective — extract learnings, propose conventions |

## 5-Phase Feature Lifecycle

| Command | Phase | Purpose |
|---------|-------|---------|
| `/cks:new "feature"` | — | Create feature entry → enters Phase 1 |
| `/cks:discover` | 1 | Discovery — gather 10 Elements (problem, stories, scope, API, criteria) |
| `/cks:design` | 2 | Design — UX flows, screen generation, component specs |
| `/cks:sprint` | 3 | Sprint — plan → build → review → QA → UAT → merge |
| `/cks:review` | 4 | Review & retro — feedback → iteration decision |
| `/cks:release` | 5 | Release — environment promotion (Dev → Staging → RC → Prod) |
| `/cks:next` | — | Auto-advance to next phase |
| `/cks:autonomous` | — | Run all 5 phases without stopping |
| `/cks:progress` | — | Show 5-phase dashboard + suggest next action |
| `/cks:status` | — | Quick roadmap overview |
| `/cks:refactor` | — | Refactor with safety checks |
| `/cks:map-codebase` | — | Analyze codebase structure |
| `/cks:help` | — | Show usage guide |

## Monetize Commands

| Command | Purpose |
|---------|---------|
| `/cks:monetize` | Full evaluation: discover → research → evaluate → report → roadmap |
| `/cks:monetize-discover` | Discovery + context gathering |
| `/cks:monetize-research` | Market research (Perplexity API or WebSearch fallback) |
| `/cks:monetize-evaluate` | Model scoring + stack recommendation |
| `/cks:monetize-report` | Generate assessment report |
| `/cks:monetize-roadmap` | Generate roadmap + PRD handoff |

## Research Commands

| Command | Purpose |
|---------|---------|
| `/cks:research` | Deep multi-hop recursive research (topic, competitive, tech eval) |
| `/cks:context` | Quick coding reference lookup → `.context/` |
| `/cks:retro` | Retrospective — analyze what worked, extract learnings |
| `/cks:retro --metrics` | Velocity dashboard |

## Lifecycle Order

```
/cks:kickstart → /cks:bootstrap → /cks:new → /cks:discover → /cks:design → /cks:sprint → /cks:review → /cks:release → /cks:retro
```
