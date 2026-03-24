# CKS — Claude Code Starter Kit

A Claude Code plugin providing full-lifecycle project management — from idea to production. Skills, agents, commands, hooks, and tools for bootstrapping, building, shipping, and maintaining projects.

---

## Install

```bash
claude /plugin add cardinalconseils/claude-starter
```

After install, all commands are available with the `/cks:` prefix.

---

## Commands at a Glance

### Lifecycle — From Idea to Shipped

The core pipeline. Each step feeds the next:

```
/cks:kickstart → /cks:new → /cks:discuss → /cks:plan → /cks:execute → /cks:verify → /cks:ship → /cks:retro
  discover        define      refine          plan          build           test          deliver    learn
```

| Command | What It Does |
|---------|-------------|
| `/cks:kickstart` | Idea → guided Q&A → market research → PRD + ERD + architecture → scaffold project |
| `/cks:new [brief]` | Initialize feature lifecycle + run full autonomous cycle |
| `/cks:discuss [phase]` | Interactive feature discovery (auto-researches technologies) |
| `/cks:plan [phase]` | Write PRD + execution plan from discovery context |
| `/cks:execute [phase]` | Build the feature |
| `/cks:verify [phase]` | Check acceptance criteria pass |
| `/cks:ship [phase\|all]` | Doctor → PR → changelog → CLAUDE.md update → review → deploy → retro |

### Quick Actions — Daily Development

One command for everything you do during development. PRD-aware — hints at lifecycle next steps.

```
/cks:go              build → commit → push → PR    (the daily driver)
/cks:go commit       stage + smart commit message
/cks:go pr           commit + push + open PR
/cks:go dev          auto-detect and start dev server
/cks:go build        auto-detect and run build
```

**How `/cks:go` fits into the lifecycle:**
```
/cks:execute                      ← build the feature
  ├── /cks:go dev                 ← dev server running while you work
  ├── /cks:go commit              ← save checkpoints as you code
  ├── /cks:go commit              ← more checkpoints
  └── /cks:go pr                  ← quick PR for review → hints: /cks:verify
```

### Utility — Research, Health, Learning

| Command | What It Does |
|---------|-------------|
| `/cks:context "topic"` | Research a library/API → saves to `.context/` (auto-runs during discuss) |
| `/cks:research "topic"` | Deep multi-hop research → saves to `.research/` (strategic intelligence) |
| `/cks:doctor` | Project health diagnostic: env vars, TODOs, tests, git, deps (auto-runs pre-ship) |
| `/cks:changelog [--since]` | Auto-generate CHANGELOG.md from git history (auto-runs post-ship) |
| `/cks:retro [--auto]` | Retrospective — extract learnings, propose conventions (auto-runs post-ship) |
| `/cks:status` | Unified dashboard: git, build, PRD lifecycle, code health |

### Automation — Hands-Free

| Command | What It Does |
|---------|-------------|
| `/cks:next` | Auto-detect state → run the next lifecycle step → stop |
| `/cks:autonomous` | Run all remaining phases + ship (no interruption) |

### Modules — Specialized Tools

| Command | What It Does |
|---------|-------------|
| `/cks:kickstart` | Idea → design artifacts → scaffold project |
| `/cks:bootstrap` | Adapt `.claude/` to project. Generates `CLAUDE.md`. |
| `/cks:monetize` | Business model evaluation — scores 12 revenue models |
| `/cks:deploy` | Deploy to Railway |
| `/cks:test` | Run test suite |
| `/cks:review` | Code review a PR or file |
| `/cks:browse` | Browser automation |
| `/cks:seo-audit` | Full SEO audit |
| `/cks:decide` | Stop asking — diagnose and act |
| `/cks:virginize` | Strip project-specific content for starter repo |

---

## Hooks — Automatic Behaviors

No commands to run — these fire on their own:

| Event | What Happens |
|-------|-------------|
| **Session Start** | If `.prd/PRD-STATE.md` exists, shows current phase + status + next action. Silent otherwise. |
| **Stop** | If uncommitted changes exist, reminds you to commit. Silent if clean. |

---

## The Escalation Ladder

Pick the level of ceremony that matches the moment:

```
/cks:go commit       → save my work                                          (5 sec)
/cks:go              → build + commit + push + PR                              (15 sec)
/cks:ship            → doctor + PR + changelog + CLAUDE.md + deploy + retro    (full ceremony)
```

---

## What's Inside

```
cks/
├── .claude-plugin/        ← Plugin manifest
├── commands/              ← Slash commands (one .md per command)
├── agents/                ← Sub-agent definitions
├── skills/                ← Skills with workflows & references
│   ├── prd/               ← Feature lifecycle (discuss → ship)
│   ├── kickstart/         ← Idea → scaffolded project
│   ├── context-research/  ← Technology research briefs
│   ├── deep-research/     ← Multi-hop recursive research
│   ├── retrospective/     ← Post-ship learning + conventions
│   ├── cicd-starter/      ← Bootstrap + deploy + virginize
│   ├── monetize/          ← Business model evaluation
│   ├── aeo-geo/           ← Answer Engine Optimization
│   └── seo-local/         ← Local SEO
├── hooks/                 ← SessionStart + Stop hooks
└── tools/                 ← External tool references
```

---

## Configuration

### Research Sources (optional)

Create `.context/config.md` to customize how `/cks:context` researches topics:

```yaml
sources: [context7, firecrawl, websearch, webfetch]  # priority order
auto-research: true   # auto-research during /cks:discuss
max-lines: 200        # max lines per context brief
```

### API Keys (optional)

Add to `.env.local` for deep research and monetization:
```
PERPLEXITY_API_KEY=your-key-here
```

---

## Adding Components

Just add files to the right directory — no config changes needed:

| To add | Create |
|--------|--------|
| Command | `commands/my-command.md` → `/cks:my-command` |
| Agent | `agents/my-agent.md` |
| Skill | `skills/my-skill/SKILL.md` |
| Hook | Add entry to `hooks/hooks.json` |

Then `git push` and `/reload-plugins` on any machine.

---

## Developing This Plugin

When working on the CKS plugin source code itself, disable the installed version to avoid conflicts:

```bash
# Start dev session (load local files, not installed version)
claude plugin disable cks@cks-marketplace
claude --plugin-dir .

# Test your changes...

# When done, re-enable the installed version
claude plugin enable cks@cks-marketplace
```

After pushing changes, update the installed plugin on any machine:

```bash
git push
claude plugin marketplace update cks-marketplace
claude plugin update cks@cks-marketplace
```

---

## Design Principles

- **Plugin format** — install once, works in every project on every machine
- **Auto-discovery** — add files, they're immediately available
- **One namespace** — everything is `/cks:{action}`, flat and consistent
- **PRD-aware** — quick actions know where you are in the lifecycle
- **Auto-detect** — project type detected from `package.json` / `pyproject.toml` / `Cargo.toml` / `go.mod`
- **Hints not gates** — lifecycle suggestions after actions, never blocking
- **Full lifecycle** — idea → scaffold → build → test → ship in one toolkit
