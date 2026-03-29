# Source Adapters Reference

How to query each configured research source. Read this file when executing research queries.

## Source: perplexity

**Requires:** `PERPLEXITY_API_KEY` in `.env.local` or environment.

**Load key:**
```bash
export $(grep -v '^#' .env.local 2>/dev/null | xargs) 2>/dev/null
```

**Query pattern:**
```bash
curl -s https://api.perplexity.ai/chat/completions \
  -H "Authorization: Bearer $PERPLEXITY_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "sonar-pro",
    "messages": [
      {"role": "system", "content": "{system_prompt}"},
      {"role": "user", "content": "{query}"}
    ]
  }'
```

**Parse response:** Extract `.choices[0].message.content` and `.citations` array.

**System prompts by mode:**
- **Topic**: "You are a technology researcher. Provide specific details, data points, code examples where relevant, and cite sources. Be precise and factual."
- **Competitive Intel**: "You are a competitive intelligence analyst. For each company/product, provide: name, pricing, key features, technology stack, funding status, strengths, weaknesses. Cite sources."
- **Tech Eval**: "You are a senior software architect evaluating technology options. Compare objectively with specific benchmarks, community metrics, and real-world tradeoffs. Cite sources."

**Best for:** Broad research with citations, market data, current information.

**Rate limits:** ~50 req/min. On 429 error: retry once after 5s.

---

## Source: context7

**Requires:** Context7 MCP connected.

**Query pattern (two-step):**

Context7 MCP may be registered under different namespaces depending on the installation method.
Try both patterns in order — use whichever resolves successfully.

Step 1 — Resolve library (try in order):
```
TRY: mcp__claude_ai_Context7__resolve-library-id(libraryName: "{library_name}")
IF error → TRY: mcp__plugin_context7_context7__resolve-library-id(libraryName: "{library_name}")
IF both error → SKIP, note "Context7 unavailable"
```

Step 2 — Query docs (use same namespace that resolved in Step 1):
```
mcp__{resolved_namespace}__query-docs(libraryId: "{resolved_id}", query: "{query}")
```

**Best for:** Library/framework documentation, API patterns, code examples.

**Fallback:** If library not found in Context7, skip and note "Library not indexed in Context7". If Context7 MCP is not connected at all, skip source entirely (respecting `skip-unavailable` config).

---

## Source: firecrawl

**Requires:** Firecrawl skill/MCP available.

**Query pattern:** Use the firecrawl skill to scrape documentation pages:
- Construct URLs from the topic (e.g., "Stripe subscriptions" → `docs.stripe.com/billing/subscriptions`)
- Scrape and extract markdown content
- Particularly good for official documentation sites

**Best for:** Comprehensive documentation scraping, getting full page content.

**Fallback:** If Firecrawl unavailable, fall back to webfetch for specific URLs.

---

## Source: websearch

**Requires:** WebSearch tool available.

**Query pattern:**
```
WebSearch(query: "{search_query}")
```

**Query construction by mode:**
- **Topic**: `"{topic}" best practices 2024 2025`
- **Competitive Intel**: `"{domain}" competitors comparison pricing`
- **Tech Eval**: `"{tech A}" vs "{tech B}" comparison benchmark`
- **Sub-topic follow-up**: `"{sub_topic}" "{parent_topic}" details`

**Best for:** Broad discovery, finding recent articles, blog posts, discussions.

**Note:** Results are summaries — use webfetch to get full content of promising URLs.

---

## Source: webfetch

**Requires:** WebFetch tool available.

**Query pattern:**
```
WebFetch(url: "{url}")
```

**Usage:** Not for discovery — use after other sources identify specific URLs worth reading in full.

**Best for:** Reading full articles, documentation pages, GitHub READMEs, comparison posts.

---

## Source: huggingface

**Requires:** HuggingFace MCP connected.

**Query pattern:**
```
mcp__claude_ai_Hugging_Face__paper_search(query: "{query}")
```

For model/dataset info:
```
mcp__claude_ai_Hugging_Face__hub_repo_search(query: "{query}", type: "model|dataset")
```

**Best for:** Academic research, ML/AI topics, finding relevant papers and models.

**Fallback:** If HuggingFace not connected, skip and note "Academic sources unavailable".

---

## Source: ahref

**Requires:** aHref MCP connected.

**Query patterns:**

Domain overview:
```
mcp__claude_ai_aHref__site-explorer-metrics(target: "{domain}")
```

Competitor discovery:
```
mcp__claude_ai_aHref__site-explorer-organic-competitors(target: "{domain}")
```

Keyword analysis:
```
mcp__claude_ai_aHref__keywords-explorer-overview(keywords: ["{keyword}"])
```

**Best for:** SEO competitive analysis, domain authority, organic traffic estimates, backlink profiles.

**Fallback:** If aHref not connected, use websearch with `site:similarweb.com "{domain}"` as approximation.

---

## Source: mintlify

**Requires:** Mintlify MCP connected.

**Query pattern:**
```
mcp__plugin_mintlify_Mintlify__search_mintlify(query: "{query}")
```

**Best for:** Searching across documentation sites powered by Mintlify.

**Fallback:** If Mintlify not connected, skip.

---

## Source Availability Check

Before starting research, verify which sources are actually available:

```
For each source in config:
  perplexity  → check: env var PERPLEXITY_API_KEY is set
  context7    → check: attempt resolve-library-id with a known library (e.g., "react")
  firecrawl   → check: Skill("firecrawl") is available
  websearch   → check: WebSearch tool exists (almost always available)
  webfetch    → check: WebFetch tool exists (almost always available)
  huggingface → check: attempt paper_search with a simple query
  ahref       → check: attempt site-explorer-metrics with test domain (e.g., "example.com")
  mintlify    → check: attempt search_mintlify with a simple query
```

Report available/unavailable sources before starting. If `skip-unavailable: true`, silently skip failed sources. If false, warn the user.

## Parallel Execution

When multiple sources are configured and available, run queries in parallel where possible:
- **Parallel safe:** perplexity + websearch + context7 (independent APIs)
- **Sequential:** webfetch after websearch (needs URLs from search results)
- **Sequential:** context7 resolve → context7 query (two-step)

Use Agent() dispatches for parallel source queries when depth is `deep`.

## Fallback Chain on Query Failure

When a query fails on a source, follow this cascade:

```
IF skip-unavailable: true (default):
  → Skip failed source, try next source in config list
  → If ALL sources exhausted for a query, note as "research gap" in report
  → Continue with remaining queries

IF skip-unavailable: false:
  → Halt and warn user: "Source {name} failed: {error}. Fix or set skip-unavailable: true."

Special cases:
  Rate limit (429)  → Retry once after 5 seconds. If still 429, mark source as
                       rate-limited for this session. Prefer WebSearch for remaining queries.
  Timeout (>30s)    → Skip this query on this source. Try next source.
  Auth error (401)  → Mark source as unavailable for session. Note: "Check API key for {source}."
  MCP not connected → Mark source as unavailable for session. Skip silently.
```

The fallback order is always the config source list order. WebSearch and WebFetch are always
available as last-resort sources — a research query should only be marked as a "gap" if even
WebSearch returns no useful results.
