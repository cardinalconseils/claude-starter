# Step 4: Update State

<context>
Phase: Sprint (Phase 3)
Requires: All sub-steps complete, documentation checked ([3h])
Produces: Updated PRD-STATE.md + PRD-ROADMAP.md
</context>

## Instructions

**Update PRD-STATE.md:**

First Sprint:
```yaml
active_phase: {NN}
phase_name: {name}
phase_status: sprinted
iteration_count: 0
last_action: "Sprint complete — merged via PR #{number}"
last_action_date: {today}
next_action: "Run /cks:review for sprint review and iteration decision"
pr_number: {number}
pr_url: {url}
```

Iteration Sprint:
```yaml
active_phase: {NN}
phase_name: {name}
phase_status: sprinted
iteration_count: {iteration}
last_action: "Iteration #{iteration} complete — merged via PR #{number}"
last_action_date: {today}
next_action: "Run /cks:review to evaluate iteration #{iteration}"
pr_number: {number}
pr_url: {url}
```

**Update PRD-ROADMAP.md:**
- Set phase status to "Sprinted — Pending Review"
