# Workflow: Complexity Gate

<purpose>
Pre-sprint check that estimates feature complexity and warns before oversized sprints.
Runs automatically before Phase 3 planning. Prevents scope explosions.
</purpose>

## When to Run

- Before Phase 3 (Sprint) planning starts
- When `/cks:sprint` is invoked
- When prd-planner agent begins work

## Steps

### Step 1: Read Feature Scope

Read the feature's `{NN}-CONTEXT.md` and extract:
- Number of user stories
- Number of acceptance criteria (total across stories)
- Number of API endpoints mentioned
- Number of UI screens/components mentioned
- Cross-project dependencies count

### Step 2: Estimate Complexity

| Metric | Low | Medium | High |
|--------|-----|--------|------|
| User stories | 1-3 | 4-7 | 8+ |
| Acceptance criteria | 1-10 | 11-20 | 21+ |
| API endpoints | 0-3 | 4-8 | 9+ |
| UI screens | 0-3 | 4-6 | 7+ |
| Cross-project deps | 0 | 1-2 | 3+ |

**Complexity rating:**
- All Low → `simple` — proceed normally
- Any Medium → `moderate` — proceed with note
- Any High → `complex` — warn and suggest decomposition
- Multiple High → `oversized` — block and require split

### Step 3: Act on Rating

#### simple / moderate
Log the rating and continue:
```json
{
  "timestamp": "{ISO-8601}",
  "event": "gate.complexity",
  "feature_id": "{NN}-{name}",
  "rating": "moderate",
  "metrics": {"stories": 5, "criteria": 12, "endpoints": 3, "screens": 4, "deps": 0},
  "action": "proceed"
}
```

#### complex
Warn the user:
```
⚠ COMPLEXITY WARNING — {feature-name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Stories: {N}  Criteria: {N}  Endpoints: {N}
  Screens: {N}  Dependencies: {N}
  Rating: COMPLEX

  Consider splitting into smaller features.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Use AskUserQuestion:
- "Proceed anyway (I understand the risk)"
- "Help me split this into smaller features"
- "Let me simplify the scope first"

#### oversized
Block sprint entry:
```
🛑 OVERSIZED — Sprint blocked for {feature-name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Stories: {N}  Criteria: {N}  Endpoints: {N}
  This feature is too large for a single sprint.
  Split it before proceeding.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Use AskUserQuestion:
- "Help me split into 2-3 smaller features"
- "Override — proceed anyway (not recommended)"

## Post-Conditions
- Complexity logged to `.prd/logs/decisions.jsonl`
- Sprint either proceeds or user chooses to split/override
