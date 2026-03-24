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
▶ Running /cks:new
```
→ `Skill(skill="new")`
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
  → Skill(skill="new")

if no active phase:
  → Find next undone phase from PRD-ROADMAP.md
  → If none exist: "All work complete!"
  → Set as active, fall through to discuss

if not has_context:
  → Skill(skill="discuss", args="{NN}")

elif not has_plan:
  → Skill(skill="plan", args="{NN}")

elif not has_summary:
  → Skill(skill="execute", args="{NN}")

elif not has_verification:
  → Skill(skill="verify", args="{NN}")

elif verification_passed:
  → Check for next incomplete phase in ROADMAP
  → If exists:
    → Update PRD-STATE.md with new active phase
    → Skill(skill="discuss", args="{next_NN}")
  → If none (all phases done):
    → Skill(skill="ship", args="all")

elif verification_failed:
  → Skill(skill="execute", args="{NN}")

elif phase_status == "shipped":
  → Check for next feature in ROADMAP
  → If exists: Skill(skill="discuss", args="{next}")
  → If none: "All work shipped!"
```

### Step 4: Display and Execute

Before invoking, briefly show:
```
PRD Next
━━━━━━━
Current: Phase {NN} — {name} | {status}
▶ Next: /cks:{command} {args}
  {one-line reason}
```

Then immediately invoke via Skill(). Do NOT ask for confirmation — the whole point of `/cks:next` is zero-friction advancement.

### Step 5: Single Step — No Chaining

**Do NOT re-run this workflow after the invoked command completes.** Each phase workflow ends with a Context Reset instruction telling the user to `/clear` then `/cks:next`.

The flow is now:
```
/cks:next → invokes one phase → phase completes with Context Reset banner
  ↓
user runs: /clear
  ↓
user runs: /cks:next → invokes next phase → ...
```

This ensures each phase starts with a fresh context window. All state is on disk in `.prd/` — nothing is lost between clears.

## Important Notes

- `/cks:next` is idempotent — safe to run repeatedly
- If verification failed, routes back to execute (not discuss)
- After ship, routes to next feature (if any) or reports completion
- Uses Skill() to invoke the single next phase — then stops
- **Context resets between every phase** — each phase starts fresh
- All state persists in `.prd/PRD-STATE.md` and `.prd/PRD-ROADMAP.md`
