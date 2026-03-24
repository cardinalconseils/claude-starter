# Workflow: Next (Auto-Advance)

<purpose>
Detect current workflow position and immediately invoke the next logical action via Skill(). Zero friction — no confirmation, no questions. Like pressing "play" on the workflow.
</purpose>

## Steps

### Step 1: Read State

```
Read .prd/PRD-STATE.md
Read .prd/PRD-ROADMAP.md
```

If `.prd/` doesn't exist:
```
No project initialized.
▶ Running /prd:new
```
→ `Skill(skill="prd:new")`
Return.

### Step 2: Determine Next Action

Read the active phase from PRD-STATE.md. Check artifacts:

```
phase_dir = .prd/phases/{NN}-{name}/

has_context = exists(phase_dir/{NN}-CONTEXT.md)
has_plan = exists(phase_dir/{NN}-PLAN.md) or exists(phase_dir/{NN}-01-PLAN.md)
has_summary = exists(phase_dir/{NN}-SUMMARY.md) or exists(phase_dir/{NN}-01-SUMMARY.md)
has_verification = exists(phase_dir/{NN}-VERIFICATION.md)
verification_passed = {NN}-VERIFICATION.md contains "PASS"
```

### Step 3: Route (Decision Tree)

```
if no .prd/:
  → Skill(skill="prd:new")

if no active phase:
  → Find next undone phase from PRD-ROADMAP.md
  → If none exist: "All work complete!"
  → Set as active, fall through to discuss

if not has_context:
  → Skill(skill="prd:discuss", args="{NN}")

elif not has_plan:
  → Skill(skill="prd:plan", args="{NN}")

elif not has_summary:
  → Skill(skill="prd:execute", args="{NN}")

elif not has_verification:
  → Skill(skill="prd:verify", args="{NN}")

elif verification_passed:
  → Check for next incomplete phase in ROADMAP
  → If exists:
    → Update PRD-STATE.md with new active phase
    → Skill(skill="prd:discuss", args="{next_NN}")
  → If none (all phases done):
    → Skill(skill="prd:ship", args="all")

elif verification_failed:
  → Skill(skill="prd:execute", args="{NN}")

elif phase_status == "shipped":
  → Check for next feature in ROADMAP
  → If exists: Skill(skill="prd:discuss", args="{next}")
  → If none: "All work shipped!"
```

### Step 4: Display and Execute

Before invoking, briefly show:
```
PRD Next
━━━━━━━
Current: Phase {NN} — {name} | {status}
▶ Next: /prd:{command} {args}
  {one-line reason}
```

Then immediately invoke via Skill(). Do NOT ask for confirmation — the whole point of `/prd:next` is zero-friction advancement.

### Step 5: Chain

After the invoked command completes, re-run this workflow to continue advancing. Keep chaining until:
- All phases are complete and shipped
- A blocker is encountered
- The user interrupts

This creates a continuous flow: next → discuss → next → plan → next → execute → next → verify → next → ship.

## Important Notes

- `/prd:next` is idempotent — safe to run repeatedly
- If verification failed, routes back to execute (not discuss)
- After ship, routes to next feature (if any) or reports completion
- Always uses Skill() for invocation — keeps everything in the same session
