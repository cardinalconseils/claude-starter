# CKS Workflow Reference

> **Version 4.6.1** | Built 2026-04-08 | `9495668`

## How to Call `/cks:peers` — Session Orchestration

### Prerequisites

1. Install claude-peers-mcp: `/cks:peers setup`
2. Open 2+ Claude Code terminals in the **same repo**

### Usage

```
/cks:peers                 Show the session dashboard
/cks:peers setup           Install claude-peers-mcp broker
```

### What Happens Automatically

Every session auto-announces its status via lifecycle hooks — no manual step:

| Hook Event | What Gets Announced |
|------------|-------------------|
| **SessionStart** | `[active] ProjectName — branch feat/xyz` |
| **SubagentStop** | `[sprint:3c] F-010 Rich Standings — implementing` |
| **Stop** | `[closing] ProjectName — session ending` |

The summary updates on every phase transition, agent completion, or session event.

### Dashboard Output

When you run `/cks:peers` in the main session:

```
Session Dashboard — NHL
┌──────────┬──────────────┬────────────────────────────────────────────┬──────────────────────────┐
│ Session  │ Activity     │ Status                                     │ Doc                      │
├──────────┼──────────────┼────────────────────────────────────────────┼──────────────────────────┤
│ abc123   │ [sprint:3c]  │ F-010 Rich Standings — implementing        │ .prd/phases/01-rich/     │
│ def456   │ [discover]   │ F-011 Player Profiles — gathering elements │ .prd/phases/02-profiles/ │
│ ghi789   │ [active]     │ Working on branch main (this session)      │                          │
└──────────┴──────────────┴────────────────────────────────────────────┴──────────────────────────┘

⚠ No conflicts detected.
```

### Conflict Detection

The dashboard flags when two sessions overlap:

```
⚠ Conflict: sessions abc123 and def456 both working on F-010
   → Consider: "tell session def456 to switch to F-011"
```

### Sending Directives

From the main session, use natural language:

```
"Tell session abc123 to stop working on auth — I'm handling it"
"Ask session def456 what files they've changed"
"Let all sessions know we're freezing merges"
```

Directives arrive via channel push — the worker session sees them immediately without polling.

---

## Activity Codes

Auto-summaries use these codes covering ALL session types:

| Code | Session Activity |
|------|-----------------|
| `[kickstart:step]` | Project enabler flow |
| `[ideate]` | Brainstorming |
| `[discover]` | Phase 1: Requirements |
| `[design]` | Phase 2: UX/API |
| `[sprint:3a]` | Phase 3: Sprint planning |
| `[sprint:3c]` | Phase 3: Implementation |
| `[sprint:3d]` | Phase 3: Code review |
| `[sprint:3e]` | Phase 3: QA |
| `[review]` | Phase 4: Feedback |
| `[release]` | Phase 5: Deployment |
| `[research]` | Deep research |
| `[debug]` | Debugging |
| `[tdd]` | Test-driven development |
| `[security]` | Security audit |
| `[bootstrap]` | Project setup |
| `[adopt]` | Mid-dev CKS adoption |
| `[context]` | Library/API research |
| `[active]` | Freeform work (fallback) |
| `[idle]` | No active task |
| `[closing]` | Session ending |

---

## Full Lifecycle Flow

```
/cks:kickstart           Idea → scaffolded project
  └── /cks:bootstrap     Scaffold → CLAUDE.md, .prd/, rules

/cks:new "feature"       Create feature → Phase 1
  ├── /cks:discover      Phase 1: Discovery (11 Elements)
  ├── /cks:design        Phase 2: Design (Stitch MCP screens)
  ├── /cks:sprint        Phase 3: Sprint (plan → build → review → QA → merge)
  ├── /cks:review        Phase 4: Review & retro → iteration decision
  └── /cks:release       Phase 5: Release (Dev → Staging → RC → Prod)

/cks:peers               Multi-session awareness dashboard
/cks:go                  Build → commit → push → PR
/cks:sprint-start        Load session context (every session open)
/cks:sprint-close        Capture learnings (every session close)
```

---

## Delegation: Subagents vs Agent Teams

The executor decides how to split work:

| Condition | Delegation |
|-----------|-----------|
| 1-2 task groups OR ≤ 3 files | Inline (executor does it) |
| 3-5 independent task groups | Parallel subagents (shared context) |
| 6+ task groups OR context pressure | Agent Teams (worktree isolation) |

Subagents share the parent's context window. Agent Teams get independent context windows and shell environments via git worktrees — use them when the plan + files exceed ~50% of context.

---

## Quick Reference

| Goal | Command |
|------|---------|
| Start a project | `/cks:kickstart` |
| Start a feature | `/cks:new "feature"` |
| See what sessions are doing | `/cks:peers` |
| Save my work | `/cks:go commit` |
| Ship it | `/cks:go` |
| Full ceremony release | `/cks:release` |
| What should I do next? | `/cks:next` |
