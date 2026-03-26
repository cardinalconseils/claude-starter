# Performance Testing Reference

## When to Test Performance

| Lifecycle Phase | What to Test | Tool |
|----------------|-------------|------|
| Sprint [3e] QA | Component render time, API response time | Unit benchmarks |
| Release [5b] Staging | Page load, Core Web Vitals | Lighthouse |
| Release [5c] RC | Load testing, stress testing | k6, Artillery |
| Release [5d] Post-prod | Real user monitoring | Analytics, dashboards |

## Core Web Vitals Targets

| Metric | Good | Needs Work | Poor |
|--------|------|------------|------|
| **LCP** (Largest Contentful Paint) | ≤ 2.5s | ≤ 4.0s | > 4.0s |
| **INP** (Interaction to Next Paint) | ≤ 200ms | ≤ 500ms | > 500ms |
| **CLS** (Cumulative Layout Shift) | ≤ 0.1 | ≤ 0.25 | > 0.25 |
| **FCP** (First Contentful Paint) | ≤ 1.8s | ≤ 3.0s | > 3.0s |
| **TTFB** (Time to First Byte) | ≤ 800ms | ≤ 1800ms | > 1800ms |

## Lighthouse Audit (Browser-Based)

Run via Chrome DevTools MCP:
```
Skill(skill="browse", args="Navigate to {url}. Run Lighthouse audit. Report scores for Performance, Accessibility, Best Practices, SEO.")
```

Or CLI:
```bash
npx lighthouse {url} --output json --output html --output-path ./reports/lighthouse
```

### Lighthouse Score Targets

| Category | Minimum | Target |
|----------|---------|--------|
| Performance | 70 | 90+ |
| Accessibility | 80 | 95+ |
| Best Practices | 80 | 90+ |
| SEO | 80 | 90+ |

## API Performance Testing

### Response Time Benchmarks

| Endpoint Type | p50 | p95 | p99 |
|--------------|-----|-----|-----|
| Simple read (GET list) | < 100ms | < 300ms | < 500ms |
| Complex read (GET with joins) | < 200ms | < 500ms | < 1000ms |
| Write (POST/PUT) | < 200ms | < 500ms | < 1000ms |
| Search/filter | < 300ms | < 800ms | < 1500ms |
| File upload | < 1000ms | < 3000ms | < 5000ms |

### Quick API Benchmark

```bash
# Simple response time check
for i in {1..10}; do
  curl -o /dev/null -s -w "%{time_total}\n" {api_url}
done | awk '{sum+=$1} END {print "avg:", sum/NR, "s"}'
```

### Load Testing with k6

```javascript
// k6-test.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '30s', target: 10 },   // Ramp up
    { duration: '1m', target: 50 },     // Sustained load
    { duration: '30s', target: 0 },     // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],   // 95% under 500ms
    http_req_failed: ['rate<0.01'],     // <1% errors
  },
};

export default function () {
  const res = http.get('{api_url}');
  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
  sleep(1);
}
```

```bash
k6 run k6-test.js
```

## Frontend Performance

### Bundle Size Limits

| Asset | Max Size (gzipped) |
|-------|--------------------|
| Main JS bundle | < 200KB |
| Main CSS | < 50KB |
| Individual route chunk | < 100KB |
| Total initial load | < 500KB |
| Images (each) | < 200KB |

### Check Bundle Size

```bash
# Next.js
npx next build && npx @next/bundle-analyzer

# Vite
npx vite build --report

# General
npx bundlephobia {package-name}
```

### Image Optimization Checklist

- [ ] Use modern formats (WebP, AVIF)
- [ ] Responsive images with srcset
- [ ] Lazy load below-fold images
- [ ] Proper width/height to prevent CLS
- [ ] CDN for static assets

## Database Performance

### Query Performance

| Query Type | Target |
|-----------|--------|
| Simple SELECT by ID | < 5ms |
| Indexed SELECT | < 20ms |
| JOIN query (2-3 tables) | < 50ms |
| Aggregation | < 100ms |
| Full-text search | < 200ms |

### Common Issues

| Issue | Detection | Fix |
|-------|-----------|-----|
| N+1 queries | Multiple identical queries in logs | Use includes/joins |
| Missing index | EXPLAIN shows seq scan | Add index on filtered columns |
| Over-fetching | SELECT * on large tables | Select specific columns |
| No pagination | Queries return 1000+ rows | Add LIMIT/OFFSET or cursor |

## Integration with Release Phase

### Release [5c] RC Gate — Performance Check

```
AskUserQuestion({
  questions: [{
    question: "Performance check results:",
    header: "Performance Gate",
    multiSelect: false,
    options: [
      { label: "All targets met", description: "Lighthouse: {score}, API p95: {ms}ms, Bundle: {size}KB" },
      { label: "Minor misses — proceed", description: "Some targets missed but acceptable" },
      { label: "Performance issues — block", description: "Critical performance regression detected" }
    ]
  }]
})
```
