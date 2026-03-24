# Workflow: Roadmap

## Overview
Creates PRD-ready phase briefs from the monetization stack, updates the existing
project roadmap, and hands off to `/cks:new` for implementation.

## Prerequisites
- `docs/monetization-assessment.md` must exist
- `.monetize/evaluation.md` must exist (for stack details)

## Steps

### Step 1: Load Stack Details

Read `.monetize/evaluation.md` and extract the Recommended Monetization Stack section:
- Phased timeline (which model, which months, key deliverables)
- Revenue milestones per phase
- Prerequisites per phase

### Step 2: Create Phase Briefs

For each phase in the monetization stack, create a PRD-ready brief at `.monetize/phases/`:

```bash
mkdir -p .monetize/phases
```

**Phase brief template:**

```markdown
# Monetization Phase {N}: {Model Name}

**Timeline:** Month {x} — Month {y}
**Revenue Target:** ${milestone} MRR by end of phase
**Prerequisite Phases:** {list or "none — can start immediately"}

## Objective
{What this phase achieves in 2-3 sentences}

## Key Deliverables
1. {Specific deliverable with acceptance criteria}
2. {Specific deliverable with acceptance criteria}
3. {Specific deliverable with acceptance criteria}

## Technical Requirements
- {Specific technical requirement — e.g., "Integrate Stripe billing with usage metering"}
- {Specific technical requirement}

## Success Metrics
- {Measurable KPI — e.g., "10 paying customers within 60 days of launch"}
- {Measurable KPI}

## Risks
- {Risk + mitigation from evaluation}

## Dependencies
- {What must exist from the codebase before this can start}

---
*This brief is designed to be passed directly to `/cks:new` for full lifecycle implementation.*
```

Save each as `.monetize/phases/phase-{N}-{model-slug}.md`

### Step 3: Update Roadmap

Read `docs/ROADMAP.md`. Add monetization phases to the roadmap:

**Placement rules:**
- Add under a new `## Monetization` section (or append to existing sections if the format is flat)
- Mark entries as `Planned (Monetization)` — NOT as formal PRD entries yet
- Respect the existing roadmap format (check the table structure, heading levels, etc.)
- Do NOT remove or modify existing entries

**Example entry to add:**

```markdown
## Monetization

### Phase M1: {Model Name} — Planned (Monetization)
**Brief:** [Phase 1](.monetize/phases/phase-1-{slug}.md)
**Timeline:** Month {x}-{y}
**Revenue Target:** ${target} MRR

### Phase M2: {Model Name} — Planned (Monetization)
**Brief:** [Phase 2](.monetize/phases/phase-2-{slug}.md)
**Timeline:** Month {x}-{y}
**Revenue Target:** ${target} MRR
```

### Step 4: Final Display + Handoff

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 MONETIZE -> COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Assessment:  docs/monetization-assessment.md
 Roadmap:     docs/ROADMAP.md (updated)
 Phase Briefs: .monetize/phases/

 Recommended Stack: {Model A} -> {Model B} -> {Model C}
 Projected Revenue (24mo): ${conservative} — ${aggressive}

 -> Ready to start Phase 1: {Model Name}
    Run: /cks:new "Implement {Model Name} monetization — {brief summary}"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
