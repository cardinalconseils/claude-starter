<!-- Source: phuryn/pm-skills opportunity-solution-tree (MIT) — adapted for CKS -->

# Opportunity Solution Tree — Facilitation Workflow

Read `skills/strategic-frameworks/workflows/opportunity-solution-tree.dot` for the 4-level tree structure.

Read `skills/strategic-frameworks/output-schemas.yaml` for the `opportunity_solution_tree` output schema.

## Purpose

Build an OST: outcome → opportunities → solutions → experiments. Forces outcome-first thinking. Output: `.strategic-frameworks/ost-{date}.yaml`. Patch CONTEXT.md `section_1b_user_flows`.

## Facilitation Steps

### Step 1 — Desired Outcome

Use AskUserQuestion:
- Ask: "What is the single measurable business or product goal you're optimizing for? Express as: [metric] goes from [X] to [Y] by [date]."
- Good: "Monthly active users from 500 to 2000 by Q4." Bad: "Grow the product."
- If outcome is a feature ("build a dashboard"), push back: "That's a solution. What business result does it create?"

### Step 2 — Opportunity Discovery

Use AskUserQuestion (repeat for each opportunity, minimum 3):
- Ask: "What customer needs, pains, or jobs-to-be-done stand between users and your desired outcome?"
- Frame: "Opportunities are gaps — things customers need to do or feel that they currently can't."
- Collect 3-7 opportunities. Do not filter yet.

### Step 3 — Opportunity Scoring

For each opportunity, use AskUserQuestion:
- Ask: "Rate this opportunity: How important is solving this for customers? (1-10) How satisfied are they with current solutions? (1-10)"
- Score = Importance × (1 − Satisfaction/10)
- Higher score = better opportunity. Surface the top 2-3 for solution generation.

### Step 4 — Solution Generation

For each top opportunity (use AskUserQuestion):
- Ask: "Generate minimum 3 different solutions for [opportunity]. Solutions should vary — not just feature variations."
- Constraint: no solution should be the obvious one only. Push for a surprising option.
- Record all solutions. Do not filter at this step.

### Step 5 — Experiment Design

For the highest-scored opportunity + best solution candidate, use AskUserQuestion:
- Ask: "What is the cheapest experiment to test if this solution creates the desired outcome?"
- Assess each experiment on 4 axes: Value (does it deliver?), Usability (can users adopt it?), Viability (is it sustainable?), Feasibility (can we build it?).
- Select the experiment with the best coverage across all 4 axes.

## Output

Write to `.strategic-frameworks/ost-{YYYY-MM-DD}.yaml`:

```yaml
framework: opportunity_solution_tree
date: {YYYY-MM-DD}
desired_outcome: ""
opportunities:
  - name: ""
    importance: 0
    satisfaction: 0
    score: 0
solutions:
  - opportunity: ""
    options: []
experiments:
  - solution: ""
    hypothesis: ""
    axes: {value: "", usability: "", viability: "", feasibility: ""}
```

Append to `.prd/PRD-STATE.md` Working Notes:
```
| ost_run | {YYYY-MM-DD} | .strategic-frameworks/ost-{YYYY-MM-DD}.yaml |
```

If CONTEXT.md exists, append top opportunity + selected solution to `section_1b_user_flows`.
