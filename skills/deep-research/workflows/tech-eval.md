# Workflow: Technology Evaluation

## Overview

Specialized research mode for comparing technologies. Structures the research loop around
objective comparison: features, performance, ecosystem, learning curve, and long-term viability.
Produces a recommendation with clear justification.

## Prerequisites
- Config loaded, sources validated (from SKILL.md)
- Topic contains two or more technologies to compare (e.g., "Next.js vs Remix", "Supabase vs Firebase vs PlanetScale")

## Process

### Step 1: Parse Comparison

Extract from topic:
- **Technologies**: The options being compared (2-4 options)
- **Context**: What they'll be used for (if specified)
- **Constraints**: Any requirements mentioned (e.g., "for a startup", "with real-time needs")

If only one technology mentioned, reframe as "evaluate {tech}" and discover alternatives automatically.

Display:
```
Tech Evaluation: {tech A} vs {tech B} [vs {tech C}]
Context: {use case or "general comparison"}
Constraints: {list or "none specified"}
```

### Step 2: Establish Evaluation Criteria

Generate comparison dimensions based on the technology category:

**For frameworks/libraries:**
| Criterion | Weight | What to Measure |
|-----------|--------|-----------------|
| Features | 20% | Core capabilities, built-in functionality |
| Performance | 15% | Benchmarks, bundle size, runtime speed |
| DX (Developer Experience) | 20% | Learning curve, docs quality, error messages |
| Ecosystem | 15% | Packages, plugins, integrations |
| Community | 10% | GitHub stars, contributors, Stack Overflow activity |
| Stability | 10% | Breaking changes history, version cadence, LTS policy |
| Production Readiness | 10% | Companies using it, case studies, maturity |

**For databases/infrastructure:**
| Criterion | Weight | What to Measure |
|-----------|--------|-----------------|
| Performance | 20% | Read/write speed, latency, scalability benchmarks |
| Features | 20% | Query language, real-time, full-text search, extensions |
| Pricing | 15% | Free tier, scaling costs, egress fees |
| DX | 15% | Client libraries, migration tools, local dev story |
| Reliability | 15% | Uptime SLAs, data durability, backup/restore |
| Ecosystem | 15% | ORMs, admin tools, monitoring integrations |

**For SaaS/API services:**
| Criterion | Weight | What to Measure |
|-----------|--------|-----------------|
| Features | 25% | API capabilities, SDKs, webhooks |
| Pricing | 20% | Free tier, per-unit costs, enterprise pricing |
| Reliability | 15% | Uptime, rate limits, SLAs |
| DX | 15% | Documentation quality, SDK quality, support |
| Ecosystem | 15% | Integrations, marketplace, community tools |
| Lock-in Risk | 10% | Data portability, standard APIs, migration path |

### Step 3: Execute Research (Using Research Loop)

For each technology, generate targeted queries:

**Hop 1 — Overview and features:**
1. "{tech} features overview architecture 2024"
2. "{tech} documentation getting started"
3. "{tech} pricing plans comparison" (if applicable)

**Hop 2 — Deep comparison:**
4. "{tech A} vs {tech B} comparison benchmark 2024 2025"
5. "{tech A} limitations problems migration from"
6. "{tech B} limitations problems migration from"
7. "{tech A} production usage case studies"
8. "{tech B} production usage case studies"

**Hop 3 — Community and ecosystem (if depth allows):**
9. "{tech} ecosystem packages libraries plugins"
10. "{tech} GitHub stars contributors issues activity"
11. "{tech} breaking changes upgrade difficulty version history"

Use Context7 for library documentation (if the tech is a library/framework).
Use HuggingFace paper search if comparing ML tools.
Use aHref if comparing SaaS products (traffic, SEO presence as proxy for adoption).

### Step 4: Score Each Technology

For each criterion, assign a score (1-5) based on research findings:

```
Score 5: Best in class, clear leader
Score 4: Strong, minor gaps
Score 3: Adequate, meets expectations
Score 2: Weak, notable limitations
Score 1: Poor, significant concerns
```

Each score must have a justification citing specific findings.

Calculate weighted total:
```
Total = SUM(criterion_score * criterion_weight)
```

### Step 5: Generate Comparison Matrix

Write `.research/{slug}/matrix.md`:

```markdown
# Tech Evaluation — {Tech A} vs {Tech B} [vs {Tech C}]

> Generated: {date} | Context: {use case}

## Score Summary

| Criterion | Weight | {Tech A} | {Tech B} | {Tech C} |
|-----------|--------|----------|----------|----------|
| Features | 20% | 4 | 3 | 5 |
| Performance | 15% | 5 | 4 | 3 |
| DX | 20% | 3 | 5 | 4 |
| Ecosystem | 15% | 5 | 3 | 4 |
| Community | 10% | 5 | 4 | 3 |
| Stability | 10% | 4 | 3 | 4 |
| Production | 10% | 5 | 3 | 3 |
| **Weighted Total** | | **4.15** | **3.65** | **3.85** |

## Detailed Comparison

### Features
{Tech A}: {score}/5 — {justification with citations}
{Tech B}: {score}/5 — {justification with citations}

### Performance
{Tech A}: {score}/5 — {specific benchmarks and citations}
{Tech B}: {score}/5 — {specific benchmarks and citations}

### Developer Experience
{...}

{Continue for each criterion}

## Code Examples

### {Common Task} in {Tech A}
```{language}
// Example code
```

### {Same Task} in {Tech B}
```{language}
// Example code
```

## Migration Considerations

| From → To | Difficulty | Key Challenges |
|-----------|-----------|----------------|
| {Tech A} → {Tech B} | {Easy/Medium/Hard} | {list} |
| {Tech B} → {Tech A} | {Easy/Medium/Hard} | {list} |

## Decision Matrix by Use Case

| Use Case | Recommended | Why |
|----------|-------------|-----|
| {Use case 1} | {Tech A} | {reason} |
| {Use case 2} | {Tech B} | {reason} |
| {Use case 3} | {Tech A} | {reason} |
```

### Step 6: Synthesize Recommendation

Write the report.md with:

```markdown
## Recommendation

**For {user's context}: {Recommended Tech}** (score: {weighted_total}/5)

### Why {Recommended Tech}
{3-5 specific reasons based on the evaluation, citing criterion scores}

### When to Choose {Other Tech} Instead
{Scenarios where the other option(s) would be better}

### Risk Factors with {Recommended Tech}
{Honest assessment of the recommended option's weaknesses}

### Suggested Approach
{Concrete next steps — e.g., "Start with X, evaluate Y after 2 months if Z becomes a concern"}
```

### Step 7: Report Summary

```
Tech Evaluation: {Tech A} vs {Tech B}

  Winner: {Tech} ({score}/5 weighted)
  Runner-up: {Tech} ({score}/5)

  Key differentiators:
  - {Tech A}: Best at {criterion}
  - {Tech B}: Best at {criterion}

  Report: .research/{slug}/report.md
  Matrix: .research/{slug}/matrix.md
  Sources: .research/{slug}/sources.md

  Recommendation: {one-line summary}
```

## Integration with PRD Lifecycle

When invoked from the PRD discuss or plan phase:
- The recommended technology feeds into architecture decisions
- The matrix.md can be referenced in PRD documents
- Score justifications become rationale for technology choices
