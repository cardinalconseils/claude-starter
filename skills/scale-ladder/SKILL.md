---
name: scale-ladder
description: >
  Progressive scaling decision tree for CKS projects. Encodes the 7-rung scaling
  ladder with maturity-gate sequencing and "not yet" guardrails. Delegates to
  monitoring, caching, performance, observability, and architecture skills — never
  duplicates their content. Loaded by cks:scale-advisor.
allowed-tools: Read, Glob
---

# Scale Ladder

A progressive scaling reference for CKS projects. The decision layer — not the implementation layer. For implementation details, delegate to the skill named in each rung's "Delegate to" column.

## The 7-Rung Ladder

| Rung | What | Earliest Maturity | Delegate to |
|------|------|------------------|-------------|
| 1 | Single VM + co-located DB | Prototype | — |
| 2 | Split DB to dedicated server | Prototype → Pilot | architecture skill |
| 3 | Logging + monitoring + product analytics | Pilot | monitoring skill |
| 4 | Horizontal scaling + load balancer | Candidate | — |
| 5 | CDN + multi-layer caching | Candidate | caching skill, performance skill |
| 6 | Async queue + background workers | Candidate | — |
| 7 | DB read replicas | Production | observability skill |

## When to Use

- User runs `/cks:scale` on a project
- Project has just promoted to a new maturity stage and user asks "what should I scale next?"
- Architecture review surfaces a pain point (memory pressure, slow queries, API timeouts)

## When NOT to Use

- Prototype stage: stop at rung 2 or 3. Do not pre-optimize.
- The user is mid-sprint on a feature: scaling decisions belong at phase boundaries, not mid-build

## Maturity → Rung Mapping

This is the sequencing rule. The advisor MUST NOT recommend a rung above the ceiling for the current maturity stage.

| Maturity | Maximum Rung | Do NOT Recommend |
|----------|-------------|------------------|
| Prototype | 2 | Rungs 3–7 |
| Pilot | 3 | Rungs 4–7 |
| Candidate | 6 | Rung 7 |
| Production | 7 | — |

## Identifying Current Rung

Read ARCHITECTURE.md or ask these 3 questions via AskUserQuestion:

1. **Database setup**: Same server as app? Separate dedicated DB? Managed DB service?
2. **Traffic pattern**: Under 1K req/day? Growing fast? Seeing latency spikes? Specific endpoint bottleneck?
3. **Known pain point**: Memory? Slow queries? API timeouts? Async jobs taking too long?

Map answers → rung using the ladder table. When in doubt, assume the lower rung.

## The "Not Yet" Guardrail

This is the primary value of this skill. For each recommendation, the advisor MUST explicitly state what NOT to do yet and WHY.

Examples:
- "You're Pilot. Do NOT add read replicas yet — your query load doesn't justify the replication lag tradeoff."
- "You're Candidate. Do NOT shard your database yet — add read replicas first. Sharding before replicas is premature."
- "You're Prototype. Do NOT add a load balancer yet — first ensure your DB is on a separate server."

## One Recommendation Rule

The advisor gives ONE next rung. Not a roadmap. Not "here are 3 things to consider."

Why: Non-developers get overwhelmed by options. One clear next step with a "not yet" guardrail is more actionable than a complete plan.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "They're growing fast, recommend rungs 4+5+6" | One rung. The user cannot absorb a scaling roadmap mid-crisis. |
| "I'll explain caching inline since it's relevant" | Delegate to the caching skill. Don't duplicate. |
| "They're Pilot but they asked about Kubernetes" | The guardrail holds. Tell them why Kubernetes is premature at Pilot. |
| "The current rung is ambiguous, I'll recommend two" | Assume the lower rung. One recommendation. |

## Verification

- [ ] Advisor output names exactly ONE rung
- [ ] Output explicitly states what NOT to do yet
- [ ] Output references an existing CKS skill for implementation detail (not inline instructions)
- [ ] Recommendation respects the maturity ceiling table
- [ ] No monitoring/caching/observability content duplicated inline
