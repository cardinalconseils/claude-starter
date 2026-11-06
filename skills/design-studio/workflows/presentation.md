# Workflow: Studio presentation deck

Produces `design/studio/{slug}/deck.html` — one self-contained file, 16:9, keyboard driven.

## Step 1: Ground

- Tokens as in `workflows/website.md` Step 1. A deck with no token source still asks.
- Audience, the single decision or belief the deck must leave behind, and the time slot.
  No stated outcome → AskUserQuestion; a deck without one becomes a document with slides.
- Source material: brief, PRD, metrics the user supplied. Every number on a slide needs a
  source in the brief; an unsourced number is a question.

## Step 2: Storyline before slides

One line per slide — the sentence the audience should repeat — in an arc: situation →
complication → resolution → evidence → ask. 1 idea per slide; 8–15 slides for 20 minutes.
Checkpoint: AskUserQuestion with the storyline when interactive; in a routine, state it in
the return and proceed. With a Figma deck link, read its frames for layout and variables
first and keep the user's structure unless the brief asks to rework it.

## Step 3: Build the deck

- Each slide a `<section>` at 1920×1080 scaled to the viewport with CSS
  (`aspect-ratio: 16/9`, `width: min(100vw, 177.78vh)`); never scroll inside a slide.
- Slide headline is the full sentence from the storyline, not a topic label.
- Body ≥ 24px; ≤ 30 words of body per slide; charts as inline SVG with direct labels, no
  legend when labels fit, one highlighted series.
- Navigation: ←/→, PageUp/PageDown, Home/End; `#n` deep link; slide counter; `aria-live`
  announces the slide title; print stylesheet puts one slide per page for PDF export.
- Craft standards and slop gate from `SKILL.md`; decks get one layout grid reused, not a
  new composition per slide.

## Step 4: Render and fix (loop, max 3 passes)

1. Serve and navigate as in `workflows/website.md` Step 5.1, to `/deck.html`.
2. `browser_resize` to 1920×1080; for each slide navigate to `#n` and
   `browser_take_screenshot` with `filename: design/studio/{slug}/shots/slide-{nn}.png`.
   Repeat slide 1 at 1280×720.
3. `browser_console_messages` level `error` — any error is a defect.
4. Look at every slide: text overflowing its slide, under-24px type, more than one focal
   point, chart without a takeaway in the headline → fix.
5. `browser_close`, then `pkill -f 'http.server 8765'`.

## Step 5: Return

DESIGN block with `Mode: studio`, deck and screenshot paths, the storyline, token source,
the `SKILL.md` § Verification checklist with evidence, and how to export
("open deck.html, Print → Save as PDF, one slide per page"). `.pptx` requested → a gap.
