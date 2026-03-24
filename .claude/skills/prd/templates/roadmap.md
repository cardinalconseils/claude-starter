# ROADMAP.md Template

Use this template when creating `.prd/PRD-ROADMAP.md` and `docs/ROADMAP.md`. Replace all `{placeholders}`.

---

```markdown
# {Project Name} — Roadmap

**Last Updated:** {YYYY-MM-DD}

## Active Work

{Features currently being implemented. Show phases with status.}

<!-- Add active features here as they start -->

---

## Up Next

{Features planned but not yet started. Ordered by priority.}

<!-- Add planned features here -->

---

## Completed

{Features fully shipped. Most recent first.}

<!-- Move completed features here -->

---

## Backlog

{Ideas captured but not yet prioritized or scoped.}

<!-- Add backlog ideas here -->

---

*Roadmap maintained by the PRD plugin. Updated automatically during feature lifecycle.*
```

## Status Values

| Status | Meaning |
|--------|---------|
| **Discussing** | Requirements being gathered |
| **Discussed** | Discovery complete, ready for planning |
| **Planned** | PRD written, execution plan ready |
| **In Progress** | Implementation started |
| **Executed** | Code written, pending verification |
| **Complete** | Verified and shipped |
| **On Hold** | Paused intentionally |
| **Cancelled** | Will not be built |

## Phase Entry Format

When adding a feature to Active Work:

```markdown
### PRD-{NNN}: {Feature Title} — {Overall Status}
**PRD:** [PRD-{NNN}](../docs/prds/PRD-{NNN}-{name}.md)
**Priority:** {P0|P1|P2|P3}

| Phase | Description | Status | Date |
|-------|-------------|--------|------|
| 1 | {Phase title} | {status} | {date or —} |
| 2 | {Phase title} | {status} | {date or —} |
```
