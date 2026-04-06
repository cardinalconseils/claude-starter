# Workflow: 4Ds Audit

<purpose>
Score every feature across Delegation, Description, Discernment, and Diligence.
Produces a scored report and appends entries to `.prd/logs/audit.jsonl`.
</purpose>

## Pre-Conditions
- `.prd/` directory exists
- At least one feature in `.prd/phases/`

## Steps

### Step 1: Discover Features
Scan `.prd/phases/` for all feature directories (`{NN}-{name}/`).
Read `.prd/PRD-ROADMAP.md` for feature metadata.

### Step 2: Score Each Feature

For each feature directory, score all 4 dimensions.
Read `references/scoring-rubric.md` for the detailed rubric.

#### 2a. Delegation Score
- Check: Does a command dispatch an agent for this feature? (Read commands/)
- Check: Does the agent declare tools/skills in frontmatter? (Read agents/)
- Check: Is the command under 60 lines?
- Check: Does the agent use AskUserQuestion for decisions?

#### 2b. Description Score
- Check: Does `{NN}-CONTEXT.md` exist?
- Count: How many of the 11 Elements are present?
- Check: Are acceptance criteria measurable (not vague)?
- Check: Is `PRD-STATE.md` current (last_action_date within 7 days)?

#### 2c. Discernment Score
- Check: Is maturity stage set in `.prd/prd-config.json`?
- Check: Do quality gates match the maturity stage?
- Scan: `.prd/logs/decisions.jsonl` for trade-off entries
- Scan: Any skipped gates without justification?

#### 2d. Diligence Score
- Check: Does `{NN}-CONFIDENCE.md` exist?
- Count: How many gates pass vs fail vs N/A?
- Check: Do tests exist for acceptance criteria?
- Check: Has pre-commit guard been triggered (check lifecycle.jsonl)?

### Step 3: Calculate Scores
Sum each dimension (0-3) per feature.
Average across features for project score.

### Step 4: Log Results
Append to `.prd/logs/audit.jsonl`:
```json
{
  "timestamp": "{ISO-8601}",
  "event": "audit.4ds",
  "feature_id": "{NN}-{name}",
  "scores": {
    "delegation": 2,
    "description": 3,
    "discernment": 1,
    "diligence": 2
  },
  "total": 8,
  "gaps": ["No trade-off logs found", "CONFIDENCE.md missing gate X"]
}
```

### Step 5: Display Report
Use the report format from `references/scoring-rubric.md`.
Show per-feature breakdown + project average.
Highlight top 3 actionable gaps with suggested fixes.

## Post-Conditions
- `.prd/logs/audit.jsonl` updated with new entries
- Report displayed to user
- Top gaps identified with fix suggestions
