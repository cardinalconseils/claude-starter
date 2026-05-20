---
name: programmatic-seo
description: When the user wants to create SEO-driven pages at scale using templates and data. Also use when the user mentions 'programmatic SEO,' 'template pages,' 'pages at scale,' 'directory SEO,' or 'data-driven pages.'
allowed-tools: Read, Write, WebSearch, WebFetch, AskUserQuestion
model: sonnet
---

# Programmatic SEO

Expert knowledge for creating SEO-driven pages at scale using templates and structured data to capture long-tail search traffic.

## What Programmatic SEO Is

Programmatic SEO (pSEO) creates hundreds or thousands of pages automatically by combining a content template with a structured data source.

**Examples:**
- Zapier: "Connect [App A] and [App B]" — 40,000+ integration pages
- Nomad List: "[City] for digital nomads" — 1,000+ city pages
- G2: "[Category] software" — category pages for every software type
- Wise: "[Currency A] to [Currency B] exchange rate" — all currency pairs

Each page is unique, targets a specific long-tail keyword, and requires almost no incremental content effort once the template is built.

## When Programmatic SEO Works

pSEO works when:
1. There is a **large keyword space** with consistent patterns ("X for Y," "X vs Y," "X in City," "Best X for Z")
2. You have or can create a **structured data source** (database, spreadsheet, API)
3. The pages provide **genuine value to the searcher** (not just keyword coverage)
4. The variation between pages is **meaningful and accurate** (not just find-replace thin content)

pSEO fails when pages are thin, duplicate, or don't serve real user intent.

## Step 1: Keyword Pattern Identification

Find repeating patterns in your keyword space.

**Common pSEO keyword patterns:**

| Pattern | Example | Search intent |
|---|---|---|
| [Tool] for [Use Case] | "CRM for real estate agents" | Finding the right product |
| [Tool] vs [Tool] | "Notion vs Airtable" | Comparison, evaluation |
| [Tool] alternatives | "Salesforce alternatives" | Seeking options |
| [Location] + [Topic] | "SEO agency in Austin" | Local services |
| Best [Tool] for [Segment] | "Best project management for agencies" | Top-of-category |
| How to [Task] with [Tool] | "How to automate email with Zapier" | Tutorial, how-to |
| [Template type] template | "Marketing plan template" | Free resources |

**Research process:**
1. Start with 10 seed keywords you already rank for or care about
2. Use Ahrefs or Semrush to find keyword clusters with consistent patterns
3. Export and look for repeating modifiers (industries, locations, use cases, tools)
4. Estimate total keyword space: pattern volume × number of variations

**Quality filters:**
- Minimum 50 searches/month per keyword (combined, the tail adds up)
- Search intent must match page format you can deliver
- Low-to-medium difficulty (< 30 KD for new sites, < 50 for established)

## Step 2: Data Source Selection and Creation

Your data source determines whether the pages are good or just filled.

**Data source types:**

| Type | Example | Quality lever |
|---|---|---|
| Internal product data | Integration pairs, template library | High (you own it) |
| Third-party enriched data | Company data from Clearbit or Crunchbase | Medium (accuracy varies) |
| Manually curated | City guides, tool reviews | High (but time-intensive) |
| User-generated | Marketplace listings, customer submissions | Variable |
| API-sourced | Exchange rates, weather data, sports stats | High (if real-time) |

**Data quality requirements:**
- Every field used in template must be present for every record
- Data must be accurate (wrong data = trust damage)
- Data must be updatable (stale data = poor UX and potential ranking risk)
- Data must have enough fields to create meaningful page variation

## Step 3: Template Design

The template is the page structure that wraps the data.

**Template design principles:**

**1. The 60/40 rule:**
At minimum, 40% of each page's content should be unique to that combination. Pages that are 95% identical will be treated as duplicate content.

**2. Unique value per page:**
For each variation, ask: "Would a user who searched for this specific combination get meaningfully different value than from the generic page?" If no, the page may not deserve to exist.

**3. Template sections:**

```
[Hero] — Keyword-matched H1 + value prop for this combination
[Quick answer] — Direct answer to the likely search intent
[Data table or structured content] — The unique data for this combination
[How-to or context section] — Templated but references the combination
[Related combinations] — Internal links to adjacent pages
[CTA] — What to do next
```

**4. Dynamic content fields:**
Mark clearly in your template which fields pull from the data source and which are static. Every dynamic field must have a fallback for missing data.

