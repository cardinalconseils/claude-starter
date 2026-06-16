---
globs: "agents/concept-orchestrator.md,skills/strategic-frameworks/workflows/pre-mortem.md"
---

# Pre-Mortem Rules

## Mandatory Behavior

When `concept-orchestrator` returns a Go verdict (overall score ≥ 4.0), it MUST call
`AskUserQuestion` offering the Klein pre-mortem before surfacing branch creation or
next-step instructions. This gate is non-negotiable — only the user may dismiss it.

## What MUST Happen

1. After Step 9 (scorecard display), if `overall >= 4.0`:
   - Call `AskUserQuestion` with two options: "Yes — run pre-mortem" and "Skip — open branch now"
   - Never skip this question silently, even if the concept seems low-risk
2. If user selects Yes:
   - Use **Concept Mode framing** from `skills/strategic-frameworks/workflows/pre-mortem.md`
   - Past-tense only: "it failed" — never "it might fail"
   - Output: `.concept/{slug}/PRE-MORTEM.yaml`
   - Append "Pre-Launch Risks" section to `.concept/{slug}/FEASIBILITY.md`
3. If user selects Skip:
   - Proceed to branch creation immediately — no further prompting about pre-mortem

## When This Does NOT Fire

- Defer or Reject verdicts (overall < 4.0) — no implementation imminent, gate skipped
- Ideation (Phase 0) — Klein probe is wired into stress-test directly, not this gate
- Phase 1–2 discovery/planning — handled by `.claude/rules/pm-frameworks.md` keyword trigger

## Klein Framing Rule (applies everywhere pre-mortem is used)

The pre-mortem's cognitive mechanism depends on temporal framing. Agents MUST:
- Use past tense: "the project **has** failed" — not "might fail" or "could fail"
- Ask for independent cause generation before elaboration (prevents anchoring)
- Push back on vague causes: accept only causes specific enough to assign an owner or mitigation

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The concept scored 4.5 — no need for a pre-mortem" | High score = imminent build. That's exactly when pre-mortem adds value. The gate is unconditional on Go. |
| "The user is eager to build, I'll skip the gate" | The user can skip it themselves by selecting "Skip". You cannot skip it on their behalf. |
| "I'll frame it as 'what might go wrong' to be gentler" | Klein's technique requires past-tense framing. Forward-looking language defeats the cognitive mechanism. |
| "Pre-mortem is for big projects, not a small agent" | Small concepts have failure modes too. The 15-minute gate costs less than one debugging session. |
