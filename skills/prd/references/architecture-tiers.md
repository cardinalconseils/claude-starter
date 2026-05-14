# Architecture Tiers — System Scaling Reference

Maps revenue/traffic scale to infrastructure decisions.
Used by prd-discoverer (Element [1l]) and prd-designer (architecture diagrams).

## Tier 1 — Bootstrap (~$1 MRR)

**Goal:** Launch fast, validate idea. Cost beats everything.

- Single low-cost VM ($5–20/month)
- App server and database **co-located on the same host**
- No horizontal scaling, no redundancy
- No caching layer
- Manual monitoring (check logs when something breaks)

**Diagram:** Single box — app + DB inside one VM
**Upgrade trigger:** Users complaining of slowness, or $500+ MRR

---

## Tier 2 — Traction (~$1,000 MRR)

**Goal:** Reliability for paying users + actionable analytics.

- **Dedicated application server** (separate from DB)
- **Dedicated database server**
- Analytics: track user actions, conversion funnels
- Performance monitoring: latency alerts, uptime tracking
- Basic backup strategy (nightly snapshots)

**Diagram:** App server → DB server (two boxes), + monitoring sidecar
**Upgrade trigger:** DB becomes the bottleneck, or $10K+ MRR

---

## Tier 3 — Scale (~$100,000+ MRR)

**Goal:** Handle massive unpredictable traffic at sub-second latency.

- **Horizontally scalable app layer** — auto spin up/down behind load balancer
- **Database read replicas** — distribute query load
- **Database sharding** — distribute write load at extreme scale
- **Caching layer** (Redis/Memcached) — prevent DB overload for hot reads
- **Async background queues** — offload slow/resource-heavy ops from request path
- CDN for static assets
- Zero-downtime deployment pipeline

**Diagram:** Load balancer → app cluster → DB primary + replicas + cache + queue workers
**Upgrade trigger:** When you actually get there — don't over-engineer early

---

## Tier Selection Guide

| Maturity Stage | Target Tier |
|----------------|-------------|
| Prototype | Tier 1 |
| Pilot | Tier 2 |
| Candidate / Production | Tier 3 |
| "We'll figure it out later" | Tier 1 — explicit choice, not avoidance |

---

## Agent Usage Notes

**prd-discoverer:** Ask user to select tier during Element [1l]. Record selected tier and rationale in CONTEXT.md Section 12.

**prd-designer:** Read tier from CONTEXT.md Section 12 before generating architecture diagrams.
Generate tier-appropriate topology:
- Tier 1 → single-node diagram (one VM, co-located app + DB)
- Tier 2 → two-node diagram (app server, DB server) + monitoring layer annotation
- Tier 3 → full distributed diagram (load balancer, app cluster, DB primary/replicas, cache, queue workers)

Do NOT default to Tier 3 because it looks more impressive. Match what the user selected.
