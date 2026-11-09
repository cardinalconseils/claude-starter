---
description: "Phase 1 — Discover: Gather 11 elements to understand what to build and why"
---

# Discover Workflow

## Purpose
Gather requirements and understand what to build before writing any code.

## Steps

1. **Read state:** Check if `.phases/PRD-STATE.json` exists. If not, create it with the feature name and phase "discover".

2. **Gather the 11 elements.** For each element, ask the user targeted questions, then synthesize answers:

   - **Problem Statement:** What problem are we solving? Who is affected? What's the impact?
   - **User Stories:** Who are the users? What do they want to accomplish? Why?
   - **Scope:** What's explicitly in scope? What's explicitly out of scope?
   - **API Surface:** What endpoints, data structures, and interfaces are needed?
   - **Acceptance Criteria:** What measurable criteria define "done"?
   - **Constraints:** What technical, business, or time constraints exist?
   - **Test Plan:** What's the testing strategy? Unit, integration, E2E?
   - **UAT Scenarios:** What user acceptance test scenarios are needed?
   - **Definition of Done:** When is the feature considered complete?
   - **KPIs:** What key performance indicators measure success?
   - **Dependencies:** What cross-project or external dependencies exist?
   - **Architecture Tier:** Is this Prototype, Pilot, Candidate, or Production?

3. **Generate artifact:** Write all elements to `.phases/{feature_id}/CONTEXT.md`.

4. **Update state:** Set `phase_status` to "complete", `current_phase` to "design", `next_action` to "Starting design phase automatically".

5. **Report and auto-advance:** Show a plain-English summary of what we're building. Ask: "Does this look right?" If yes → automatically continue to the design workflow. If no → ask what to change and update.

## Rules
- Never skip elements — if one doesn't apply, document why
- Ask clarifying questions when information is missing
- Flag assumptions explicitly
- Keep scope minimal — only what's necessary for first iteration
- Use confirmation dialogs for all decisions
- **Auto-advance to design after user confirms** — don't make the user run the next command
- **Plain English only** — no jargon, no command names, no phase numbers
