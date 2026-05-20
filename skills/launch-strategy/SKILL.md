---
name: launch-strategy
description: Launch strategy expertise — 8-week pre/launch/post campaign planning, maturity-stage channel selection (Prototype/Pilot/Candidate/Production), Product Hunt warm-up, press strategy, community seeding
allowed-tools: Read
---

# Launch Strategy Skill

Expertise in building launch campaigns that match the product's actual maturity stage. A Prototype launch and a Candidate launch are different operations — same channels, different expectations, different blast radius risk.

## How to Use This Skill

1. Read `phases.yaml` for the timeline structure and deliverables — hard constraints
2. Read `workflows/launch-timeline.dot` for phase dependencies and maturity gate logic
3. Read `channel_priority` section of `phases.yaml` to select channels for the detected maturity stage
4. Read `.marketing/product.md` for ICP context if available

## Maturity Stage Adaptation

The biggest mistake in launches: using Candidate-stage tactics at Prototype stage. Amplifying a product that isn't ready creates churn and reputation cost.

**Prototype**: Validate before amplifying. HN Show HN and relevant subreddits are the right channels — the feedback density per effort is highest here. Do NOT run paid ads or press outreach at this stage.

**Pilot**: First real launch. Product Hunt is viable if you've been building community for 90 days. Email list is your most reliable channel. The goal is not viral — it's finding 25-50 power users who will become references.

**Candidate**: Full launch. Press, paid ads, and partner channels are worth the effort now because the product can handle the volume and the story is clear. Press requires 4 weeks lead time minimum.

**Production**: Ongoing demand generation, not a launch event. Optimize existing channels before adding new ones.

## Product Hunt Strategy

Product Hunt day-1 upvotes are a proxy for warm community size, not product quality. Requirements from `phases.yaml`:
- 90 days of community building before launch day
- Hunter outreach 2 weeks before (pick someone with 500+ followers on PH)
- Target 200 upvotes in first 24 hours to stay in top 10
- Go live at 12:01am PST — the leaderboard resets at midnight

Common failure: launching on Product Hunt with a cold audience. The product hunts that work are community events, not discovery events.

## Warm-Up Sequence

The pre-launch period (weeks -8 to -1) is more important than launch day. People who join a waitlist convert at 30-40%. People who click a product launch cold convert at 2-5%. Build the waitlist.

## Common Rationalizations

| Rationalization | Reality |
|----------------|---------|
| "We'll launch when the product is perfect" | Perfect is a moving target. Launch at Pilot stage — users tell you what perfect actually means. |
| "We don't need press — our community is enough" | For Candidate stage, press provides the credibility signal that converts skeptics. Community converts believers. You need both. |
| "Product Hunt is pay-to-win" | The teams that win PH spent 90 days building relationships on the platform before launch day. That's not pay-to-win, that's community. |
| "We can compress the pre-launch to 2 weeks" | You can, at Prototype stage. At Candidate stage, the press lead time alone is 4 weeks. |
