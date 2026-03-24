---
name: context-research
description: >
  Researches a topic, library, or API using available tools (Context7, Firecrawl, WebSearch)
  and produces a persistent context brief in .context/ that informs future coding sessions.
  Use when the user wants to pre-research a technology before coding with it.
---

# Context Research Skill

## Purpose

Eliminate the "let me look that up" cycle. Research a topic once, persist the findings, and
let Claude reference them automatically in future sessions.

## Configuration

Check for `.context/config.md` in the project root. If it exists, read the YAML frontmatter for source priority and preferences:

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

**If no config file exists**, use these defaults:
```yaml
sources: [context7, firecrawl, websearch, webfetch]
skip-unavailable: true
max-lines: 200
auto-research: true
preferred-sites: []
```

## Workflow

### Step 1: Parse Input

Extract from `$ARGUMENTS`:
- **Topic**: The subject to research (e.g., "Stripe subscriptions with Next.js")
- **Refresh flag**: Whether `--refresh` was passed

### Step 2: Load Config

Read `.context/config.md` if it exists, parse YAML frontmatter for source priority.
Fall back to defaults if missing.

### Step 3: Check Existing Context

```bash
# Slugify the topic: lowercase, spaces→hyphens, strip special chars
SLUG=$(echo "$TOPIC" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')
```

Check if `.context/${SLUG}.md` already exists:
- If exists AND no `--refresh` → show the existing brief, note its date, ask if user wants to refresh
- If exists AND `--refresh` → proceed with re-research
- If not exists → proceed with research

### Step 4: Research (Using Configured Source Priority)

Iterate through the `sources` list from config. For each source:

**context7** (if in list and available):
- `resolve-library-id` for the library/framework mentioned in topic
- `query-docs` with relevant queries
- Extract: API patterns, code examples, configuration

**firecrawl** (if in list and available):
- Scrape official documentation pages
- Use `preferred-sites` from config to prioritize specific doc sites
- Extract: comprehensive guides, migration notes, gotchas

**websearch** (if in list and available):
- Search for `"${TOPIC}" best practices`
- Search for `"${TOPIC}" gotchas common mistakes`
- If `preferred-sites` configured: `site:${site} ${TOPIC}`

**webfetch** (if in list and available):
- Fetch specific documentation URLs found via earlier sources
- Good for grabbing API references, changelogs

**If `skip-unavailable: true`** (default): silently skip sources that error or aren't connected.
**If `skip-unavailable: false`**: warn the user when a configured source isn't available.

Gather across all sources:
- **Core concepts**: What is this? Key mental models
- **API patterns**: Common usage patterns with code examples
- **Gotchas**: Known pitfalls, breaking changes, version-specific issues
- **Code examples**: Real-world snippets (not toy examples)
- **Official docs links**: URLs for deeper reading

### Step 5: Generate Context Brief

Create `.context/${SLUG}.md` (respect `max-lines` from config):

```markdown
# ${TOPIC}

> Researched: ${DATE} | Sources: ${SOURCE_LIST} | Lines: ${LINE_COUNT}/${MAX_LINES}

## Core Concepts

[Key mental models and architectural decisions]

## API Patterns

[Common usage patterns with code examples]

```[language]
// Example code
```

## Gotchas & Pitfalls

- [Known issues, version-specific problems, common mistakes]

## Code Examples

```[language]
// Production-ready patterns
```

## References

- [Official doc URL 1]
- [Official doc URL 2]
```

### Step 6: Confirm

```
✅ Context saved: .context/${SLUG}.md
   Sources: ${SOURCES_USED} (of ${SOURCES_CONFIGURED})
   Topics: [list key sections]

This context will be automatically available when working on related code.
```

## Directory Structure

```
.context/
├── config.md                              ← Source priority + preferences
├── stripe-subscriptions-with-nextjs.md
├── supabase-rls-policies.md
└── react-server-components.md
```

## PRD Integration

When called from the **Discuss phase** (auto-research mode):
- The discuss workflow extracts technology keywords from the feature brief
- Calls this skill automatically for each identified technology
- Context briefs are then available to the discoverer agent

When called standalone:
- User runs `/cks:context "topic"` directly
- Full interactive mode with confirmations

## Rules

1. **Always create `.context/` directory** if it doesn't exist
2. **Include the research date** — context goes stale
3. **Prefer official docs** over blog posts or tutorials
4. **Include real code examples** — not just descriptions
5. **Keep it concise** — respect `max-lines` config (default 200)
6. **Slugify consistently** — lowercase, hyphens, no special chars
7. **Respect source priority** — use config order, skip unavailable
8. **Don't duplicate** — check existing briefs before researching
