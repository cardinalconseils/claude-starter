---
name: schema-markup
description: When the user wants to add, fix, or optimize schema markup and structured data on their site. Also use when the user mentions 'schema markup,' 'structured data,' 'JSON-LD,' 'rich snippets,' or 'schema.org.'
allowed-tools: Read, Write, WebSearch, WebFetch, AskUserQuestion
model: sonnet
---

# Schema Markup & Structured Data

Expert knowledge for implementing, validating, and optimizing schema.org structured data to earn rich results in search engines and improve AI citation potential.

## Why Schema Markup Matters

Schema markup (structured data) does two things:
1. Helps search engines understand your content's structure and context
2. Makes your content eligible for rich results (enhanced SERP features)

Rich results improve CTR by 20-30% vs standard results. AI search engines (Perplexity, Google AI Overviews) also use structured data to extract and attribute information.

## Implementation Method: JSON-LD

Always use JSON-LD (not Microdata or RDFa). JSON-LD is recommended by Google because:
- It's placed in `<head>` (doesn't affect page HTML structure)
- Easier to implement and maintain
- Works with dynamic content

**JSON-LD placement:**
```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "TypeName",
  ...
}
</script>
```

Place in `<head>` of each page where it applies. Multiple JSON-LD blocks are supported — use one block per schema type.

## Priority Schema Types

Per-type JSON-LD examples (Organization, LocalBusiness, Article, Product, FAQ, HowTo, Event, BreadcrumbList, and the rest) live in `references/priority-schema-types.md`. Read it when writing markup; the checklist below decides which types a site needs.

## Schema Validation

**Always validate before deploying:**

1. **Google Rich Results Test:** https://search.google.com/test/rich-results
   - Tests eligibility for specific rich result types
   - Shows warnings and errors

2. **Schema Markup Validator:** https://validator.schema.org/
   - More permissive than Google's tool
   - Validates against schema.org spec

3. **Google Search Console Rich Results report:**
   - Shows errors and warnings across your indexed pages
   - Lag of 1-7 days after deployment

**Common validation errors:**

| Error | Cause | Fix |
|---|---|---|
| Missing required field | Schema type requires fields not included | Add the required field |
| Invalid URL format | URL doesn't start with http:// or https:// | Fix URL format |
| Invalid date format | Should be ISO 8601 (2024-01-15) | Fix date format |
| Rating value out of range | ratingValue > bestRating | Ensure ratingValue ≤ bestRating |
| Duplicate content | Same schema type appears twice on page | Merge into one block |

## Rich Result Eligibility

Not all schema types produce rich results. Current Google-supported rich results:

| Schema Type | Rich Result |
|---|---|
| FAQPage | Expandable Q&A in SERP |
| HowTo | Step-by-step instructions in SERP |
| Product | Price, rating, availability badge |
| Article | Top stories, author byline |
| Review/AggregateRating | Star ratings in SERP |
| Event | Event card with date and location |
| JobPosting | Job listing cards |
| Recipe | Recipe cards with images |

**FAQPage** is the highest-priority for SaaS because it's available on any content page and produces the largest SERP real estate expansion.

## Implementation Checklist by Site Type

**SaaS company homepage:**
- [ ] Organization schema
- [ ] SoftwareApplication schema (if product is software)
- [ ] BreadcrumbList

**Pricing page:**
- [ ] FAQPage schema (pricing questions)
- [ ] Offer schema within SoftwareApplication

**Blog posts:**
- [ ] BlogPosting / Article schema
- [ ] BreadcrumbList

**Tutorial / how-to content:**
- [ ] HowTo schema
- [ ] FAQPage (if FAQ section present)
- [ ] BreadcrumbList

**Comparison / alternative pages:**
- [ ] FAQPage (comparison questions)
- [ ] BreadcrumbList

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Schema is optional — we rank fine without it" | You rank despite not having schema. With schema, you may rank in rich result positions above traditional results. |
| "We'll add it to every page at once later" | Prioritize by impact: FAQ and HowTo first. Don't let perfect be the enemy of deployed. |
| "Our CMS adds schema automatically" | CMS-generated schema is often generic or incomplete. Review what's generated against the eligibility requirements. |
| "Schema only matters for Google" | AI systems (Perplexity, Google AI Overviews, Bing Copilot) use structured data for content extraction and attribution. |
| "We validated it once — it's done" | Schema validation is ongoing. Content changes break schema. GSC rich results report is your ongoing monitor. |

## Verification

- [ ] Organization schema on homepage with sameAs links to all profiles
- [ ] FAQPage schema on pricing page, FAQ page, and key feature pages
- [ ] BlogPosting schema on all blog posts with author, datePublished, and dateModified
- [ ] BreadcrumbList on all non-root pages
- [ ] All schema validated with Google Rich Results Test (zero errors)
- [ ] Google Search Console rich results report checked for errors
- [ ] Schema added to CMS template (not manually per page)
- [ ] dateModified updated whenever content is significantly revised
