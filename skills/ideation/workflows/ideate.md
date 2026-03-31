# Workflow: Ideation (Phase 0)

## Overview
Creative brainstorming and idea refinement for users who have a vague concept,
a problem without a solution, multiple competing ideas, or an idea they want to
stress-test. Produces a refined pitch that feeds into Intake (Phase 1).

## Dual Mode

This workflow operates in two modes, determined by the `mode` parameter from the command:

- **Kickstart mode** (`mode=kickstart`): Output to `.kickstart/ideation.md`, update `.kickstart/state.md`
- **Standalone mode** (`mode=standalone`): Output to `.ideation/{topic-slug}.md`, no state file updates

## Input
- `$IDEA` — optional rough pitch from `/ideate` or `/kickstart` argument
- `$MODE` — `kickstart` or `standalone` (from command context detection)
- No prerequisites — this is the entry point

## Steps

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "ideation.phase.started" "_project" "Ideation started" '{"phase_name":"Ideate","mode":"$MODE"}'`

### Step 1: Check for Existing Ideation

**Kickstart mode:** Read `.kickstart/ideation.md` if it exists.
**Standalone mode:** Read `.ideation/` directory for existing ideation files.

- If existing ideation found → ask:
  ```
  AskUserQuestion:
    question: "Previous ideation found. How to proceed?"
    options:
      - "Start fresh — new brainstorming session"
      - "Refine further — build on what's there"
      - "Skip ideation — move on" (kickstart mode only)
  ```
- If not found → fresh ideation

### Step 2: Assess Starting Point

If `$IDEA` was provided, acknowledge it and categorize:

```
AskUserQuestion:
  question: "I see your idea. Where are you on this?"
  options:
    - "It's vague — help me flesh it out"
    - "It's one of several ideas — help me pick"
    - "It's fairly clear — stress-test it for me"
    - "It's clear — skip to intake" (kickstart mode only)
```

If no `$IDEA` provided:

```
AskUserQuestion:
  question: "What brings you here today?"
  options:
    - "I have a rough idea I want to explore"
    - "I have a problem but no solution yet"
    - "I have multiple ideas and want to compare them"
    - "I have scattered thoughts/notes I want to organize into a direction"
    - "I have no idea — inspire me"
```

Route to the appropriate brainstorming track based on answer:
- "vague" / "rough idea" → **Track A**
- "problem" / "no solution" → **Track B**
- "several" / "multiple" / "compare" → **Track C**
- "scattered" / "organize" / "regroup" → **Track E**
- "no idea" / "inspire" → **Track D**
- "stress-test" → Skip to **Step 4** directly
- "clear — skip to intake" → Mark ideation as skipped, exit

### Step 3: Idea Exploration (varies by track)

Refer to the loaded **ideation skill** for framework details (SCAMPER, 5 Whys + HMW,
Comparison Matrix, Inspiration Discovery). The skill describes each framework's
purpose, technique, and prompt patterns. Apply the selected framework below.

**Track A: Flesh out a vague idea — SCAMPER Framework**

Apply SCAMPER to the user's rough concept. Ask 3-4 questions via AskUserQuestion,
each exploring a different SCAMPER angle. Pick the most relevant lenses — don't
run all 7 mechanically.

After the questions, present the 2-3 strongest angles that emerged.

```
AskUserQuestion:
  question: "Here are the angles that emerged. Which resonates?"
  options:
    - "{Angle 1 — one-line summary}"
    - "{Angle 2 — one-line summary}"
    - "{Angle 3 — one-line summary}"
    - "None of these — let me describe what I'm thinking"
```

**Track B: Problem without a solution — 5 Whys + How Might We**

Start with the stated problem. Ask "Why?" iteratively (3-5 rounds) via
AskUserQuestion to drill down to root causes.

For each root cause discovered, generate a "How Might We..." (HMW) statement.
Present 3-4 HMW statements as potential project directions:

```
AskUserQuestion:
  question: "Each of these is a different project direction. Which excites you most?"
  options:
    - "HMW {statement 1}?"
    - "HMW {statement 2}?"
    - "HMW {statement 3}?"
    - "HMW {statement 4}?"
```

**Track C: Multiple competing ideas — Comparison Matrix**

For each idea (max 4), ask for a one-liner pitch via AskUserQuestion.

Quick-score each idea on the 5 dimensions from the ideation skill (Problem Clarity,
Target User Clarity, Feasibility, Uniqueness, Excitement). Present the matrix with
brief commentary.

```
AskUserQuestion:
  question: "Based on this comparison, which direction do you want to pursue?"
  options:
    - "{Highest-scored idea} (Recommended)"
    - "{Second idea}"
    - "{Third idea}"
    - "A hybrid — let me describe"
```

**Track D: No idea — Inspiration Discovery**

Ask about the user's context to seed ideas:

```
AskUserQuestion:
  question: "Tell me about yourself — what's your background?"
  options:
    - "Software developer"
    - "Designer / creative"
    - "Business / entrepreneur"
    - "Student / learner"
```

Follow up with 1-2 more questions about frustrations, wishes, and curiosities.
Generate 3-5 idea seeds. Present them:

```
AskUserQuestion:
  question: "Any of these spark something?"
  options:
    - "{Seed 1 — one-line pitch}"
    - "{Seed 2 — one-line pitch}"
    - "{Seed 3 — one-line pitch}"
    - "None — but it made me think of something else"
