# Workflow: Studio website

Produces `design/studio/{slug}/index.html` (and sibling pages when the brief names them).

## Step 1: Ground

- Read the token source (`DESIGN.html` → `DESIGN.md` → `.kickstart/brand.md`). None and no
  Figma link → AskUserQuestion: run design-system first, or supply brand colors and fonts.
- Read the brief, `CONTEXT.md` and PRD for audience, the one action the page exists for,
  and the real copy. Missing copy for a section → ask; never fill it.
- Slug: kebab-case of the page purpose (`pricing`, `launch-landing`).

## Step 2: Pull the reference apart (only when the user named one)

- **URL** → REA `inspect_web_page` for section order, grid, type scale, spacing rhythm and
  font families; `capture_web_screenshot` at 1440 and 375 into `shots/reference-*.png`;
  `analyze_web_bundle` only when the interaction model (sticky nav, scroll effects) matters.
- **Figma link** → the connected Figma server's design-context and variable tools for the
  frame; variables become tokens only when they do not contradict DESIGN.html.
- Write down, in your return, the 3–5 structural moves worth keeping. Do not copy copy.

## Step 3: Structure before pixels

Section list with one job each (hero → proof → how it works → objection → action is a
default, not a rule). Checkpoint: AskUserQuestion with the section list when the session is
interactive; in a routine, state it in the return and proceed.

## Step 4: Build the page

Single self-contained HTML: tokens as CSS custom properties on `:root` with a
`prefers-color-scheme: dark` block, semantic landmarks, mobile-first CSS, one primary CTA.
Apply the craft standards in `SKILL.md`. Images: inline SVG or files under the slug.

## Step 5: Render and fix (loop, max 3 passes)

1. Playwright MCP blocks `file://`. Serve the slug folder on loopback only:
   `(python3 -m http.server 8765 --bind 127.0.0.1 --directory design/studio/{slug} >/dev/null 2>&1 &)`,
   then `browser_navigate` to `http://127.0.0.1:8765/index.html`.
2. For each width in 375, 768, 1440: `browser_resize`, then `browser_take_screenshot`
   (`fullPage: true`, `filename: design/studio/{slug}/shots/{width}-light.png`);
   `browser_emulate_media` dark, repeat to `{width}-dark.png`. Always pass `filename` —
   without it shots land in `.playwright-mcp/` at the project root.
3. `browser_console_messages` level `error` — any error is a defect.
4. Look at every screenshot. Fix overflow, collisions, contrast, orphaned headings, slop.
5. With a reference: `compare_web_screenshots` reference vs result at 1440 — report kept
   and changed structure, not pixel similarity.
6. `browser_close`, then `pkill -f 'http.server 8765'`.

## Step 6: Return

DESIGN block (architect output format) with `Mode: studio`, artifact and screenshot paths,
the token source, the checklist from `SKILL.md` § Verification ticked with evidence, and a
builder hand-off naming the framework port (e.g. "port to `app/(marketing)/page.tsx`").
