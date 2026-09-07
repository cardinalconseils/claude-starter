# CKS Plugin Architecture

CKS (Claude Kickstart) is a Claude Code plugin organized into 4 layers. Each layer has a distinct role. After installation, review and adapt each layer to your needs.

## The 4 Layers

```
User types /cks:command
       │
       ▼
┌─────────────┐
│  Commands    │  User interface (138 slash commands)
│  /cks:*     │  Thin dispatchers — Agent() to a role, or Skill() to an orchestrator
└──────┬──────┘
       │ invokes
       ▼
┌─────────────┐
│  Skills      │  Expertise (144 skill sets + orchestrator skills)
│  SKILL.md   │  Domain knowledge, workflows, progressive disclosure
└──────┬──────┘
       │ dispatches
       ▼
┌─────────────┐
│  Roles       │  Isolated work (18 roles — grant + model, not prompt)
│  agents/*.md │  Scoped tools, focused context, worktree isolation
└──────┬──────┘
       │ monitored by
       ▼
┌─────────────┐
│  Hooks       │  Automation (27 event-driven handlers)
│  hooks.json │  Session start, commit guard, integrity, merge, edit warnings, learnings
└─────────────┘
```

| Layer | Role | Count | Config File |
|-------|------|-------|------------|
| **Hooks** | Automation (event-driven, no user action) | 7 events, 27 scripts | `hooks/hooks.json` |
| **Skills** | Expertise (auto-activated domain knowledge) + orchestrators (`SKILL-ORCHESTRATOR.md`, loaded via `Skill()`) | 144 skills | `skills/*/SKILL.md` |
| **Roles** | Isolated work (18 sub-agents, differ by tool grant and model) | 18 roles (+168 legacy in `legacy/agents/`, not loaded) | `agents/*.md`, `docs/v6-workforce.md` |
| **Commands** | User interface (`/cks:*` slash commands) | 138 commands | `commands/*.md` |
| **Rules** | Guardrails (glob-scoped, auto-applied) | 41 rules | `.claude/rules/*.md` |

## How They Work Together

1. **User** types a command like `/cks:discover`
2. **Command** (`commands/discover.md`) loads the relevant skill workflow
3. **Skill** (`skills/prd/workflows/discover-phase.md`) contains the expertise and process
4. **Skill dispatches a role** (`agents/strategist.md`, `Mode: discover`) for isolated, focused work
5. **Hooks fire automatically** throughout — guarding commits, capturing learnings, showing status

Commands are your interface. Skills hold the knowledge. Roles do the isolated work. Hooks automate the guardrails.

A sub-agent cannot dispatch another sub-agent. Anything that must fan out (the sprint pipeline, kickstart, loops, monetize, concept evaluation, the chief of staff) is a `SKILL-ORCHESTRATOR.md` a command loads top-level with `Skill(skill="cks:<domain>")`; it then dispatches roles normally. Only `chief-of-staff` carries the `Agent` tool.

## What to Review After Installation

### 1. Skills — Check tool restrictions and model

Every skill has a `## Customization` section listing what you can adapt. Key frontmatter fields:

- **`allowed-tools`**: Restricts which tools Claude can use when the skill is active. Remove tools for security, add tools for flexibility.
- **`model`**: 8 lightweight skills use `sonnet` to reduce cost. Remove to use your default model.

```bash
# See which skills have restrictions
grep -l 'allowed-tools' skills/*/SKILL.md

# See which skills use sonnet
grep -l 'model: sonnet' skills/*/SKILL.md
```

### 2. Roles — Check tool scope matches your security posture

Each role has a `tools:` list in frontmatter that controls what it can do in isolation:

- `reviewer`, `watchdog`, `observer` have no Write/Edit — they judge and report
- `debugger` has Edit but no Write — it fixes in place, never creates files
- `builder`, `shipper`, `operator` are the only roles with Bash read-write plus Write and Edit
- Roles differ by grant and model; a change to a grant is a change to the role (`docs/v6-workforce.md`)

### 3. Hooks — Disable any you don't want

Review `hooks/hooks.json`. Each hook entry can be removed without breaking anything:

