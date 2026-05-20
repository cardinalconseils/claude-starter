---
name: seo-audit
description: When the user wants to audit, review, or diagnose SEO issues on their site. Also use when the user mentions 'SEO audit,' 'technical SEO,' 'why am I not ranking,' 'SEO issues,' 'on-page SEO,' or 'site audit.'
allowed-tools: Read, Write, WebSearch, WebFetch, AskUserQuestion
model: sonnet
---

# SEO Audit

Expert knowledge for diagnosing technical SEO issues, on-page problems, and content gaps that prevent sites from ranking.

## Audit Framework

An SEO audit covers five layers. Work through them in order — technical issues block all subsequent gains.

```
1. Crawlability → 2. Indexation → 3. On-Page → 4. Content → 5. Authority
```

Don't optimize content on pages that aren't being crawled correctly.

## Layer 1: Crawlability

### robots.txt

Check `/robots.txt` for:
- Blocked URLs that should be indexed (especially `/blog/`, `/pricing/`, `/product/`)
- Blocked directories that contain important pages
- Disallowed user-agents that should be allowed

**Critical:** `Disallow: /` blocks the entire site. This is a catastrophic error that happens after migrations.

**Tool:** Fetch `yoursite.com/robots.txt` directly in browser.

### XML Sitemap

Requirements:
- Sitemap exists at `/sitemap.xml` or `/sitemap_index.xml`
- All important URLs included
- No noindex URLs in the sitemap (contradictory signals)
- `lastmod` dates present and accurate
- Sitemap submitted to Google Search Console

**Check:** Does GSC show sitemap submitted and processed?

### Crawl Errors

In Google Search Console → Coverage report:
- **Excluded by robots.txt:** Are important pages excluded?
- **Blocked by noindex:** Intentional or accidental noindex tags?
- **Crawl anomalies:** Server errors during crawl
- **Not found (404):** Pages generating 404 errors (check if they have backlinks)

**Tool:** Screaming Frog SEO Spider for full crawl (free up to 500 URLs).

### Page Speed and Core Web Vitals

Google uses CWV as a ranking signal. Measure:

| Metric | Good | Needs Work | Poor |
|---|---|---|---|
| LCP (Largest Contentful Paint) | < 2.5s | 2.5-4s | > 4s |
| FID / INP (Interaction to Next Paint) | < 200ms | 200-500ms | > 500ms |
| CLS (Cumulative Layout Shift) | < 0.1 | 0.1-0.25 | > 0.25 |

**Tools:** Google PageSpeed Insights, Core Web Vitals report in GSC, web-vitals Chrome extension.

**Common CWV problems and fixes:**
- LCP: Large unoptimized images → compress and convert to WebP; add `loading="lazy"` to below-fold images; add `fetchpriority="high"` to hero image
- CLS: Images without width/height attributes → add dimensions; fonts causing layout shift → use `font-display: swap`
- INP: Heavy JavaScript blocking interaction → defer non-critical JS

## Layer 2: Indexation

### Google Search Console Coverage

Categories to review:

**Valid (indexed):** Are the right pages indexed?
- Do you have pages indexed that shouldn't be? (admin pages, thank-you pages, filtered URLs)
- Are important pages missing from indexed?

**Excluded:**
- "Crawled, currently not indexed" → Google crawled but chose not to index. Usually: thin content, duplicate content, or low quality signal.
- "Discovered, currently not indexed" → Google knows about the page but hasn't crawled it yet. Usually: low PageRank signal, crawl budget issues.
- "Duplicate, submitted URL not selected as canonical" → You submitted a URL but Google chose a different canonical.

### Canonical Tags

Check for:
- Canonical tag present on every page (self-canonical)
- Canonical points to the correct, preferred URL
- No pages pointing canonical to a different page (unintended)
- Consistent canonical form (www vs non-www, trailing slash vs no trailing slash)

**Common mistake:** Paginated pages all pointing to page 1 as canonical. This tells Google to ignore pages 2-N.

### Duplicate Content

**URL parameter duplication:**
- Does `/page?color=red` and `/page?color=blue` produce identical content?
- If yes, canonicalize or noindex the parameterized versions

**HTTP/HTTPS duplication:**
- Does your site serve on both http:// and https://?
- All http pages should 301 redirect to https

**www/non-www duplication:**
- Does your site serve on both www and non-www?
- Pick one; redirect the other

**Check with:** Screaming Frog crawl + duplicate content analysis; Copyscape for external duplicate detection.

## Layer 3: On-Page SEO

### Title Tags

**Requirements:**
- Unique on every page
- Contains the primary keyword (near the front preferred)
- 50-60 characters (displays fully in SERPs)
- Each title should be descriptively different from others

**Common issues:**
- Duplicate titles ("Home | Company Name" repeated across pages)
- Missing titles (defaults to page URL or H1)
- Too long (truncated in SERPs at ~60 chars)
- Not keyword-optimized (just brand name or generic terms)

### Meta Descriptions

**Requirements:**
- Unique on every page
- 150-160 characters
- Contains a call to action and the primary keyword
- Accurately describes the page (Google may rewrite if not accurate)

**Note:** Meta descriptions are not a direct ranking factor, but affect CTR.

