---
description: "Luv creative suite — dispatch copywriters, brand strategist, photo creator, and video creator directly without going through the full agency hierarchy"
argument-hint: "[creative task]"
allowed-tools: Read, Agent, AskUserQuestion
---

# /cks:creative — Luv Creative Suite

Direct access to the Luv creative specialists. Use this instead of `/cks:luv` when the task is purely creative — no engineering, no analytics, no media buying. Faster dispatch, narrower scope.

## Usage

```
/cks:creative Write 5 Google Ads headlines for our B2B SaaS product
/cks:creative Alan Sharpe style email for manufacturing procurement managers
/cks:creative Brand positioning workshop for our new fintech product
/cks:creative Generate hero images for our product launch (Peter Belanger style)
/cks:creative 15-second Instagram Reels ad — Kling video
/cks:creative Write a thought leadership whitepaper for our CEO
/cks:creative Mission, vision, and key messages for our rebrand
```

## Creative Specialists

```
creative
├── short copy
│   ├── AdsCopywriter    → Joel Klettke VoC methodology — Google/Meta/LinkedIn ad copy
│   └── AlanSharpe       → Direct response B2B — industrial, professional services
├── long copy
│   └── LongFormCopywriter → TBWA\Media Arts Lab — blog, whitepaper, email sequences
├── brand strategy
│   └── BrandStrategist  → April Dunford positioning + Seth Godin brand philosophy
│                          (mission, vision, community, key messages, value proposition)
├── photo
│   └── PhotoCreator     → Peter Belanger aesthetic — OpenAI gpt-image-1
└── video
    └── VideoCreator     → Kling API — text-to-video and image-to-video
```

## What is Deterministic vs. Indeterministic

**Deterministic** (YAML frontmatter, structured configs — the system always does the same thing):
- Agent tool declarations, model selection, skill loading
- API call patterns (OpenAI Image 2, Kling) — model, size, quality, aspect ratio, duration
- Platform specifications (character limits, aspect ratios, hook timing)
- Copywriting frameworks (PAS, AIDA, BAB — when to use which)
- Lighting presets for photo direction
- Prompt structure templates (8-element video prompt, photo prompt template)
- Trigger rules (scheduling.md, arch-patterns.md, evals.md)

**Indeterministic** (Markdown body — the system uses judgment and context):
- Persona voice (Joel Klettke's VoC language, Alan Sharpe's precision, TBWA's storytelling)
- Creative concept generation (hooks, angles, emotional registers)
- Positioning work (competitive alternatives, value chains, brand philosophy)
- Specific prompts generated for photo/video (vary by subject and brief)
- Strategy recommendations (channel selection, community direction)
- Copy variations and psychological angle selection

## Dispatch

**If a specific specialist is requested or implied:**

```
/cks:creative Write Meta ad copy for a SaaS tool
→ Agent(subagent_type="luv:ads-copywriter", prompt="...")

/cks:creative Position our product — April Dunford style
→ Agent(subagent_type="luv:brand-strategist", prompt="...")

/cks:creative Product hero image, clean white background
→ Agent(subagent_type="luv:photo-creator", prompt="...")

/cks:creative 15s TikTok ad — Kling
→ Agent(subagent_type="luv:video-creator", prompt="...")
```

**If no args or ambiguous:** AskUserQuestion with options:
- Short-form ad copy (Google / Meta / LinkedIn)
- B2B direct response copy (Alan Sharpe)
- Long-form content (blog / whitepaper / email)
- Brand positioning + strategy
- Product photography (gpt-image-1)
- Video content (Kling API)
