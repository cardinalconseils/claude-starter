# Memory Index — CKS — Claude Code Starter Kit
# Updated: 2026-06-07
#
# Claude: Read this file first when looking for context.
# Do not scan memory/ directly — use this index to find the right file.

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

_No files indexed yet. Add entries here as you create content in memory/._

## Tips for Claude

- Check `wiki/` first for established context before asking the user
- Move processed `raw/` files to `wiki/` once they're codified
- Never modify `output/` files without user confirmation — they may be shared
