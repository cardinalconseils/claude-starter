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

### Step 2: Load Cost & Compliance Data

Read `.monetize/cost-analysis.md` if it exists (enables margin-aware reporting).
Read the "Legal, Regulatory & Compliance" section from `.monetize/context.md`.

If cost-analysis.md is missing, note in the report: "Cost analysis was not run — revenue figures are gross, not net."

### Step 3: Generate Report

Read `references/report-template.md` and fill in every section using the loaded artifacts.

**Writing guidelines:**
- **Executive Summary:** 2-3 paragraphs. Lead with the recommended stack and the critical assumptions that must hold. State the confidence level. Make it readable by a non-technical executive in under 2 minutes.
- **Research Findings:** Preserve all citations with dates. Tag data freshness. Include the "Founder-Provided Intelligence" section even if empty. Flag any benchmark that comes from an adjacent (not identical) category.
- **Legal/Compliance:** Always include, even if "no constraints identified." List any models that are blocked by regulation.
- **Model Analysis:** Use evidence-based tiers (Strong/Possible/Weak) — NOT numeric scores. The rationale column is the primary content. Include the full assumption chain for revenue.
- **Monetization Stack:** This is the most important section. Explain WHY these models together, not just what they are. Include the GTM plan per phase and the compliance checklist.
- **What to Validate First:** This is the second most important section. List the assumptions that, if wrong, would invalidate the strategy. Provide specific validation methods.
- **Revenue Projections:** Always presented as assumption chains with confidence grades. Never as bare numbers in a table without context.
- **Honesty rule:** If data is weak, say so. If a projection is mostly assumptions, label it "Low confidence." Never present a guess as a data point.

### Step 4: Save Report

Write the completed report to `docs/monetization-assessment.md`.

If the file already exists, check if user chose "archive" or "update" in the re-run flow:
- Archive: the old file was already moved. Write fresh.
- Update: overwrite with new content.

### Step 5: Display Summary

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