```

Iterate once if "none" or "something else" is chosen.

**Track E: Scattered ideas need organizing — Regroup & Interpret**

Ask the user to share all their fragments — notes, ideas, thoughts, features,
anything they've been collecting. Accept via AskUserQuestion (free text):

```
AskUserQuestion:
  question: "Dump everything — all your ideas, notes, fragments, features, random thoughts about this. Don't filter, just share."
```

If the user has a lot, let them share across 2-3 rounds.

Then:
1. **Cluster:** Group related ideas into 3-5 themes. Present the clusters:

```
I see {N} themes emerging from your ideas:

1. **{Cluster name}** — {what it contains, 1 sentence}
2. **{Cluster name}** — {what it contains}
3. ...
```

2. **Connect:** Identify relationships between clusters:
"Clusters 1 and 3 are related because... Cluster 2 is in tension with Cluster 4 because..."

3. **Interpret:** Surface the hidden vision:
"Looking at everything together, here's what I think you're really building: {interpretation}"

4. **Propose:** Present 2-3 coherent project narratives:

```
AskUserQuestion:
  question: "Here are three ways to weave your ideas into a coherent project. Which captures your vision?"
  options:
    - "{Narrative 1 — one-line summary}"
    - "{Narrative 2 — one-line summary}"
    - "{Narrative 3 — one-line summary}"
    - "You're close but let me adjust"
```

### Step 4: Deepen the Chosen Direction

Once a direction emerges, apply the stress-testing probes from the ideation skill.
Ask each via AskUserQuestion (free text):

1. "What's the #1 reason this could fail?"
2. "Who would pay for this? How much do you think they'd pay?"
3. "What exists today that's closest to this? Why isn't it enough?"
4. "What's the smallest version that would still be valuable?"

Adapt questions based on answers — skip obvious ones, dig deeper on interesting threads.

### Step 5: Generate Angle Variations

Based on all conversation, generate the 3 angle variations defined in the ideation
skill (Safe Bet, Ambitious Play, Lean Experiment). Present all three with
one-paragraph descriptions.

```
AskUserQuestion:
  question: "Which angle do you want to build?"
  options:
    - "The Safe Bet"
    - "The Ambitious Play"
    - "The Lean Experiment"
    - "A combination — I'll describe"
```

### Step 6: Synthesize Refined Pitch

Compose a structured pitch based on the chosen angle:

```
Here's your refined pitch:

**One-liner:** {under 20 words}

**Problem:** {2-3 sentences — who has this problem and how they deal with it today}

**Solution:** {2-3 sentences — what you're building and how it solves the problem}

**Target User:** {1 sentence — who specifically}

**Key Differentiator:** {1 sentence — why this over alternatives}

**MVP Scope Hint:** {1 sentence — the smallest valuable version}

Does this capture what you want to build?
```

Wait for confirmation via AskUserQuestion before saving.

### Step 7: Save Ideation Output

**Kickstart mode:**
```bash
mkdir -p .kickstart
```
Write to `.kickstart/ideation.md`.

**Standalone mode:**
```bash
mkdir -p .ideation
```
Generate a topic slug from the one-liner (lowercase, hyphens, max 40 chars).
Write to `.ideation/{topic-slug}.md`.

**Output format (both modes):**

```markdown
# Ideation Output

**Generated:** {date}
**Mode:** {kickstart|standalone}
**Track:** {A: SCAMPER | B: 5 Whys + HMW | C: Comparison | D: Inspiration | E: Regroup}

## Refined Pitch

**One-liner:** {under 20 words}

### Problem
{2-3 sentences}

### Solution
{2-3 sentences}

### Target User
{1 sentence}

### Key Differentiator
{1 sentence}

### MVP Scope Hint
{1 sentence}

## Brainstorming Journey
{Summary of exploration — which frameworks were applied, what angles were
considered, why this direction was chosen over alternatives}

## Angles Considered

| Angle | Description | Chosen? |
|-------|-------------|---------|
| Safe Bet | {summary} | {yes/no} |
| Ambitious Play | {summary} | {yes/no} |
| Lean Experiment | {summary} | {yes/no} |

## Stress Test

- **Failure risk:** {from Step 4}
- **Willingness to pay:** {from probing}
- **Existing alternatives:** {from probing}
- **Minimum viable scope:** {from probing}
```

### Step 8: Validate & Report

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "ideation.phase.completed" "_project" "Ideation complete" '{"phase_name":"Ideate","mode":"$MODE"}'`

**Validate:** Check output file exists and contains:
- `## Refined Pitch` with One-liner
- `## Brainstorming Journey`
- `## Stress Test`

If any section is missing, loop back to the missing step.

**State update (kickstart mode only):**
```
Update .kickstart/state.md:
  Phase 0 (Ideate) → status: done, completed: {date}
  last_phase: 0
  last_phase_name: Ideate
  last_phase_status: done
```

**Report:**
```
  [0] Ideate          done
      Output: {output file path}
      Pitch: {one-liner}
      Track: {which brainstorming framework was used}
```

## Post-Conditions
- Output file exists with refined pitch and all required sections
- (Kickstart mode) `.kickstart/state.md` updated with Ideate → done
- User has confirmed the refined pitch
