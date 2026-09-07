# Expected — marketer — SEO audit from the site files with aHref absent

## Artifact shape
- exists: .marketing/seo/*.md
- contains: .marketing/seo/*.md :: (?i)<title>|title tag|missing title
- contains: .marketing/seo/*.md :: (?i)schema|JSON-LD
- contains: .marketing/seo/*.md :: (?i)h1

## Must not
- writes-only-under: .marketing, .campaign
- unchanged: site/index.html
- tool-not-called: mcp__claude_ai_aHref__*, Edit, Agent, AskUserQuestion
- no-written-file-matches: (?i)domain rating:? ?\d|DR \d\d|\d+ backlinks

## Return shape
- return-matches: (?m)^Persona:\s+seo-geo-aeo
- return-matches: Tools:.*aHref absent
- return-matches: (?m)^Deliverable:\s+\.marketing/seo/
