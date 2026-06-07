---
name: operating-model
description: When the user wants to design how the business actually runs, prioritize initiatives, or build a phased execution plan. Use when PMC says "how do I actually run this", "what should I build first", "operating model for X", "prioritize my initiatives", "roadmap", "what's the phased plan", "how do I sequence this", "what's the 90-day plan", or "what do I cut to go faster."
allowed-tools: Read, Write, AskUserQuestion
---

# Operating Model & Execution

Module 04 of the McKinsey Strategy OS. Designs the machine behind the strategy — who does what, how decisions get made, and what ships first. For launch-specific roadmaps (Product Hunt, press, community), load `launch-strategy` skill instead.

## Operating Model Essentials

Four components every operating model must define:

**Decision rights** — Who decides what. Not who does the work — who makes the call when there's a conflict. Undefined decision rights produce committees, delays, and reversions to the loudest voice.

**Core loop** — The repeating activity that creates value. For a SaaS: acquire → activate → retain → expand. For a marketplace: supply acquisition → demand acquisition → transaction facilitation → repeat. If you can't describe your core loop in one sentence, you haven't designed an operating model — you've built an org chart.

**Resource allocation rhythm** — How often you reallocate resources (people, budget, attention) across initiatives. Weekly for early-stage. Quarterly for scaled teams. If you only reallocate annually, you're a bureaucracy.

**Performance cadence** — How often you check the scoreboard and make corrections. Daily for metrics that can move daily (conversion, churn signals). Weekly for operational health. Monthly for strategic indicators.

## Initiative Prioritization

Use the impact × feasibility matrix. Two axes, four quadrants:

- **High impact, high feasibility** → Do first. These are your immediate priorities.
- **High impact, low feasibility** → Plan carefully. These require investment but are worth it.
- **Low impact, high feasibility** → Delegate or deprioritize. Easy wins that distract from the hard ones.
- **Low impact, low feasibility** → Kill. These are the initiatives that consume energy without return.

Do NOT use effort as the primary axis. Effort is a function of your current capabilities — it changes. Impact doesn't.

**The primary question is:** "What unlocks everything else?" Not "what's easiest?" The initiative that unblocks three others ranks above three standalone quick wins.

**Top 3 rule:** If you have more than 3 priorities, you have no priorities. Everything marked "critical" means nothing is critical. Force-rank to 3 and defend the ranking.

## Phase 1 Principle

Phase 1 must be the minimum that proves the model, not the minimum viable feature.

The right Phase 1 question: "What decision does Phase 1 make possible?"

Phase 1 is not about impressing anyone. It is about creating a decision point. After Phase 1, you should be able to say: "We learned X. That means we do Y next." If Phase 1 doesn't produce a clear next decision, it was either too small or pointed at the wrong question.

Fast and small beats big and slow. A Phase 1 that runs 90 days is a Phase 1 that delayed the learning by 90 days.

## Kill Criteria

Every initiative needs a kill signal defined before launch. Not after the team is attached to it.

A kill signal is:
- A specific metric (not "it's not working")
- A specific threshold ("below X")
- A specific time window ("by day 30")

Example: "If we do not have 3 customers willing to pay $200/month by day 60, we do not build Phase 2."

Kill criteria are not defeatism. They are respect for your own resources. Building kill criteria up front is the act of saying: "We are running an experiment, not starting a religion."

## Cross-Reference

For launch-specific sequencing — Product Hunt launch timing, press embargo strategy, community seeding — load `launch-strategy` skill. This skill handles how the business runs; `launch-strategy` handles the market entry moment.

## Output Structure

Every operating model analysis delivers:

1. **Operating model** — one paragraph: who decides what, what the core loop is, how often you reallocate and review
2. **Top 3 initiatives** — ranked by impact × feasibility; each with an owner and a time horizon
3. **Phase 1 (0-30 days)** — what ships or is decided; framed as a decision, not a deliverable
4. **Phase 2 (30-90 days)** — what gets built once Phase 1 validates; framed as a hypothesis, not a commitment
5. **Kill criteria** — the specific metric + threshold that stops Phase 2 before it starts

## Quality Bar

- [ ] Operating model paragraph names who decides (not just who does)
- [ ] Initiatives are ranked, not listed (rank 1 vs rank 3 is an explicit call)
- [ ] Phase 1 output is a decision, not just a deliverable
- [ ] Kill criteria is a specific metric + threshold, not "if it's not working"

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "We can't prioritize to 3 — everything is critical" | That belief is the primary operating model problem. The inability to prioritize is the constraint this module exists to fix. |
| "Phase 1 is too small to be meaningful" | Phase 1's job is to produce a decision, not to impress. Small and fast is correct. |
| "Kill criteria feels defeatist" | Kill criteria are respect for your own resources. Build them before you're attached to the work, or you'll never trigger them. |
| "The roadmap will change, so why plan past Phase 1?" | Phase 2 is a hypothesis, not a commitment. You need it to know what Phase 1 is validating. Without Phase 2 as a hypothesis, Phase 1 has no success criteria. |
