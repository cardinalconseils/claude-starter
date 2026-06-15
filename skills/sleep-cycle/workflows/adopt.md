# Adopt Workflow (Deterministic)

Guides user through reviewing staged proposals and applying approved ones to `skills/*/SKILL.md`.
Every adoption decision goes through a `❓ DECISION REQUIRED` block — nothing auto-applies.

## Inputs

- `.sleep/staged/` — staged proposals awaiting review
- `skills/{skill}/SKILL.md` — target skill file (read-only until user approves)

## Steps

### 1. List Staged Proposals

```bash
ls .sleep/staged/ 2>/dev/null | sort
```

If empty: "No staged proposals. Run /cks:sleep to generate a cycle."

### 2. For Each Proposal — Decision Block

For each file in `.sleep/staged/`:

Parse metadata from the proposal file header:
- `skill` name
- `date` of cycle
- `lift` delta from gate scores
- Brief summary of changes (first `## Summary` section)

Show:

```
─────────────────────────────────────────────────
❓ DECISION REQUIRED
─────────────────────────────────────────────────
Skill proposal: {skill-name}
Cycle date:     {date}
Lift delta:     +{lift*100:.1f}% on smoke eval gate
Change summary: {1-2 line summary from proposal header}

  1. Adopt — apply proposal to skills/{skill}/SKILL.md
  2. View diff — show full before/after sections
  3. Discard — delete from .sleep/staged/, skill unchanged
  4. Defer — leave in .sleep/staged/ for next session

Recommended: 1 (Adopt) — gate confirmed improvement is above threshold

Reply with the number or describe what you want.
─────────────────────────────────────────────────
```

### 3. View Diff (option 2)

Display side-by-side diff using:

```bash
diff skills/{skill}/SKILL.md .sleep/staged/{skill}-{date}.md
```

Then re-show the Decision Required block.

### 4. Adopt (option 1)

```bash
# Backup current skill
cp skills/{skill}/SKILL.md .sleep/applied/{skill}-{date}-before.md

# Apply proposal
cp .sleep/staged/{skill}-{date}.md skills/{skill}/SKILL.md

# Archive proposal
mv .sleep/staged/{skill}-{date}.md .sleep/applied/{skill}-{date}-adopted.md
```

Confirm: "Applied. `skills/{skill}/SKILL.md` updated. Backup at `.sleep/applied/{skill}-{date}-before.md`"

### 5. Discard (option 3)

```bash
rm .sleep/staged/{skill}-{date}.md
```

Confirm: "Discarded. `skills/{skill}/SKILL.md` unchanged."

### 6. Defer (option 4)

Leave file in `.sleep/staged/`. Session-start hook will surface it again next session.

### 7. Completion

After all proposals reviewed:

```
💤 Adoption review complete.
   Adopted: {N} skills
   Discarded: {N}
   Deferred: {N} (still in .sleep/staged/)
```

## Adoption Invariants

- NEVER apply a proposal without showing the Decision Required block
- NEVER auto-adopt even if lift is very high
- ALWAYS create a backup in `.sleep/applied/` before overwriting
- Backup enables manual rollback: `cp .sleep/applied/{skill}-{date}-before.md skills/{skill}/SKILL.md`
- Adopted skills are queued for the next sleep cycle automatically (source: "adopted")