### H1 Tags

**Requirements:**
- One H1 per page (not zero, not multiple)
- Contains the primary keyword
- Describes the page's core topic
- Different from the title tag (not identical)

### Heading Hierarchy

- H1 → H2 → H3 structure (don't skip levels)
- H2s should cover major sections
- H3s break down subsections
- Use keywords naturally in H2s and H3s (subkeywords and related terms)

### Internal Linking

**Audit questions:**
- Do all important pages have internal links pointing to them?
- Are any important pages "orphaned" (no internal links)?
- Are anchor texts descriptive (not "click here" or "read more")?
- Are there broken internal links (Screaming Frog → Response Codes → 4xx)?

**PageRank distribution:** Internal links pass PageRank. Important pages need more internal links from high-authority pages.

## Layer 4: Content Audit

### E-E-A-T Signals

E-E-A-T = Experience, Expertise, Authoritativeness, Trustworthiness. Not a direct algorithm, but a quality evaluation framework Google uses for manual reviews and training its systems.

**Experience signals:**
- Author bylines with relevant experience stated
- First-hand accounts and case examples
- Original data and research

**Expertise signals:**
- Author credentials relevant to the topic
- Depth and accuracy of content
- Citations of reputable sources

**Authoritativeness signals:**
- Backlinks from authoritative sites in your space
- Brand mentions across the web
- Press coverage

**Trustworthiness signals:**
- HTTPS
- Clear privacy policy and contact information
- Real company address and phone number
- No broken links or pages
- Accurate, up-to-date content

### Content Quality Assessment

For each key page, evaluate:

| Criterion | Check |
|---|---|
| Search intent match | Does this content match what someone searching this keyword actually wants? |
| Comprehensiveness | Does it cover the topic thoroughly? |
| Freshness | Is the content current? Are examples and stats recent? |
| Unique value | Does this add something not found elsewhere? |
| Engagement signals | Low bounce rate, longer time-on-page |

**"Crawled, currently not indexed"** pages often have thin content. They need expansion before indexing.

### Keyword Cannibalization

Occurs when multiple pages target the same keyword. Google gets confused about which to rank.

**Detection:** Use Ahrefs or Semrush site explorer → search for your target keyword → see if multiple pages rank for it.

**Fix:** Consolidate into one comprehensive page, or clearly differentiate intent between pages.

## Layer 5: Authority (Backlink Profile)

### Backlink Audit

**Tools:** Ahrefs Site Explorer, Semrush Backlink Analytics, Google Search Console (Links report)

**Key metrics:**
- Domain Rating (Ahrefs DR) or Domain Authority (Moz DA)
- Total referring domains (more unique domains = better)
- Anchor text distribution (over-optimized exact-match anchors are a red flag)
- Lost backlinks (identify if major links were recently lost)

**Toxic link signals:**
- Links from link farms or PBNs (Private Blog Networks)
- Links from sites with DR < 10 and no organic traffic
- Sitewide footer links with exact-match anchor text
- Sudden spike in links from unrelated foreign-language sites

**Disavow:** Use Google's disavow tool sparingly and only for clearly toxic links you cannot get removed. Wrong disavow submissions can harm your site.

## Audit Report Structure

Organize findings into:

**Critical (fix within 1 week):** Issues that are actively harming rankings or blocking indexation
- Crawl blocks on important pages
- Whole-site noindex or robots block
- Canonical pointing wrong
- 5xx server errors

**High (fix within 1 month):** Issues with significant ranking impact
- CWV fails
- Duplicate title tags
- Missing or duplicate H1s
- Key pages not indexed

**Medium (fix within quarter):** Issues that add up over time
- Missing meta descriptions
- Thin content on secondary pages
- Missing alt text on images
- Broken internal links

**Low (optimize when possible):**
- Suboptimal title tag lengths
- Missing schema markup
- Image file size optimization

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "We rank for our brand — SEO is fine" | Brand rankings are easy. Non-branded organic traffic is the revenue driver. |
| "We did an SEO audit 2 years ago" | SEO changes. Google algorithm updates, site changes, and competitive shifts require annual audits at minimum. |
| "Our developer handles technical SEO" | Developers fix technical issues; they don't diagnose SEO strategy. Both roles are needed. |
| "We can't fix the Core Web Vitals — it requires a site rebuild" | Most CWV improvements are targeted changes (image optimization, JS deferral) not full rebuilds. |
| "We don't have time to write new content" | Before writing new content, audit and improve existing content. Consolidating thin pages often outperforms new pages. |

## Verification

- [ ] robots.txt checked for unintended blocks
- [ ] XML sitemap submitted to GSC and processed without errors
- [ ] GSC Coverage report reviewed (error pages investigated)
- [ ] Core Web Vitals checked via PageSpeed Insights (all three metrics)
- [ ] Canonical tags verified on all key pages
- [ ] Duplicate content check completed (www/https/parameter variations)
- [ ] Title tags verified: unique, 50-60 chars, keyword-containing
- [ ] H1 tags verified: one per page, keyword-containing
- [ ] Orphaned pages identified (important pages with no internal links)
- [ ] Backlink profile checked for toxic links
- [ ] Audit findings organized into Critical/High/Medium/Low with owner and timeline
