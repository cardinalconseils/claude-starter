# Workflow: Scale Advice — one next rung, and what not to do yet

Place the project on the 7-rung scaling ladder (`skills/scale-ladder/SKILL.md`) and
recommend exactly one next move. Decision layer, not implementation.

## 1. Maturity stage

Read in order, stop at the first hit: `PROJECT.md` (`maturity:` or a stage keyword) →
`.prd/PRD-STATE.md` → `AskUserQuestion` "What stage is your project at?" (Prototype /
Pilot / Candidate / Production).

## 2. Current rung

From `ARCHITECTURE.md`: DB co-located vs separate → rung 1 or 2; monitoring/logging →
rung 3; load balancer / multiple app servers → 4; CDN or cache layer → 5; queue / async
workers → 6; read replicas → 7.

Absent or ambiguous → three `AskUserQuestion` calls, one at a time:
1. "Where is your database running?" — same server as app · dedicated DB (Supabase, RDS…) · not sure
2. "What's your current traffic pattern?" — under 1K req/day, stable · growing fast,
   slowness starting · one endpoint is the bottleneck · don't know
3. "What's your biggest pain right now?" — nothing, being proactive · slow pages or
   queries · memory/CPU pressure · jobs or emails too slow

## 3. Next rung

Ceilings: Prototype 2 · Pilot 3 · Candidate 6 · Production 7.
`next = min(current + 1, ceiling)`. At the ceiling: "You've scaled as far as {stage}
warrants. When you promote to {next stage}, the next rung is {N+1}."

## 4. Output (mandatory shape)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 SCALING ADVISOR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Current stage:  {stage}
 Current rung:   {N} — {description}
 Next move:      Rung {N+1} — {one sentence}

 Why now:        {one sentence}
 Not yet:        {what not to do and why — one sentence}
 How to do it:   Run /cks:{skill or command}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

"How to do it" names an existing CKS skill or command — never inline implementation.

## 5. Optional ADR

`AskUserQuestion` "Save this recommendation as an Architecture Decision Record?" Yes →
`.decisions/ADR-scale-rung-{N+1}.md` with recommendation, rationale, and the "not yet"
guardrail, in the `templates/adr.md` format.

## Constraints

One recommendation — never a list or a roadmap. Never duplicate caching, monitoring,
observability, or performance content inline; delegate to those skills.
