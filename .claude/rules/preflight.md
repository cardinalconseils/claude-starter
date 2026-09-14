# Pre-flight Rules

## Mandatory Behavior

A `PREFLIGHT.md` whose last line reads `Cleared for takeoff: YES` is REQUIRED for the active
feature before either of these happens:

1. Any Phase 1 Discovery dispatch (`cks:strategist` `Mode: discover`)
2. Any sprint pipeline run (`pipelines/sprint.dot`, via `/cks:sprint`, `/cks:sprint-run`,
   `/cks:sprint-auto`, `/cks:factory`)

Artifact: `.preflight/{NN}-{slug}/PREFLIGHT.md` (`00-{slug}` when no phase number exists yet).
Owner: `cks:architect` in `Mode: preflight`, reading `skills/agile-eagle/workflows/preflight.md`.
The strategist does not write it; commands and orchestrators do not write it inline.

A `Cleared for takeoff: NO` (any `BLOCK` gotcha) stops the chain. The orchestrator surfaces a
`▶ ACTION REQUIRED` block naming each BLOCK gotcha, with `Then: re-run /cks:preflight {NN}`,
and dispatches nothing further. Discovery and the sprint pipeline never start on a `NO`.

## The Gate

Per `.claude/rules/phase-gates.md`: no silent conditional. Before each chain below, glob the
artifact, read its verdict, show the phase status banner (row 1 is Pre-Flight), then ask:

```
AskUserQuestion(
  question: "Phase 1 — Pre-Flight: .preflight/{NN}-*/PREFLIGHT.md {✅ found, verdict YES / ⚠️ missing}. Run or skip?",
  header: "Phase 1 Gate",
  options: [
    { label: "Run pre-flight (Recommended)",   description: "Architect maps P→R→E→F→L→I→G and writes PREFLIGHT.md" },  ← when missing, or found with verdict NO
    { label: "Stop — I'll come back",           description: "End here; nothing is dispatched" },                       ← when missing
    { label: "Skip — already done (Recommended)", description: "Use existing PREFLIGHT.md (verdict YES)" },             ← when found with verdict YES
    { label: "Re-run pre-flight",               description: "Map again — the codebase or the brief changed" }           ← when found
  ]
)
```

Missing → two options: `Run pre-flight (Recommended)` / `Stop — I'll come back`.
Found with `YES` → two options: `Skip — already done (Recommended)` / `Re-run pre-flight`.
Found with `NO` → treat as missing (the blocker must be fixed and the pre-flight re-run).
The Recommended label is always first. There is NO "proceed without pre-flight" option in any
chain, and no orchestrator may add one.

The dispatch on Run / Re-run:

```
Agent(subagent_type="cks:architect", prompt="Mode: preflight — feature {slug}, phase {NN}. Read skills/agile-eagle/workflows/preflight.md; write .preflight/{NN}-{slug}/PREFLIGHT.md; return the Cleared for takeoff verdict.")
```

After it returns, re-read the verdict from disk (not from the agent's summary): `YES` →
continue the chain; `NO` → `▶ ACTION REQUIRED`, stop.

## Chains Covered

| Chain | Where the gate fires | Then |
|---|---|---|
| `/cks:new` | Step 3.5, after the feature entry exists, before the Discovery dispatch | Discovery |
| `/cks:sprint` | Gate 1 of the pre-sprint phase check | Gates 2–3, then the attractor |
| `/cks:sprint-run`, `/cks:sprint-auto`, `/cks:factory` | `Preflight` node of `pipelines/sprint.dot` (`skills/attractor/SKILL-ORCHESTRATOR.md`) | `Discover` node |
| Kickstart auto-chain | `skills/kickstart/workflows/auto-chain.md` step 3, after the manifest copy | Strategist discovery |
| `/cks:adopt` | Phase 1.6 — unconditional dispatch (no artifact can exist yet), `00-{slug}` | Phase 2 Generate |
| `/cks:concept`, `/cks:monetize`, `/cks:ideate`, `/cks:brainstorm` | Inherited — each hands off to `/cks:new`, which gates | — |

`/cks:sprint` passes `PREFLIGHT gate: passed at {path}` to the attractor so the `Preflight` node
does not ask the same question twice in one session; every other entry into the pipeline is
gated by the node itself. `--auto` runs: found with `YES` → pass; missing → dispatch; `NO` → stop.

## Trigger Phrases (for intake routing)

Any inbound request matching these, case-insensitive, is a build request and enters a covered
chain — never a direct builder dispatch. `.claude/rules/intake.md` references this list.

- `build`, `implement`, `ship`, `add a feature`, `new feature`, `feature`
- `product`, `MVP`, `prototype`, `app`, `dashboard`
- `monetize`, `pricing`, `business model` (→ `/cks:monetize` → `/cks:new`)
- `concept`, `idea`, `evaluate`, `feasibility` (→ `/cks:concept` → `/cks:new`)

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The user chose /cks:sprint, that is consent to skip pre-flight" | Consent to sprint ≠ consent to fly blind. The gate asks; the only ways forward are Run or Stop. |
| "PREFLIGHT.md exists, no need to ask" | It may be stale or say NO. Read the verdict, then ask Skip or Re-run — the human decides. |
| "Discovery covers dependencies in element 9" | Discovery records what the user says depends on what. Pre-flight maps what the code says. Different source, different owner. |
| "It's an adopt — the code is already written" | That is the case with the most unmapped surfaces. `/cks:adopt` dispatches pre-flight unconditionally for that reason. |
| "The BLOCK is minor, I'll note it and continue" | A BLOCK the architect could not downgrade with a named mitigation stops the chain. Fix it, re-run, get the YES. |
| "Auto mode means no gates" | `--auto` removes the question, not the requirement: missing → dispatch, NO → stop. |
| "I'll have the strategist do it during discovery to save a dispatch" | The strategist does not hold `agile-eagle` and does not write `.preflight/`. Dependency mapping is design work; it is the architect's. |

## Verification

- [ ] No Discovery dispatch and no sprint pipeline run in a session without a preceding pre-flight gate (`AskUserQuestion`) in that session
- [ ] `grep -rn "without pre-flight" commands/ skills/` returns nothing
- [ ] Every gate shows the artifact path + found/missing + verdict in the question text
- [ ] Recommended label is first: missing → `Run pre-flight (Recommended)`, found with YES → `Skip — already done (Recommended)`
- [ ] Every Run / Re-run dispatches `cks:architect` with `Mode: preflight` and names `skills/agile-eagle/workflows/preflight.md`
- [ ] Verdict is read from `.preflight/{NN}-*/PREFLIGHT.md` on disk after the dispatch, not from the agent's summary
- [ ] A `NO` verdict produced a `▶ ACTION REQUIRED` block and nothing was dispatched after it
- [ ] `pipelines/sprint.dot` has a `Preflight` node before `Discover`, and the orchestrator's artifact contract lists it
