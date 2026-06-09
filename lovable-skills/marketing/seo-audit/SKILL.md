---
name: seo-audit
description: Use when the user wants to audit, review, or diagnose SEO issues on their site. Also use when the user mentions 'SEO audit,' 'technical SEO,' 'why am I not ranking,' 'SEO issues,' 'on-page SEO,' 'site audit,' or 'how do I improve my Google rankings.'
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
- `Disallow: /` blocks the entire site — a catastrophic error that happens after migrations

**Tool:** Fetch `yoursite.com/robots.txt` directly in browser.

### XML Sitemap

Requirements:
- Sitemap exists at `/sitemap.xml` or `/sitemap_index.xml`
- All important URLs included
- No noindex URLs in the sitemap (contradictory signals)
- `lastmod` dates present and accurate
- Sitemap submitted to Google Search Console

### Crawl Errors

In Google Search Console → Coverage report:
- **Excluded by robots.txt:** Are important pages excluded?
- **Blocked by noindex:** Intentional or accidental noindex tags?
- **Not found (404):** Pages generating 404 errors (check if they have backlinks)

**Tool:** Screaming Frog SEO Spider for full crawl (free up to 500 URLs).

### Core Web Vitals

Google uses CWV as a ranking signal. Measure:

| Metric | Good | Needs Work | Poor |
|---|---|---|---|
| LCP (Largest Contentful Paint) | < 2.5s | 2.5-4s | > 4s |
| INP (Interaction to Next Paint) | < 200ms | 200-500ms | > 500ms |
| CLS (Cumulative Layout Shift) | < 0.1 | 0.1-0.25 | > 0.25 |

**Common CWV fixes:**
- LCP: Compress images to WebP; add `fetchpriority="high"` to hero image
- CLS: Add width/height attributes to images; use `font-display: swap`
- INP: Defer non-critical JavaScript

**Tools:** Google PageSpeed Insights, Core Web Vitals report in GSC.

## Layer 2: Indexation

### Google Search Console Coverage

**Valid (indexed):** Are the right pages indexed?
- Do you have pages indexed that shouldn't be? (admin pages, thank-you pages, filtered URLs)

**Excluded:**
- "Crawled, currently not indexed" → Usually: thin content, duplicate content, or low quality signal.
- "Discovered, currently not indexed" → Usually: low PageRank signal, crawl budget issues.
- "Duplicate, submitted URL not selected as canonical" → Google chose a different canonical.

### Canonical Tags

Check for:
- Canonical tag present on every page (self-canonical)
- Canonical points to the correct, preferred URL
- Consistent canonical form (www vs non-www, trailing slash vs no trailing slash)

### Duplicate Content

**URL parameter duplication:** Does `/page?color=red` and `/page?color=blue` produce identical content? Canonicalize or noindex parameterized versions.

**HTTP/HTTPS duplication:** All http pages should 301 redirect to https.

**www/non-www duplication:** Pick one; redirect the other.

## Layer 3: On-Page SEO

### Title Tags

**Requirements:**
- Unique on every page
- Contains the primary keyword (near the front preferred)
- 50-60 characters (displays fully in SERPs)

**Common issues:**
- Duplicate titles across pages
- Too long (truncated in SERPs at ~60 chars)
- Not keyword-optimized

### Meta Descriptions

- Unique on every page
- 150-160 characters
- Contains a call to action and the primary keyword

### H1 Tags

- One H1 per page (not zero, not multiple)
- Contains the primary keyword
- Different from the title tag (not identical)

### Internal Linking

**Audit questions:**
- Do all important pages have internal links pointing to them?
- Are any important pages "orphaned" (no internal links)?
- Are anchor texts descriptive (not "click here" or "read more")?

## Layer 4: Content Audit

### E-E-A-T Signals

E-E-A-T = Experience, Expertise, Authoritativeness, Trustworthiness.

**Experience signals:** Author bylines with relevant experience; first-hand accounts; original data.

**Expertise signals:** Author credentials; depth and accuracy of content; citations of reputable sources.

**Authoritativeness signals:** Backlinks from authoritative sites; brand mentions; press coverage.

**Trustworthiness signals:** HTTPS; clear privacy policy and contact information; accurate, up-to-date content.

### Keyword Cannibalization

Occurs when multiple pages target the same keyword. Google gets confused about which to rank.

**Detection:** Use Ahrefs or Semrush site explorer → search for your target keyword → see if multiple pages rank for it.

**Fix:** Consolidate into one comprehensive page, or clearly differentiate intent between pages.

## Layer 5: Authority (Backlink Profile)

**Tools:** Ahrefs Site Explorer, Semrush Backlink Analytics, Google Search Console (Links report)

**Key metrics:**
- Domain Rating (Ahrefs DR) or Domain Authority (Moz DA)
- Total referring domains (more unique domains = better)
- Anchor text distribution (over-optimized exact-match anchors are a red flag)
- Lost backlinks (identify if major links were recently lost)

**Toxic link signals:**
- Links from link farms or PBNs
- Links from sites with DR < 10 and no organic traffic
- Sudden spike in links from unrelated foreign-language sites

## Audit Report Structure

**Critical (fix within 1 week):**
- Crawl blocks on important pages
- Whole-site noindex or robots block
- Canonical pointing wrong
- 5xx server errors

**High (fix within 1 month):**
- CWV fails
- Duplicate title tags
- Missing or duplicate H1s
- Key pages not indexed

**Medium (fix within quarter):**
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
| "We did an SEO audit 2 years ago" | SEO changes. Algorithm updates, site changes, and competitive shifts require annual audits at minimum. |
| "Our developer handles technical SEO" | Developers fix technical issues; they don't diagnose SEO strategy. Both roles are needed. |
| "We can't fix the Core Web Vitals — it requires a site rebuild" | Most CWV improvements are targeted changes (image optimization, JS deferral) not full rebuilds. |

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