- **SessionStart**: Shows project status on session open
- **PreToolUse (git commit)**: Blocks secrets, debug code, .env files
- **PreToolUse (git commit)**: Validates plugin cross-references (integrity check)
- **PreToolUse (git merge)**: Validates merge conditions
- **PostToolUse (Edit/Write)**: Warns about console.log and TODO markers
- **SubagentStop**: Post-processes kickstart and ideation phase completions
- **Stop**: Captures session learnings, reminds about uncommitted changes

### 4. Commands — Your interface

Commands in `commands/` are thin wrappers. You can:
- Rename commands by renaming files
- Add your own by creating new `.md` files
- Remove commands you don't use

## Quick Customization Guide

| What to Change | Where | How |
|---------------|-------|-----|
| Tool restrictions for a skill | `skills/*/SKILL.md` frontmatter | Add/remove tools from `allowed-tools` |
| Model cost/quality for a skill | `skills/*/SKILL.md` frontmatter | Set `model: sonnet` or remove for default |
| Workflow process steps | `skills/*/workflows/*.md` | Edit step files directly |
| Domain knowledge/templates | `skills/*/references/*.md` | Edit reference files |
| Role capabilities | `agents/*.md` frontmatter | Add/remove from `tools:` list — keep the invariants in `docs/v6-workforce.md` |
| Role cost/quality | `agents/*.md` frontmatter or `/cks:model set <role> <model>` | Set `model:` per role |
| Hook behavior | `hooks/handlers/*.sh` | Edit shell scripts |
| Which hooks run | `hooks/hooks.json` | Remove entries to disable |
| Commit guard patterns | `hooks/handlers/pre-commit-guard.sh` | Edit `SECRET_PATTERNS` array |
| Available commands | `commands/*.md` | Add/remove/rename files |

## File Structure

```
.claude-plugin/
├── plugin.json              Plugin manifest (name, version)
.claude/rules/               41 glob-scoped guardrails (destructive-ops, human-intervention, agents, commands, skills, hooks, docs, ideation, dispatch-first, loops, …)
commands/                    138 slash commands
agents/                      18 roles (docs/v6-workforce.md) — README.md is the template
legacy/agents/               168 v5 task agents — not loaded, removed in 6.1
skills/                      144 skill sets
│   ├── prd/                 Feature lifecycle (discover → release)
│   ├── kickstart/           Idea → scaffolded project
│   ├── monetize/            Business model evaluation
│   ├── observability/       Live signal triage (log, Sentry, LangSmith)
│   ├── debug/               Diagnostic expertise
│   ├── ciso/                Security auditing (OWASP, supply chain, RLS)
│   ├── deep-research/       Multi-hop research
│   ├── context-research/    Coding reference briefs
│   ├── retrospective/       Post-ship learning
│   ├── cicd-starter/        Bootstrap CI/CD
│   ├── no-code/             Automation building
│   ├── api-docs/            API documentation
│   ├── guardrails/          Domain rule generation
│   ├── language-rules/      Language coding rules
│   ├── ideation/            Brainstorming frameworks
│   ├── migrations/          Version-aware state migration
│   ├── monitoring/          App monitoring setup (wiring logging into apps)
│   ├── observability/       Live signal triage (logs, Sentry, LangSmith)
│   ├── aeo-geo/             Answer Engine Optimization
│   ├── seo-local/           Local SEO
│   ├── chief-of-staff/      Session brain (SKILL-ORCHESTRATOR loaded via /cks:chief)
│   ├── attractor/           Sprint pipeline orchestrator (loaded via /cks:sprint)
│   ├── marketing/           Marketer personas (the former Luv bench)
│   ├── routines/            Scheduled Claude Code Remote triggers
│   └── finops/              Cost, margin, invoice, budget
tools/                       Operational references (PRD state, lifecycle log, phase transitions)
hooks/
│   ├── hooks.json           Event → handler mapping (7 events, 27 scripts)
│   └── handlers/            Shell scripts
scripts/                     Utility scripts (logging, versioning, integrity test, agent-graph, remap, migrate-v5-to-v6)
```

## Further Reading

- `skills/README.md` — Skill structure and customization
- `agents/README.md` — Role template and invariants
- `docs/v6-workforce.md` — Role specification (grants, models, skills, absorbed agents)
- `docs/wiki/agents.md` — Per-role catalogue
- `hooks/README.md` — Hook events and customization
- `commands/README.md` — Command catalog
- `tools/README.md` — Operational reference docs (PRD state, lifecycle log, phase transitions)
