# Roadmap Format Guide

The roadmap is a single markdown file at `docs/ROADMAP.md` that serves as the living
source of truth for all planned and in-progress work.

## Structure

```markdown
# {Project Name} — Roadmap

**Last Updated:** {YYYY-MM-DD}

## Active Work

{Features currently being implemented. Show phases with status.}

### PRD-{NNN}: {Feature Title} — {Overall Status}
**PRD:** [PRD-{NNN}](prds/PRD-{NNN}-{name}.md)
**Priority:** {P0|P1|P2|P3}

| Phase | Description | Status | Date |
|-------|-------------|--------|------|
| 1 | {Phase title} | Complete | {YYYY-MM-DD} |
| 2 | {Phase title} | In Progress | — |
| 3 | {Phase title} | Planned | — |

---

## Up Next

{Features that are planned but not yet started. Ordered by priority.}

- **PRD-{NNN}: {Title}** (P{n}) — {one-line summary} → [PRD](prds/PRD-{NNN}-{name}.md)

---

## Completed

{Features that are fully shipped. Most recent first.}

- **PRD-{NNN}: {Title}** — Completed {YYYY-MM-DD} → [PRD](prds/PRD-{NNN}-{name}.md)

---

## Backlog

{Ideas and features captured but not yet prioritized or scoped.}

- {Idea title} — {brief description}

---

*Roadmap maintained by the PRD skill. Updated automatically during feature lifecycle.*
```

## Status Values

Use these consistently:

| Status | Meaning | When to Use |
|--------|---------|-------------|
| **Planned** | Scoped but not started | PRD written, phases defined |
| **In Progress** | Actively being worked on | Implementation started |
| **Complete** | Shipped and verified | All acceptance criteria pass |
| **On Hold** | Paused intentionally | Waiting on dependency or decision |
| **Cancelled** | Will not be built | Scope removed or superseded |

## Rules

1. **Only one feature should be "In Progress" at a time** unless explicitly working on
   parallel streams. This prevents context switching.

2. **Update dates when status changes.** The Date column shows when a phase was completed,
   not when it was started.

3. **Move completed features to the Completed section** once all phases are done. Don't
   let them linger in Active Work.

4. **Backlog is a capture bucket**, not a commitment. Items there have no PRD and no
   priority. When they're ready to be worked on, create a PRD and move them to Up Next.

5. **Keep it scannable.** Someone should be able to glance at the roadmap and know:
   what's happening now, what's next, and what's done. No prose paragraphs.

## Creating the Roadmap for the First Time

If `docs/ROADMAP.md` doesn't exist yet, create it with:
- The project name from CLAUDE.md or package.json
- An empty Active Work section
- An empty Up Next section
- An empty Completed section
- An empty Backlog section

Then add the first feature being planned.

## Updating the Roadmap

**When a new PRD is written:**
- Add the feature to "Up Next" (or "Active Work" if starting immediately)
- Include all phases from the PRD

**When implementation starts:**
- Move the feature from "Up Next" to "Active Work"
- Set the first phase to "In Progress"

**When a phase completes:**
- Mark the phase as "Complete" with today's date
- Set the next phase to "In Progress"

**When all phases are done:**
- Move the entire feature to "Completed" with the date
- Update the PRD status to "Complete"

**When priorities change:**
- Reorder items in "Up Next"
- If an active feature is deprioritized, set it to "On Hold"
