# Agents — the v6 workforce

Eighteen roles. Each `.md` file here is one role: a system prompt plus a tool grant and a
model. Roles differ by **grant** (what they may read, write, reach) and **model**, never by
prompt alone — two roles with identical grants are one role. The contract, roster and
absorption rules live in `docs/v6-workforce.md`; the per-role catalogue is
`docs/wiki/agents.md`; the chief of staff's dispatch lookup is
`skills/chief-of-staff/references/roster.md`.

| Role | Model | Writes | Runs as |
|---|---|---|---|
| `chief-of-staff` | opus | nothing | top-level skill (`Skill(skill="cks:chief-of-staff")`); agent file kept for `claude --agent` |
| `project-manager` | sonnet | `.prd/` state | sub-agent |
| `assistant` | sonnet | user dir drafts, reminders | sub-agent |
| `finops` | sonnet | `.finops/` | sub-agent |
| `watchdog` | sonnet | nothing | sub-agent |
| `observer` | sonnet | nothing | sub-agent |
| `researcher` | sonnet | `.research/`, research artifacts | sub-agent |
| `strategist` | opus | discovery artifacts | sub-agent |
| `architect` | opus | design docs, PLAN.md, ADRs | sub-agent |
| `builder` | sonnet | code | sub-agent (worktree) |
| `reviewer` | opus | nothing | sub-agent |
| `tester` | sonnet | fixtures, VERIFICATION.md, `.evals/` | sub-agent |
| `debugger` | opus | edits only, never new files | sub-agent |
| `shipper` | sonnet | code, CHANGELOG.md, config | sub-agent |
| `historian` | sonnet | `memory/`, `.learnings/` | sub-agent |
| `marketer` | opus | `.campaign/`, `.marketing/` | sub-agent |
| `operator` | sonnet | project config, scaffolds | sub-agent |
| `writer` | haiku | docs, contract drafts | sub-agent |

Every role other than the chief of staff is dispatched by the chief of staff or by a
`skills/<domain>/SKILL-ORCHESTRATOR.md` loaded top-level via `Skill()`. On a project repo
other than the session's, the chief of staff opens a Claude Code Remote session and the role
runs there.

## Role file template

```yaml
---
name: reviewer
subagent_type: cks:reviewer
description: One line — what this role decides or produces; used for routing and help
tools:
  - Read
  - Grep
  - Glob
  - Bash
  - AskUserQuestion
  - mcp__plugin_github_github__pull_request_read
model: opus
color: red
skills:
  - code-excellence
  - security-hardening
  - core-behaviors
  - caveman
---
```

The body is the system prompt: instructions to the role, not documentation about it. Modes
(`Mode: security`, `Mode: db audit`) are sections that name the workflow file to read.

## Invariants (checked by `scripts/smoke-test.sh` and `scripts/agent-graph.sh`)

- `subagent_type: cks:<basename>` and `name: <basename>` — the file name is the type.
- `tools:` is a YAML list. No role carries `Agent` except `chief-of-staff` — a sub-agent
  cannot dispatch a sub-agent; anything that must dispatch is a `SKILL-ORCHESTRATOR.md`.
- Decide / review / report roles have no `Write` and no `Edit`. A role that writes names its
  write scope in the body and stays inside it. `Bash` granted for reading says so in the body
  and forbids redirects, `sed -i`, `tee`, heredocs and `mkdir`.
- `AskUserQuestion` only on `sonnet`/`opus` roles.
- Gated actions (send, invite, post, invoice, pay, deploy to production, delete, change a
  Routine) are never executed by a role — draft, return, let the chief of staff route `GATED:`.
- `skills:` lists every skill directory the body relies on; each `skills/<name>/SKILL.md`
  must exist. Roles do not inherit skills or tools from the caller.
- No model names in the body. No bracketed placeholder markers (`docs.md` rule).
- Every role must have a static dispatch site (`agent-graph.sh` fails otherwise); the only
  allowlisted exception is `chief-of-staff`.

## Changing a role

Change the grant or the model when the job changes; change the body when the procedure
changes. Domain knowledge goes in `skills/<domain>/SKILL.md`, procedures in
`skills/<domain>/workflows/`, and the role body points at them by path. Do not add a
nineteenth role for a new task — add a `Mode:` or a `Persona:` to the role whose grant
already fits, or a skill it loads. See `docs/wiki/extending.md`, "Changing a role".

## Legacy

The v5 task agents live in `legacy/agents/` — not loaded, not scanned, removed in 6.1.
Old `subagent_type` → role: `scripts/agent-map.tsv`, `docs/MIGRATION-v5-to-v6.md`.
