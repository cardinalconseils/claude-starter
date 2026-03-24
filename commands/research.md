---
name: research
description: "Deep multi-hop research on any topic — recursive investigation with configurable sources"
argument-hint: '"topic" [--depth shallow|medium|deep] [--competitive] [--eval] [--refresh]'
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - Grep
  - WebSearch
  - WebFetch
  - Agent
  - Skill
  - AskUserQuestion
  - "mcp__*"
---

# /cks:research — Deep Multi-Hop Research

Load the skill from `.claude/skills/deep-research/SKILL.md` and follow it exactly.

## Quick Reference

Recursively researches a topic across configurable sources (Perplexity, Context7, Firecrawl, WebSearch, HuggingFace, aHref, Mintlify). Discovers sub-topics, cross-references, and produces structured intelligence reports.

```
/cks:research "Next.js App Router patterns"
/cks:research --competitive "AI code review tools"
/cks:research --eval "Supabase vs Firebase vs PlanetScale"
/cks:research "topic" --depth deep
/cks:research "topic" --refresh
```

## Modes

| Flag | Mode | Output |
|------|------|--------|
| (none) | Topic research | Report + sources |
| `--competitive` | Competitor analysis | Report + matrix + sources |
| `--eval` | Tech evaluation | Report + scored matrix + sources |
| `--depth` | Override default depth | shallow=1 hop, medium=2, deep=3+ |
| `--refresh` | Force re-research | Archives old report, runs fresh |

## Output

All reports saved to `.research/{slug}/` directory:
- `report.md` — Synthesized findings with confidence scores
- `sources.md` — All sources with citations
- `matrix.md` — Comparison matrix (competitive/eval modes)
- `raw/` — Raw query results for audit trail

## Configuration

Edit `.research/config.md` to customize sources, depth, and output settings.
Created automatically on first run with sensible defaults.

## vs /cks:context

| | /cks:context | /cks:research |
|---|---|---|
| **Purpose** | Quick coding reference | Strategic intelligence |
| **Depth** | Single-hop | Multi-hop recursive |
| **Output** | `.context/{slug}.md` | `.research/{slug}/report.md` |
| **Best for** | "How do I use this API?" | "Should we use this technology?" |
