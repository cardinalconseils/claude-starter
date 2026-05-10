# Mode 3: CKS Self-Debug Workflow

You received a CKS component name or "last action" context describing unexpected CKS behavior. Follow these steps in order.

## Step 1: Read the Lifecycle Logs

Read `.prd/logs/lifecycle.jsonl`.

Look for the most recent events related to the failing component or action. Note:
- The last 10 entries relevant to the component
- Any `error` or `failed` events
- Which steps started and which did not complete (missing `step.N.started` or `step.N.completed` pairs)

## Step 2: Read PRD State

Read `.prd/PRD-STATE.md`.

Note the current values for: current phase, current step, status, and any fields relevant to the reported failure.

## Step 3: Identify the Component

Determine which CKS component is involved based on the failure context:

- **Skills**: `${CLAUDE_PLUGIN_ROOT}/skills/{name}/SKILL.md`
- **Agents**: `${CLAUDE_PLUGIN_ROOT}/agents/{name}.md`
- **Commands**: `${CLAUDE_PLUGIN_ROOT}/commands/{name}.md`

Read the correct file for the component in question.

## Step 4: Diff Expected vs. Actual

Compare the component's instructions (what it says it should do) against what the lifecycle logs show actually happened.

Ask:
- Did the agent follow its own instructions?
- Did a step get skipped that the skill workflow requires?
- Did the agent use a tool it is not listed as having?
- Does the PRD-STATE reflect a valid state for the current lifecycle position?

## Step 5: Match Against CKS Failure Patterns

| Pattern | Diagnosis Method |
|---------|-----------------|
| **Wrong output** | Read skill/agent instructions. Compare to log events. Find where agent deviated. |
| **Skill didn't trigger** | Read skill `description` field. Compare against what user typed. Check for keyword mismatch. |
| **Agent off-rails** | Read agent prompt. Check `tools` list — missing tool? Check agent constraints — violated? |
| **State corrupted** | Read PRD-STATE.md. Glob `.prd/phases/` for actual files. Diff references vs reality. |
| **Skipped steps** | Read workflow step files. Cross-ref lifecycle.jsonl for missing `step.N.started` events. |

## Step 6: Collect CKS-Specific Evidence

Always include in your evidence:
- Last 10 lifecycle log entries relevant to the component
- PRD-STATE current values (phase, step, status)
- The component's frontmatter (description, tools, constraints, skills)
- Any `error` events in lifecycle.jsonl

Rate confidence using the same scale as other modes (High / Medium / Low).
