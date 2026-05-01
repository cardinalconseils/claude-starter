# CKS Plugin Architecture

CKS (Claude Kickstart) is a Claude Code plugin organized into 4 layers. Each layer has a distinct role. After installation, review and adapt each layer to your needs.

## The 4 Layers

```
User types /cks:command
       │
       ▼
┌─────────────┐
│  Commands    │  User interface (68 slash commands)
│  /cks:*     │  Thin wrappers that route to skills
└──────┬──────┘
       │ invokes
       ▼
┌─────────────┐
│  Skills      │  Expertise (auto-activated skill sets)
│  SKILL.md   │  Domain knowledge, workflows, progressive disclosure
└──────┬──────┘
       │ dispatches
       ▼
┌─────────────┐
│  Agents      │  Isolated work (63 specialized subprocesses)
│  agents/*.md │  Scoped tools, focused context, parallel execution
└──────┬──────┘
       │ monitored by
       ▼
┌─────────────┐
│  Hooks       │  Automation (9 event-driven handlers)
│  hooks.json │  Session start, commit guard, integrity, merge, edit warnings, learnings
└─────────────┘
```

| Layer | Role | Count | Config File |
|-------|------|-------|------------|
| **Hooks** | Automation (event-driven, no user action) | 6 events, 9 scripts | `hooks/hooks.json` |
| **Skills** | Expertise (auto-activated domain knowledge) | 16+ skills | `skills/*/SKILL.md` |
| **Agents** | Isolated work (subprocesses with scoped tools) | 63 agents | `agents/*.md` |
| **Commands** | User interface (`/cks:*` slash commands) | 68 commands | `commands/*.md` |

## How They Work Together

1. **User** types a command like `/cks:discover`
2. **Command** (`commands/discover.md`) loads the relevant skill workflow
3. **Skill** (`skills/prd/workflows/discover-phase.md`) contains the expertise and process
4. **Skill dispatches agent** (`agents/prd-discoverer.md`) for isolated, focused work
5. **Hooks fire automatically** throughout — guarding commits, capturing learnings, showing status

Commands are your interface. Skills hold the knowledge. Agents do the isolated work. Hooks automate the guardrails.

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

### 2. Agents — Check tool scope matches your security posture

Each agent has a `tools:` list in frontmatter that controls what it can do in isolation:

- The `debugger` agent has no Write/Edit — it diagnoses but doesn't fix
- The `prd-executor-worker` uses `model: sonnet` for cost efficiency
- Agents serving a skill should have tools no broader than needed

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
| Agent capabilities | `agents/*.md` frontmatter | Add/remove from `tools:` list |
| Agent cost/quality | `agents/*.md` frontmatter | Set `model: sonnet` or remove |
| Hook behavior | `hooks/handlers/*.sh` | Edit shell scripts |
| Which hooks run | `hooks/hooks.json` | Remove entries to disable |
| Commit guard patterns | `hooks/handlers/pre-commit-guard.sh` | Edit `SECRET_PATTERNS` array |
| Available commands | `commands/*.md` | Add/remove/rename files |

## File Structure

```
.claude-plugin/
├── plugin.json              Plugin manifest (name, version)
├── .claude/rules/           8 glob-scoped guardrails
commands/                    68 slash commands
agents/                      63 agent definitions
skills/
│   ├── prd/                 Feature lifecycle (discover → release)
│   ├── kickstart/           Idea → scaffolded project
│   ├── monetize/            Business model evaluation
│   ├── observability/       Live signal triage (log, Sentry, LangSmith)
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
│   ├── aeo-geo/             Answer Engine Optimization
│   └── seo-local/           Local SEO
tools/                       Operational references (PRD state, lifecycle log, phase transitions)
hooks/
│   ├── hooks.json           Event → handler mapping (6 events, 9 scripts)
│   └── handlers/            Shell scripts
scripts/                     Utility scripts (logging, versioning, integrity test)
```

## Further Reading

- `skills/README.md` — Skill structure and customization
- `agents/README.md` — Agent roles and customization
- `hooks/README.md` — Hook events and customization
- `commands/README.md` — Command catalog
- `tools/README.md` — Operational reference docs (PRD state, lifecycle log, phase transitions)
