> Attribution: Adapted from [impeccable](https://github.com/pbakaus/impeccable) by Peter Bakaus, Apache-2.0.

# Typography Reference

Signals covered: `overused-font`, `flat-type-hierarchy`, `single-font`, `italic-serif-display`, `all-caps-body`, `wide-tracking`, `tight-leading`, `tiny-text`

## Type Scale

Use fewer sizes with more contrast. A 5-step system covers most needs:

| Token | Size | Use |
|-------|------|-----|
| `--text-xs` | 0.75rem | Captions, legal, metadata |
| `--text-sm` | 0.875rem | Secondary UI, helper text |
| `--text-base` | 1rem | Body text |
| `--text-lg` | 1.25–1.5rem | Subheadings, lead text |
| `--text-xl+` | 2–4rem | Headlines, hero text |

Minimum 1.25 ratio between adjacent steps. Flat scales (14/15/16/18px) produce `flat-type-hierarchy`. Fewer sizes with bolder contrast beats many sizes with subtle differences.

## Hierarchy Through Weight

Do not rely on size alone. Combine size + weight + spacing:
- Heading: larger + bold + more space above
- Body: regular weight, 1.5–1.7 line height
- Label: smaller + medium weight + optional wide tracking (uppercase labels only)

Weight contrast must be visible. Thin vs. regular is not enough contrast. Bold vs. regular reads clearly.

## Overused Fonts — Reject List

These fonts signal AI-generated UI. Each wave of LLM output converges on the same handful:

**Reject without a strong contextual reason:**
- Inter, Geist Sans, Geist Mono, Geist (default AI app fonts)
- Roboto, Open Sans, Lato (default body fonts)
- Montserrat, Plus Jakarta Sans, Space Grotesk (AI "modern clean" defaults)
- Fraunces, Instrument Sans, Mona Sans (editorial AI defaults)
- Recoleta (AI "warm, approachable" default)

**Alternatives with less saturation:**
- System fonts (`-apple-system, BlinkMacSystemFont, system-ui`) — fast, native, readable
- DM Sans, Albert Sans, Bricolage Grotesque — underused grotesques
- Literata, Source Serif 4 — underused serifs for editorial/reading contexts
- Custom or brand-specific type if available

When one font family must cover everything, use weight and size to build hierarchy. Pair a display face with a body face only when you need genuine contrast (different optical sizes, different registers).

## Italic Serif Display

Oversized italic serif (Fraunces, Recoleta, Playfair, Newsreader-italic) as the primary hero headline has become the AI startup default. It reads as "AI chose this" in isolation.

Fix: set roman, use a non-serif display face, or use a lower-saturation serif not in the reject list. Exception: editorial/magazine register where the italic is genuinely chosen, not defaulted.

## Readability Rules

**Line height:**
- Body text: 1.5–1.7× font size
- Headings: 1.1–1.3× (tight is intentional at large sizes)
- Line height below 1.3× on body text = `tight-leading` signal

**Line length:**
- Use `max-width: 65ch` to `75ch` on text containers
- Beyond ~80 characters, the eye loses its place on return
- `ch` units scale with the font, making this relative and robust

**Minimum size:**
- Body text: 14px minimum, 16px preferred
- Below 12px = `tiny-text` signal
- Captions/legal at 11–12px: acceptable if marked secondary

**All-caps:**
- Reserve for short labels, badges, UI metadata (6 words max)
- Long body passages in uppercase = `all-caps-body` signal
- We recognize words by ascender/descender shape — caps destroys that

**Letter spacing:**
- Body text: 0 to 0.01em maximum
- Above 0.05em on body = `wide-tracking` signal
- Wide tracking is correct only for short uppercase labels

**Dark backgrounds:**
Perceived weight drops on dark. Compensate across three axes simultaneously:
1. Line height +0.05–0.1
2. Letter spacing +0.01–0.02em
3. Font weight up one step (regular → medium)

Fix one axis and the text still feels wrong. Fix all three and it reads.

## Paragraph Rhythm

Pick one: space between paragraphs OR first-line indentation. Never both. Digital interfaces use space; editorial/long-form can use indent-only.

## Verification

- [ ] No font from the reject list unless justified
- [ ] Type scale has ≥1.25 ratio between steps
- [ ] Body line height 1.5–1.7
- [ ] Body line length max 65–75ch
- [ ] No body text below 14px
- [ ] All-caps limited to short labels only
- [ ] Dark-mode text uses three-axis compensation
