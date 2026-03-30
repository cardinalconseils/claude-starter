# Context Research Source Configuration Template

This template is used when creating `.context/config.md` in a project.

```markdown
---
# Source priority: ordered list of research tools to try
# Available: context7, firecrawl, websearch, webfetch
sources:
  - context7
  - firecrawl
  - websearch
  - webfetch

# Skip sources that aren't available (default: true)
skip-unavailable: true

# Max lines per context brief (default: 200)
max-lines: 200

# Auto-research: run context research automatically during /cks:discuss (default: true)
auto-research: true

# Preferred documentation sites (prioritized in search)
preferred-sites:
  - docs.stripe.com
  - supabase.com/docs
  - nextjs.org/docs
  - react.dev
---

# Context Research Config

Project-specific research preferences. Edit the frontmatter above to customize.
```
