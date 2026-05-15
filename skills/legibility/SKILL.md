---
name: legibility
description: "PMC Legibility Framework — every idea has a legible face (pitch/deck) and an illegible face (truth: gut, relationships, timing, tacit knowledge). Explore Mode gates sprint eligibility. Commit Mode catches plan-vs-reality gaps before building. Use when evaluating new ideas or reviewing active sprints."
allowed-tools:
  - Read
  - AskUserQuestion
---

# Legibility Framework

## The Concept

Every idea has two faces:

- **Legible face** — the pitch, the deck, the clean explanation. What you can say out loud. What looks good in a document.
- **Illegible face** — the truth: gut instinct, relationships, timing, tacit knowledge, unwritten rules. What gets destroyed when systems force reality into neat boxes.

James C. Scott's concept of *mētis* — local, contextual knowledge that cannot be captured in top-down plans — is the illegible side made explicit. The illegible face is not vague by nature. It is vague because we choose not to look at it.

**PMC pattern:** 10 half-finished projects = strong legible side, blank illegible side. The pitch was clear; the reality was not.

---

## Explore Mode

**Use when:** Idea is forming. Nothing committed. Deciding whether to sprint.

**Goal:** Decide if this idea earns a 7-day sprint slot.

**Time budget:** 20 minutes max.

### The 5 Buckets

| # | Bucket | Legible Side | Illegible Side |
|---|--------|-------------|----------------|
| 1 | The Problem | "Pain in one sentence?" | "Who feels it at 4pm Tuesday, what do they do right now instead?" |
| 2 | The Buyer | "Segment, size, budget?" | "Who in the org actually decides? Unwritten incentive? What gets them fired for buying this?" |
| 3 | The Build | "MVP-able in 7-day sprint with my stack?" | "What am I hand-waving because I don't want to look at it?" |
| 4 | The Exit | "Which exit: sell direct / license / credibility play?" | "If this works, do I actually want to run it? Or building because it's interesting?" |
| 5 | The Gut | "Score 1-10 on excitement" | "Why am I really drawn to this? Validation? Boredom? Real opportunity? Shiny-object pattern?" |

### Decision Rule

- **All 5 illegible cells are sharp** → Green (sprint)
- **2+ illegible cells are vague** → Red (park — research the vague cells first)
- **Mixed (1 vague)** → Yellow (note the weak cell, sprint with caution)

### Anti-Pattern It Kills

**The Pitch Trap** — you sprint on an idea where the illegible column is blank. The pitch is compelling. The reality was never examined.

---

## Commit Mode

**Use when:** Already decided to sprint. Currently building.

**Goal:** Diagnose where illegible reality is about to ambush the legible plan.

**Time budget:** 15 minutes. Run before starting the sprint, optionally weekly.

### The 5 Buckets

| # | Bucket | Legible Side | Illegible Side |
|---|--------|-------------|----------------|
| 1 | Customer Reality | "Who said they'd buy, what did they say?" | "Have I watched them try it? What did their face do? What did they say after I left?" |
| 2 | Sales Motion | "Pricing, pitch, channel?" | "Unwritten rule in this industry I'm about to break? Who in buyer's org will quietly sink this?" |
| 3 | Stack & Speed | "What's left to ship? Days remaining?" | "What part of the build am I avoiding because it's boring/scary? That's the part that kills the project." |
| 4 | My Energy | "On track vs sprint plan?" | "Still excited, or forcing it? When I think about working on this tomorrow: pull or push?" |
| 5 | Exit Reality | "Which exit am I building toward?" | "Has anything changed about whether that exit actually exists? Am I lying to myself about the path?" |

### Decision Rule

- **Green — Ship it** (0-1 red cells, My Energy is green): all 5 illegible show real signal or nameable risk. Proceed.
- **Yellow — Pivot** (1-2 red cells, opportunity still real): illegible cells reveal the plan is wrong but the opportunity is real. Adjust before building.
- **Red — Kill signal** (3+ red cells, especially My Energy + Customer Reality): keep building because the legible side (code shipped, money spent) makes you ignore what the illegible side is screaming.

### Anti-Pattern It Kills

**The Sunk-Cost Drift** — you keep building because the legible side (code shipped, money spent) makes you ignore what the illegible side is screaming.

---

## What Counts as "Sharp" vs "Vague"

**Sharp** = specific, concrete, observed.
- Example: "Maria, head of ops at Cardinal, said Tuesday 'I waste 3 hrs/week on this.'"

**Vague** = generic, assumed, unverified.
- Example: "Operations people probably have this problem."

**Rule:** If the answer could apply to any idea, it is vague.

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I can fill the illegible side after I start building" | You won't. The illegible side gets harder to see once you're invested. |
| "The illegible side is just gut feeling — it can't be filled" | It can be filled with specific observations, conversations, and research. Vagueness is a choice. |
| "My gut score is 9/10 so the other cells don't matter" | The gut bucket is one of five. High excitement masks blank illegible cells more than anything else. |
| "I've done this type of project before, I know the territory" | Prior experience fills the legible side, not the illegible. Domain knowledge ≠ specific current knowledge. |

---

## Verification

- [ ] All 5 Explore Mode illegible cells filled with specific, concrete answers (not generic ones)
- [ ] All 5 Commit Mode illegible cells filled before sprint starts
- [ ] Decision rule applied (not skipped)
- [ ] Results saved to `.ideation/{slug}.md` or the ideation output
