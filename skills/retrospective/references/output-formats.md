# Retrospective Output Formats

## Output Structure

```
.learnings/
├── session-log.md          ← Append-only log of all retro entries (date-stamped)
├── conventions.md          ← Extracted conventions (candidates for CLAUDE.md)
├── gotchas.md              ← Project-specific pitfalls discovered
└── metrics.md              ← Velocity tracking (phases/session, retry rates)
```

## session-log.md Format

```markdown
# Session Log

Append-only record of retrospective entries.

---

## {date} — Phase {NN}: {name}

**Duration:** {time from first discuss to ship}
**Retries:** {count}
**Verification result:** {PASS|FAIL→PASS|FAIL}

### What Worked
- {pattern or approach that succeeded}

### Issues Encountered
- {problem}: {what happened} → {how it was resolved}

### Learnings
- **CONVENTION**: {rule extracted}
- **PATTERN**: {pattern identified}
- **GOTCHA**: {pitfall discovered}

### Deployment Health
- **Platform:** {vercel|railway|cloudflare|...}
- **Status:** {healthy|degraded|errors detected}
- **Errors in window:** {count} ({window} post-deploy)
- **Latency:** {normal|elevated|spike detected}
- **Notable logs:** {summary of any errors or warnings}

### LLM Observability (if applicable)
- **Trace errors:** {count}
- **P99 latency:** {value}
- **Token usage:** {total} ({cost estimate})
- **Anomalies:** {description or "none"}

### Files Most Changed
| File | Changes | Category |
|------|---------|----------|
| {path} | {count} | {iteration/bug/config} |

---
```

## conventions.md Format

```markdown
# Conventions

Extracted from retrospective analysis. Each convention is a candidate for CLAUDE.md.

## Applied
{Conventions already added to CLAUDE.md}

- [x] {Convention} — applied {date}

## Proposed
{Conventions waiting for review}

- [ ] {Convention} — proposed {date}, confidence: {HIGH|MEDIUM}
  - Source: Phase {NN} retro — {brief reason}
```

## gotchas.md Format

```markdown
# Gotchas

Project-specific pitfalls discovered during development.

## {Category}

### {Gotcha title}
- **Discovered:** Phase {NN} ({date})
- **What happened:** {description}
- **Fix:** {how to avoid}
- **Files affected:** {list}
```

## metrics.md Format

```markdown
# Velocity Metrics

## Summary
| Metric | Value | Trend |
|--------|-------|-------|
| Total phases | {N} | — |
| Avg duration | {time} | {up/down/stable} |
| Retry rate | {%} | {up/down/stable} |
| Ship success | {%} | {up/down/stable} |

## Per-Phase History
| Phase | Name | Duration | Retries | Verification | Deploy Health | Ship |
|-------|------|----------|---------|--------------|---------------|------|
| {NN} | {name} | {time} | {N} | {PASS/FAIL} | {healthy/degraded/errors} | {date} |
```
