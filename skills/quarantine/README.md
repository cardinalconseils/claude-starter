# Quarantine — Candidate Skills Pending Review

## Inertness Guarantee

No `SKILL.md` files are allowed anywhere in this directory tree.
CKS auto-discovery triggers on the `SKILL.md` filename — any file with that name
is immediately live. Candidates here are stored as `CANDIDATE.md` to remain inert
until the gatekeeper explicitly promotes them.

## Submission Flow

1. Drop a `CANDIDATE.md` into `skills/quarantine/{skill-name}/`
2. Run `/cks:gate` to start a gatekeeper review session
3. Gatekeeper runs format / conflict / scope checks, then asks for a human verdict
4. On approval: gatekeeper renames the file to `SKILL.md` in `skills/validated/{skill-name}/` — this IS the activation act
5. On rejection: gatekeeper moves the file to `skills/archived/{skill-name}/CANDIDATE.md`

## Why CANDIDATE.md

Auto-discovery is triggered by the `SKILL.md` filename — not by content, not by directory.
`CANDIDATE.md` is completely ignored by the discovery system. Do not rename it manually.
Only the gatekeeper renames files; that rename is the promotion gate.
