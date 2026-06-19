# Phase Gate Rules

## Mandatory Behavior

Before any lifecycle phase runs, the orchestrating agent MUST call `AskUserQuestion` to confirm run or skip. The agent may recommend based on artifact status, but the human decides. No silent conditionals.

## The Rule

**No phase may dispatch silently.** The pattern `if no {artifact} → dispatch phase` is forbidden in orchestrators. Replace every such conditional with an `AskUserQuestion` gate.

Required gate format:

```
AskUserQuestion(
  question: "Phase {N} — {Name}: {artifact} {✅ found / ⚠️ missing}. Run or skip?",
  header: "Phase {N} Gate",
  options: [
    { label: "Run {Phase Name} (Recommended)",  description: "..." },  ← when artifact missing
    { label: "Skip — already done",              description: "Use existing {artifact}" },  ← when found
    { label: "Skip — not needed",                description: "Proceed without this phase" }
  ]
)
```

Flip the Recommended label: missing artifact → recommend Run. Existing artifact → recommend Skip. Never omit the Recommended label — it must be the first option per `.claude/rules/human-intervention.md`.

## Phase Status Banner (show before gates)

Before asking, display a phase checklist so the human has context for all phases at once:

```
┌─── Phase Status ─────────────────────────────────────┐
│  1. Pre-Flight   {✅ / ⚠️}  → recommend: {Run/Skip}  │
│  2. Discover     {✅ / ⚠️}  → recommend: {Run/Skip}  │
│  3. Design       {✅ / ⚠️}  → recommend: {Run/Skip}  │
│  4. Sprint       {✅ / ⚠️}  → recommend: {Run/Skip}  │
│  5. Review       — confirm at completion              │
│  6. Release      — confirm at completion              │
└──────────────────────────────────────────────────────┘
```

Then ask per-phase sequentially — not as a single multi-select. Phases are dependent: skipping Discover affects whether Design is valid.

## Artifact Locations

| Phase | Artifact to check |
|---|---|
| Pre-Flight | `.preflight/{NN}-*/PREFLIGHT.md` |
| Discover | `.prd/phases/{NN}-*/CONTEXT.md` |
| Design | `.prd/phases/{NN}-*/DESIGN.md` |
| Sprint | `.prd/phases/{NN}-*/VERIFICATION.md` (with PASS verdict) |

## Artifact Writing Is Non-Negotiable

Phase gates control whether a phase RUNS. Artifact writing controls whether a phase is DONE. Both must be enforced:

- `prd-executor` MUST write `SUMMARY.md` before returning — not optional, not skippable
- `prd-verifier` MUST write `VERIFICATION.md` + `CONFIDENCE.md` before returning
- If either agent opens a PR without writing its artifact, that is a definition-of-done violation — see `.claude/rules/definition-of-done.md`

The gate for the next phase will find no artifact and recommend Re-run. This is the recovery path.

## Scope

This rule applies to:
- `agents/prd-orchestrator.md`
- `commands/sprint.md` (pre-sprint phase checks)
- Any future lifecycle orchestrator or command

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The artifact is missing so obviously we should run" | Obvious to the AI ≠ confirmed by the human. Ask. |
| "The artifact exists so we can skip" | Human may want to re-run a phase. Ask. |
| "Asking every phase is slow" | Each gate is one AskUserQuestion — 5 seconds, not 5 minutes. |
| "The user already chose to run /cks:sprint, that's implied consent" | Consent to sprint ≠ consent to skip discovery. Ask per phase. |
| "The executor opened a PR, so the phase is done" | PR ≠ done. SUMMARY.md + VERIFICATION.md must exist on disk before the phase is complete. |
