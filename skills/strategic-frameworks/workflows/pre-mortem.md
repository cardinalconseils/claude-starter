<!-- Source: phuryn/pm-skills pre-mortem (MIT) — adapted for CKS -->

# Pre-Mortem — Facilitation Workflow

Read `skills/strategic-frameworks/workflows/pre-mortem.yaml` for risk category definitions (tigers, paper tigers, elephants).

Read `skills/strategic-frameworks/output-schemas.yaml` for the `pre_mortem` output schema.

## Purpose

Imagine failure. Work backward. Surface real risks before launch. Output: `.strategic-frameworks/pre-mortem-{date}.yaml`. Produces go/no-go checklist. Patch CONTEXT.md `section_1j_risks`.

## Framing

Open with: "It's 6 months after launch. The product failed. Not a near miss — a real failure. What happened?"

This framing unlocks risks people won't surface in a forward-looking discussion.

## Facilitation Steps

### Step 1 — Failure Imagination

Use AskUserQuestion:
- Ask: "Imagine the product launched and failed in 6 months. Brainstorm: what went wrong? List everything — technical, market, team, timing, assumptions."
- No filtering at this stage. Collect raw risks, 10-20 items.

### Step 2 — Tigers: Launch-Blocking

Use AskUserQuestion (for each candidate risk):
- Ask: "Is this risk real and evidence-based? If it happened, would it block the launch entirely?"
- If yes to both: Tiger — Launch Blocking. Assign owner + deadline immediately.
- Good examples: no payment processor approved, key API not available in target market, security audit outstanding.

### Step 3 — Tigers: Fast Follow

Use AskUserQuestion:
- Ask: "Which risks are real but survivable at launch? Can you ship and fix within 30 days?"
- If yes: Tiger — Fast Follow. Plan during sprint. Track post-launch.

### Step 4 — Tigers: Track

Use AskUserQuestion:
- Ask: "Which risks are real but unlikely to trigger immediately? Would you know if they emerged from monitoring?"
- If yes: Tiger — Track. Add to monitoring dashboard.

### Step 5 — Paper Tigers

Use AskUserQuestion:
- Ask: "Which risks feel scary but have no real evidence behind them? Stakeholder fears, hypothetical edge cases?"
- Classify as Paper Tiger. Document for alignment — do not spend sprint time here.

### Step 6 — Elephants

Use AskUserQuestion:
- Ask: "What assumptions is the team making that nobody has said out loud? What would embarrass us if it turned out to be wrong?"
- These are the hardest to surface. Common examples: "users will figure out onboarding," "sales will hit quota," "the API won't change."
- For each elephant: name it, assign an owner to validate it before launch.

### Step 7 — Go/No-Go Checklist

Generate checklist from launch-blocking tigers:
- Each tiger becomes a checkbox with owner and deadline
- Checklist is the pre-launch gate

## Output

Write to `.strategic-frameworks/pre-mortem-{YYYY-MM-DD}.yaml`:

```yaml
framework: pre_mortem
date: {YYYY-MM-DD}
tigers_launch_blocking:
  - risk: ""
    owner: ""
    deadline: ""
tigers_fast_follow:
  - risk: ""
    plan: ""
tigers_track:
  - risk: ""
    monitor_signal: ""
paper_tigers:
  - risk: ""
    reason_dismissed: ""
elephants:
  - assumption: ""
    owner: ""
    validation_method: ""
go_no_go_checklist:
  - item: ""
    owner: ""
    deadline: ""
    status: pending
```

Append to `.prd/PRD-STATE.md` Working Notes:
```
| pre_mortem_run | {YYYY-MM-DD} | .strategic-frameworks/pre-mortem-{YYYY-MM-DD}.yaml |
```

If CONTEXT.md exists, append launch-blocking tigers to `section_1j_risks`.
