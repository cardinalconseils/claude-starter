---
name: idea-validation
description: >
  Generates 5 idea validation artifacts from a refined project pitch: MARKETING.md
  (positioning + copy pillars + channel matrix), EMAIL-SEQUENCE.md (5-email waitlist nurture),
  GTM-BRIEF.md (pre/launch/post phases + kill criteria), landing-page.html (standalone
  deployable waitlist page), and BRAND-GUIDELINES.md (color palette, typography, voice).
  Triggered after kickstart Phase 0 ideation confirms a refined pitch. Input: .kickstart/ideation.md.
  Output: .kickstart/validation/*.
allowed-tools: Read, Write, Bash
---

# Idea Validation Skill

## Purpose

Generate 5 ready-to-use artifacts from the ideation output. No additional user questions — derive everything from the refined pitch already in context.

---

## Artifact 1: MARKETING.md

### Section 1 — Positioning Line
One sentence: tagline + single strongest differentiator.
> {tagline} — unlike [category norm], [product name] [key difference].

### Section 2 — Hero Copy Variants
Two headline alternatives beyond the primary. Apply:
- **Pain-first**: opens with the specific friction, 6–8 words
- **Aspiration**: opens with the outcome the persona wants, 6–8 words

Include a 2-sentence subhead for each.

### Section 3 — Copy Pillars
3–4 recurring themes for all channels. Per pillar:
- **Name** (2–3 words)
- One-line description
- Example hook (one sentence for social)

### Section 4 — Channel Priority Matrix
Rank 4 channels for pre-launch. Base on business model signal and personas.

| Rank | Channel | Why it fits | First action |
|------|---------|-------------|--------------|
| 1 | ... | ... | ... |
| 2 | ... | ... | ... |
| 3 | ... | ... | ... |
| 4 | ... | ... | ... |

Channel pool: organic social, niche communities, waitlist email, content/SEO, paid social, cold outreach, partnerships.

---

## Artifact 2: EMAIL-SEQUENCE.md

Five emails. Each: subject line, preview text (≤90 chars), body (150–250 words), CTA.

**Email 1 — Welcome**
Subject: confirms signup + core promise in ≤8 words.
Body: thank them, restate what the product does, set expectation.
CTA: reply with their #1 frustration (seeds reply data).

**Email 2 — Problem Agitation** (day 3)
Subject: names the specific friction.
Body: describe the broken status quo from the persona's daily experience. End with "That's why we're building {name}."
CTA: "Does this sound like you? Hit reply."

**Email 3 — Solution Reveal** (day 6)
Subject: bridges from problem to fix.
Body: what the product does, how it addresses root cause, what they get that they can't get today. One before/after example.
CTA: "Tell one person who needs this." + share link.

**Email 4 — Social Proof Ask** (day 10)
Subject: low-friction ask.
Body: momentum update (X people joined), ask to forward to one person.
CTA: referral/forward prompt.

**Email 5 — Kill Metric CTA** (day 13)
Subject: mild urgency around the validation timeframe.
Body: "We're N signups from our goal. Here's what happens when we hit it: [launch benefit]."
CTA: share link + "Help us hit [target]."

---

## Assumption Mapping — Pre-GTM Gate

Before writing GTM-BRIEF.md, check whether the refined pitch from `.kickstart/ideation.md` contains unvalidated assumptions that would undermine the Kill Criteria.

If the stress-test section of the ideation file contains "we think," "we assume," "we believe," or lacks evidence for willingness-to-pay — run Assumption Mapping first:

1. Read `skills/strategic-frameworks/workflows/assumption-mapping.md`
2. Execute Steps 1–3 (collect, score, classify) using the pitch as the input
3. Feed the top 3 Leap of Faith assumptions directly into the GTM-BRIEF.md Kill Criteria section — those assumptions ARE the kill criteria

This is indeterministic: apply when the pitch's stress-test is shallow or evidence-free. If the ideation file already has concrete evidence for willingness-to-pay and differentiation, proceed directly to GTM-BRIEF.

## Artifact 3: GTM-BRIEF.md

### Pre-Launch (Days 1–7)
Goal: build waitlist foundation before any public push.

| Action | Channel | Success Signal |
|--------|---------|----------------|
| Founding story post | LinkedIn / X | 10+ meaningful replies |
| Seed 2 niche communities | Reddit / Discord | 20+ upvotes or replies |
| Personal outreach to 10 personas | DM / email | 5 signups from network |
| Problem-framing post | Blog / LinkedIn | Saves and shares |

### Launch Week (Days 8–14)
| Day | Action | Channel |
|-----|--------|---------|
| 8 | Public announcement | X + LinkedIn |
| 9 | Community post (problem-first) | Top niche community |
| 10 | Email 3 — Solution Reveal | Waitlist |
| 11 | Ask 5 signups to share | DM |
| 12 | Mid-week pulse (signups so far) | Social |
| 13 | Email 5 — Kill Metric CTA | Waitlist |
| 14 | Kill/continue decision | Internal |

### Post-Launch (Days 15–30)

**If kill metric MET:** thank waitlist, announce next milestone, open beta from top-engagement signups.

**If NOT MET:** diagnose (traffic vs conversion vs wrong persona), test one copy change, run 7-day extension.

### Kill Criteria
Derive from the stress-test section of `.kickstart/ideation.md`. If no explicit metric, default:
- **Continue:** 100 waitlist signups in 14 days — 60%+ from target persona
- **Pivot signal:** <50% of target with low engagement
- **Kill signal:** <25% of target AND no organic sharing

---

## Artifact 4: landing-page.html

Generate a single standalone HTML file. Requirements:
- Tailwind CSS via CDN (no build step)
- Google Fonts — choose 2 fonts matching the concept mood (heading + body)
- Waitlist form using Formspree (`action="https://formspree.io/f/YOUR_FORMSPREE_ID"`)
- Sections: Hero, 3 Feature cards, CTA form, Footer
- Mobile-responsive
- No external JS beyond Tailwind CDN

**Color palette:** derive 3 colors from the concept mood:
- Primary (CTA buttons, links) — pick from Tailwind's color palette
- Background — near-white or light neutral matching the brand feel
- Accent (highlights, icons) — a complementary pop color

**Hero section:**
```html
<h1>{headline from ideation}</h1>
<p>{subhead}</p>
<a href="#waitlist">Get early access →</a>
```

**Features section:** 3 cards from the top 3 value propositions in the pitch. Each card: icon (emoji), title (2–4 words), description (1–2 sentences).

**Waitlist form:**
```html
<form id="waitlist" action="https://formspree.io/f/YOUR_FORMSPREE_ID" method="POST">
  <input type="email" name="email" placeholder="Your email" required />
  <button type="submit">Join the waitlist</button>
</form>
```

**Replace placeholder text** — every field must contain real content from the ideation pitch, not lorem ipsum.

---

## Artifact 5: BRAND-GUIDELINES.md

### Color Palette
Three colors chosen to match the concept's emotional register:

| Role | Color | Hex | Rationale |
|------|-------|-----|-----------|
| Primary | ... | #... | Why it fits the brand |
| Background | ... | #... | ... |
| Accent | ... | #... | ... |

Choose from named palettes (e.g., "warm amber for a food/hospitality concept", "deep indigo for B2B SaaS", "emerald for health/wellness").

### Typography
Two Google Fonts:

| Role | Font | Weight | Why |
|------|------|--------|-----|
| Heading | ... | 700 | ... |
| Body | ... | 400 | ... |

Guidelines: heading font should be distinctive and convey the brand personality; body font should be highly readable at small sizes.

### Voice & Tone
3–5 descriptors with a do/don't example each.

| Descriptor | Do | Don't |
|------------|----|-------|
| ... | "..." | "..." |

Derive from the target personas and problem statement. B2C brands lean warmer; B2B SaaS leans direct and credible.

### Logo Direction
Two sentences describing the logo concept — not the logo itself (Claude can't generate images).
Cover: style (wordmark / icon / combination), mood (geometric precision / organic warmth / bold editorial), and color application (primary on white / reversed on dark).

### Application Notes
- Primary color for all CTA buttons and key links
- Background color for page background and card backgrounds
- Accent for icons, badges, and hover states
- Never use more than 3 colors in a single layout
- Heading font for H1–H3; body font for all body copy and labels

---

## Verification

- [ ] All 5 files exist in `.kickstart/validation/`
- [ ] landing-page.html opens in a browser with no console errors
- [ ] No placeholder text remaining except `YOUR_FORMSPREE_ID` (intentional — requires user's account)
- [ ] MARKETING.md contains real positioning, not generic copy
- [ ] GTM-BRIEF.md kill criteria reference the actual concept
