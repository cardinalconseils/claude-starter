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

## PRD Commands

| Command | Purpose |
|---------|---------|
| `/cks:prd-new` | Initialize project and run full lifecycle |
| `/cks:prd-discuss` | Interactive discovery session for a feature |
| `/cks:prd-plan` | Write PRD and execution plan |
| `/cks:prd-execute` | Implement the next planned phase |
| `/cks:prd-verify` | Verify acceptance criteria |
| `/cks:prd-ship` | Commit, PR, review, deploy |
| `/cks:prd-autonomous` | Run all phases automatically |
| `/cks:prd-status` | Quick roadmap overview |
| `/cks:prd-progress` | Show project progress |
| `/cks:prd-next` | Auto-advance to next step |
| `/cks:prd-refactor` | Refactor with safety checks |
| `/cks:prd-evaluate` | Process evaluator feature |
| `/cks:prd-map-codebase` | Analyze codebase structure |
| `/cks:prd-help` | Show usage guide |

## Monetize Commands

| Command | Purpose |
|---------|---------|
| `/cks:monetize` | Full evaluation: discover → research → evaluate → report → roadmap |
| `/cks:monetize-discover` | Discovery + context gathering |
| `/cks:monetize-research` | Perplexity API market research |
| `/cks:monetize-evaluate` | Model scoring + stack recommendation |
| `/cks:monetize-report` | Generate assessment report |
| `/cks:monetize-roadmap` | Generate roadmap + PRD handoff |

## Lifecycle Order

```
/cks:kickstart → /cks:bootstrap → /cks:prd-discuss → /cks:prd-plan → /cks:prd-execute → /cks:prd-verify → /cks:prd-ship
```
