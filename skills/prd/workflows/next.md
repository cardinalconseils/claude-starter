# Workflow: Next (Auto-Advance)

<purpose>
Detect current workflow position and immediately invoke the next logical action via Skill(). Zero friction — no confirmation, no questions. Like pressing "play" on the workflow. Routes through all 5 phases including the iteration loop.
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

Read the active phase from PRD-STATE.md. Check artifacts AND phase_status:

```
phase_dir = .prd/phases/{NN}-{name}/

has_context = exists(phase_dir/{NN}-CONTEXT.md)
has_design = exists(phase_dir/{NN}-DESIGN.md)
has_plan = exists(phase_dir/{NN}-PLAN.md)
has_summary = exists(phase_dir/{NN}-SUMMARY.md)
has_verification = exists(phase_dir/{NN}-VERIFICATION.md)
has_review = exists(phase_dir/{NN}-REVIEW.md)

phase_status = from PRD-STATE.md
```

### Step 3: Route (Decision Tree)

```
if no .prd/:
  → Skill(skill="new")

if no active phase:
  → Find next undone phase from PRD-ROADMAP.md
  → If none exist: "All work complete!"
  → Set as active, fall through to discover

# Phase 1: Discovery
if not has_context:
  → Skill(skill="discover", args="{NN}")

# Phase 2: Design
elif not has_design:
  → Skill(skill="design", args="{NN}")

# Phase 3: Sprint
elif not has_plan or not has_summary or not has_verification:
  → Skill(skill="sprint", args="{NN}")

# Phase 4: Review
elif phase_status == "sprinted" and not has_review:
  → Skill(skill="review", args="{NN}")

# Iteration routing (from Phase 4 decisions)
elif phase_status == "iterating_design":
  → Skill(skill="design", args="{NN}")

elif phase_status == "iterating_sprint":
  → Skill(skill="sprint", args="{NN}")

elif phase_status == "iterating_discover":
  → Skill(skill="discover", args="{NN}")

# Phase 5: Release
elif phase_status == "reviewed":
  → Skill(skill="release", args="{NN}")

# Feature complete — next feature
elif phase_status == "released":
  → Check for next incomplete feature in ROADMAP
  → If exists:
    → Update PRD-STATE.md with new active phase
    → Skill(skill="discover", args="{next_NN}")
  → If none (all features done):
    → "All features released! Run /cks:new for the next feature."

# Fallback
else:
  → Display current state and suggest manual command
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

Then immediately invoke via Skill(). Do NOT ask for confirmation.

### Step 5: Single Step — No Chaining

**Do NOT re-run this workflow after the invoked command completes.** Each phase workflow ends with a Context Reset instruction telling the user to `/clear` then `/cks:next`.

The flow is:
```
/cks:next → invokes one phase → phase completes with Context Reset banner
  ↓
user runs: /clear
  ↓
user runs: /cks:next → invokes next phase → ...
```

## Important Notes

- `/cks:next` is idempotent — safe to run repeatedly
- Iteration decisions from Phase 4 are respected — routes back to correct phase
- After release, routes to next feature (if any) or reports completion
- Uses Skill() to invoke the single next phase — then stops
- **Context resets between every phase** — each phase starts fresh
- All state persists in `.prd/PRD-STATE.md` and `.prd/PRD-ROADMAP.md`
