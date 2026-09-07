# Workflow: Design Fluency Review

Visual-slop lint and maturity gate for UI output. Ported from the `design-fluency-reviewer`
agent. Run by the reviewer role (design fluency mode). Review only — no source changes.

## Inputs

`target` (file, directory, or URL); `maturity` (Prototype | Pilot | Candidate | Production),
read from `PROJECT.md` when absent, default Prototype.

## Steps

1. **Lint** — `npx impeccable detect <target>`. Parse each finding: `id` (signal name),
   `file`, `line`, `message`. Tool missing → surface the install step as `▶ ACTION REQUIRED`
   and stop.
2. **Map** — look each `id` up in the Visual Slop Signals table of `skills/design-fluency/SKILL.md`:
   category (`slop` or `quality`), design verb (bolder / quieter / distill / polish /
   clarify / animate / harden), reference file under `references/`.
3. **Gate**

| Maturity | Slop findings | Quality findings |
|---|---|---|
| Prototype | ADVISORY | ADVISORY |
| Pilot | ADVISORY | ADVISORY |
| Candidate | BLOCKING | BLOCKING (critical severity only) |
| Production | BLOCKING | BLOCKING |

No UI files in scope → `Gate Status: N/A — no UI files in scope`.

## Output

```
Design Review: <target>

| Signal | Category | File | Line | Design Verb | Reference |
|--------|----------|------|------|-------------|-----------|
| side-tab | slop | Card.tsx | 12 | distill | references/spatial.md |

Summary: {N} slop findings, {M} quality findings.
Gate Status: {PASS / ADVISORY / BLOCKING / N/A}
```

Every finding maps to a verb — none left without an actionable fix. Scope is the target only.
