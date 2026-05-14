---
name: github-project-setup
description: "Onboarding wizard for GitHub Project Kanban setup — configures plugin.json, creates the 6-column board, seeds Phase items, and verifies the null-config no-op path. Trigger when: user runs /cks:new with github_project configured, user asks to set up Kanban, user wants AFK observability, attractor mode setup, GitHub Project board creation, autonomous development tracking, or any variation of Kanban / project board / sprint board setup for CKS."
allowed-tools:
  - Read
  - Write
  - Bash
  - AskUserQuestion
  - "mcp__plugin_github_github__*"
---

# GitHub Project Kanban Setup

This skill configures a GitHub Project board for Attractor-mode AFK development. It produces a 6-column Kanban wired to `plugin.json`, seeded with Phase items from the PRD roadmap.

## What This Skill Does

- Detects repo identity from `git remote`
- Creates a GitHub Project with 6 columns and 4 custom fields
- Updates `plugin.json` with owner/repo/number
- Seeds one Backlog item per PRD phase
- Verifies `isConfigured()` returns true after setup
- Validates that unconfigured installs produce zero API calls (null-config no-op)

## Setup Checklist

Before the wizard runs, confirm all three conditions are met:

**GitHub Auth**
- `GITHUB_TOKEN` env var present, OR
- `gh auth status` shows an active login
- Token needs scopes: `project`, `repo` (read)

**Git Remote**
- `git remote get-url origin` must return a GitHub SSH or HTTPS URL
- Remote must point to the correct consumer repo, not a fork

**plugin.json present**
- File exists at `.claude-plugin/plugin.json`
- Contains a `github_project` block (even if empty/zero values)
- Block shape: `{ "owner": "", "repo": "", "number": 0 }`

If any condition fails, surface it with an ACTION REQUIRED block before proceeding.

## Wizard Steps

### Step 1 — Detect Repo Identity

Parse `git remote get-url origin` to extract owner and repo name. Handle both SSH (`git@github.com:owner/repo.git`) and HTTPS (`https://github.com/owner/repo`) formats. Strip `.git` suffix. This is the source of truth — do not ask the user to type the owner/repo manually.

### Step 2 — Confirm Project Name

Present the default name `{repo-name} — Attractor Pipeline` via `AskUserQuestion`. User may accept or provide a custom name. This is the only interactive step before creation.

### Step 3 — Create GitHub Project with 6 Columns

Use `mcp__plugin_github_github__*` to create a v2 Project under the owner (org or user). Add columns in this exact order:

| Column | Purpose |
|--------|---------|
| Backlog | Phases not yet started |
| Ready | Phase discovered and designed, awaiting sprint |
| In Progress | Active sprint running |
| In Review | PR open, awaiting review |
| Blocked | Waiting on external dependency or decision |
| Done | Phase released |

### Step 4 — Create 4 Custom Fields

Add these single-select or number fields to the project:

| Field | Type | Purpose |
|-------|------|---------|
| Phase Number | Number | Maps to PRD phase NN |
| Runner State | Single Select | `idle / running / paused / failed` |
| PR Count | Number | How many PRs this phase produced |
| Last Sync | Text | ISO timestamp of last `github-project-sync.js` run |

### Step 5 — Update plugin.json

Write the confirmed values back to `.claude-plugin/plugin.json`:

```json
"github_project": {
  "owner": "<detected-owner>",
  "repo": "<detected-repo>",
  "number": <project-number-from-api>
}
```

Do not touch any other fields in `plugin.json`. Read the file first, merge only the `github_project` block, write back.

### Step 6 — Verify isConfigured()

After writing, read `plugin.json` and confirm all three fields are non-empty/non-zero:
- `owner` is a non-empty string
- `repo` is a non-empty string
- `number` is a positive integer

If any field is missing or zero, the setup failed — report what went wrong and do not proceed to Step 7.

### Step 7 — Seed Phase Items

Read `.prd/PRD-ROADMAP.md`. For each phase entry, create one GitHub Project item in the Backlog column. Set the Phase Number field to the phase's `NN` value. Item title format: `Phase {NN}: {phase-slug}`.

If `.prd/PRD-ROADMAP.md` does not exist yet, skip seeding and note it as a follow-up action — do not fail setup.

## Null-Config No-Op Verification

Unconfigured installs (number = 0) must produce zero GitHub API calls. This is the guarantee that CKS works for users who do not opt into Kanban.

**How to verify:**

1. Temporarily set `github_project.number` to `0` in `plugin.json`
2. Run any command that would trigger a sync (`/cks:new`, `/cks:investigate`)
3. Check that no GraphQL request was made — `tools/github-project-sync.js` reads `isConfigured()` at entry and returns early if false
4. Restore `plugin.json` to the real project number

**What to look for:** No network errors, no 401/404 from GitHub, command completes normally. The absence of an error IS the evidence.

**When this matters:** Every time a new user installs CKS without configuring Kanban. If the no-op path throws, it breaks onboarding for the majority of users.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll set up the Kanban later" | The wizard only runs cleanly once. Skipping it means no AFK observability and no sync between PRD phases and the board. Retro-fitting after sprints start is painful. |
| "I can manage phases in my head / in Notion" | Attractor-mode AFK runs happen while you're away. Without the board, there's no passive signal when a phase gets blocked or a runner fails. |
| "The 6 columns are too many for my project" | The column set matches the CKS 5-phase lifecycle exactly. Removing columns breaks `github-project-sync.js` column mapping without a corresponding code change. |
| "I don't need custom fields — title is enough" | Phase Number and Runner State are read by `github-project-sync.js` to update items programmatically. Plain titles are display-only and break automation. |
| "Setting number=0 is fine for now" | Zero is the null sentinel. Any sync call with number=0 would target no project or hit a wrong project by coincidence. The no-op guard exists to prevent silent data corruption. |

## Verification

After completing the wizard, confirm all four signals are green:

- [ ] `isConfigured()` returns true — read `plugin.json`, all three fields non-empty/non-zero
- [ ] 6 columns present in the GitHub Project — visit the project URL or query via API
- [ ] At least one Phase item exists in Backlog — visible in the project board
- [ ] `plugin.json` parses valid — run `jq . .claude-plugin/plugin.json` with exit code 0

If any check fails, do not declare setup complete. Report the failure and the remediation step.
