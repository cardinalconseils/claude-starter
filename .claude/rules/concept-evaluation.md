# Concept Evaluation Rules

## Mandatory Behavior

When the concept-orchestrator or concept-pillar-worker agents are running, these rules are non-negotiable.

## Rules

**1. Brainstorm before scoring**
The orchestrator MUST invoke the brainstorming skill via `/cks:ideate` (dispatched as an agent, not a Skill() call) and receive user confirmation on the refined concept BEFORE dispatching any pillar workers. Scoring a concept that hasn't been fleshed out produces unreliable scores.

**2. Evidence, not vibes**
Every pillar score MUST cite specific files, grep results, or observations. "Seems like a good fit" is not evidence. If a worker cannot find evidence, it must say so explicitly and score conservatively.

**3. All three pillars required**
No pillar may be skipped. A two-pillar evaluation is incomplete. If a pillar is genuinely not applicable (edge case), the worker must state why and assign the score with reasoning.

**4. Write FEASIBILITY.md before reporting**
The orchestrator MUST write `.concept/{slug}/FEASIBILITY.md` to disk BEFORE displaying the scorecard to the user. A scorecard shown without a persisted artifact is a dead end.

**5. Use AskUserQuestion for decisions**
Any decision point where the user's answer changes the outcome (concept clarification, mode confirmation, proceed/abort after scoring) MUST use `AskUserQuestion`. Plain text questions for interactive decisions are forbidden.

**6. EnterPlanMode from the command, not the agent — and always first**
The orchestrator MUST NOT call `EnterPlanMode`. That call belongs in `commands/concept.md` as Step 1 — BEFORE the orchestrator is dispatched, not after. EnterPlanMode inside an agent context has no effect on the user's session, and EnterPlanMode after the orchestrator completes defeats the purpose of planning.

**7. Specialist failure is non-blocking**
If a specialist agent (evals-runner, security-auditor, etc.) fails or is unavailable, the pillar worker MUST continue scoring inline. The failure is noted in the FEASIBILITY.md findings, not used to abort the evaluation.

**8. Technology Fit pillar must apply the bucket test**
When scoring Technology Fit for any CKS component (command, agent, skill, hook, rule, integration), the pillar worker MUST confirm the candidate belongs in the correct layer per `.claude/rules/setup-philosophy.md`. A hook that contains model reasoning, or a skill that encodes a hard rule with no enforcement mechanism, is a bucket violation — score it down and note the finding.

**9. External Resource Ingestion is mandatory when URL or long text is provided**
When `$ARGUMENTS` (or the user's input) contains a URL or a text block > 100 words, the orchestrator MUST run Step 0 (External Resource Ingestion) before classification or brainstorming. Treating a URL as a concept description without fetching it is a rule violation. The Resource Summary from Step 0 becomes the concept brief.

**10. Supersession scan is mandatory before brainstorming**
The orchestrator MUST grep commands/, agents/, and skills/ for concepts that overlap with the concept brief before Step 4. If overlap is found, it MUST surface a DECISION REQUIRED block (Replace / Enhance / Add-alongside / Prune) before any brainstorming or scoring begins. Silent additions when a replacement would be leaner are violations.

**11. FEASIBILITY.md must include Continuous Improvement Impact**
Every FEASIBILITY.md must include a `## Continuous Improvement Impact` section showing: the supersession decision from Step 3.5 (or "no overlap"), and the net change in plugin surface area (commands/agents/skills count). A FEASIBILITY.md without this section is incomplete.

**12. Klein Pre-Mortem gate is unconditional for Go verdicts**
When `overall >= 4.0`, the orchestrator MUST present the Klein Pre-Mortem gate (Step 10) via AskUserQuestion. The user may select "Skip" — but the question must always be asked. Silently omitting the gate because the concept "seems straightforward" is a rule violation.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The concept is simple, brainstorming is overkill" | Rule 1 is unconditional. Simple concepts need brainstorming too — it takes 2 minutes and prevents 2-hour rewrites. |
| "I'll mention the evidence in prose, not cite files" | Prose evidence can't be verified. File paths and grep results can. Rule 2 requires citable evidence. |
| "I'll skip Data Impact — it's just a new agent" | New agents still write output files and may touch state. Rule 3 requires all three pillars. |
| "I'll display the scorecard first, write the file after" | Rule 4 is explicit: file first, then display. If the session crashes after display, the artifact is lost. |
| "EnterPlanMode is cleaner from inside the agent" | Rule 6 exists because agents run in subagent context — EnterPlanMode there doesn't affect the user's session. |
| "The URL is from a well-known library, I know what it does" | Rule 9: fetch it anyway. The concept brief must come from the actual resource, not memory. |
| "Nothing obvious overlaps with this concept" | Rule 10: grep first, then conclude. "Nothing obvious" is not a supersession scan. |
| "The concept reduces something, no need to track surface area" | Rule 11 requires the net count to be stated explicitly — even when it's a reduction (especially then). |
| "The Go verdict is strong enough, pre-mortem is optional" | Rule 12: the gate is unconditional. A 4.5 score makes the pre-mortem MORE valuable, not less. |
