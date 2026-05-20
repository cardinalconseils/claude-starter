---
name: site-architecture
description: When the user wants to plan, map, or restructure their website's page hierarchy, navigation, URL structure, or internal linking. Also use when the user mentions 'sitemap,' 'site map,' 'information architecture,' 'URL structure,' 'navigation redesign,' or 'internal linking strategy.'
allowed-tools: Read, Write, WebSearch, WebFetch, AskUserQuestion
model: sonnet
---

# Site Architecture & Information Architecture

Expert knowledge for planning website structure, URL hierarchy, navigation, and internal linking that serves both users and search engines.

## Why Site Architecture Matters

Good site architecture does three things simultaneously:
1. **User experience:** Visitors find what they need without frustration
2. **SEO:** Search engines can crawl, understand hierarchy, and distribute authority efficiently
3. **Conversion:** Users flow naturally from discovery to decision to action

Bad architecture is the most common reason technically sound content doesn't rank.

## Core Principles

### Flat vs Deep Hierarchy

**Flat hierarchy (preferred):**
- Every page reachable within 3-4 clicks from the homepage
- Fewer navigational layers
- More direct internal links

**Deep hierarchy (avoid):**
- Pages buried 5-7 levels deep
- Limited internal links to deep pages
- Search engines deprioritize deeply buried pages (low crawl priority)

**Rule of thumb:** No important page should be more than 3 clicks from the homepage.

### The Pillar-Cluster Model (for content)

The pillar-cluster model is the SEO standard for content architecture:

```
Homepage
├── Pillar Page: [Core Topic 1]
│   ├── Cluster: [Subtopic A]
│   ├── Cluster: [Subtopic B]
│   └── Cluster: [Subtopic C]
├── Pillar Page: [Core Topic 2]
│   ├── Cluster: [Subtopic D]
│   └── Cluster: [Subtopic E]
```

**Each cluster page:**
- Links back to its pillar page (passes authority up)
- Is linked from its pillar page (receives authority from the pillar)
- May link to related cluster pages within the same pillar (contextual relevance)

**Benefits:**
- Concentrates PageRank at pillar pages (which target high-volume, competitive keywords)
- Signals topical depth to search engines
- Creates a user journey from broad exploration to specific answers

## URL Structure Design

### URL Naming Conventions

**Good URLs:**
- `yoursite.com/marketing-analytics` (clear, readable, keyword-containing)
- `yoursite.com/blog/how-to-reduce-churn` (descriptive, hierarchical)
- `yoursite.com/features/reporting` (simple, category → feature)

**Bad URLs:**
- `yoursite.com/p?id=1234` (no meaning, not crawlable)
- `yoursite.com/marketing_analytics_software_best` (keyword-stuffed)
- `yoursite.com/en-us/home/v2/new/page1` (unnecessary hierarchy)

