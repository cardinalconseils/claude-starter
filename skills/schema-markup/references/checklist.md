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
