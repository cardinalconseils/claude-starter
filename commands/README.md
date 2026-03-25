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

## PRD Commands

| Command | Purpose |
|---------|---------|
| `/cks:new` | Initialize project and run full lifecycle |
| `/cks:discuss` | Interactive discovery session for a feature |
| `/cks:plan` | Write PRD and execution plan |
| `/cks:execute` | Implement the next planned phase |
| `/cks:verify` | Verify acceptance criteria |
| `/cks:ship` | Commit, PR, review, deploy |
| `/cks:autonomous` | Run all phases automatically |
| `/cks:status` | Quick roadmap overview |
| `/cks:progress` | Show project progress |
| `/cks:next` | Auto-advance to next step |
| `/cks:refactor` | Refactor with safety checks |
| `/cks:evaluate` | Process evaluator feature |
| `/cks:map-codebase` | Analyze codebase structure |
| `/cks:help` | Show usage guide |

## Monetize Commands

| Command | Purpose |
|---------|---------|
| `/cks:monetize` | Full evaluation: discover → research → evaluate → report → roadmap |
| `/cks:monetize-discover` | Discovery + context gathering |
| `/cks:monetize-research` | Perplexity API market research |
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
/cks:kickstart → /cks:bootstrap → /cks:new → /cks:discuss → /cks:plan → /cks:execute → /cks:verify → /cks:ship → /cks:retro
```
