# CKS — Claude Code Starter Kit

A Claude Code plugin providing full-lifecycle project management — from idea to production. Skills, agents, commands, and tools for bootstrapping, PRD management, monetization strategy, SEO/AEO, and deployment.

---

## Install

```bash
claude /plugin add cardinalconseils/claude-starter
```

After install, all commands are available with the `/cks:` prefix.

---

## What's Inside

```
cks/
├── .claude-plugin/   ← Plugin manifest
├── commands/         ← Slash commands
├── agents/           ← Sub-agent definitions
├── skills/           ← Skills with workflows & references
└── tools/            ← External tool references
```

---

## Full Product Lifecycle

```
/cks:kickstart → /cks:bootstrap → /cks:prd:discuss → /cks:prd:plan → /cks:prd:execute → /cks:prd:verify → /cks:prd:ship
  discover        scaffold          refine              plan             build              test              deliver
```

| Command | What It Does |
|---------|-------------|
| `/cks:kickstart` | Takes an idea through guided Q&A, optional market research (Perplexity), optional monetization analysis, then generates PRD + ERD + architecture. Hands off to `/cks:bootstrap`. |
| `/cks:bootstrap` | Adapts all project files. Generates `CLAUDE.md`. |
| `/cks:monetize` | Business model evaluation — scores 12 revenue models with competitor research. |
| `/cks:prd:discuss` | Deep-dive a specific feature with interactive discovery. |
| `/cks:prd:plan` | Write the execution plan from discovery context. |
| `/cks:prd:execute` | Build the feature. |
| `/cks:prd:verify` | Check acceptance criteria pass. |
| `/cks:prd:ship` | Commit, PR, review, deploy. |
| `/cks:prd:autonomous` | Chain discuss → plan → execute → verify → ship automatically. |
| `/cks:deploy` | Deploy to Railway. |
| `/cks:test` | Run test suite. |
| `/cks:review` | Code review a PR or file. |
| `/cks:virginize` | Strip project-specific content for starter repo. |
| `/cks:status` | Project health overview. |
| `/cks:browse` | Browser automation. |
| `/cks:decide` | Stop asking — diagnose and act. |
| `/cks:seo-audit` | Full SEO audit. |

---

## Optional: API Keys

Add to `.env.local` for deep research and monetization features:
```
PERPLEXITY_API_KEY=your-key-here
```

---

## Adding Components

Just add files to the right directory — no config changes needed:

| To add | Create |
|--------|--------|
| Command | `commands/my-command.md` |
| Subcommand | `commands/prd/my-sub.md` → `/cks:prd:my-sub` |
| Agent | `agents/my-agent.md` |
| Skill | `skills/my-skill/SKILL.md` |

Then `git push` and `/reload-plugins` on any machine.

---

## Design Principles

- **Plugin format** — install once, works in every project on every machine
- **Auto-discovery** — add files, they're immediately available
- **Generic templates** — zero project-specific content; adapt via `/cks:bootstrap`
- **Full lifecycle** — idea → scaffold → build → test → ship in one toolkit
