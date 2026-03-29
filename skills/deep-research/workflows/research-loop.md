# Workflow: Research Loop (Core Recursive Engine)

## Overview

The recursive research engine. Takes a topic, generates seed queries, executes across configured
sources, discovers sub-topics, and loops until depth budget is exhausted. Produces a structured
report with confidence scores and source attribution.

Used by all three modes (topic, competitive-intel, tech-eval) as the underlying engine.

## Prerequisites
- `.research/config.md` loaded (or defaults applied)
- Available sources identified
- Topic and depth determined

## Process

### Step 1: Initialize Research State

Create tracking variables:
```
topic: "{user's topic}"
slug: "{slugified topic}"
depth_budget: {from config or --depth flag: shallow=1, medium=2, deep=3}
query_budget: {from config: max-queries, default 20}
queries_used: 0
current_hop: 0
findings: []           # Accumulated findings across all hops
sub_topics: []         # Discovered sub-topics needing investigation
contradictions: []     # Conflicting information between sources
sources_used: []       # Track which sources provided what
```

Create output directory:
```bash
mkdir -p ".research/${slug}/raw"
```

Display:
```
Research: {topic}
Depth: {level} ({depth_budget} hops)
Sources: {available sources list}
Query budget: {query_budget}

Starting hop 1...
```

### Step 2: Generate Seed Queries

Based on the topic, generate 3-5 targeted queries. Adapt to the topic type:

**For technology topics:**
1. "What is {topic}? Core concepts, architecture, and design philosophy"
2. "{topic} best practices, common patterns, and production usage"
3. "{topic} limitations, known issues, and gotchas in 2024-2025"
4. "{topic} ecosystem: popular libraries, tools, and integrations"
5. "{topic} vs alternatives: key differentiators"

**For market/business topics:**
1. "What is the {topic} market? Size, growth, and key players"
2. "{topic} trends and emerging opportunities 2024-2025"
3. "{topic} challenges, risks, and common failure modes"
4. "Who are the leading companies in {topic}? Pricing and positioning"

**For concept/abstract topics:**
1. "What is {topic}? Definition, core principles, and mental models"
2. "{topic} practical applications and real-world examples"
3. "{topic} current state of the art and recent developments"
4. "{topic} common misconceptions and nuances"

### Step 3: Execute Queries (Per Hop)

For each query, iterate through configured sources in priority order.
Read `references/source-adapters.md` for the specific API pattern for each source.

**Execution order:**
1. Run queries across sources (parallel where safe — see source-adapters.md)
2. Parse each response, extract:
   - **Key findings** — factual claims, data points, patterns
   - **Sub-topics** — mentioned topics worth deeper investigation
   - **Citations** — source URLs, paper references
   - **Contradictions** — claims that conflict with earlier findings
3. Increment `queries_used` for each query sent

**Per-query result structure:**
```
{
  query: "...",
  source: "perplexity|context7|...",
  hop: 1,
  findings: [
    { claim: "...", confidence: high|medium|low, citation: "..." },
    ...
  ],
  sub_topics: ["...", "..."],
  raw_response: "..." (saved to .research/{slug}/raw/hop{N}-{source}-{N}.md)
}
```

**Confidence scoring:**
- **High**: Claim appears in 2+ sources with citations, or from official documentation
- **Medium**: Claim appears in 1 source with citation, or 2+ without
- **Low**: Single source, no citation, or from user-generated content (forums, blogs)

**Save raw results:**
Write each query result to `.research/{slug}/raw/hop{N}-{source}-{N}.md` for later refresh.

**Progress display:**
```
Hop {N}: {queries_used}/{query_budget} queries | {findings count} findings | {sub_topics count} sub-topics discovered
```

### Step 4: Analyze & Decide (Recursion Gate)

After each hop completes:

**4a. Deduplicate findings:**
- Merge findings that say the same thing from different sources
- When merged, boost confidence (two medium → high)
- Keep all citations

**4b. Detect contradictions:**
- Compare new findings against accumulated findings
- Flag pairs where claims conflict
- Add to contradictions list with both citations

**4c. Rank sub-topics:**
Score each discovered sub-topic:
- +3 if mentioned by multiple sources
- +2 if directly relevant to the original topic
- +1 if mentioned once
- -1 if too broad or tangential
- -2 if already covered by existing findings

Select top `max-sub-topics` (from config, default 5) sub-topics.

**4d. Recursion decision:**
```
IF current_hop < depth_budget
   AND queries_used < query_budget
   AND sub_topics (after ranking) has items with score >= 2
THEN:
  current_hop += 1
  Generate targeted queries for top sub-topics
  Go to Step 3
ELSE:
  Proceed to Step 5 (Synthesis)
```

