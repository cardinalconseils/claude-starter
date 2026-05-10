# Extending CKS

CKS uses file-based discovery — add a file to the right directory and it's immediately available. No config changes, no registration. After pushing changes, run `claude plugin marketplace update cks-marketplace` on any machine to get them.

## Adding a Command

Create `commands/my-command.md`. The filename becomes the command name: `commands/summarize.md` → `/cks:summarize`.

**Required frontmatter:**

```yaml
---
description: One-line description of what this command does
allowed-tools: Read, Agent
---
```

**Rules:**
- Commands are thin dispatchers — they route to agents, they don't contain workflow logic
- `allowed-tools` lists only what the command itself needs, not what agents need
- Keep under 60 lines — if longer, the logic belongs in an agent
- Thin dispatchers use at most: `Read`, `Agent`, `AskUserQuestion`

**Minimal example:**

```markdown
---
description: Summarize recent changes into a status update
allowed-tools: Read, Agent
---

## Usage
/cks:summarize

Dispatches the summarizer agent on the current git log.

## Steps
1. Read `.prd/PRD-STATE.md` to get the current feature context
2. Dispatch Agent(subagent_type="my-summarizer") with the context

## Quick Reference
/cks:summarize    → summarize recent changes
```

After creating the file, update `commands/README.md` with the new entry.

---

## Adding an Agent

Create `agents/my-agent.md`. The `subagent_type` value in frontmatter is how commands and skills reference it.

**Required frontmatter:**

```yaml
---
name: my-agent
subagent_type: my-agent
description: One-line description — used for auto-selection and help display
tools:
  - Read
  - Write
  - Edit
  - Bash
model: sonnet
color: blue
skills:
  - core-behaviors
  - prd
---
```

**Field notes:**
- `subagent_type` must match the value used in `Agent(subagent_type="...")` calls
- `tools` must list every tool the agent needs — agents don't inherit parent tools
- `skills` must list every domain skill the agent needs — agents don't inherit parent skills
- Use `model: sonnet` for mechanical tasks, omit for reasoning-heavy work (defaults to Opus)
- `description` controls when Claude Code auto-selects this agent — make it specific

**Body format:**

The body is the agent's system prompt. Write it as instructions to the agent, not documentation about it:

```markdown
You are a specialist in X. When dispatched, you:

1. Read the current context from...
2. Analyze Y by...
3. Produce Z as output in...

## Constraints
- Never modify files outside...
- Always verify before declaring done...

## Output
Produce a file at `.prd/phases/{feature}/SUMMARY.md` with...
```

---

## Adding a Skill

Create `skills/my-skill/SKILL.md`. Skills hold domain expertise that agents load at startup.

**Required frontmatter:**

```yaml
---
name: my-skill
description: >
  What this skill provides and when it activates. Be keyword-rich — this description
  controls auto-triggering. Use when: [specific scenarios].
allowed-tools: Read, Write, Edit, Bash
---
```

**Directory structure:**

```
skills/my-skill/
├── SKILL.md              Entry point — frontmatter + domain knowledge
├── workflows/            Step-by-step processes (agents read these on demand)
│   └── my-workflow.md
└── references/           Static lookup data — templates, checklists, catalogs
    └── reference.md
```

**Rules:**
- `SKILL.md` holds domain expertise (what to know), not step-by-step instructions (how to run)
- Keep `SKILL.md` under 300 lines — extract processes to `workflows/`
- Workflows use the thin orchestrator pattern: an orchestrator file routes to sub-step files, each under 100 lines
- Every skill should include a `## Verification` checklist with evidence requirements
- Every skill should include a `## Common Rationalizations` table to prevent agents from skipping steps

**Example skill body:**

```markdown
## Domain Knowledge

[What the agent needs to know about this domain]

## Key Patterns

[Reusable patterns and conventions]

## Common Rationalizations

| Rationalization | Reality |
|----------------|---------|
| "I'll add tests later" | Untested code is broken code |

## Verification

Before declaring done:
- [ ] [Specific evidence required]
- [ ] [Passing test output or build result]
```

---

## Adding a Hook

Hooks fire automatically on Claude Code events. Add entries to `hooks/hooks.json`:

```json
{
  "hooks": [
    {
      "event": "PostToolUse",
      "matcher": "Edit",
      "script": "${CLAUDE_PLUGIN_ROOT}/hooks/handlers/my-handler.sh"
    }
  ]
}
```

Create the handler script in `hooks/handlers/`. Hook rules:
- Scripts must exit 0 on success — non-zero blocks the triggering action
- Never use `set -e` — a failing grep/find should not block the user
- Always quote variables: `"$VAR"` not `$VAR`
- Use `2>/dev/null` on file checks that may not exist
- Keep scripts under 30 lines — complex logic belongs in `scripts/`
- Hooks are for automation (logging, guarding) only — never dispatch agents or interact with the user

---

## After Making Changes

```bash
# Test locally
claude plugin disable cks@cks-marketplace
claude --plugin-dir .

# When done, re-enable and push
claude plugin enable cks@cks-marketplace
git add commands/my-command.md    # or agents/, skills/
git commit -m "feat: add my-command"
git push

# Update on any other machine
claude plugin marketplace update cks-marketplace
claude plugin update cks@cks-marketplace
```
