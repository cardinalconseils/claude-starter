# Workflow: Multi-Session Parallel Sprint

## When to Offer

Offer multi-session sprint when ALL of these are true:
1. Sprint plan has 2+ independent task groups
2. `list_peers` returns 1+ other sessions (besides coordinator)
3. Task groups have non-overlapping file scopes
4. User explicitly opts in (never auto-distribute without asking)

## Decision Point

Before dispatching workers, present the choice:

```
Sprint Plan has {N} task groups. You have {M} peer sessions available.

Option A: Single-session (subagents) — all work in this terminal
Option B: Multi-session — distribute across {M+1} sessions

Multi-session benefits: full context window per session, independent shell access
Multi-session trade-off: requires open terminals, harder to consolidate
```

Use `AskUserQuestion` — never decide for the user.

## Distribution Protocol

### Step 1: Map task groups to peers

Read PLAN.md → extract task groups with file scopes.
`list_peers(scope="repo")` → get available sessions.

Assign one task group per peer. Coordinator keeps one task group for itself.

Rules:
- Never assign overlapping file scopes to different peers
- If more task groups than peers → coordinator takes extras as subagents
- If more peers than task groups → leave extras idle (inform them)

### Step 2: Send task assignments

For each peer, send a structured `task` message:

```json
{
  "type": "task",
  "phase": "01-auth",
  "task_group": "TG-2",
  "description": "Implement API route handlers for auth endpoints",
  "files_scope": ["src/routes/auth/"],
  "plan_path": ".prd/phases/01-auth/01-PLAN.md",
  "constraints": "Do not modify src/auth/middleware.ts (owned by TG-1)"
}
```

### Step 3: Set coordinator summary

```
set_summary("Coordinator — Phase 01 sprint across {N} sessions. TG-1: self, TG-2: peer-abc, TG-3: peer-def")
```

### Step 4: Execute own task group

The coordinator works on its assigned task group using normal sprint execution (subagents or direct implementation).

### Step 5: Poll for peer results

At natural breakpoints (after completing own task group, or every 5 minutes):

1. `check_messages` for incoming results
2. Parse `status` and `result` messages
3. Track completion: `{completed}/{total} task groups done`

### Step 6: Handle edge cases

**Peer goes offline mid-task:**
- Detect via `list_peers` — peer disappears
- Wait 60 seconds (peer may reconnect)
- If still gone → pick up their task group locally (subagent fallback)
- Log: "Peer {id} disconnected — reassigning TG-{N} to coordinator"

**Peer reports blocked:**
- Read the blocker from the `status` message
- If resolvable (missing file, dependency order) → send guidance
- If not resolvable → reassign to self or ask user

**Peer reports failed:**
- Read the error from the `result` message
- Assess: retry-worthy or needs human intervention
- If retry → send `task` again with additional context
- If human needed → report to user via `AskUserQuestion`

### Step 7: Consolidate

When all task groups report `result` with `outcome: "success"`:

1. Read each peer's changed files (they should be on disk — same repo)
2. Run build + lint + test to verify integration
3. If passing → write consolidated SUMMARY.md
4. If failing → identify which task group's changes conflict, coordinate fix

## Fallback to Single-Session

If at any point multi-session becomes impractical:
- Only 1 peer and it disconnects → switch to subagent mode
- User requests single-session → honor immediately
- Integration conflicts are severe → ask user to pick one session's changes

Always announce the fallback:
```
"Switching to single-session mode — {reason}. Continuing sprint with subagents."
```
