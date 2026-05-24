# Archived — Demoted or Rejected Skills

## What Lives Here

Skills that were rejected during gatekeeper review or demoted from `skills/validated/`.
All files are stored as `CANDIDATE.md` — never as `SKILL.md` — so they are NOT
auto-discovered and have no effect on running agents.

## Rollback Procedure

To restore an archived skill to the review queue:

1. Move `skills/archived/{name}/CANDIDATE.md` → `skills/quarantine/{name}/CANDIDATE.md`
2. Run `/cks:gate` to start a new review session
3. The gatekeeper will re-run checks and ask for a fresh human verdict

Do not copy the file directly to `skills/validated/` — that bypasses the gate.
