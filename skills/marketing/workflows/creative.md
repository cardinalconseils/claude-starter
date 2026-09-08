# Creative Workflow

For a single creative deliverable — no campaign scaffolding. Ported from the creative
command's dispatch table; persona loads replace the agent dispatches.

## Pick the persona from the ask

```
creative
├── short copy
│   ├── ads-copywriter       → VoC method — Google / Meta / LinkedIn ad copy
│   └── alan-sharpe          → direct response B2B — industrial, professional services
├── long copy
│   └── long-form-copywriter → blog, whitepaper, email sequences, case studies
├── brand strategy
│   └── brand-strategist     → positioning (Dunford) + brand philosophy (Godin):
│                              mission, vision, community, key messages, value proposition
├── photo
│   └── photo-creator        → commercial product imagery via the image API
└── video
    ├── video-creator        → short video via the video API — text- or image-to-video
    └── video-producer       → scripted / long-form: demos, explainers, testimonials
```

| Ask looks like | Persona |
|---|---|
| "Meta ad copy for a SaaS tool", "5 Google headlines" | `ads-copywriter` |
| "Alan Sharpe style email for procurement managers" | `alan-sharpe` |
| "Thought-leadership whitepaper", "6-email nurture" | `long-form-copywriter` |
| "Position our product — Dunford style", "mission, vision, key messages" | `brand-strategist` |
| "Product hero image, clean white background" | `photo-creator` |
| "15-second Reels ad", "animate this product shot" | `video-creator` |
| "2-minute demo script with shot list" | `video-producer` |

**If the ask is ambiguous or empty**, `AskUserQuestion` with these options:

- Short-form ad copy (Google / Meta / LinkedIn)
- B2B direct response copy (Alan Sharpe)
- Long-form content (blog / whitepaper / email)
- Brand positioning + strategy
- Product photography
- Video content

## Run

1. Load `skills/marketing/personas/<persona>.md`; read the skills its `reads:` list names
   only if the brief needs that depth
2. Let the persona clarify with `AskUserQuestion` where its file says to
3. Produce the deliverable in the persona's format; write it under `.marketing/`
   (`copy/`, `positioning/`, `assets/`) with a short file name that names the ask
4. For image and video personas: run the vendor call by the pattern in the persona file,
   then write `.marketing/assets/<slug>.md` with the prompt used, the returned URL or task
   ID, size or ratio, and the variation prompts. Do not download binaries — report the URL
   and return to the chief of staff if a local copy is needed
5. Close with `Persona: <name>` and the file path(s) written

## Deterministic vs judgment

Deterministic (the same every time): API call shape, size and ratio tables, platform
character limits, hook timing, lighting presets, the 8-element video prompt structure,
the copywriting framework choice tables (PAS / AIDA / BAB).

Judgment (the persona's craft): voice, concept and angle, emotional register, positioning
reasoning, the specific prompt for a given subject, copy variations, channel and community
recommendations.
