# Extending CKS

CKS uses file-based discovery — add a file to the right directory and it's immediately available. No config changes, no registration. After pushing changes, run `claude plugin marketplace update cks-marketplace` on any machine to get them.

## Adding a Command

Create `commands/my-command.md`. The filename becomes the command name: `commands/summarize.md` → `/cks:summarize`. A command dispatches one of the 18 roles (`Agent(subagent_type="cks:<role>", prompt="Mode: … ")`) or loads an orchestrator skill (`Skill(skill="cks:<domain>")`) — it never introduces a new agent.

**Required frontmatter:**

```yaml
---
description: One-line description of what this command does
allowed-tools: Read, Agent
---
```

**Rules:**
- Commands are thin dispatchers — they route to roles or orchestrator skills, they don't contain workflow logic
- `allowed-tools` lists only what the command itself needs, not what agents need
- Keep under 60 lines — if longer, the logic belongs in a skill workflow
- Thin dispatchers use at most: `Read`, `Agent`, `AskUserQuestion`

**Minimal example:**

```markdown
---
description: Summarize recent changes into a status update
allowed-tools: Read, Agent
---

## Usage
/cks:summarize

Dispatches the historian on the current git log.

## Steps
1. Read `.prd/PRD-STATE.md` to get the current feature context
2. Dispatch Agent(subagent_type="cks:historian", prompt="Mode: summarize. …") with the context

## Quick Reference
/cks:summarize    → summarize recent changes
```

After creating the file, update `commands/README.md` with the new entry.

---

## Changing a Role (not adding an agent)

CKS v6 has eighteen roles in `agents/` and no task agents. **Do not add a nineteenth file.**
A new task is a new `Mode:` (a workflow the role reads) or a new `Persona:` (a voice the role
takes) on the role whose grant already fits — or a new skill that role loads. Splitting a role
only compartmentalises if the tool grants actually differ; identical grants across two files buy
nothing and cost a dispatch site, a golden brief, and a roster row. The contract is
`docs/v6-workforce.md`; `scripts/agent-graph.sh` fails the build for any role without a static
dispatch site and `scripts/smoke-test.sh` checks the frontmatter invariants.

**Where things go:**

| You want to… | Put it in |
|---|---|
| Teach a role something (facts, patterns, checklists) | `skills/<domain>/SKILL.md` or `references/` — add the skill to the role's `skills:` |
| Give a role a procedure to follow step by step | `skills/<domain>/workflows/<verb>.md`; the role body names it under a `Mode:` section |
| Give the marketer a new voice | `skills/marketing/personas/<name>.md`; dispatch with `Persona: <name>` |
| Fan work out across several roles | `skills/<domain>/SKILL-ORCHESTRATOR.md`, loaded by a command via `Skill(skill="cks:<domain>")` — never an agent with `Agent` in `tools:` |
| Let a role reach a new system | Add the narrowest MCP tool to its `tools:` and mention the grant in the body |
| Run something on a schedule | `skills/routines/` template + `/cks:routine new` — the operator sets it up, the chief of staff registers it |

**Required frontmatter (every role):**

```yaml
---
name: reviewer
subagent_type: cks:reviewer
description: One-line description — used for routing and help display
tools:
  - Read
  - Grep
  - Glob
  - Bash
  - AskUserQuestion
model: opus
color: red
skills:
  - code-excellence
  - core-behaviors
---
```

**Invariants (from `docs/v6-workforce.md`):**
- `subagent_type: cks:<basename>` must match the `Agent(subagent_type="…")` call; a mismatch
  makes the role unreachable and `agent-graph.sh` reports it as dangling
- `tools` is a list; a role gets nothing from its caller. No role carries `Agent` except
  `chief-of-staff` — sub-agents cannot dispatch sub-agents
- Decide / review / report roles have no `Write` and no `Edit`. A role that writes names its
  write scope in the body and stays inside it
- `Bash` is a write tool: redirects, `sed -i`, `tee` and heredocs bypass a missing `Write`. A
  read-only grant says so in the body and forbids those forms
- `AskUserQuestion` only on `sonnet` / `opus` roles
- Gated actions (send, invite, post, invoice, pay, production deploy, delete, change a Routine)
  are never executed by a role — draft, return, let the chief of staff route `GATED:`
- Every granted tool appears in the body; every `skills:` entry resolves to a `SKILL.md`
- No model names in the body; no bracketed placeholder markers (`.claude/rules/docs.md`)

**Least agency — scope `tools` before you write the body.** OWASP's agentic extension of
least privilege: constrain not just what a role can reach, but what it can *do*. The tool list
is the only limit that holds when the prompt does not. `agents/chief-of-staff.md`,
`agents/watchdog.md` and `agents/reviewer.md` do this deliberately.

**Body format:**

The body is the role's system prompt. Write it as instructions to the role, not documentation
about it. Modes are sections that name the workflow to read:

