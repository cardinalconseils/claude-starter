---
name: performance
description: >
  Performance optimization and Core Web Vitals for production applications.
  Use when: optimizing page load, measuring Core Web Vitals, reducing bundle size,
  fixing N+1 queries, optimizing images, adding caching, running Lighthouse audits,
  or when users report slowness.
allowed-tools: Read, Grep, Glob, Bash
---

# Performance

## Overview

Performance optimization follows one rule: measure first, optimize second. Never optimize based on intuition. Profile, identify the bottleneck, fix it, measure again. Premature optimization wastes time; late optimization costs users.

## When to Use

- Page load is slow or Lighthouse scores are low
- Core Web Vitals are failing (LCP, INP, CLS)
- Bundle size is growing unchecked
- Database queries are slow or N+1 patterns detected
- Users report sluggishness or timeouts
- Preparing for production launch

## When NOT to Use

- Prototype stage where speed-to-market matters more
- Optimizing code that runs once during setup
- Micro-optimizing hot paths without profiling evidence

## Process

### 1. Measure Current State

Run Lighthouse, check Core Web Vitals, analyze bundle size, enable query logging. Establish baselines before changing anything.

### 2. Core Web Vitals Targets

| Metric | Good | Needs Improvement | Poor |
|---|---|---|---|
| LCP (Largest Contentful Paint) | < 2.5s | 2.5s - 4.0s | > 4.0s |
| INP (Interaction to Next Paint) | < 200ms | 200ms - 500ms | > 500ms |
| CLS (Cumulative Layout Shift) | < 0.1 | 0.1 - 0.25 | > 0.25 |

### 3. Common Optimization Areas

**Bundle Size** — Identify large dependencies with bundle analyzer. Apply code splitting for routes, tree shaking for unused exports, dynamic imports for heavy components. Target < 200KB initial JS.

**Images** — Use WebP/AVIF formats, responsive images with srcset, lazy loading below the fold, explicit width/height to prevent CLS. Images are typically the largest payload.

**N+1 Queries** — Enable query logging and count queries per page load. Use ORM eager loading, batch queries, or the dataloader pattern. One page load should not generate dozens of queries.

**Caching** — CDN for static assets with long cache headers, browser cache with content hashing, API response caching with stale-while-revalidate, Redis/Memcached for expensive computations.

**Database** — Run EXPLAIN on slow queries, add indexes for frequent WHERE/JOIN columns, avoid SELECT * (fetch only needed columns), paginate all list endpoints.

### 4. Lighthouse Audit Interpretation

Focus on opportunities sorted by estimated savings. Fix the largest impact items first. Do not chase a perfect 100 score — diminishing returns set in fast.

### 5. Verify Improvements

Re-run the same measurements after each optimization. If the metric did not improve, revert. Optimization that does not move the needle is complexity for nothing.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Performance doesn't matter yet" | Users leave after 3 seconds. Rewriting for performance later costs 10x. |
| "It's fast on my machine" | Your machine has fast internet and SSD. Test on throttled connections. |
| "We'll optimize when we scale" | N+1 queries at 100 users become timeouts at 1000. Fix the pattern now. |
| "The framework handles performance" | Frameworks provide tools, not guarantees. You still need to measure. |
| "Users have fast connections now" | 40% of global web traffic is on 3G or slower. |

## Red Flags

- Optimizing without measuring first
- No bundle analysis ever run
- Images served as uncompressed PNG at original resolution
- Database queries with no indexes on filtered columns
- No caching strategy for static assets
- Lighthouse never run or scores ignored
- Optimizing code paths that profiling shows are not bottlenecks

## Verification

- [ ] Baseline measurements taken before any optimization
- [ ] Core Web Vitals meet targets (LCP < 2.5s, INP < 200ms, CLS < 0.1)
- [ ] Bundle size analyzed and large dependencies addressed
- [ ] Images optimized (format, sizing, lazy loading)
- [ ] No N+1 query patterns in critical paths
- [ ] Caching strategy defined for static and dynamic content
- [ ] Improvements verified with post-optimization measurements
