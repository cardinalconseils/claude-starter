---
name: prompt-caching
description: >
  Claude API prompt caching via cache_control: {type: "ephemeral"} — reduces
  input token costs by 90% on cached prefixes. Use when: reducing API costs,
  prompt caching, cache_control, token savings, multi-turn Claude API app,
  stable system prompt with repeated tool definitions, Anthropic SDK caching,
  cache_read_input_tokens, ephemeral cache, pre-warming cache, agentic loop
  caching. NOT for Redis/Memcached or application-level caching.
allowed-tools: Read, Grep, Glob, Bash
---

# Prompt Caching (Claude API)

Prompt caching uses `cache_control: {type: "ephemeral"}` to cache stable
prefix content at Anthropic's API layer. Subsequent calls that share the same
prefix pay 10% of the base input token price instead of 100%.

This is NOT Redis, Memcached, or application-level caching. For those, see
`skills/caching/SKILL.md`.

---

## When to Use

- Multi-turn products with a stable system prompt and/or tool definitions
- Agentic loops where the same tools + instructions repeat across many calls
- RAG pipelines where a large document chunk is prepended to every request
- Any app where the API call log shows high input tokens per request and low
  `cache_read_input_tokens`

**Trigger keywords:** "reduce API costs", "prompt caching", "cache_control",
"token savings", multi-turn Claude API app, `cache_read_input_tokens` is 0.

## When NOT to Use

- Single-turn calls with no shared prefix across requests
- System prompt under the model minimum: 2048 tokens (Sonnet 4.6) / 4096
  tokens (Opus models) — caching has no effect below these thresholds
- Tool list that varies per user, role, or feature flag — variable tools
  cannot form a stable cache key
- Non-Anthropic providers that do not pass `cache_control` through (OpenAI
  uses automatic caching; Anthropic syntax is silently ignored or errors)

---

## The MARK-ORDER-VERIFY Framework

### 1. MARK
Add `cache_control: {type: "ephemeral"}` to the **last content block of each
stable section** — not every block, just the final one in the stable prefix.

### 2. ORDER
The API processes payload sections in this order:
```
tools definitions → system prompt → messages[0..N-1] → [new user message]
```
Stable content must appear **before** volatile content or the cache prefix
is broken. Never inject dynamic values (timestamps, UUIDs, per-user data)
before a cache breakpoint.

### 3. VERIFY
Log `usage.cache_read_input_tokens` on every response. From the second call
onward, this value should be greater than zero. A persistently zero value
means a silent invalidator is breaking the prefix (see below).

---

## Breakpoint Placement

| Section | Where to mark | Stable? |
|---|---|---|
| `tools` array | After the last tool definition | Most stable — cache first |
| `system` prompt | At the end of the static body | Stable if no dynamic injection |
| `messages[0..N-1]` | After the last shared/stable message | Stable up to conversation context |
| New user message | No mark — always the dynamic tail | Never cache |

Mark each section independently. A cache hit on `tools` does not require a
hit on `system` — they are separate breakpoints.

---

## Cost Economics

| Scenario | Token cost multiplier |
|---|---|
| Normal input (no cache) | 1.0x base price |
| Cache write (first call) | 1.25x base price for cached portion |
| Cache read (subsequent calls) | 0.1x (10%) base price for cached portion |

**Break-even:** 2 calls sharing the same prefix. The write premium is recovered
on the first read.

**Typical savings:** 35–45% of total input bill for multi-turn sessions.

**Example (Sonnet 4.6):**
- 6000 cacheable tokens, 10-turn session
- Without caching: 60,000 input tokens billed at full rate
- With caching: 7,500 write tokens at 1.25x + 52,500 read tokens at 0.1x
- Cost reduction: ~78% on the cached portion → ~45% of total session cost

---

## Silent Invalidators

These look stable but will break the cache prefix, causing every call to
incur a write penalty with no reads.

| Invalidator | Why it breaks caching |
|---|---|
| `new Date()` / `datetime.now()` before a breakpoint | Generates a new value on every call |
| Per-request or per-user UUIDs in system prompt | Content differs per call |
| Tool definitions that vary by feature flag or user role | No stable prefix |
| Non-deterministic JSON key ordering in tool schemas | Hash differs |
| Toggling `thinking` on/off between requests | Invalidates messages cache |
| Model changes between calls | Full invalidation — cache is model-scoped |
| Whitespace or formatting changes in the system prompt | Content mismatch |

