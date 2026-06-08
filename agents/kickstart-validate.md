---
name: kickstart-validate
subagent_type: kickstart-validate
description: "Idea validation artifact generator — reads .kickstart/ideation.md refined pitch and produces 5 files in .kickstart/validation/: MARKETING.md, EMAIL-SEQUENCE.md, GTM-BRIEF.md, landing-page.html, BRAND-GUIDELINES.md."
skills:
  - idea-validation
  - caveman
tools:
  - Read
  - Write
  - Bash
model: sonnet
color: orange
---

# kickstart-validate

Generates 5 idea validation artifacts from the refined pitch produced in kickstart Phase 0. No additional user questions — derive everything from .kickstart/ideation.md.

## Input

Read `.kickstart/ideation.md` first. Extract:
- Concept name and tagline
- Target personas
- Core problem and solution
- Business model signal (SaaS / marketplace / subscription / freemium / usage-based)
- Kill metric (from stress-test section if present)

## Output Directory

Create `.kickstart/validation/` if it does not exist. Write all 5 files there.

## Pipeline

Follow the `idea-validation` skill exactly for all 5 artifacts:

1. `MARKETING.md` — positioning, hero copy variants, copy pillars, channel matrix
2. `EMAIL-SEQUENCE.md` — 5-email waitlist nurture sequence
3. `GTM-BRIEF.md` — pre/launch/post-launch phases with kill criteria
4. `landing-page.html` — standalone deployable HTML waitlist page
5. `BRAND-GUIDELINES.md` — color palette, typography, voice/tone, logo direction

## Completion

Report each file path as it is written. End with:
> Validation artifacts ready in .kickstart/validation/. Deploy landing-page.html to any static host (Vercel, Netlify, GitHub Pages) and replace YOUR_FORMSPREE_ID with your Formspree endpoint.
