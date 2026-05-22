---
extends: ../../judge-prompt.md
feature: prd-discoverer
last_updated: 2026-05-22
---

# Judge Rubric: prd-discoverer

Use this rubric to fill `{rubric}` in the global judge prompt.

## Dimensions

### discovery_completeness
**Threshold:** 0.85
**Weight:** high

Did the agent ask questions that pursue discovery of the problem, users, and requirements?
Not all 12 CONTEXT.md elements need to appear in one message, but the response must clearly
be in discovery mode — gathering information, not proposing solutions.

Score 1.0: Asks about problem, users, data model, and at least one other element.
Score 0.85: Asks about problem and users but misses data/integrations.
Score 0.70: Asks only one clarifying question.
Score < 0.60: Proposes a solution, skips to planning, or makes decisions for the user.

### assumption_surfacing
**Threshold:** 0.85
**Weight:** high

Did the agent make its assumptions explicit rather than deciding on behalf of the user?
If the input contains embedded technical choices (e.g. "add a React component"), the agent
must surface the assumption and ask whether it reflects the actual need.

Score 1.0: Explicitly names the embedded assumption and asks if it's correct.
Score 0.85: Acknowledges the technical detail but doesn't fully surface the assumption.
Score 0.70: Proceeds with the assumption without mentioning it.
Score < 0.60: Accepts the implementation detail as a requirement without question.

### scope_adherence
**Threshold:** 0.80
**Weight:** medium

Did the agent stay in its discovery role?
It must NOT create artifacts (PLAN.md, PRD, sprint tasks), propose solutions, or skip to planning.

Score 1.0: Purely in discovery mode, no artifacts created or suggested.
Score 0.80: Mostly in discovery, minor forward-looking language acceptable.
Score < 0.60: Creates or proposes artifacts, or says "I'll set up the sprint now."

### question_quality
**Threshold:** 0.80
**Weight:** medium

Are the clarifying questions clear, specific, and open-ended?
Leading questions ("Would you like feature X?") and yes/no questions ("Is this for web?")
are signs of lower quality. Good questions invite the user to describe their context.

Score 1.0: All questions are open-ended, specific, and targeted to discovery.
Score 0.80: Mostly good questions, one or two yes/no questions acceptable.
Score < 0.60: Majority are leading or yes/no questions.
