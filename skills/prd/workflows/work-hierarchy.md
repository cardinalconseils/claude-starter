# Workflow: Work Hierarchy — sole writer of `.prd/work-hierarchy.md`

Every mutation to the Feature → Phase → Task tree goes through the project-manager.
Read consumers may parse the file with `yq`; only this workflow writes it.
Mechanical job: parse → validate → mutate → write atomically → echo a structured result.

## Source of Truth

`.prd/work-hierarchy.md` is the sole on-disk truth for the tree. `.prd/PRD-STATE.md`
references it via `Active Feature:` and `Active Phase (Hierarchy):` and never duplicates it.

Artifacts (CONTEXT.md, DESIGN.md, …) stay flat under `.prd/phases/{NN}-{slug}/`.
Reparenting moves the tree edge, not the directory.

## File Schema

YAML frontmatter is the contract; the Markdown body is a human note.

```markdown
---
version: 1
active_feature: F-01
active_phase: P-01
features:
  - id: F-01
    title: "Checkout v2"
    status: doing            # todo | doing | done | blocked
    slug: checkout-v2
    phases:
      - id: P-01
        title: "Cart redesign"
        status: doing
        slug: cart-redesign
        tasks:
          - id: T-01-01
            title: "Wire up empty state"
            status: done
          - id: T-01-02
            title: "Mobile breakpoints"
            status: todo
  - id: F-LEGACY
    title: "Legacy"
    status: doing
    slug: legacy
    phases:
      - id: P-03
        title: "Legacy phase: foo"
        status: doing
        slug: foo
        tasks: []
---

# Work Hierarchy

_Auto-managed by the project-manager. Edit via `/cks:work` only._
```

## ID Rules

- Features: `F-NN`, zero-padded, ≥ 2 digits, monotonically increasing (except reserved `F-LEGACY`).
- Phases: `P-NN`, globally numbered, ≥ 2 digits. Match the existing `.prd/phases/{NN}-{slug}/`
  number when possible.
- Tasks: `T-NN-NN` — first segment = parent Phase number; second = task index within it.
- IDs are immutable after creation. `move` preserves the ID.

## Mutation Contracts

### `new`
Inputs: `--type {feature|phase|task}`, `--title "X"`, optional `--parent ID`, optional `--slug`
(defaults to kebab-cased title).
- `feature`: no parent; next free `F-NN`.
- `phase`: parent must be a Feature; next free `P-NN`.
- `task`: parent must be a Phase; next free `T-{phase}-NN`.
- Set `active_feature` / `active_phase` when the created node is more specific than the
  current pointer (creating a Phase sets `active_phase`).
- Reject if parent is missing, wrong type, or closed.

### `move <ID> --to <PARENT_ID>`
- Allowed: Phase → another Feature, Task → another Phase.
- Forbidden: Task → Feature, Feature → anywhere, cycles.
- IDs preserved. Artifacts on disk are NOT moved.

### `close <ID>`
- Sets status `done`.
- Close-blocking: a Feature cannot close while any child Phase has an open Task; a Phase
  cannot close while any child Task is open. Reject with a Decision-Required block listing
  the blocking IDs. No `--force`.

### `activate <ID>`
- Sets `active_feature` (Feature) or `active_phase` (Phase). Tasks are not activated.
- Mirror into `.prd/PRD-STATE.md` `Active Feature:` / `Active Phase (Hierarchy):`.

### `list [--type T] [--status S] [--parent ID]`
- Read-only. Output `ID  TYPE  STATUS  TITLE`, one per line.

## Operational Rules

1. Re-read before every write — never trust an in-memory snapshot from earlier in the session.
2. Atomic write: write `.prd/work-hierarchy.md.tmp`, then `mv` into place.
3. Validate before write: schema (required fields, status values, ID format), parent type,
   close-blocking.
4. Never edit the Markdown body other than the trailing auto-managed note.
5. Idempotent activate: activating an already-active ID is a no-op success.
6. Empty-state safe: if the file is missing, treat the tree as empty and create it on the first
   mutation. Do NOT auto-wrap legacy phases — the SessionStart hook does that.

## Error Format

On any rejection, emit a `❓ DECISION REQUIRED` block per `.claude/rules/human-intervention.md`
naming the failure, the offending IDs, and the safer alternative. Then stop without writing.

```
─────────────────────────────────────────────────
❓ DECISION REQUIRED
─────────────────────────────────────────────────
F-01 cannot be closed — open Tasks: [T-01-02, T-01-05]

  1. Close the blocking Tasks first
  2. Skip — leave F-01 open
  3. Describe what you want

Recommended: 1 — open Tasks must complete before the Feature can be marked done.

Reply with the number or describe what you want.
─────────────────────────────────────────────────
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0    | success |
| 64   | usage error (bad flags) |
| 65   | data error (invalid schema, parent-type) |
| 66   | missing input (no such ID) |
| 73   | write failure |
| 75   | concurrent-write retry-suggested |

## PRD-STATE.md Mirroring

When `active_feature` / `active_phase` change, update the matching lines in `.prd/PRD-STATE.md`:

- `Active Feature: F-NN` (or `—`)
- `Active Phase (Hierarchy): P-NN` (or `—`)

Do NOT touch the legacy `Active Phase:` key — it belongs to the 5-phase lifecycle.

## Output

One block: action taken, IDs touched, new active pointers (if changed), file paths written.
