---
description: "Generate monetization roadmap and PRD handoff"
allowed-tools:
  - Read
  - Write
---

# /cks:monetize-roadmap

Generate phase briefs and update the project roadmap from evaluation results.

## Prerequisite

Verify `docs/monetization-assessment.md` and `.monetize/evaluation.md` exist.

## Execution

Read `.monetize/evaluation.md`. For each recommended monetization model:
1. Create `.monetize/phases/{NN}-{model-name}.md` with a PRD-ready phase brief
2. If `.prd/PRD-ROADMAP.md` exists, append monetization phases as "Planned" entries

Display summary of created phase briefs and next steps.
