# Workflow: Research (Phase 2)

## Overview
Uses Perplexity API to gather real market intelligence for the project idea — competitors,
market size, technology landscape, and comparable solutions. Produces `.kickstart/research.md`.

This phase is **optional** — user must opt in and have `PERPLEXITY_API_KEY` configured.

## Deep Research Upgrade

If the deep-research skill is available (`${CLAUDE_PLUGIN_ROOT}/skills/deep-research/SKILL.md` exists),
offer the user an enhanced research option:

```
Research options:
  1. Standard research (Perplexity API — fast, 5 queries)
  2. Deep research (multi-hop, multi-source — thorough, configurable)

Deep research uses /cks:research with competitive-intel mode for a more comprehensive analysis.
```

If user chooses deep research:
```
Skill(skill="research", args="--competitive \"{project_description}\" --depth medium")
```
Then verify the output exists and copy into kickstart format:
```
1. Check: ls .research/*/report.md 2>/dev/null
2. If found → read the report, extract key sections, write to .kickstart/research.md
3. If NOT found → log warning, fall back to standard Perplexity research below
```
This ensures the handoff works even if deep-research changes its output path.

If user chooses standard or deep research is not available, continue with the Perplexity-only flow below.

## Prerequisites
- `.kickstart/context.md` must exist (run intake first)
- `PERPLEXITY_API_KEY` must be set in `.env.local` or environment

## Steps

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "kickstart.phase.started" "_project" "Kickstart Phase 2: Research" '{"phase_number":"2","phase_name":"Research"}'`

### Step 1: Validate Prerequisites

1. Check `.kickstart/context.md` exists. If not → "Run `/kickstart` first — intake phase needed."

2. Load API key:
   ```bash
   export $(grep -v '^#' .env.local 2>/dev/null | xargs) 2>/dev/null
   echo "${PERPLEXITY_API_KEY:+set}"
   ```
   If empty:
   ```
   To enable deep research, add to .env.local:
     PERPLEXITY_API_KEY=your-key-here

   Get a key at: https://www.perplexity.ai/settings/api
   Then re-run /kickstart (will resume from research phase).

   Or skip research and continue to design phase? (yes/no)
   ```
   If user says yes → skip, return control to SKILL.md flow.

3. Read `.kickstart/context.md` to extract: project description, target users, domain, entities, integrations.

### Step 2: Execute Research Queries

Run each query via Bash curl to Perplexity API. Use model `sonar-pro`.

**API Pattern:**
```bash
curl -s https://api.perplexity.ai/chat/completions \
  -H "Authorization: Bearer $PERPLEXITY_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "sonar-pro",
    "messages": [
      {"role": "system", "content": "You are a product researcher analyzing market opportunities. Provide specific examples, data points, and cite sources."},
      {"role": "user", "content": "{query}"}
    ]
  }'
```

**Queries (construct from context.md):**

1. **Competitor Landscape**
   "What are the top 5-10 existing solutions for {problem_statement} targeting {target_users}? For each, list: name, pricing, key features, technology stack if known, and any notable strengths/weaknesses."

2. **Market Sizing**
   "What is the market size (TAM/SAM/SOM) for {domain} software targeting {target_users}? Provide dollar figures and growth rates. Cite sources."

3. **Technology Approaches**
   "What are the common technology stacks and architectural patterns used to build {domain} products? Include any open-source solutions, frameworks, or platforms commonly used."

4. **User Expectations**
   "What do users of {domain} software typically expect? What are the most common complaints or unmet needs in existing solutions? Reference review sites, forums, or surveys if possible."

5. **Regulatory & Compliance**
   (Only if context mentions compliance concerns)
   "What regulatory or compliance requirements apply to {domain} software in {region}? Include any certifications, standards, or legal requirements."

**Error handling per query:**
- Non-200 status or timeout: retry once after 5 seconds
- Second failure: log "Research gap: {topic}" and continue
- Parse: extract `.choices[0].message.content` and `.citations`

### Step 3: Synthesize Findings

Combine research into actionable insights:

- **Opportunity gaps** — what competitors miss that the user's idea addresses
- **Stack recommendation** — informed by what works in the space
- **Risk factors** — saturated segments, regulatory hurdles, technical challenges
- **Differentiation opportunities** — based on unmet user needs

### Step 4: Save Research

Write to `.kickstart/research.md`:

```markdown
# Market Research

**Generated:** {date}
**Source:** Perplexity API (sonar-pro)
**Research Gaps:** {list any failed queries, or "none"}

## Competitor Landscape

### Direct Competitors
| Name | Pricing | Key Features | Stack | Weakness |
|------|---------|-------------|-------|----------|
| {data} |

### Indirect Competitors / Alternatives
{How people solve this problem today without a dedicated tool}

## Market Size
| Metric | Value | Growth | Source |
|--------|-------|--------|--------|
| TAM | {value} | {rate} | {citation} |
| SAM | {value} | {rate} | {citation} |
| SOM | {value} | {rate} | {citation} |

## Technology Landscape
- **Common stacks:** {list}
- **Open-source alternatives:** {list}
- **Emerging trends:** {list}

## User Expectations & Pain Points
{Structured findings from Query 4}

## Regulatory Considerations
{From Query 5 if applicable, or "No specific regulatory requirements identified"}

## Synthesis

### Opportunity Gaps
1. {gap 1 — what competitors miss}
2. {gap 2}

### Informed Stack Recommendation
Based on the competitive landscape and project requirements:
- **Frontend:** {recommendation + why}
- **Backend:** {recommendation + why}
- **Database:** {recommendation + why}
- **Hosting:** {recommendation + why}

### Risk Factors
1. {risk 1}
2. {risk 2}

### Differentiation Opportunities
1. {opportunity 1}
2. {opportunity 2}

---
*Research via Perplexity API. Verify critical data points independently.*
```

Display: "Research complete. {N}/5 queries successful. Saved to `.kickstart/research.md`."

### Step 5: Validate & Report

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "kickstart.phase.completed" "_project" "Kickstart Phase 2 complete" '{"phase_number":"2"}'`

**Validate:** Check that `.kickstart/research.md` exists and contains:
- `## Competitor Landscape` section
- `## Synthesis` section
- At least one data point in Market Size table

If research is incomplete (queries failed), note gaps but still mark as done if the file exists.

**Update state:**
```
Update .kickstart/state.md:
  Phase 2 (Research) → status: done, completed: {date}
  last_phase: 2
  last_phase_status: done
```

**Report:**
```
  [2] Research        ✅ done
      Output: .kickstart/research.md
      Queries: {N}/5 successful | Competitors: {N} | Gaps: {N}
```

## Post-Conditions
- `.kickstart/research.md` exists with structured market intelligence
- `.kickstart/state.md` updated with Research → done
- Synthesis section provides actionable inputs for design phase
