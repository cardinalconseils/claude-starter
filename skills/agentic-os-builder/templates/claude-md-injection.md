## Agentic OS

This project uses the CKS Agentic OS structure.

### Memory System

Read `memory/index.md` first when looking for context — do not scan `memory/` directly.

| Folder | Purpose |
|--------|---------|
| `memory/raw/` | Staging: unprocessed notes, research, raw context |
| `memory/wiki/` | Codified knowledge: reports, decisions, stable reference |
| `memory/output/` | Final deliverables: exports, proposals, client-ready docs |

### Domains

{{DOMAINS_CLAUDE_MD}}

Domain skills live in `.agentic-os/skills/`. Read the relevant skill before executing domain tasks.

### Dashboard

`dashboard/index.html` — open in browser for a visual interface with skill buttons.
Re-run `/cks:agentic-os init` to refresh the dashboard with current domain and memory state.
