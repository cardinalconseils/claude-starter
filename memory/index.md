---
type: index
name: memory-index
description: Directory listing for CKS memory bundle — read this first, do not scan memory/ directly
---

# Memory Index — CKS — Claude Code Starter Kit
# Updated: 2026-06-15

## Structure

| Folder | Purpose | When to use |
|--------|---------|-------------|
| `raw/` | Staging — unprocessed notes, research, meeting outputs | Drop new material here first |
| `wiki/` | Codified — reports, decisions, stable reference | Look here for established knowledge |
| `output/` | Deliverables — final documents ready for sharing | Finished products live here |

## Domains

- **Plugin Dev** — commands, agents, hooks, skills, TDD → skill: `.agentic-os/skills/plugin-dev.md`
- **Release** — version bump, CHANGELOG, PR, publish → skill: `.agentic-os/skills/release.md`
- **Docs** — README, wiki, changelogs → skill: `.agentic-os/skills/docs.md`
- **Community** — issue triage, PR review, announcements, feedback → skill: `.agentic-os/skills/community.md`
- **Widget Dev** — dashboard widgets: create, layout, data source, debug, docs → skill: `.agentic-os/skills/widget-dev.md`
- **Data** — schemas, live sources, aggregations, memory layer, exports → skill: `.agentic-os/skills/data.md`

## Files

| File | Type | Description |
|---|---|---|
| `log.md` | log | Chronological knowledge event history (OKF reserved) |
| `correction_log.md` | log | Agent mistake corrections (human-reviewed) |
| `project_global_memory_layer.md` | article | Global memory layer design spec |
| `wiki/learnings/phase-08-arch-pattern-auto-invocation.md` | learning | Phase 08 retrospective — arch-pattern auto-invocation |

## Tips for Claude

- Check `wiki/` first for established context before asking the user
- Move processed `raw/` files to `wiki/` once they're codified
- Never modify `output/` files without user confirmation — they may be shared