## Step 4: Thin Content Avoidance

Thin content is the death of pSEO. Google penalizes and deindexes thin pages.

**Thin content warning signs:**
- Page body < 300 words of meaningful content
- No unique data or insight for the specific combination
- Same template text with only a keyword swap
- No internal links or related content
- No user-generated elements (reviews, comments) to create variation

**Enrichment strategies:**
- Add a data table (real, accurate, specific to the combination)
- Add contextual commentary generated from the data (e.g., "Teams using [Tool A] and [Tool B] typically automate [specific workflow]")
- Add user reviews or ratings if available
- Add related resources (blog posts, case studies) filtered to the combination
- Add FAQ content specific to the combination

## Step 5: Canonicalization and Indexation

Scale creates new technical SEO challenges.

**Canonical strategy:**
- All programmatic pages should be self-canonical (point to themselves)
- If two combinations resolve to the same content (e.g., "/city-a-to-city-b" and "/city-b-to-city-a"), set one as canonical
- Avoid canonical pointing to a hub page — it signals "this page is duplicate"

**Indexation control:**
Not all programmatic pages should be indexed immediately.

Use these signals to decide what to index:
- Pages with < 50 searches/month for their target keyword → noindex initially
- Pages with very thin data → noindex until enriched
- Priority index: pages with good data, meaningful search volume, and unique value

**Use robots.txt or noindex meta tag strategically.** Large-scale thin-content indexation can dilute your site's overall quality signal.

## Step 6: Internal Linking at Scale

Internal linking is critical for distributing PageRank across thousands of pages.

**Internal linking strategies for pSEO:**

1. **Hub page → all instances:** A category page linking to all pages in that category
2. **Cross-linking combinations:** Page for [A + B] links to [A + C] and [B + C]
3. **Popular to long-tail:** High-traffic pages link to relevant programmatic pages
4. **Breadcrumbs:** Every programmatic page has a breadcrumb trail (Category → Subcategory → Page)
5. **Sitemap:** Auto-generated XML sitemap updated as pages are created

**Anchor text diversity:**
Avoid repeating the exact same anchor text for every internal link. Vary phrasing while keeping relevance.

## Step 7: Page Quality Scoring

Build a quality score for your programmatic pages to prioritize indexation and identify problem areas.

**Quality score components:**

| Signal | Weight | How to measure |
|---|---|---|
| Data completeness | 30% | % of template fields populated |
| Unique content word count | 25% | Words in non-template sections |
| Search volume for target keyword | 20% | Monthly searches |
| Click-through rate in GSC | 15% | After indexation |
| Organic traffic after 3 months | 10% | GSC impressions/clicks |

Pages scoring below 40% → noindex or improve before indexing.

## Measurement

**Leading indicators (month 1-3):**
- Index coverage (how many pages indexed vs submitted)
- Crawl rate (are bots crawling the new pages?)
- Click-through rate for indexed pages

**Lagging indicators (month 3-12):**
- Organic traffic to programmatic section
- Number of keywords ranking in top 10
- Conversion rate from programmatic pages

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "More pages = more traffic" | More indexed thin pages = Google penalty. Quality gates every programmatic page before indexing. |
| "We'll fix the thin content after we see what ranks" | By the time you see a problem in rankings, the damage to your domain authority has already happened. |
| "Our data source has gaps — we'll just leave those fields blank" | Template fields with missing data produce incoherent pages. Build fallbacks or conditionally exclude sections. |
| "We don't need internal links — the pages will rank on their own" | Programmatic pages often have no external backlinks. Internal linking is the primary authority signal. |
| "All 10,000 pages should be indexed on day one" | Phase indexation. Start with your highest-quality 200 pages. Let them prove value before scaling. |

## Verification

- [ ] Keyword pattern validated with search volume data (total addressable volume estimated)
- [ ] Data source complete (no critical fields missing for any record)
- [ ] Template tested with 10 sample pages before building all instances
- [ ] 60/40 rule checked: each page has at least 40% unique content
- [ ] Canonical tags implemented correctly (self-canonical on all programmatic pages)
- [ ] Internal linking structure defined (hub pages, breadcrumbs, cross-links)
- [ ] Indexation strategy defined (phased rollout with quality score threshold)
- [ ] Quality score system built to identify thin pages before indexing
- [ ] Monitoring in place (GSC coverage report, traffic by section)
