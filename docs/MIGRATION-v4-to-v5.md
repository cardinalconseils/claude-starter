# CKS v4 → v5 Migration Guide

## Overview

CKS v5 consolidates the **dual execution spines** of v4 into a single **Attractor spine**, providing unified observability for autonomous (AFK) development runs through an integrated GitHub Project Kanban surface.

### What the Migration Does

**v4 carried two overlapping execution systems:**
- **PRD spine** — `sprint-runner` reading `.prd/PRD-STATE.md`
- **Attractor spine** — pipeline DOT files in `pipelines/` executed as box nodes with edges

**v5 consolidates these into one:**
- Single Attractor-based execution spine (`attractor-runner`)
- GitHub Project as the canonical human-observable Kanban (optional, opt-in)
- Bidirectional automation: Kanban moves trigger runner actions; runner state transitions move cards
- All 89 agents and 74 skills preserved with no behavioral changes
- Full flag-guarded rollout — `attractor_mode: false` until Phase 8 flips it on

### Why This Matters

- **Maintenance**: One codebase, one mental model, no drift
- **Observability**: Run an AFK feature and watch progress from your phone via GitHub Projects
- **Automation**: Move a Kanban card to pause/resume a runner; get approval gates on Kanban moves
- **Opt-in**: Works without GitHub Projects configured — pure local execution still available

---

## Migration Phases (9 Total)

The migration executes in 9 phases (0–8), each with a feature branch, PRs, tests, and backward-compatibility gates. Each phase ships behind `attractor_mode: false` until Phase 8 flips the default.

| Phase | Name | Scope |
|-------|------|-------|
| **0** | Foundation, Safety Net, Project Setup | Migration overview doc; script stub; `attractor_mode` flags in plugin.json; GitHub Project skeleton created |
| **1** | Bridge State Systems | Extend `.prd/PRD-STATE.md` schema; build `tools/github-project-sync.js` GraphQL wrapper; wire runner state reads/writes to sync helpers with null-config check |
| **2** | Rename Runner + Expand SprintReview | Rename `sprint-runner.md` → `attractor-runner.md`; expand SprintReview into 5-edge box node (Discover → Design → Build → Test → Review); add `runner.enterNode()` helper |
| **3** | Release Node | Compose Release node as `go-runner` → `deployer`; auto-close child Issues; post release URLs as Phase item comments |
| **4** | Wire Both Pipeline Entry Points | Feature spine: rewrite `/cks:new` to create Phase items + Discover Issues, write Phase item ID to PRD-STATE; Bug spine: wire `/cks:investigate` and `/cks:debug`; add GitHub Project setup skill |
| **5** | Agentic OS Integration as Data Layer | Discover node queries prior closed Phase items for prior art; Business Model writes to wiki; Learnings writes back with cross-links; build `/cks:wiki` command |
| **6** | Bidirectional Kanban Automation | Build `tools/webhook-listener.js` (HMAC-SHA256 verification, column→action dispatch); 60s reconciliation loop; decommission old Agentic OS board UI; build `/cks:setup-webhooks` command; write `docs/AUTOMATION.md` |
| **7** | Archive Legacy, Update Session Commands | Mark `/cks:go`, `/cks:release`, `/cks:review` as `[legacy]`; delete `sprint-close.md`; merge `sprint-start` into `/cks:standup` with Attractor awareness |
| **8** | Documentation, Migration Script, v5.0.0 Release | Finalize all docs; run migrator against v4 fixture; cut v5.0.0 via new Release node (full dogfood); flip `attractor_mode` default-on; Phase 8's Phase item closes as final card flip |

---

## How `attractor_mode` Works

The `attractor_mode` flag controls which execution spine is active:

### When `attractor_mode: false` (v4 behavior — default until Phase 8)
- All commands use the PRD spine and `sprint-runner.md`
- Attractor pipeline and GitHub Project automation do not run
- No webhook listeners active
- Existing v4 workflows unchanged
- All automation happens locally via PRD-STATE.md

