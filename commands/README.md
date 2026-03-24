# Commands

Slash commands available via the CKS plugin. Each `.md` file defines one command. Subdirectories (like `prd/`, `monetize/`) contain sub-commands.

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

## Sub-command Directories

| Directory | Commands |
|-----------|----------|
| `prd/` | `/cks:prd:new`, `/cks:prd:discuss`, `/cks:prd:plan`, `/cks:prd:execute`, `/cks:prd:verify`, `/cks:prd:ship`, `/cks:prd:autonomous`, etc. |
| `monetize/` | `/cks:monetize:discover`, `/cks:monetize:research`, `/cks:monetize:evaluate`, `/cks:monetize:report`, `/cks:monetize:roadmap` |

## Lifecycle Order

```
/cks:kickstart → /cks:bootstrap → /cks:prd:discuss → /cks:prd:plan → /cks:prd:execute → /cks:prd:verify → /cks:prd:ship
```
