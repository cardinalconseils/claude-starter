---
name: seo-local
description: Local SEO expertise for rank-and-rent sites without GBP
---

# Local SEO Skill (No GBP)

Local SEO knowledge for ranking service-area websites without Google Business Profile.

## Core Ranking Factors (Without GBP)

### 1. On-Page Signals (Highest Control)
- **Title tags**: "[Service] in [City] | [Brand]" — under 60 characters
- **Meta descriptions**: Include CTA + phone + city — under 155 characters
- **H1**: Primary keyword + city — one per page
- **Content**: 800-1500 words, locally relevant, answer-first
- **URL structure**: `/services/[primary-service]-[city]`
- **Image alt text**: Descriptive with local context

### 2. Technical Signals
- **Page speed**: LCP < 2.5s (critical for mobile)
- **Mobile responsive**: Must pass Google's mobile-friendly test
- **HTTPS**: Required
- **Structured data**: LocalBusiness + Service + FAQPage
- **Sitemap**: Auto-generated, complete, submitted
- **Canonical URLs**: Prevent duplicate content
- **hreflang**: Not needed (single language/region)

### 3. Content Signals
- **Location pages**: One per service area (city/town)
- **Service pages**: One per service type
- **Blog posts**: Long-tail keyword targets
- **FAQ content**: Answer real user questions
- **Testimonials**: Social proof (from renter's customers)

### 4. Off-Page Signals
- **Local citations**: NAP consistency across 20+ directories
- **Backlinks**: Local news, blogs, community sites, chambers of commerce
- **Social profiles**: Facebook, Instagram, Yelp — all linking to site
- **Reviews**: Yelp, Facebook, BBB (cannot use Google Reviews)

### 5. User Signals
- **CTR**: Compelling titles and descriptions
- **Bounce rate**: Relevant content that matches intent
- **Dwell time**: Engaging, comprehensive content
- **Conversion rate**: Clear CTAs, easy contact

## Schema Implementation

Every page must have at minimum:

```json
{
  "@context": "https://schema.org",
  "@type": "LocalBusiness",
  "name": "[PROJECT_NAME]",
  "telephone": "+1-XXX-XXX-XXXX",
  "areaServed": {
    "@type": "City",
    "name": "[CITY]",
    "containedInPlace": {
      "@type": "AdministrativeArea",
      "name": "[STATE_PROVINCE]"
    }
  }
}
```

Service pages add:
```json
{
  "@type": "Service",
  "serviceType": "[PRIMARY_SERVICE]",
  "provider": { "@id": "#organization" },
  "areaServed": { "@type": "City", "name": "[CITY]" }
}
```

## Keyword Research Framework

Target keywords by intent:

| Intent | Pattern | Example |
|--------|---------|---------|
| Transactional | [service] + [city] | "[PRIMARY_SERVICE] [CITY]" |
| Informational | how much + [service] + [city] | "how much [PRIMARY_SERVICE] [CITY]" |
| Navigational | [service] near me | "[PRIMARY_SERVICE] near me" |
| Commercial | best + [service] + [city] | "best [PRIMARY_SERVICE] [CITY]" |
