# Commands

Slash commands available in this project. Each `.md` file defines one command. Subdirectories (like `prd/`, `monetize/`) contain sub-commands.

## Available Commands

| Command | Purpose |
|---------|---------|
| `/kickstart` | Project enabler — idea to artifacts to bootstrap |
| `/bootstrap` | Adapt `.claude/` to the current project |
| `/deploy` | Deploy to Railway |
| `/test` | Run test suite |
| `/review` | Code review a PR or file |
| `/virginize` | Strip project-specific content for starter repo |
| `/status` | Project health overview |
| `/browse` | Browser automation |
| `/decide` | Stop asking, diagnose and act |
| `/seo-audit` | Full SEO audit |

## Sub-command Directories

| Directory | Commands |
|-----------|----------|
| `prd/` | `/prd:new`, `/prd:discuss`, `/prd:plan`, `/prd:execute`, `/prd:verify`, `/prd:ship`, `/prd:autonomous`, etc. |
| `monetize/` | `/monetize:discover`, `/monetize:research`, `/monetize:evaluate`, `/monetize:report`, `/monetize:roadmap` |

## Lifecycle Order

```
/kickstart → /bootstrap → /prd:discuss → /prd:plan → /prd:execute → /prd:verify → /prd:ship
```
