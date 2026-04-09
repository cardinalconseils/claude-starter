---
description: "Deep multi-hop research on any topic — recursive investigation with configurable sources"
argument-hint: '"topic" [--depth shallow|medium|deep] [--competitive] [--eval] [--refresh]'
allowed-tools:
  - Read
  - Agent
---

# /cks:research — Deep Multi-Hop Research

Dispatch the **deep-researcher** agent (which has `skills: deep-research` loaded at startup).

## Dispatch

```
Agent(subagent_type="cks:deep-researcher", prompt="Research topic: $ARGUMENTS. Recursively investigate across available sources. Discover sub-topics, cross-reference findings, and produce a structured report with confidence scores. Save output to .research/{topic-slug}/. Arguments: $ARGUMENTS")
```

## Quick Reference

```
/cks:research "Next.js App Router patterns"
/cks:research --competitive "AI code review tools"
/cks:research --eval "Supabase vs Firebase vs PlanetScale"
/cks:research "topic" --depth deep
/cks:research "topic" --refresh
```

| Flag | Mode | Output |
|------|------|--------|
| (none) | Topic research | Report + sources |
| `--competitive` | Competitor analysis | Report + matrix |
| `--eval` | Tech evaluation | Scored matrix |
| `--depth` | Override depth | shallow=1 hop, medium=2, deep=3+ |
| `--refresh` | Force re-research | Archives old, runs fresh |

## vs /cks:context

| | /cks:context | /cks:research |
|---|---|---|
| **Purpose** | Quick coding reference | Strategic intelligence |
| **Depth** | Single-hop | Multi-hop recursive |
| **Output** | `.context/{slug}.md` | `.research/{slug}/report.md` |
