# Priority Schema Types

JSON-LD examples per type. Extracted from SKILL.md to keep the doctrine under the 300-line cap.

### 1. Organization

Every site should have this on the homepage.

```json
{
  "@context": "https://schema.org",
  "@type": "Organization",
  "name": "Your Company Name",
  "url": "https://www.yoursite.com",
  "logo": "https://www.yoursite.com/logo.png",
  "description": "One-paragraph description of what you do",
  "contactPoint": {
    "@type": "ContactPoint",
    "telephone": "+1-555-555-5555",
    "contactType": "customer service",
    "availableLanguage": "English"
  },
  "sameAs": [
    "https://www.linkedin.com/company/yourcompany",
    "https://twitter.com/yourcompany",
    "https://www.crunchbase.com/organization/yourcompany"
  ]
}
```

**sameAs is critical for entity disambiguation** — links to your authoritative profiles on other platforms help AI systems recognize your brand as a unified entity.

### 2. SoftwareApplication (for SaaS products)

```json
{
  "@context": "https://schema.org",
  "@type": "SoftwareApplication",
  "name": "Product Name",
  "applicationCategory": "BusinessApplication",
  "operatingSystem": "Web, iOS, Android",
  "description": "What your product does in 1-2 sentences",
  "url": "https://www.yoursite.com",
  "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "USD",
    "description": "Free trial available"
  },
  "aggregateRating": {
    "@type": "AggregateRating",
    "ratingValue": "4.8",
    "reviewCount": "342",
    "bestRating": "5"
  }
}
```

### 3. FAQPage

The highest-impact schema for earning rich results and AI citations.

```json
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is [Product Name]?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Direct answer in 1-3 sentences. Plain language."
      }
    },
    {
      "@type": "Question",
      "name": "How much does [Product Name] cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "[Product Name] starts at $X/month. Plans available from $X to $X. Free trial available."
      }
    }
  ]
}
```

**Best pages for FAQPage schema:**
- FAQ page (obvious)
- Pricing page (questions about cost, trials, contracts)
- Feature pages (questions about how each feature works)
- Comparison/alternative pages (questions about vs competitors)

### 4. HowTo

For step-by-step guides and tutorials.

```json
{
  "@context": "https://schema.org",
  "@type": "HowTo",
  "name": "How to [accomplish the task]",
  "description": "Brief description of the outcome",
  "totalTime": "PT15M",
  "step": [
    {
      "@type": "HowToStep",
      "name": "Step 1 name",
      "text": "Clear description of what to do in this step",
      "image": "https://www.yoursite.com/step1-image.jpg"
    },
    {
      "@type": "HowToStep",
      "name": "Step 2 name",
      "text": "Clear description of step 2"
    }
  ]
}
```

Use on tutorial blog posts, guide articles, and documentation.

### 5. Article / BlogPosting

```json
{
  "@context": "https://schema.org",
  "@type": "BlogPosting",
  "headline": "Full Article Title Here",
  "description": "Article summary (1-2 sentences — use the meta description)",
  "image": "https://www.yoursite.com/article-image.jpg",
  "datePublished": "2024-01-15",
  "dateModified": "2024-03-20",
  "author": {
    "@type": "Person",
    "name": "Author Full Name",
    "url": "https://www.yoursite.com/author/name",
    "jobTitle": "Title at Company"
  },
  "publisher": {
    "@type": "Organization",
    "name": "Company Name",
    "logo": {
      "@type": "ImageObject",
      "url": "https://www.yoursite.com/logo.png"
    }
  }
}
```

The `dateModified` field signals freshness to search engines. Always update it when content is significantly revised.

### 6. Product

For product pages with pricing.

```json
{
  "@context": "https://schema.org",
  "@type": "Product",
  "name": "Product Name",
  "description": "Product description",
  "brand": {
    "@type": "Brand",
    "name": "Company Name"
  },
  "offers": {
    "@type": "AggregateOffer",
    "priceCurrency": "USD",
    "lowPrice": "29",
    "highPrice": "299",
    "offerCount": "3"
  },
  "aggregateRating": {
    "@type": "AggregateRating",
    "ratingValue": "4.7",
    "reviewCount": "215"
  }
}
```

### 7. BreadcrumbList

Required for sites with hierarchical structure. Improves navigation appearance in SERPs.

```json
{
  "@context": "https://schema.org",
  "@type": "BreadcrumbList",
  "itemListElement": [
    {
      "@type": "ListItem",
      "position": 1,
      "name": "Home",
      "item": "https://www.yoursite.com"
    },
    {
      "@type": "ListItem",
      "position": 2,
      "name": "Blog",
      "item": "https://www.yoursite.com/blog"
    },
    {
      "@type": "ListItem",
      "position": 3,
      "name": "Article Title",
      "item": "https://www.yoursite.com/blog/article-slug"
    }
  ]
}
```