**Audit rule:** If `cache_read_input_tokens` is 0 after the second call,
treat it as a bug. Bisect by removing content blocks before the breakpoint
until caching resumes.

---

## Pre-Warming Pattern

Fire a `max_tokens: 1` call on session initialization to write the cache
before the first real user request. This absorbs the write penalty invisibly
so users never experience slower first-call latency.

Pre-warm conditions:
- System prompt + tools exceed the model minimum threshold
- Session is expected to last more than one turn
- The cost of a 1-token write call is acceptable (it is — it's one call)

---

## TTL and Invalidation

| TTL mode | Duration | Write cost | Best for |
|---|---|---|---|
| Default | 5 minutes | 1.25x | Standard multi-turn sessions |
| Extended | 1 hour | 2.5x | Infrequent callers, heavy prefixes |

TTL resets on every cache **read**. There is no explicit invalidation API —
only TTL expiry or content change. Choose extended TTL when the interval
between calls exceeds 5 minutes but the prefix is large enough to justify
the 2x write premium.

---

## 20-Block Lookback Limit (Agentic Loops)

In agentic loops with many `tool_use` / `tool_result` pairs, the API walks
back at most **20 content blocks** to find a prior cache entry. If a loop
runs more than ~10 tool calls, the cache breakpoint marked early in the
conversation history falls outside the lookback window.

Mitigation: re-mark a breakpoint closer to the end of stable history on
each turn when the loop exceeds 10 tool calls. The new breakpoint refreshes
the TTL and stays within the 20-block window.

---

## Provider Portability

| Provider | Behavior |
|---|---|
| Anthropic direct | Full support — use `cache_control` |
| OpenRouter → Anthropic | Passes `cache_control` through — works |
| OpenAI | Automatic caching — no markers needed; Anthropic syntax errors or is silently ignored |
| Other providers | Check docs — assume unsupported unless confirmed |

**Pattern:** Keep `cache_control` injection at the API client layer, wrapped
in a provider check. Do not embed it deep in prompt construction where it
cannot be toggled per provider.

```
// Conceptual — inject at client layer, not prompt layer
if (provider === "anthropic") {
  addCacheBreakpoint(payload, "tools")
  addCacheBreakpoint(payload, "system")
}
```

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Our system prompt is short, caching won't help" | Check the token count. Under 2048 (Sonnet) / 4096 (Opus) it does nothing; over threshold it cuts costs 90% per read. Measure first. |
| "We only make one call at a time" | Cache reads pay off from the second call. Multi-turn products get this for free — wire it during build, not retrofit. |
| "Adding cache_control markers is risky" | Markers are additive metadata. A missed cache hit wastes money; an incorrect marker has no effect on output. |
| "The model will figure out caching automatically" | Only OpenAI does automatic caching. Anthropic requires explicit markers — nothing happens without `cache_control`. |
| "Our tools change based on user role" | That's the one case where caching breaks. Gate it: cache only the stable base tool set, inject role-specific tools after the breakpoint. |
| "Cache_read_input_tokens is 0 but I think it's working" | Zero means it is not working. A silent invalidator is present. Bisect until the hit appears. |
| "We'll add caching in a future optimization sprint" | Input token costs compound with usage. Wire the markers now — retrofitting to a large codebase is harder than doing it at build time. |

---

## Verification

Before declaring prompt caching implemented:

- [ ] `cache_read_input_tokens > 0` logged from the second call onward
- [ ] System prompt audited for silent invalidators (no dynamic values before breakpoints)
- [ ] Token count of stable prefix confirmed to exceed model minimum threshold
- [ ] Pre-warm call fires on session initialization (if multi-turn product)
- [ ] Provider check wraps `cache_control` injection (if app targets multiple providers)
- [ ] TTL mode chosen intentionally: 5-min default or 1-hour extended based on call frequency
- [ ] Agentic loops re-mark breakpoints if loop depth exceeds 10 tool calls
- [ ] Cache write cost (1.25x) accounted for in cost projections — not just the read savings
