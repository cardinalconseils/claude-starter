# Workflow: Coordination Status — who is active, what they claimed, where they collide

Read side of the agent registry. `claim`, `release` and `clean` mutate lock files and
belong to the operator; this workflow only reads and reports.

## Preconditions

1. `.cks/control-plane/config.yaml` missing → "Control plane not initialized. Run
   `/cks:control-plane init` first." and stop.
2. `.cks/control-plane/agents/registry/` absent or empty → "No active sessions in
   registry. You may be the only session." and stop.

## Steps

1. `bash scripts/agent-registry.sh list` — active session JSON (read-only). Do not run
   `clean`; note any lock whose `updated_at` is older than the stale threshold instead.
2. Parse each lock file (`jq`, or grep as fallback) and display:

```
Active Sessions
┌──────────────────┬───────────────────────────────────┬─────────────────────────────┐
│ Session          │ Task                              │ Claimed Resources           │
├──────────────────┼───────────────────────────────────┼─────────────────────────────┤
│ 20260520-143201  │ Implementing F-007 auth flow      │ src/auth/login.ts (+1)      │
└──────────────────┴───────────────────────────────────┴─────────────────────────────┘
```

3. Conflicts — any resource present in 2+ lock files:
   `⚠ CONFLICT: <resource> claimed by sessions: <sid1>, <sid2>`. Never suppress.
4. Only this session → "You're the only active session in this repo."
5. Stale locks found → list them and end with the operator dispatch needed
   (`scripts/agent-registry.sh clean`).

## Peers (claude-peers-mcp)

The cross-session dashboard and directives (`list_peers(scope="repo")`, `send_message`)
need the peers MCP, which observation roles do not hold. Report what the file registry
shows and name the chief-of-staff dispatch if a directive to another session is needed.
See `skills/peers/SKILL.md` for the summary format and conflict rules.

## Rules

- Mask `supabase_service_key` as `***` if it ever appears.
- Caveman voice; table format preferred.
