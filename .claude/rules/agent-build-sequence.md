# Agent Build Sequence Rules

## Mandatory Behavior

When `project_type: ai-agent-system` is set in `.kickstart/state.md` or
`.bootstrap/scan-context.md`, OR any feature description, CONTEXT.md, PLAN.md, or pitch text
matches a trigger pattern below, the orchestrating agent MUST offer the 15-stage
`skills/agent-build-sequence/` methodology via `AskUserQuestion` (Run/Skip) before proceeding
past kickstart Phase 1b (Compose) or the PRD Phase 1 Discover gate. This is not a suggestion —
it fires deterministically on match.

The offer is non-blocking — per the confirmed decision, `project_type` never blocks
progression. The user may skip and continue with standard kickstart/discovery. The act of
asking is mandatory; the answer is the user's judgment call.

## Trigger Patterns

Match is case-insensitive. Any single match is sufficient to trigger.

**AI agent system language**
- `AI agent`, `autonomous agent`, `agent system`, `agentic system`
- `multi-agent`, `multi-agent orchestration`, `agent orchestration`
- `tool-calling loop`, `tool calling loop`, `tool use loop`

**Project-type tag**
- `project_type: ai-agent-system` present in `.kickstart/state.md` frontmatter
- `project_type: ai-agent-system` present in `.bootstrap/scan-context.md`

## Required Behavior by Lifecycle Gate

### Kickstart Gate — Phase 1b (Compose)

**When:** `kickstart-intake` agent has completed Phase 1 (Intake) and is about to run Phase 1b
(Compose), AND a trigger pattern matched during intake or `project_type: ai-agent-system` was
recorded.

**What MUST happen:**
1. Before running Phase 1b compose steps, call `AskUserQuestion`:

```
question: "This looks like an AI agent system build. Run the 15-stage Agentic System Build
  Sequence to sequence state machine + tool inventory before architecture?"
header: "Agent Build Sequence"
options:
  - label: "Run the 15-stage sequence (Recommended)"
    description: "Reads skills/agent-build-sequence/ — ensures state machine and tool
      inventory exist before any architecture decision is made"
  - label: "Skip — proceed with standard kickstart"
    description: "Continue Phase 1b normally, no ordering enforcement"
```

2. If "Run": read `skills/agent-build-sequence/SKILL.md` and
   `skills/agent-build-sequence/workflows/build-sequence.md`, and follow the stage sequence
   from wherever kickstart has already progressed (Stages 1-3 are typically already covered
   by ideation/intake — do not re-run them, pick up from Stage 4).
3. If "Skip": proceed with Phase 1b as normal. Record the skip — do not re-prompt for the
   same project within the same kickstart session.

### PRD Gate — Phase 1 Discover

**When:** `prd-discoverer` is about to gather the 11 Elements AND a trigger pattern matched in
the feature description, OR `project_type: ai-agent-system` is set for the project.

**What MUST happen:**
1. Before proceeding too far into the 11-Elements gathering (ideally right after Step 0
   codebase research, before Step 1's first AskUserQuestion batch), call `AskUserQuestion`
   with the same Run/Skip offer as above, scoped to this feature.
2. If "Run": read `skills/agent-build-sequence/SKILL.md` — for a feature-level (not
   project-level) build, this typically means confirming Stage 4 (state machine) and Stage 5
   (tool inventory) are addressed before Stage 6 (architecture-generator) is dispatched later
   in the sprint.
3. If "Skip": proceed with standard 11-Elements discovery.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The project might not really be an agent system" | Trigger matched = offer it. The user can say Skip in one click — offering costs nothing. |
| "I'll mention the methodology as a suggestion in prose" | The rule mandates an `AskUserQuestion` offer, not a prose suggestion. Ask directly. |
| "It's early, the build sequence can come later" | Later means architecture gets decided before the tool inventory exists — the exact failure mode this rule exists to prevent. |
| "The user didn't explicitly ask for a 15-stage methodology" | Agent-system signals in descriptions are implicit requirements. Surface the offer — the user decides. |
| "project_type isn't set yet so this doesn't apply" | Keyword match alone is sufficient — the tag and the keyword trigger are independent, either fires the offer. |