### When `attractor_mode: true` (v5 behavior — Phase 8 flips this on)
- All commands use the Attractor spine and `attractor-runner.md`
- GitHub Project Kanban (if configured) syncs with runner state
- Webhook listeners watch for card moves and trigger corresponding actions
- PRD spine archived; no code path depends on it
- Bidirectional automation: Kanban ↔ runner state

### Configuration in `plugin.json`

```json
{
  "attractor_mode": false,
  "webhook_enabled": false,
  "github_project": {
    "owner": "",
    "repo": "",
    "number": 0
  }
}
```

- `attractor_mode`: `true/false` — active spine (v5/v4)
- `webhook_enabled`: `true/false` — listen for GitHub Project webhook events
- `github_project`: Project coordinates for Kanban sync
  - `owner`: GitHub org/user
  - `repo`: Repository name
  - `number`: Project number (from GitHub URL `/projects/{number}`)

### Opt-In GitHub Integration

Everything works without GitHub Project configured:
- `github_project` fields remain empty
- Sync helpers check for null config and no-op gracefully
- Runner executes locally; no errors surface
- Users who want Kanban observable run `/cks:setup-webhooks` to configure

---

## Consumer Upgrade Path

### For CKS v4 Users Staying on v4

1. **No action required.** Your projects continue to work as-is.
2. Existing PRD workflows unchanged — `.prd/` structure, `/cks:new`, `/cks:review`, `/cks:release` all work.
3. When you upgrade the CKS plugin to v5.0.0, `attractor_mode` defaults to `false` — v4 behavior is preserved.

### For CKS v5 Early Adopters (Wanting Attractor + Kanban)

1. **Upgrade CKS plugin** to v5.0.0 once Phase 8 ships.
2. **Create a GitHub Project** in your repo (6 columns: Backlog, Ready, In Progress, In Review, Done, Blocked).
3. **Run `/cks:setup-webhooks`** to configure webhook and set `attractor_mode: true` in plugin.json.
4. **New features created via `/cks:new`** automatically create Phase items on the Kanban; runner state moves cards; you observe from anywhere.

### For CKS v4 → v5 Migrators

A migration script (`scripts/migrate-v4-to-v5.sh`) will be available in Phase 8:
- Detects v4 project shape (`.prd/PRD-STATE.md` structure, old agent names)
- Creates corresponding GitHub Project and Phase items
- Updates agent references
- Sets `attractor_mode: true` and GitHub Project config
- Validates the migration with a test run

---

## Key Differences v4 → v5

| Aspect | v4 | v5 |
|--------|-----|-----|
| **Execution Spine** | Two (PRD + Attractor) | One (Attractor) |
| **Canonical Kanban** | None (local `.prd/` only) | GitHub Project (optional, opt-in) |
| **Runner Agent** | `sprint-runner.md` | `attractor-runner.md` (renamed Phase 2) |
| **Entry Points** | `/cks:new`, `/cks:investigate`, `/cks:debug`, `/cks:go` | Same commands, Attractor-aware (Phase 4) |
| **State Sync** | Manual PRD-STATE updates | Auto-sync via `github-project-sync.js` (Phase 1) |
| **Backward Compat** | N/A | Full via `attractor_mode: false` until Phase 8 |
| **GitHub Integration** | None | Webhook-driven Kanban ↔ runner bidirectional automation (Phase 6) |

---

## Rollout Safety

Every phase:
- Ships behind `attractor_mode: false` — v4 behavior unaffected
- Includes unit + integration + E2E tests for new code
- Marked as feature-complete but flag-guarded (no "experimental" tag)
- Receives code review and UAT sign-off
- Uses `attractor_mode: true` only in test/staging environments until Phase 8

Phase 8 final step: flip `attractor_mode` default to `true` in the production release.

---

## Questions?

Refer to:
- **Integration details**: `docs/PROJECT-INTEGRATION.md` (Phase 1)
- **Automation spec**: `docs/AUTOMATION.md` (Phase 6)
- **GitHub Project setup**: run `/cks:setup-webhooks` (Phase 4+)
- **Migration script**: `scripts/migrate-v4-to-v5.sh` (Phase 8)