```markdown
You are the reviewer. You judge; you never write.

## Mode: security
Read `skills/security-hardening/references/audit-checklist.md`, then…

## Constraints
- Never modify files. Findings only.

## Output
A graded report: severity, scope, remediation — full prose (auto-clarity override).
```

**Changing a grant or model** is a change to the role: update `docs/v6-workforce.md`, the
role's section in `docs/wiki/agents.md`, and its row in
`skills/chief-of-staff/references/roster.md`, then run `bash scripts/smoke-test.sh` and
`bash scripts/agent-graph.sh`. Add a golden brief under `.evals/golden/roles/<role>/` when the
observable artifact changes.

**Migrating an old agent you copied to `~/.claude/agents/`:** find its row in
`scripts/agent-map.tsv` (or `docs/MIGRATION-v5-to-v6.md`) and dispatch the role it names with
the hint as the first line of the brief. The v5 bodies stay in `legacy/agents/` until 6.1.

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

## Adding a Guardrail Rule

Guardrail rules live in `.claude/rules/` and are glob-scoped — Claude Code loads them automatically for every session in the project. They enforce project-level behaviors that override Claude's defaults.

**Create `.claude/rules/my-rule.md`:**

```markdown
# My Rule Title

## Mandatory Behavior
[What Claude must always / never do]

## Trigger Points
[When the rule fires]

## Common Rationalizations
| Rationalization | Reality |
|---|---|
| "This case is different" | It isn't. |

## Verification
- [ ] Evidence that the rule is being followed
```

**Active rules in this repo:**

| File | Enforces |
|---|---|
| `destructive-ops.md` | Warning block before any irreversible action |
| `secrets.md` | Never echo raw credentials — always mask |
| `verification.md` | Prove work is done before declaring "done" |
| `dispatch-first.md` | Main session orchestrates; roles do the work |
| `human-intervention.md` | Formatted blocks for action/decision/suggestion |
| `output-voice.md` | Caveman compression with auto-clarity overrides |
| `engineering-discipline.md` | Simplicity first, minimal impact, root-cause fixes only |
| `git-hygiene.md` | Branch naming, lifecycle, stale branch policy |
| `commands.md` | Commands are thin dispatchers, under 60 lines |
| `agents.md` | Required role frontmatter, tool/skill declarations |
| `skills.md` | Skills are expertise, not process scripts |
| `hooks.md` | Hooks exit 0, never dispatch agents |
| `docs.md` | CLAUDE.md under 150 lines, no placeholder tokens |
| `ideation.md` | Never pick direction for user; produce a pitch not a PRD |

**Rules for rules:**
- Use the warning/decision/suggestion block formats from `human-intervention.md` for blocking situations
- Include a `## Common Rationalizations` table — it prevents agents from rationalizing away the rule
- Include a `## Verification` checklist so compliance is measurable
- Reference the rule file name in any CLAUDE.md pointer: "See `.claude/rules/my-rule.md`"

---

## Regenerating docs

The role catalogue and the counts are generated, not hand-edited. `scripts/generate-docs.sh`
reads `agents/*.md` frontmatter, `scripts/agent-graph.sh --edges`, `scripts/agent-map.tsv` and
the file counts, and rewrites only the text between `<!-- generated:<name> start -->` /
`<!-- generated:<name> end -->` markers — prose around them survives:

| File | Marker | What is generated |
|---|---|---|
| `docs/wiki/agents.md` | `generated:roles` | one section per role (purpose, model, writes, grants, skills, dispatched by, absorbed v5 agents) |
| `commands/help.md` | `generated:agents` | the `ROLES (N — agents/*.md …)` block, ≤80 columns; anchored on that header line and the next blank line because a comment would print in the terminal |
| `commands/README.md` | `generated:count` | the `**N commands total**` number |
| `README.md` | `generated:structure-counts` | the counts on the `commands/`, `agents/`, `legacy/agents/`, `skills/` lines |
| `docs/ARCHITECTURE.md` | `generated:layer-counts` | the Skills / Roles / Commands count cells |
| `CLAUDE.md` | none (150-line cap) | the numbers on the `agents/`, `commands/`, `skills/` lines, by pattern |
| `skills/chief-of-staff/references/roster.md` | `generated:roster`, `generated:lookup` | the role table and the v5 → v6 lookup |

After changing a role's frontmatter, a dispatch site, `agent-map.tsv`, or adding a command or
skill: `bash scripts/generate-docs.sh`, then commit the regenerated files with the change.
`bash scripts/generate-docs.sh --check` exits 1 with a unified diff when any target is stale —
`scripts/test-integrity.sh` runs it as check 13, so a stale doc blocks the commit.

---

## After Making Changes

```bash
# Test locally
claude plugin disable cks@cks-marketplace
claude --plugin-dir .

# When done, re-enable and push
claude plugin enable cks@cks-marketplace
git add commands/my-command.md    # or skills/, agents/<role>.md
git commit -m "feat: add my-command"
git push

# Update on any other machine
claude plugin marketplace update cks-marketplace
claude plugin update cks@cks-marketplace
```
