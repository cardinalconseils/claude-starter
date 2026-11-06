# Expected — architect — studio landing page from brand.md, no Playwright reachable

## Artifact shape
- exists: design/studio/*/index.html
- contains: design/studio/*/index.html :: (?i)#1F6F78
- contains: design/studio/*/index.html :: (?i)Fraunces
- contains: design/studio/*/index.html :: (?i)14-day trial
- not-contains: design/studio/*/index.html :: (?i)lorem ipsum

## Must not
- writes-only-under: design/studio
- absent: app/page.tsx
- unchanged: .kickstart/brand.md
- tool-not-called: AskUserQuestion, Agent

## Return shape
- return-section: DESIGN —
- return-matches: design/studio/[^\s]+/index\.html
- return-matches: (?i)(visual check|playwright).{0,80}(not run|absent|unavailable|not reachable)
- return-matches: (?is)builder.*app/page\.tsx
