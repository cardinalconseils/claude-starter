# Agentic OS Configuration

Home for the Agentic OS dashboard and operational metadata.

## Files

- `domains.md` — Domain and task definitions (manually maintained)
- `DESIGN.md` — Design document for the Agentic OS system
- `skills/` — Domain-specific skills referenced in commands and agents

## Dashboard Refresh

The dashboard at `board/index.html` displays live project data. To refresh it with current state:

```bash
scripts/agentic-os-refresh.sh
```

This script:
1. Counts files in `memory/raw/`, `memory/wiki/`, `memory/output/` (excludes `.gitkeep`)
2. Pulls the last git commit message and age
3. Parses domain count from `domains.md`
4. Injects the data into the three live widgets: Memory Layer, Git Activity, and Token Tracker (user-managed via localStorage)

**Run before opening the dashboard to see current state**, or wire it into your CI/CD pipeline to auto-update on push.
