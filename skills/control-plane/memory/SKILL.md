---
name: control-plane/memory
description: "Per-agent memory files, project knowledge base, and session continuity for CKS v6 control plane"
allowed-tools: [Read, Bash, Write]
---

# Control Plane — Memory Layer

File-first memory for CKS v6. Agents write `.md` files. Supabase sync is additive durability, not the primary store.

## Memory Types

### 1. Agent Memory
**Path:** `.cks/control-plane/memory/agents/{agent-name}.md`

Per-agent scratchpad. Agent writes discoveries, patterns, and state relevant to its own operation. Key for long-running or recurring agents that need context across sessions.

### 2. Project Knowledge Base (KB)
**Path:** `.cks/control-plane/memory/project/`

Three files, each append-only:

| File | Purpose |
|------|---------|
| `facts.md` | Immutable truths — tech stack, constraints, integrations |
| `decisions.md` | Architectural/product decisions + rationale |
| `gotchas.md` | Traps, warnings, non-obvious behaviors |

### 3. Session Snapshots
**Path:** `.cks/control-plane/memory/sessions/YYYY-MM-DD-HHMM.md`

One file per session. Written by Stop hook via `scripts/stop-memory.sh`. Loaded in SessionStart banner for context continuity.

## Append-Only Format

Every entry uses this header:

```markdown
## [YYYY-MM-DD] Short Title

Content here.
```

**Never overwrite** existing entries. Always append below the last entry.

## Token-Efficient Lookups

Never load the whole file. Use targeted grep patterns:

```bash
# Recent decisions (last 5)
grep "^## \[2026" .cks/control-plane/memory/project/decisions.md | tail -5

# All gotchas containing a keyword
grep -A5 "migration" .cks/control-plane/memory/project/gotchas.md

# Today's entries
grep "^## \[$(date +%Y-%m-%d)\]" .cks/control-plane/memory/project/facts.md
```

## When to Write

Write a memory entry after any of these:

- **Significant discovery** — learned something non-obvious about the codebase, stack, or user intent
- **Architectural decision** — chose between options with real trade-offs
- **Gotcha found** — hit a trap that future agents (or future-you) should know about
- **Session end** — Stop hook writes automatically; no manual action needed

## Session Continuity Flow

```
Session ends
  → stop.sh calls stop-memory.sh
  → stop-memory.sh writes sessions/YYYY-MM-DD-HHMM.md
  → stop-memory.sh calls memory-sync.sh (if supabase_url present)

Next session starts
  → session-start.sh reads latest sessions/*.md
  → Shows "Memory: {last session line}" in control plane banner
  → Shows KB counts: facts, decisions
```

## Sync to Supabase

Sync is **session-end only** — one call via Stop hook, not per-append.

Gate is deterministic bash, not LLM reasoning:
- `supabase_url` present in `.cks/control-plane/config.yaml` → sync runs
- `supabase_url` absent → skip, zero cost

`memory-sync.sh` always exits 0. Sync failure never blocks Stop hook.

## File Paths Reference

```
.cks/control-plane/memory/
  agents/
    {agent-name}.md     ← per-agent memory
  project/
    facts.md            ← immutable project truths
    decisions.md        ← architectural decisions + rationale
    gotchas.md          ← traps and non-obvious behaviors
  sessions/
    YYYY-MM-DD-HHMM.md  ← dated session snapshots
```

Templates: `skills/control-plane/memory/templates/`

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll remember this — no need to write it down" | Context windows reset. Files don't. Write the entry. |
| "The whole file is short enough to load" | KB grows over months. Always grep; never load whole file. |
| "Sync failure means memory is lost" | Files are source of truth. Supabase is durability. Check `.cks/control-plane/memory/` directly. |
| "I should write memory before I know the outcome" | Write after decisions are made, not before. Facts only. |

## Verification

- [ ] New entries use `## [YYYY-MM-DD] Title` format
- [ ] Existing entries not overwritten
- [ ] Grep used for lookups, not full-file reads
- [ ] `memory-sync.sh` called only from `stop-memory.sh` (session-end only)
- [ ] Agent memory files named after the agent (e.g., `prd-planner.md`)
