---
name: ahe-evolution
description: AHE Evolution Agent domain knowledge — reading harness signals, clustering patterns, generating golden case proposals, HITL validation loop
allowed-tools:
  - Read
  - Bash
  - Glob
  - Grep
  - Agent
  - Write
---

# AHE Evolution — Domain Knowledge

## What AHE Evolution Is

AHE Evolution is **machine-observable learning** — distinct from retrospective (human-observable).

It reads three signal sources automatically — telemetry, governance logs, harness eval results — clusters error patterns, proposes narrow validated mutations, and gates every change behind explicit human approval (HITL). No mutation ships without a human decision.

Contrast with retrospective: retrospective surfaces what humans observed and learned. AHE Evolution surfaces what the machine recorded and what the signal data suggests needs testing coverage.

## v1 Scope

**Golden case additions only.** The agent proposes new harness-eval golden cases based on observed hook failure patterns.

Rule tuning and guardrail parameter mutations are **v2** — after the proposal loop is proven reliable.

## Three Signal Sources

| Source | Path | What to look for | How to cluster |
|--------|------|------------------|----------------|
| Telemetry | `.prd/logs/sessions/*.jsonl` (most recent 5) | Records where `outcome=error`, grouped by `tool` | Count by tool; sort descending. Flag `tool:"unknown"` as data quality issue (G3). |
| Governance | `.cks/governance.json` (JSONL append-only) | `risk_reason + decision` pairs | Group by risk_reason; compute approval rate per class |
| Harness eval results | `.harness-evals/results/*.json` | Any case where `pass: false` | List by hook name + case name |

## Proposal Format

Each `PROPOSAL-NNN.md` must contain:

1. **Evidence** — signal source, pattern description, frequency count
2. **Proposed golden case** — hook name, case name, `input.json`, `expected.json`
3. **Validation run** — exact bash command run, actual exit code captured, pattern match result
4. **Suggested action** — step-by-step instructions to apply the case

See `skills/ahe-evolution/references/proposal-template.md` for the exact template.

## Validation Protocol

Before writing any proposal, run the hook directly:

```bash
printf '%s' '{input_json}' | bash hooks/handlers/{hook-name}.sh
echo "exit: $?"
```

Rules:
- Capture actual exit code
- If output pattern check required: capture stdout/stderr, verify match
- If actual != expected: **skip** this proposal — do not write it
- A wrong `expected.json` causes a permanently failing golden case

Only write proposals where validation confirmed actual == expected.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The pattern is obvious, I don't need to validate" | Run the bash command. Memory-based expected values cause false proposals. |
| "I'll write the proposal even though validation failed" | Validation failure = wrong expected value. Fix the expected value or skip the proposal. |
| "I should expand scope to propose rule changes too" | v1 is golden cases only. Rule mutations ship in v2 after the proposal loop is proven. |
| "I can write the golden case directly to .harness-evals/golden/" | NEVER. Write to .ahe/proposals/ only. Human copies on approval. |
| "tool:unknown means telemetry is broken, I should abort" | Flag in Signal Summary and continue. Governance and harness-eval signals are usable today. |

## Verification

- [ ] Signal Summary section present, showing what was found in each source
- [ ] Candidates ranked by frequency × impact weight (harness=3, governance=2, telemetry=1)
- [ ] No proposal written without a passing validation run
- [ ] All proposal files in `.ahe/proposals/` only — no writes to `.harness-evals/golden/`
- [ ] DECISION REQUIRED block surfaces all proposal paths
- [ ] Synthetic inputs used only — no real paths, no real secrets
- [ ] Existing golden cases checked to avoid duplicates
