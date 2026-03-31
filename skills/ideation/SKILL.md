---
name: ideation
description: >
  Creative brainstorming and idea refinement expertise — SCAMPER, 5 Whys, How Might We,
  comparison matrices, angle variation, and stress-testing. Use this skill when brainstorming
  project ideas, refining vague concepts, comparing competing directions, or stress-testing
  an idea before committing. Trigger on: "brainstorm", "ideate", "refine my idea", "compare
  ideas", "stress-test", "I have a vague idea", "help me think through", "which idea is
  better", or any variation of creative exploration before building.
allowed-tools: Read, Write, AskUserQuestion, WebSearch, WebFetch
---

# Ideation — Domain Knowledge

This skill is loaded into ideation agents via the `skills: ideation` frontmatter field.
It provides domain expertise about brainstorming frameworks and creative techniques —
not execution instructions. Agents read workflow files in `workflows/` for step-by-step
process via progressive disclosure.

## Overview

Helps users who have a vague concept, a problem without a solution, multiple competing
ideas, or an idea they want to stress-test. Produces a refined, validated pitch ready
for structured intake or implementation planning.

## Brainstorming Frameworks

### SCAMPER (Track A — Flesh out a vague idea)

Best for: User has *something* but needs to expand, twist, or reframe it.

| Letter | Technique | Prompt Pattern |
|--------|-----------|----------------|
| **S**ubstitute | Replace a core element | "What if you replaced {X} with {Y}?" |
| **C**ombine | Merge with adjacent domain | "What if you merged this with {Z}?" |
| **A**dapt | Borrow from another field | "What existing solution in {field} could you adapt?" |
| **M**odify | Change scale, audience, delivery | "What if this served {different audience}?" |
| **P**ut to another use | Adjacent markets | "What other market could use exactly this?" |
| **E**liminate | Remove complexity | "What if you removed the hardest part — what's left?" |
| **R**everse | Flip relationships | "What if the user/provider roles were swapped?" |

Pick 3-4 lenses most relevant to the specific idea. Don't run all 7 mechanically.

### 5 Whys + How Might We (Track B — Problem without a solution)

Best for: User has a *pain point* but no clear product concept.

**5 Whys:** Drill from symptom to root cause. Ask "Why?" iteratively (3-5 rounds).
Stop when you reach a cause that's actionable — not every chain needs all 5.

**How Might We (HMW):** Convert each root cause into a design challenge:
- "How might we {solve root cause} for {target user}?"
- Good HMW statements are specific enough to inspire solutions but open enough to allow multiple approaches.
- Avoid "How might we build {specific solution}" — that's too narrow.

### Comparison Matrix (Track C — Multiple competing ideas)

Best for: User has 2-4 ideas and can't choose.

Score each idea on 5 dimensions (1-3 stars):
1. **Problem Clarity** — How well-defined is the problem?
2. **Target User Clarity** — Can you describe exactly who uses this?
3. **Feasibility** — Can this be built with available skills/budget/time?
4. **Uniqueness** — How differentiated from existing solutions?
5. **Personal Excitement** — How motivated is the user to build this?

Present as a matrix. Commentary matters more than scores — explain *why* each score.

### Regroup & Interpret (Track E — Scattered ideas need organizing)

Best for: User has multiple disconnected thoughts, notes, or fragments they've collected
and needs help making sense of them as a coherent project direction.

Process:
1. **Collect:** Ask the user to dump all their ideas, notes, fragments — no filtering
2. **Cluster:** Group related ideas into themes (3-5 clusters typically emerge)
3. **Name:** Give each cluster a descriptive label
4. **Connect:** Identify relationships and tensions between clusters
5. **Interpret:** Synthesize what the clusters are "saying" as a whole — what's the
   underlying vision the user is circling around?
6. **Propose:** Present 2-3 coherent project narratives that weave the clusters together

Key principle: The user's scattered ideas often contain a hidden coherent vision.
Your job is to surface it, not impose your own. Ask "Is this what you've been
thinking?" not "Here's what you should think."

### Inspiration Discovery (Track D — No idea at all)

Best for: User wants to build something but has no starting point.

Seed generation strategy:
1. Understand the user (background, skills, daily frustrations)
2. Identify friction points in their domain
3. Cross-pollinate: combine their skills with underserved markets
4. Generate 3-5 seeds, each with a one-line pitch
5. Iterate on whichever sparks interest

## Angle Variations

After a direction is chosen, always generate three angles to prevent premature commitment:

| Angle | Philosophy | Risk Profile |
|-------|-----------|--------------|
| **Safe Bet** | Most straightforward interpretation, lowest risk, fastest to build | Low risk, potentially lower differentiation |
| **Ambitious Play** | Full vision, maximum differentiation, bigger bet | Higher risk, higher potential upside |
| **Lean Experiment** | Smallest testable version, fastest to validate with real users | Lowest investment, fastest learning |

The user's choice of angle signals their risk appetite and informs downstream decisions
(MVP scope, tech stack complexity, launch strategy).

## Stress Testing

Every idea should survive basic scrutiny before entering intake. Four key probes:

1. **Failure risk:** "What's the #1 reason this could fail?" — surfaces assumptions
2. **Willingness to pay:** "Who pays? How much?" — validates there's a business
3. **Existing alternatives:** "What's closest today? Why isn't it enough?" — validates differentiation
4. **Minimum viable scope:** "What's the smallest valuable version?" — prevents scope creep from day one

Adapt probes based on context — skip obvious ones, dig deeper on weak spots.

## Output Format

Ideation output always includes:
- **Refined Pitch** — one-liner, problem, solution, target user, differentiator, MVP hint
- **Brainstorming Journey** — which frameworks were used and why this direction won
- **Angles Considered** — the three variations and which was chosen
- **Stress Test** — answers to the four probes

## Anti-Patterns

| Anti-Pattern | Why It's Wrong | Do This Instead |
|-------------|---------------|-----------------|
| Picking a direction for the user | Kills ownership and may miss their real intent | Always present options, let them choose |
| Running all frameworks mechanically | Feels like a checklist, not a conversation | Pick the right framework for the situation |
| Skipping stress-testing | Produces ideas that fall apart at intake | Always probe, even if the idea seems strong |
| Over-refining in ideation | Ideation produces a pitch, not a PRD | Stop at the pitch — intake handles the detail |
| Ignoring "none of the above" | The best idea might not be in your suggestions | Always leave room for user's own direction |

## Reference Files

| File | When to Read |
|------|-------------|
| `workflows/ideate.md` | Step-by-step ideation execution process |

## Customization

- **Framework selection:** Adapt which SCAMPER lenses to use based on domain
- **Stress test depth:** Add domain-specific probes (e.g., regulatory for healthtech)
- **Angle definitions:** Adjust the three angles for specific project types
