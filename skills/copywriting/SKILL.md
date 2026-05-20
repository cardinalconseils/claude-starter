---
name: copywriting
description: Copywriting expertise — framework selection (PAS, AIDA, BAB, FAB, 4Ps), format specs, brand voice adaptation, conversion quality signals for hero copy, ad copy, email, and landing pages
allowed-tools: Read
---

# Copywriting Skill

Expertise in writing copy that converts — not copy that sounds good. The difference: converting copy is written for a specific reader at a specific awareness level with a single desired action. Generic copy is written for everyone and converts no one.

## How to Use This Skill

1. Read `config.yaml` for framework specs and format limits — these are hard constraints
2. Read `workflows/framework-selection.dot` to choose the right framework for the context
3. Apply the framework to the brief, constrained by format_specs
4. Adapt tone using `tone_axes` values from `.marketing/brand.md` if available

## Framework Selection

The DOT graph in `workflows/framework-selection.dot` is the decision tree. The short version:

- **Cold audience, pain-driven**: PAS — lead with the problem they already feel
- **Solution-aware, any format**: AIDA — hook them, build desire, one CTA
- **Transformation / testimonial**: BAB — before is where they are, after is where they want to be
- **Feature announcement**: FAB — features are facts, benefits are why they care
- **Long-form / high-ticket**: 4Ps — picture the scenario, promise the outcome, prove it works, push to act

## Brand Voice Adaptation

Before writing, read `.marketing/brand.md` for tone axis scores. Map to copy style:
- `formal_casual <= 2`: full sentences, no contractions, no slang
- `formal_casual >= 4`: contractions OK, conversational asides, shorter sentences
- `rational_emotional <= 2`: lead with data, outcomes quantified, no adjectives
- `rational_emotional >= 4`: sensory language, identity-based framing ("people like you"), metaphors
- `conservative_bold <= 2`: expected benefit claims, safe CTAs ("Learn more")
- `conservative_bold >= 4`: pattern-interrupt headlines, contrarian claims (back with proof)

If `.marketing/brand.md` absent: ask the user for the three tone axis scores before writing.

## Conversion Quality Signals

Copy likely to convert:
- Headline answers "what's in it for me" in <= 7 words
- Reader can identify themselves in the first sentence
- One CTA, not three
- Benefit stated before feature

Copy that won't convert:
- "We are [company], we do [thing]" openers — reader doesn't care yet
- Adjectives without proof ("world-class", "best-in-class", "revolutionary")
- CTA that says "Submit" or "Click here"
- Social proof missing or buried below fold

## Output Structure

Per `config.yaml` format_specs:
- Hero copy -> `.marketing/copy/hero.md`
- Ad copy -> `.marketing/copy/ads.md` (3 variants per format_specs)
- Email -> `.marketing/copy/email.md` (subject + body, references email-sequence skill)
- Landing page -> `.marketing/copy/landing.md`

## Common Rationalizations

| Rationalization | Reality |
|----------------|---------|
| "We'll write copy after the product is done" | Copy IS the product for the first 90 days. It determines whether anyone clicks to see the product. |
| "Our audience is sophisticated — they want detail, not short copy" | Short copy fails when it's vague. Long copy fails when it's padded. Length follows complexity of the ask. |
| "PAS feels too salesy" | PAS is just empathy structured: "I see your problem, here's why it matters, here's what fixes it." |
| "We can't A/B test copy yet" | Write 3 headline variants by default. Pick one to run now, keep the others for later. Cost is minutes. |
