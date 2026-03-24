# Workflow: Report

## Overview
Generates the final Monetization Assessment document by combining discovery context,
research findings, and evaluation results into the report template.

## Prerequisites
- `.monetize/evaluation.md` must exist

## Reference
Read `references/report-template.md` for the document structure.

## Steps

### Step 1: Load All Artifacts

Read in order:
1. `.monetize/context.md` — product & market context
2. `.monetize/research.md` — market intelligence with citations
3. `.monetize/evaluation.md` — scores, projections, stack recommendation

### Step 2: Generate Report

Read `references/report-template.md` and fill in every section using the loaded artifacts.

**Writing guidelines:**
- **Executive Summary:** 2-3 paragraphs. Lead with the recommended stack and projected revenue range. Make it readable by a non-technical executive in under 2 minutes.
- **Research Findings:** Preserve Perplexity citations. Include specific numbers, not vague ranges.
- **Model Analysis:** For viable models, include the full scoring table. For N/A models, use the abbreviated table.
- **Monetization Stack:** This is the most important section. Explain WHY these models together, not just what they are.
- **Implementation Roadmap:** High-level phases with timelines. These become the phase briefs in the next workflow.
- **Revenue Projections:** Always show all three scenarios (conservative/moderate/aggressive).

### Step 3: Save Report

Write the completed report to `docs/monetization-assessment.md`.

If the file already exists, check if user chose "archive" or "update" in the re-run flow:
- Archive: the old file was already moved. Write fresh.
- Update: overwrite with new content.

### Step 4: Display Summary

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 MONETIZE -> REPORT GENERATED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Recommended Stack: {Model A} + {Model B} + {Model C}
 Projected Revenue (24mo, moderate): ${amount}
 Report: docs/monetization-assessment.md

 Moving to roadmap integration...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
