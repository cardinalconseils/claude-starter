---
name: photo-direction
description: Commercial photography direction for AI image generation — Peter Belanger aesthetic, OpenAI gpt-image-1 prompt engineering, studio lighting configurations, product photography
allowed-tools: Read, Bash
---

# Photo Direction Skill

Commercial product photography in the Peter Belanger tradition, engineered for AI generation via OpenAI gpt-image-1. This skill covers prompt construction, lighting configuration, and creative direction for brand-quality imagery.

## The Peter Belanger Aesthetic

Peter Belanger photographed Apple products for over a decade. His visual signature:
- Neutral, seamless backgrounds (white, off-white, light grey) — the background has no opinion
- Studio lighting that reveals material quality: texture, gloss, translucency, weight
- Zero unnecessary props — the product is the complete subject
- Perfect geometry — parallel lines are parallel, curved surfaces are smooth arcs
- Retouching that removes without erasing — imperfections removed, character retained

This aesthetic communicates: **precision, confidence, and premium quality without effort.**

## Prompt Construction Template

Every image generation prompt follows this deterministic structure:

```
Commercial product photography of [SUBJECT DESCRIPTION],
[LIGHTING SETUP], [BACKGROUND],
[ANGLE AND COMPOSITION],
[SURFACE/MATERIAL DETAILS],
[MOOD/EMOTIONAL REGISTER],
studio lighting, high resolution, professional retouching,
sharp focus, no lens distortion, no watermark
```

**Minimum required fields:** SUBJECT, LIGHTING SETUP, BACKGROUND, ANGLE

## Lighting Configurations (Deterministic)

### Studio Clean (Default)
```
large softbox key light at 45 degrees camera left,
silver reflector fill camera right, subtle rim light from behind,
seamless white background
```
**Use for:** General product, tech, consumer goods

### Apple Overhead
```
large overhead diffusion panel, near-specular highlight on top surface,
minimal shadow pool beneath product, pure white background
```
**Use for:** Devices, packaging, flat products viewed from above or 3/4

### Luxury Shadow
```
hard side light from camera right, deep shadow on camera left,
controlled shadow gradient on seamless dark grey or black background
```
**Use for:** Watches, jewelry, premium spirits, high-end cosmetics

### Warm Window
```
large soft window light simulation from camera left,
warm fill reflector, soft natural shadow, light warm neutral background
```
**Use for:** Food, lifestyle products, organic/natural brands

### Tabletop Flat
```
overhead diffused light panel, nearly shadowless,
flat lay perspective, clean white or coloured surface
```
**Use for:** Packaging, stationery, fashion accessories, multi-product arrangements

### Product Macro
```
ring flash or close-proximity softbox, extreme macro perspective,
sharp on subject centre with peripheral blur, neutral background
```
**Use for:** Texture emphasis, material quality, detail shots

## Angle Reference

| Angle | Use |
|-------|-----|
| Front elevation (0°) | Labels, flat faces, UI screens |
| Hero 3/4 (30° horizontal, 15° vertical) | Most products — shows depth and form |
| Overhead flat | Flat lay, top-of-box, tablet |
| Low hero (ground level 3/4 up) | Power, scale, automotive, shoes |
| Close detail | Texture, material, craftsmanship |
| In-use lifestyle | Product being used, hands optional |

## Background Palette

| Name | Prompt phrase | Context |
|------|--------------|---------|
| Pure white | `seamless pure white background` | Apple-style, maximum contrast |
| Studio white | `soft off-white seamless background` | Slightly warmer, approachable |
| Platinum grey | `light neutral grey seamless background` | Premium, versatile |
| Charcoal | `dark charcoal seamless background` | Luxury, dramatic |
| Warm cream | `warm cream linen surface, neutral background` | Organic, food, wellness |
| Gradient white | `white to light grey gradient background` | Added depth without distraction |

## API Parameters (Deterministic)

```yaml
model: gpt-image-1
quality: high    # always
size:
  square: "1024x1024"       # social grid, product detail
  landscape: "1536x1024"    # hero, banner, LinkedIn
  portrait: "1024x1536"     # story, mobile, vertical ad
```

## Prompt Variation Strategy

Always generate 3 variants per brief:
1. **Hero shot** — primary composition, full product
2. **Detail shot** — close-up on the key feature or material quality
3. **Context variant** — slight prop or environment hint (never competes with product)

## Quality Checklist

Before submitting a prompt to the API:
- [ ] Lighting configuration is one of the named presets (or explicitly specified)
- [ ] Background is from the background palette (or explicitly justified)
- [ ] Subject is described with material/texture/color specifics
- [ ] Angle is explicitly named
- [ ] "Professional retouching, sharp focus, no lens distortion" is appended

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Generic prompt will work fine" | Generic prompts produce generic images. The structured format exists because lighting + angle specificity is what separates stock-looking from campaign-quality. |
| "The background doesn't matter" | The background is a brand decision. Neutral ≠ no choice — it's a deliberate choice. |
| "I'll generate one and see" | Always generate 3 variants. The first is rarely the best. The brief deserves options. |
| "I don't need to specify lighting" | Unspecified lighting produces flat or inconsistent results. Lighting is the first decision in any photography. |