**URL rules:**
- Use hyphens (not underscores) as word separators
- All lowercase
- Include primary keyword where natural (don't force it)
- Avoid stop words (a, the, and, of) unless they're part of the keyword
- Keep URLs as short as meaningful allows (not too short to be descriptive)
- Avoid dates in blog URLs unless your content is time-bound (dates accelerate perceived staleness)

### URL Hierarchy That Reflects Site Structure

Your URL structure should mirror your navigational hierarchy.

**Typical SaaS URL hierarchy:**

```
/                           → Homepage
/product/                   → Product hub
/product/[feature]/         → Feature pages
/solutions/                 → Solutions hub
/solutions/[use-case]/      → Use case pages
/solutions/[industry]/      → Industry pages
/pricing/                   → Pricing
/blog/                      → Blog hub
/blog/[category]/           → Blog category
/blog/[category]/[post]/    → Blog posts
/customers/                 → Customer stories hub
/customers/[company]/       → Individual case studies
/about/                     → About
/about/team/                → Team page
/legal/                     → Legal hub
/legal/privacy/             → Privacy policy
```

## Navigation Design

### Primary Navigation

**Navigation principles:**
- Maximum 5-7 top-level items (cognitive load limit)
- Labels must be clear at a glance (not clever, not branded language)
- Prioritize pages that convert, not just pages that exist
- Mobile navigation must be thumb-accessible (hamburger menu or bottom tab bar)

**Typical SaaS primary navigation:**
Product | Solutions | Pricing | Customers | Blog | Login | [CTA Button]

**What to exclude from primary nav:**
- Pages that serve a narrow audience (legal, careers can go in footer)
- Pages that are in the conversion funnel (pricing can be in both nav and CTA)

### Mega Menu vs Simple Dropdown

**Use simple dropdown when:**
- Each top-level item has fewer than 8 sub-pages
- Users expect simple hierarchical navigation

**Use mega menu when:**
- You have 3+ product areas or solution categories
- Cross-category links add genuine value
- You can maintain it (mega menus become outdated quickly)

**Use no dropdown when:**
- Your site is simple (< 10 pages)
- You're optimizing conversion (landing pages often use no navigation at all)

### Breadcrumbs

Breadcrumbs serve double duty: UX (where am I?) and SEO (signals hierarchy).

**Breadcrumb implementation:**
- Present on every non-homepage page
- Format: `Home > [Category] > [Subcategory] > Current Page`
- Each element is a clickable link (except current page)
- Implemented with BreadcrumbList schema markup

**Where breadcrumbs are essential:**
- Deep content (blog posts, case studies)
- Product documentation
- E-commerce product pages
- Any site with more than 3 hierarchical levels

## Internal Linking Strategy

Internal links are how PageRank flows through your site. They are also how users navigate.

### PageRank Distribution Model

The homepage has the most external backlinks = highest inherent PageRank. Internal links distribute that authority.

**PageRank flow:**
```
Homepage (most authority)
  → Pillar pages (receive from homepage)
    → Cluster pages (receive from pillar)
      → Supporting content (receive from clusters)
```

**High-priority pages should receive the most internal links:**
- Main product pages
- Pricing page
- Pillar content pages
- High-converting landing pages

### Anchor Text Best Practices

**Good anchor text:**
- Descriptive: "[Marketing Analytics Tool]" links to the marketing analytics page
- Natural: flows in the sentence without feeling forced
- Varied: Same destination page gets different anchor texts from different pages

**Bad anchor text:**
- "Click here" (meaningless)
- "Read more" (meaningless)
- Exact-match keyword repeated identically from every page (over-optimization)
- Navigation menu text for editorial links (use contextual language instead)

### Orphaned Page Identification

An orphaned page has no internal links pointing to it. These pages:
- May not be discovered by search engine crawlers
- Receive no PageRank
- Are invisible to users navigating your site

**Finding orphans:**
- Screaming Frog crawl → "All inlinks" report → filter for pages with 0 inlinks
- Ahrefs Site Audit → Orphaned pages report

**Fixing orphans:**
- If it's important: add internal links from relevant pages
- If it's not important: consider noindex or removal

### Internal Link Audit

**Broken internal links (404s):**
- Run Screaming Frog → Response Codes → 4xx filter
- Broken internal links waste crawl budget and confuse users
- Fix: Update the link to the correct URL; if page is deleted, update to new relevant URL

**Link depth audit:**
- Flag any important page that is more than 3 clicks from homepage
- Prioritize adding internal links to reduce depth

## Crawl Budget Optimization

Crawl budget = the number of pages a search engine crawls in a given period. For large sites, this matters. For sites < 1,000 pages, focus on other things first.

**Crawl budget wasters:**
- Duplicate pages (URL parameters, session IDs)
- Thin pages that add no value (tag pages, archive pages, search results)
- Faceted navigation generating thousands of filter combinations
- Paginated content with no distinct value per page

**Crawl budget savers:**
- robots.txt blocking low-value paths
- noindex on thin/duplicate pages
- Self-canonical on all pages
- Sitemap submission (helps bots prioritize)

## Site Architecture Deliverables

### 1. Visual Sitemap

A diagram showing all pages in hierarchy. Use for:
- Internal alignment before building
- Identifying gaps (missing pages that should exist)
- Identifying redundancies (pages that overlap in purpose)

**Format:** Can be a simple tree structure in Figma, Miro, or even a spreadsheet with indent levels.

### 2. URL Map

A spreadsheet with:
- Proposed URL
- Page title
- Parent page (what it lives under in the hierarchy)
- Target keyword
- Internal link sources (which pages will link to this one)
- Priority (1=most important)

### 3. Navigation Specification

Defines:
- Primary navigation items and labels
- Dropdown content (if any)
- Footer navigation structure
- Breadcrumb pattern

### 4. Internal Link Plan

Maps:
- Which existing pages should link to new pages
- Anchor text to use
- Which new pages should link to existing high-priority pages

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "We can fix the IA after launch — structure doesn't matter that much" | URL changes after launch require 301 redirects and lose some link equity. Architecture is easier to get right before building. |
| "Users will use search anyway — navigation doesn't matter" | Site search is a failure signal. Users who find via search didn't trust your navigation. |
| "We have hundreds of pages — we can't flatten the hierarchy now" | You don't need to flatten everything. Ensure the top 20 most important pages are within 3 clicks. |
| "Breadcrumbs make the page look cluttered" | Breadcrumbs are a navigation aid and schema signal. They don't need to be visually prominent — small text, top of page, done. |
| "Our CMS generates URLs automatically — we can't control them" | Most CMS platforms allow slug customization. This is worth configuring. Automated URLs are often terrible for SEO. |

## Verification

- [ ] Visual sitemap created with all key pages in hierarchy
- [ ] No important page more than 3 clicks from homepage
- [ ] URL structure uses hyphens, lowercase, no stop words, no dates for evergreen content
- [ ] Primary navigation has ≤ 7 top-level items with clear labels
- [ ] Breadcrumbs implemented on all non-homepage pages
- [ ] BreadcrumbList schema markup added
- [ ] Orphaned pages identified and fixed (internal links added or pages removed)
- [ ] Broken internal links (4xx) resolved
- [ ] URL map documented with keyword targets and internal link plan
- [ ] Pillar-cluster model applied to content section of site
