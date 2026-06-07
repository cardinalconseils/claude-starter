# Data Flow Map Rules

## Mandatory Behavior

When any feature description, CONTEXT.md, or user message signals multi-entity writes, cascades, or async operations, the discoverer MUST populate Element [1d] Data Flow Map (Part A) with full Entities / Flows / Cascades detail BEFORE Phase 2 Design begins. The executor MUST receive this map as a "Rails" block in its prompt. These rules are non-negotiable.

## Deterministic Triggers (mandatory gate — always fires)

Match is case-insensitive. Any single match is sufficient.

**Multi-entity writes**
- Feature touches 2+ database tables/collections with any INSERT, UPDATE, or DELETE
- Feature adds a new entity or data model

**Async and cascade operations**
- `webhook`, `event`, `queue`, `worker`, `job`, `background`
- `notification`, `email`, `SMS`, `push notification`, `receipt`
- `payment`, `checkout`, `billing`, `invoice`
- `sync`, `replicate`, `propagate`, `cascade`

**State transitions**
- `status change`, `state machine`, `workflow`, `transition`
- `approval`, `rejection`, `publish`, `archive`, `activate`, `deactivate`

## Indeterministic (suggested, not gated)

Data flow map is OPTIONAL (mark Part A "N/A") when ALL of the following are true:
- Feature is read-only (no INSERT/UPDATE/DELETE)
- Single entity or UI-only with no data mutations
- No async operations, no side effects on other systems

## Required Behavior

When a deterministic trigger is matched:

1. **Do not skip** — the discoverer MUST gather Part A (Entities / Flows / Cascades) using AskUserQuestion
2. **Gate check before Phase 3** — the planner MUST verify Element [1d] Part A is populated (not "N/A" or empty) before writing PLAN.md
3. **Inject as rails into executor prompt** — add this block to the executor's prompt:

```
## Rails — Data Flow Map (Do Not Deviate)
{Paste Element [1d] Part A content from CONTEXT.md verbatim}

Do not introduce new entities, state, or data flows beyond what is listed above.
If a required change falls outside these rails, stop and surface it explicitly.
```

4. **TDD must include Data Flow Design section** — when triggers match, the TDD "Data Flow Design" section is Required, not Complex/optional.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The feature is simple, data flow is obvious" | Simple features are where untracked cascades hide. Map it — takes 2 minutes. |
| "I'll add the data flow map after the code is written" | The map is the rail. Writing code without it is exactly the vibecoding problem this rule prevents. |
| "It's only one new table" | Adding a table often cascades: auth policies, audit logs, notifications. Map Part A first. |
| "The executor will figure out the data flow from the TDD" | The TDD describes schema, not flow. The rails block in the executor prompt is the explicit constraint. |
| "Read-only features don't need this" | Correct — mark N/A. But verify it's truly read-only before skipping. |
