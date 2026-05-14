---
name: caching
description: >
  Caching strategy selection and implementation for production applications.
  Use when: choosing between write-through and write-behind cache, adding Redis
  or Memcached, reducing write or read latency, designing cache invalidation,
  implementing read-through or cache-aside patterns, or evaluating data loss
  vs latency trade-offs.
allowed-tools: Read, Grep, Glob, Bash
---

# Caching

## Overview

Caching reduces latency by storing data closer to where it's read or written. Before adding a cache, profile first — caching a slow query hides the problem rather than fixing it. Use caching when the bottleneck is confirmed and the trade-offs are understood.

## When to Use

- Write requests are slow due to database write latency
- Read requests repeatedly fetch the same expensive data
- Database cannot handle the read/write throughput required
- Expensive computations (ML inference, aggregation queries) are called frequently

## When NOT to Use

- Prototype stage where complexity outweighs the benefit
- Data that must never be stale (financial balances, inventory counts)
- Unique per-user writes with no shared read patterns
- Before profiling confirms the cache will actually hit

## Strategies

### Write-Through Cache

The server writes to both the cache and the database simultaneously. It waits for both to confirm before responding to the user.

- **Latency**: Higher — user waits for the slower DB write
- **Consistency**: Strong — cache and DB are always in sync
- **Data loss risk**: None — both stores are updated before the response
- **Best for**: Financial transactions, inventory, any data where loss is unacceptable

### Write-Behind Cache (Write-Back)

The server writes only to the cache and responds immediately. The cache flushes data to the database asynchronously at a later time.

- **Latency**: Lowest — user only waits for the cache write
- **Consistency**: Eventual — DB may lag behind cache by seconds or minutes
- **Data loss risk**: Real — if the cache fails before the flush, writes are lost
- **Best for**: High-volume writes where occasional loss is acceptable (analytics events, social activity feeds, view counts)

### Read-Through Cache

The application always reads from the cache. On a cache miss, the cache layer fetches from the database, populates itself, and returns the result.

- **Latency**: Low after warm-up, cold-start penalty on first access
- **Consistency**: Depends on TTL — stale data until TTL expires or invalidation fires
- **Best for**: Read-heavy workloads with infrequent updates (product catalogs, configuration)

### Cache-Aside (Lazy Loading)

The application checks the cache first. On a miss, it reads from the database and writes the result to the cache manually before returning.

- **Latency**: Low after warm-up, miss penalty on first access
- **Consistency**: Application controls invalidation explicitly
- **Best for**: When the application needs fine-grained control over what is cached and for how long

## Strategy Comparison

| Strategy | Write Latency | Read Latency | Data Loss Risk | Consistency | Complexity |
|---|---|---|---|---|---|
| Write-Through | High | Low | None | Strong | Low |
| Write-Behind | Lowest | Low | Real (cache failure) | Eventual | Medium |
| Read-Through | N/A | Low (warm) | N/A | TTL-based | Low |
| Cache-Aside | N/A | Low (warm) | N/A | App-controlled | Medium |

## When to Choose Each

| Requirement | Recommended Strategy |
|---|---|
| Financial data, no data loss tolerance | Write-Through |
| High-volume writes, loss of a few events is acceptable | Write-Behind |
| Read-heavy, data changes infrequently | Read-Through or Cache-Aside |
| Need explicit control over cache population | Cache-Aside |
| Simple setup with minimal application logic | Read-Through |

## Implementation Patterns

**TTL discipline** — Every cache entry must have a TTL. No TTL means stale data accumulates indefinitely. Set TTL based on how frequently the underlying data changes.

**Cache stampede prevention** — When a popular key expires, many requests hit the DB simultaneously. Mitigate with: probabilistic early expiration, mutex locks on miss, or background refresh before expiry.

**Hot key avoidance** — A single key receiving millions of requests per second overwhelms one cache node. Shard hot keys with a suffix (e.g., `user:123:1`, `user:123:2`) and fan out reads.

**Cache warming** — On startup, pre-populate frequently accessed keys before serving traffic to avoid a cold-start latency spike.

**Graceful degradation** — If the cache is unavailable, fall through to the database rather than returning an error. Log the cache miss rate; sustained high miss rates indicate a problem.

**Write-behind flush discipline** — Flush to DB on a schedule AND on cache eviction. Never rely solely on TTL-triggered flushing or data will be lost on cache restart.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "A cache will fix our slow queries" | Caching hides slow queries. Fix the query first; cache if throughput still requires it. |
| "Write-behind is fine, we rarely lose data" | "Rarely" becomes "definitely" during the outage you didn't predict. Quantify the acceptable loss before choosing write-behind. |
| "We'll add cache invalidation later" | Stale data bugs are the hardest to debug. Design invalidation before deploying the cache. |
| "Redis is always fast enough" | A single Redis node is a single point of failure. Plan for Redis unavailability from day one. |
| "We don't need TTLs for this data" | Without TTLs, caches become stale indefinitely. Every key needs a TTL or an explicit invalidation trigger. |

## Red Flags

- Write-behind cache with no flush-on-eviction logic
- Cache with no TTL on any key
- No fallback if the cache is unavailable
- Cache used as a primary store (no durable database backing it)
- No monitoring on cache hit rate (a dropping hit rate means the cache is not helping)
- Cache invalidation handled only at the application layer with no DB-level triggers

## Verification

- [ ] Caching strategy selected based on data loss tolerance, not convenience
- [ ] Every cache key has a TTL
- [ ] Write-behind: flush-on-eviction configured, not just flush-on-schedule
- [ ] Cache miss fallback path tested (what happens when Redis is down?)
- [ ] Cache stampede scenario considered for high-traffic keys
- [ ] Cache hit rate monitored (alert if drops below expected threshold)
- [ ] Stale data scenario tested: update DB directly, confirm cache reflects change within TTL
