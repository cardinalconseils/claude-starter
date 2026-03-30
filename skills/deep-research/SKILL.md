---
name: deep-research
description: >
  Multi-hop recursive research agent — takes a topic and does deep, iterative investigation
  across configurable sources (Perplexity, Context7, Firecrawl, WebSearch, HuggingFace, aHref,
  Mintlify). Unlike context-research (single-hop coding briefs), this skill produces strategic
  intelligence reports with confidence scores, source comparisons, and contradiction flagging.
  Use when: "research", "deep dive", "investigate", "analyze market", "competitive analysis",
  "compare technologies", "tech evaluation", "what are the options for", "how does X compare to Y",
  "who are the competitors", or any variation of strategic/market/technology research.
  Do NOT use for quick coding reference lookups — that's context-research.
allowed-tools: Read, Write, Grep, Glob, WebSearch, WebFetch, Agent
model: sonnet
---

# Deep Research — Multi-Hop Recursive Intelligence

Takes a topic through iterative, recursive research across multiple configurable sources.
Produces structured intelligence reports in `.research/` — not coding briefs (that's context-research).

## Flow

```
/cks:research → configure → plan queries → execute (recursive) → synthesize → save
```

## Mode Detection

Parse `$ARGUMENTS` to determine mode:

| Argument Pattern | Mode | Behavior |
|-----------------|------|----------|
| `"topic"` | **Topic** | Deep dive on a technology, concept, or domain |
| `--competitive "domain"` | **Competitive Intel** | Competitor analysis with comparison matrix |
| `--eval "tech A vs tech B"` | **Tech Evaluation** | Side-by-side technology comparison |
| `--depth shallow\|medium\|deep` | Depth override | Override config default |
| `--refresh` | Force refresh | Re-research even if report exists |
| No arguments | **Interactive** | Ask what to research |

## Configuration

Read `.research/config.md` if it exists. Parse YAML frontmatter for settings.

**If no config file exists**, create it with defaults on first run:

```yaml
---
# Source priority: ordered list of research tools to try
# Available: perplexity, context7, firecrawl, websearch, webfetch, huggingface, ahref, mintlify
sources:
  - perplexity
  - context7
  - firecrawl
  - websearch
  - webfetch
  # - huggingface    # Academic papers (uncomment to enable)
  # - ahref          # SEO/competitive data (uncomment to enable)
  # - mintlify       # Documentation search (uncomment to enable)

# Skip sources that aren't available or error (default: true)
skip-unavailable: true

# Depth settings
depth:
  default: medium       # shallow=1 hop, medium=2 hops, deep=3+ hops
  max-queries: 20       # Total queries across all sources per research session
  max-sub-topics: 5     # Max sub-topics to explore per hop

# Output settings
output:
  max-lines: 500        # Max lines per report section
  include-sources: true # Include source URLs and citations
  include-confidence: true # Include confidence scores per finding
---

# Deep Research Configuration

Edit the frontmatter above to customize research behavior per project.

## Source Reference

| Source | Best For | Requires |
|--------|----------|----------|
| perplexity | Broad market/tech research with citations | `PERPLEXITY_API_KEY` in `.env.local` |
| context7 | Library/framework documentation | Context7 MCP connected |
| firecrawl | Scraping specific documentation sites | Firecrawl MCP connected |
| websearch | General web search | WebSearch tool available |
| webfetch | Fetching specific URLs | WebFetch tool available |
| huggingface | Academic papers, ML research | HuggingFace MCP connected |
| ahref | SEO data, competitive domain analysis | aHref MCP connected |
| mintlify | Documentation search | Mintlify MCP connected |
```

## Re-run Check

Before starting, check if `.research/{slug}/report.md` exists:
- If exists AND no `--refresh` → show existing report date, ask: "Research found (dated {date}). **Use existing**, **refresh**, or **new topic**?"
  - Use existing: display the report
  - Refresh: archive old report to `.research/{slug}/archive/{date}/`, re-run
  - New topic: start fresh with different topic
- If not exists → fresh run

## Full Flow Execution

When `/cks:research` is invoked:

1. **Parse arguments** → determine mode + topic + depth + flags
2. **Load config** → read `.research/config.md` (create if missing)
3. **Re-run check** (above)
4. **Validate sources** → check which configured sources are available
   - For perplexity: check `PERPLEXITY_API_KEY` in env
   - For MCP sources: attempt a lightweight call to verify connectivity
   - Report: "Sources available: {list}. Unavailable: {list} (will be skipped)"
5. **Route to workflow by mode:**
   - Topic → Read workflow: `workflows/research-loop.md`
   - Competitive Intel → Read workflow: `workflows/competitive-intel.md`
   - Tech Evaluation → Read workflow: `workflows/tech-eval.md`

## Depth Levels

| Level | Hops | Description | Use Case |
|-------|------|-------------|----------|
| `shallow` | 1 | Single round of queries, no recursion | Quick background check |
| `medium` | 2 | Initial queries + one round of follow-up on discovered sub-topics | Most research tasks |
| `deep` | 3+ | Full recursive investigation, follows citations, cross-references | Strategic decisions, competitive intel |

## Slugification

Consistent slug generation for directory names:
```
Topic: "Next.js vs Remix for SaaS" → slug: "nextjs-vs-remix-for-saas"
Topic: "Stripe subscriptions API" → slug: "stripe-subscriptions-api"
```
Lowercase, spaces→hyphens, strip special chars, collapse multiple hyphens.

## Output Artifacts

| File | Purpose |
|------|---------|
| `.research/{slug}/report.md` | Synthesized findings with confidence scores |
| `.research/{slug}/sources.md` | All sources with URLs, dates, and reliability notes |
| `.research/{slug}/matrix.md` | Comparison matrix (competitive-intel and tech-eval modes only) |
| `.research/{slug}/raw/` | Raw query results for later refresh |
| `.research/config.md` | Source priority + settings (user-editable) |

## Integration with Other Skills

| Skill | How Deep Research Helps |
|-------|------------------------|
| `kickstart/` | Replace shallow Perplexity research with `Skill(skill="research", args="--depth medium \"{topic}\"")` |
| `monetize/` | Use competitive-intel mode for competitor analysis |
| `prd/` autonomous | Use tech-eval mode when choosing implementation approaches |
| `context-research/` | Complementary — context-research is for quick coding briefs, deep-research is for strategic intelligence |

## Error Handling

| Failure | Behavior |
|---------|----------|
| No sources available | Halt, explain which sources failed and how to configure them |
| Perplexity rate limit | Retry once after 5s, then skip and note gap |
| MCP source unavailable | Skip if `skip-unavailable: true`, warn if false |
| All queries fail for a hop | Save partial results, note "incomplete" in report |
| Depth budget exhausted | Stop recursion, synthesize what's available |

## Environment Variables

| Variable | Required By | Source |
|----------|-------------|--------|
| `PERPLEXITY_API_KEY` | perplexity source | `.env.local` |

Other sources use MCP connections (configured separately).

## Reference Files

| File | When to Read |
|------|-------------|
| `references/source-adapters.md` | When executing queries — contains the API patterns for each source |

## Customization

This skill ships with opinionated defaults. Review and adapt to your needs:

- **Source priority**: Which research tools to try — edit `.research/config.md`
- **Confidence thresholds**: When to flag low-confidence findings — edit thresholds in SKILL.md
- **Max hops**: Depth of recursive investigation (default varies by mode) — edit SKILL.md
- **Output format**: Report structure and sections — edit SKILL.md
- **allowed-tools**: Currently `Read, Write, Grep, Glob, WebSearch, WebFetch, Agent`. Add tools if needed.
- **model**: Currently `sonnet`. Remove to use your default model.
