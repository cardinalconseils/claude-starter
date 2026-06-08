---
name: video-ai-direction
description: AI video generation direction for Kling API — prompt engineering, motion design, platform specs, text-to-video and image-to-video workflows for marketing content
allowed-tools: Read, Bash
---

# Video AI Direction Skill

AI video generation using the Kling API (kling-v1-5 / kling-v2). This skill covers prompt construction, API workflow, platform specifications, and creative direction for marketing video content.

## Kling API Architecture

Kling generates video asynchronously: you POST a generation request, receive a task ID, then poll until the video is ready.

**Base URL:** `https://api.klingai.com/v1`
**Auth:** `Authorization: Bearer $KLING_API_KEY`

### Generation Modes

| Mode | Input | Best for |
|------|-------|----------|
| `text2video` | Text prompt | Campaign concepts, abstract, motion-first |
| `image2video` | Static image + motion prompt | Product animation, photo-to-video |

### Model Selection (Deterministic)

| Model | Quality | Speed | Use |
|-------|---------|-------|-----|
| `kling-v1` | Good | Fastest | Testing, iterations |
| `kling-v1-5` | Better | Medium | Production ads (default) |
| `kling-v2` | Best | Slowest | Hero brand films |

**Default for marketing: `kling-v1-5` in `pro` mode.**

## Prompt Engineering

### The 8-Element Prompt Structure

```
[OPENING_FRAME]: what the viewer sees in the first frame
[MOTION]: what moves, how it moves, camera behavior
[SUBJECT]: who/what is the protagonist
[STYLE]: cinematic / commercial / documentary / animated
[CAMERA]: static / dolly-in / pan / tilt / aerial / handheld
[LIGHTING]: natural / golden hour / studio / dramatic
[MOOD]: emotional register
[END_FRAME]: what the last frame holds
```

**Negative prompt always includes:**
```
blurry, distorted faces, watermark, text overlay, low quality, amateur, shaky, overexposed, artifacts
```

### Motion Language Reference

**Camera movements:**
- `slow dolly in` — intimate, focus draw
- `gentle pan right` — reveal, storytelling
- `aerial overhead pull back` — scale, context
- `static locked` — stability, confidence
- `handheld slight movement` — documentary authenticity
- `smooth tracking shot` — following action

**Subject motion:**
- `subtle product rotation` — product showcase
- `liquid pour in slow motion` — food/beverage premium
- `hands interacting with [product]` — demonstration
- `background bokeh shift` — focus transitions
- `particle/dust float` — atmosphere

## Platform Specifications (Deterministic)

```yaml
tiktok_reels:
  ratio: "9:16"
  duration: "5"      # 5s for ad, 10s for organic
  hook_window: "2s"
  key: mobile-first, native text overlays in post

linkedin:
  ratio: "16:9"
  duration: "5"
  hook_window: "3s"
  key: auto-plays muted, captions mandatory

instagram_feed:
  ratio: "1:1"
  duration: "5"
  hook_window: "2s"
  key: square for feed, 9:16 for reels

youtube_preroll:
  ratio: "16:9"
  duration: "5"      # skip at 5s, make it unskippable
  hook_window: "5s"
  key: must deliver value before skip

twitter_x:
  ratio: "16:9"
  duration: "5"
  hook_window: "2s"
  key: auto-plays muted
```

## API Call Patterns

### Text-to-Video
```bash
curl -s -X POST https://api.klingai.com/v1/videos/text2video \
  -H "Authorization: Bearer $KLING_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model_name": "kling-v1-5",
    "prompt": "FULL_PROMPT",
    "negative_prompt": "blurry, distorted faces, watermark, text overlay, low quality",
    "cfg_scale": 0.5,
    "mode": "pro",
    "aspect_ratio": "16:9",
    "duration": "5"
  }'
```

### Image-to-Video (animate a static image)
```bash
curl -s -X POST https://api.klingai.com/v1/videos/image2video \
  -H "Authorization: Bearer $KLING_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model_name": "kling-v1-5",
    "image": "IMAGE_URL_OR_BASE64",
    "prompt": "MOTION_DESCRIPTION",
    "negative_prompt": "blurry, distorted faces, watermark, low quality",
    "cfg_scale": 0.5,
    "mode": "pro",
    "duration": "5"
  }'
```

### Poll for Completion
```bash
# Poll every 15 seconds, up to 5 minutes
TASK_ID="<returned from generation call>"
curl -s https://api.klingai.com/v1/videos/text2video/$TASK_ID \
  -H "Authorization: Bearer $KLING_API_KEY"
# Check .data.task_status == "succeed" and extract .data.task_result.videos[0].url
```

## Deliverable Structure

Every video brief produces 3 variants:

**Variant 1 — Hero concept:** Full prompt, primary creative vision
**Variant 2 — Hook variant:** Different opening 2 seconds (stronger pattern interrupt)
**Variant 3 — CTA variant:** Different ending (clearer or softer call-to-action frame)

Plus: script/caption copy for each variant (added in post via the video editor).

## The 5-Second Rule

Every 5-second video must:
- Second 1–2: **Interrupt** — something unexpected, beautiful, or emotionally resonant
- Second 3–4: **Communicate** — one clear idea about the product or brand
- Second 5: **Direct** — a visual that implies the next step (product logo, CTA frame)

No exceptions for ad placements. For organic content the same structure applies, with more room for story in seconds 3–4.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll use std mode for speed" | std mode produces visibly lower quality. Always use pro for client assets. |
| "The negative prompt isn't necessary" | Unguided generation consistently produces watermarks and text artifacts. Include it always. |
| "One variant is enough" | The first generation is rarely the strongest. Three variants surfaces the best option and gives the client choice. |
| "Platform ratio doesn't matter much" | Wrong ratio: 20–40% reach reduction on most platforms. Ratio is a technical requirement, not a preference. |
| "I'll caption later" | Caption brief belongs in the deliverable now. Captions double engagement on muted auto-play. |
