# Concept Evaluation Rules

## Mandatory Behavior

When the concept-orchestrator or concept-pillar-worker agents are running, these rules are non-negotiable.

## Rules

**1. Brainstorm before scoring**
The orchestrator MUST invoke the brainstorming skill (via `superpowers:brainstorming` instructions) and receive user confirmation on the refined concept BEFORE dispatching any pillar workers. Scoring a concept that hasn't been fleshed out produces unreliable scores.

**2. Evidence, not vibes**
Every pillar score MUST cite specific files, grep results, or observations. "Seems like a good fit" is not evidence. If a worker cannot find evidence, it must say so explicitly and score conservatively.

**3. All three pillars required**
No pillar may be skipped. A two-pillar evaluation is incomplete. If a pillar is genuinely not applicable (edge case), the worker must state why and assign the score with reasoning.

**4. Write FEASIBILITY.md before reporting**
The orchestrator MUST write `.concept/{slug}/FEASIBILITY.md` to disk BEFORE displaying the scorecard to the user. A scorecard shown without a persisted artifact is a dead end.

**5. Use AskUserQuestion for decisions**
Any decision point where the user's answer changes the outcome (concept clarification, mode confirmation, proceed/abort after scoring) MUST use `AskUserQuestion`. Plain text questions for interactive decisions are forbidden.

**6. EnterPlanMode from the command, not the agent**
The orchestrator MUST NOT call `EnterPlanMode`. That call belongs in `commands/concept.md` after the agent returns. If the orchestrator calls it, it fires inside the agent context and has no effect on the user's session.

**7. Specialist failure is non-blocking**
If a specialist agent (evals-runner, security-auditor, etc.) fails or is unavailable, the pillar worker MUST continue scoring inline. The failure is noted in the FEASIBILITY.md findings, not used to abort the evaluation.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The concept is simple, brainstorming is overkill" | Rule 1 is unconditional. Simple concepts need brainstorming too — it takes 2 minutes and prevents 2-hour rewrites. |
| "I'll mention the evidence in prose, not cite files" | Prose evidence can't be verified. File paths and grep results can. Rule 2 requires citable evidence. |
| "I'll skip Data Impact — it's just a new agent" | New agents still write output files and may touch state. Rule 3 requires all three pillars. |
| "I'll display the scorecard first, write the file after" | Rule 4 is explicit: file first, then display. If the session crashes after display, the artifact is lost. |
| "EnterPlanMode is cleaner from inside the agent" | Rule 6 exists because agents run in subagent context — EnterPlanMode there doesn't affect the user's session. |
