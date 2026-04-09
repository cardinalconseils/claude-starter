---
description: Full SEO audit — on-page, technical, schema, content
allowed-tools: Read, Agent, AskUserQuestion
---

# /cks:seo-audit

Dispatch the SEO strategist agent to run a comprehensive audit.

## Quick Reference

```
/cks:seo-audit                — Full audit across all categories
/cks:seo-audit schema         — Focus on schema markup only
/cks:seo-audit technical      — Focus on technical SEO only
```

---

```
Agent(subagent_type="cks:seo-strategist", prompt="Run a comprehensive SEO audit on the current project. Check: (1) Page titles & meta descriptions — unique, keyword-rich. (2) H1 structure — one per page. (3) Schema markup — LocalBusiness, Service, FAQPage, BreadcrumbList. (4) Sitemap.xml — all pages, no orphans. (5) robots.txt — proper config. (6) Internal linking — service <-> area <-> homepage. (7) Image optimization — alt text, lazy loading, WebP. (8) Core Web Vitals. (9) AMP pages. (10) llms.txt. Focus on: $ARGUMENTS")
```