Display decision:
```
Hop {N} complete.
  Findings: {count} ({new} new)
  Sub-topics: {count} discovered, {selected} selected for next hop
  Contradictions: {count}
  → {Continuing to hop N+1 | Depth budget reached — synthesizing}
```

### Step 5: Synthesize Report

Organize all accumulated findings into a structured report.

**5a. Group findings by theme:**
Use the topic and sub-topics as natural groupings. Create sections for:
- Core topic findings
- Each major sub-topic investigated
- Cross-cutting themes that span multiple sub-topics

**5b. Resolve contradictions:**
For each contradiction, note both positions with citations and provide analysis of which is more likely correct (based on source reliability, recency, and number of supporting sources).

**5c. Generate confidence summary:**
```
High confidence: {N} findings (corroborated by multiple sources)
Medium confidence: {N} findings (single sourced with citation)
Low confidence: {N} findings (needs verification)
Contradictions: {N} (noted in report)
```

### Step 6: Save Report

Write `.research/{slug}/report.md`:

```markdown
# {Topic}

> Researched: {date} | Depth: {level} ({hops_used} hops) | Sources: {source_list}
> Queries: {queries_used}/{query_budget} | Findings: {count} | Confidence: {high}H / {medium}M / {low}L

## Executive Summary

{3-5 sentence synthesis of the most important findings}

## Key Findings

### {Theme 1}

{Findings grouped by theme, each with confidence indicator and citation}

- **[HIGH]** {Finding} — [{source}]({url})
- **[MED]** {Finding} — [{source}]({url})

### {Theme 2}

{...}

## Sub-Topics Investigated

{For each sub-topic that was explored in deeper hops}

### {Sub-topic 1}

{Findings from the deeper investigation}

## Contradictions & Open Questions

{For each contradiction}

| Claim A | Claim B | Sources | Assessment |
|---------|---------|---------|------------|
| {claim} | {counter-claim} | {citations} | {which is more likely and why} |

## Research Gaps

{Topics that couldn't be fully investigated — queries that failed, sources unavailable}

- {Gap 1}: {reason}
- {Gap 2}: {reason}

## Actionable Takeaways

1. {Takeaway 1 — what to do with this information}
2. {Takeaway 2}
3. {Takeaway 3}

---
*Deep research via /cks:research. {N} sources queried across {hops} hops. Verify critical findings independently.*
```

Write `.research/{slug}/sources.md`:

```markdown
# Sources — {Topic}

> Generated: {date} | Total sources: {count}

## Sources by Confidence

### High Confidence
| Finding | Source | URL | Date |
|---------|--------|-----|------|
| {finding} | {source} | {url} | {date} |

### Medium Confidence
| Finding | Source | URL | Date |
|---------|--------|-----|------|

### Low Confidence
| Finding | Source | URL | Date |
|---------|--------|-----|------|

## Source Reliability Notes

{Any notes about source quality, bias, or freshness}
```

### Step 7: Report Summary

Display completion summary:
```
Research complete: {topic}

  Hops:          {N}/{depth_budget}
  Queries:       {queries_used}/{query_budget}
  Findings:      {count} ({high} high, {medium} medium, {low} low confidence)
  Contradictions: {count}
  Sub-topics:    {count} investigated

  Report: .research/{slug}/report.md
  Sources: .research/{slug}/sources.md
  Raw data: .research/{slug}/raw/ ({file_count} files)

  Key takeaways:
  1. {takeaway 1}
  2. {takeaway 2}
  3. {takeaway 3}
```

## Error Handling

| Error | Behavior | How to Log |
|-------|----------|-----------|
| Source returns error (non-rate-limit) | Skip source for this query, try next source in config | Add to `## Research Gaps` in report: "Query '{query}' failed on {source}: {error type}" |
| All sources fail for a query | Note as research gap, continue with remaining queries | Add: "**Gap:** No data found for '{query}'. Recommend manual search." Mark confidence: LOW |
| Rate limit (429) | Retry once after 5s. If still 429, mark source as rate-limited for session | Add: "Source {source} rate-limited. Remaining queries used alternative sources." |
| Auth error (401/403) | Mark source as unavailable for session | Add: "Source {source} auth failed — check API key. Skipped for all remaining queries." |
| Timeout (>30s per query) | Skip this source for this query, try next | Add: "Source {source} timed out on '{query}'." |
| Depth budget exhausted mid-hop | Finish current hop's remaining queries, do NOT start new hop, then synthesize | Add: "Research halted at hop {N} — depth budget reached. {M} sub-topics unexplored." |
| Query budget exhausted | Stop immediately, synthesize what's available | Add: "Query budget ({max}) exhausted. {N} queries completed of {M} planned." |
| Empty results from all sources | Mark as gap with actionable suggestions | Add: "**Gap:** No sources returned data for '{topic}'. Possible causes: (1) topic too new/niche, (2) not indexed, (3) requires specialized source. Try manual search." |
