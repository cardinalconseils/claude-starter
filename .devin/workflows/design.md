---
description: "Phase 2 — Design: Define UX flows, screens, and component specifications"
---

# Design Workflow

## Purpose
Define how the feature will work before implementation begins.

## Prerequisites
- Discover phase complete (`.phases/{feature_id}/CONTEXT.md` exists)

## Steps

1. **Read state:** Load `.phases/PRD-STATE.json` and `.phases/{feature_id}/CONTEXT.md`.

2. **Research UX patterns:** Analyze the problem statement and user stories. Identify relevant UX patterns and design conventions.

3. **Create user flows:** Map out the user journey for each user story. Get approval before proceeding.

4. **Design screens:** For each user flow, design the screens. Consider:
   - Mobile-first layout
   - Accessibility (WCAG 2.1 AA)
   - Component reusability
   - Consistent design language
   Get approval on screens before proceeding.

5. **Specify components:** Break screens into reusable components. For each component:
   - Name and purpose
   - Props/inputs
   - Events/outputs
   - Visual states (default, hover, active, disabled, error)
   - Accessibility requirements

6. **Define data models:** Specify the data structures needed.

7. **Specify API contracts:** Define the API endpoints, request/response schemas, and error handling.

8. **Generate artifact:** Write everything to `.phases/{feature_id}/DESIGN.md`.

9. **Update state:** Set `phase_status` to "complete", `current_phase` to "sprint", `next_action` to "Starting sprint phase automatically".

10. **Report and auto-advance:** Show a plain-English summary of the design. Ask: "Does this design work for you?" If yes → automatically continue to the sprint workflow. If no → ask what to change and update.

## Rules
- Never implement without design approval
- Get approval at each major step (flows, screens, components)
- Flag technical feasibility concerns early
- Design for the user's mental model
- Keep components reusable and documented
- **Auto-advance to sprint after user confirms** — don't make the user run the next command
- **Plain English only** — no jargon, no command names, no phase numbers
