---
name: html-shell
description: "Shared HTML nav shell template for CKS artifact mini-site: Design, Brand, PRD, Plan, ERD, Features tabs with brand-adapted colors."
allowed-tools: Read, Write
---

# HTML Artifact Shell — Shared Nav Template

Every CKS HTML artifact (DESIGN.html, PRD-{NNN}.html, PLAN.html, etc.) embeds this nav shell. Produces a mini-site with consistent cross-linking.

## Brand Color Extraction

Before generating any artifact, extract the brand accent color:

1. **Read `.kickstart/brand.md`** — look for hex values near keywords `primary`, `brand`, `accent`, `main`. Example patterns: `primary: #6366f1`, `brand color: #6366f1`, `#6366f1 — primary`.
2. **Fallback: read existing `DESIGN.html`** at project root — look for `--color-primary:` or `--accent:` in the `<style>` block.
3. **Default:** `#6366f1` if neither source yields a hex.

Use the extracted hex as `{extracted-hex}` in the `:root` block below.

## Relative Path Logic

Each artifact lives at a different depth. Calculate relative paths from the artifact's location to reach project-root files:

| Artifact location | Prefix to root |
|---|---|
| Project root (`DESIGN.html`) | `./` (same dir) |
| `docs/prds/PRD-{NNN}.html` | `../../` |
| `.prd/phases/{NN}-{name}/{NN}-PLAN.html` | `../../../` |

Tab hrefs use this prefix: e.g., from `docs/prds/`, the Design tab href is `../../DESIGN.html`.

**Active PRD/Plan tabs:** Read `.prd/PRD-STATE.md` to find the active phase number and PRD number. Link the PRD tab to `{prefix}docs/prds/PRD-{NNN}-{slug}.html` and Plan tab to `{prefix}.prd/phases/{NN}-{name}/{NN}-PLAN.html`.

## Disabled Tab Logic

A tab is **disabled** (greyed out, not clickable) when its target file does not exist. Before rendering, check existence:

```
- DESIGN.html exists at root? → enabled; else disabled
- .kickstart/BRAND.html exists? → enabled; else disabled
- docs/prds/PRD-{NNN}.html exists? → enabled; else disabled
- .prd/phases/{NN}-{name}/{NN}-PLAN.html exists? → enabled; else disabled
- ERD.html, FEATURES.html → disabled until implemented in future phases
```

Apply `class="tab disabled"` for missing files. Apply `class="tab active"` for the current artifact.

## Full Shell Template

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{artifact-name} — {project-name}</title>
  <style>
    :root {
      --accent: {extracted-hex};
      --bg: #0d0d0d;
      --surface: #1a1a1a;
      --text: #f1f1f1;
      --muted: #888;
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, system-ui, 'Segoe UI', sans-serif;
      background: var(--bg);
      color: var(--text);
      min-height: 100vh;
    }

    /* ── Nav ── */
    .artifact-nav {
      background: var(--surface);
      border-bottom: 1px solid #2a2a2a;
      padding: 0 24px;
      position: sticky;
      top: 0;
      z-index: 100;
    }
    .nav-inner {
      display: flex;
      align-items: center;
      gap: 24px;
      height: 52px;
      max-width: 1200px;
      margin: 0 auto;
    }
    .nav-brand {
      font-size: 13px;
      font-weight: 600;
      color: var(--muted);
      letter-spacing: 0.05em;
      text-transform: uppercase;
      white-space: nowrap;
    }
    .tabs { display: flex; gap: 4px; }
    .tab {
      padding: 6px 14px;
      border-radius: 6px;
      font-size: 13px;
      font-weight: 500;
      text-decoration: none;
      color: var(--muted);
      transition: all 0.15s;
    }
    .tab:hover:not(.disabled) { background: #2a2a2a; color: var(--text); }
    .tab.active { background: var(--accent); color: #fff; }
    .tab.disabled { opacity: 0.35; pointer-events: none; cursor: default; }

    /* ── Content ── */
    main {
      max-width: 1200px;
      margin: 0 auto;
      padding: 40px 24px 80px;
    }

    /* ── Responsive ── */
    @media (max-width: 768px) {
      .nav-inner { flex-direction: column; height: auto; padding: 12px 0; gap: 12px; }
      .tabs { flex-wrap: wrap; }
      main { padding: 24px 16px 60px; }
    }

    /* ── Print ── */
    @media print {
      .artifact-nav { display: none; }
      body { background: #fff; color: #000; }
    }
  </style>
</head>
<body>
  <nav class="artifact-nav">
    <div class="nav-inner">
      <span class="nav-brand">{project-name}</span>
      <div class="tabs">
        <a href="{prefix}DESIGN.html" class="tab {active-if-design} {disabled-if-missing}">Design</a>
        <a href="{prefix}.kickstart/BRAND.html" class="tab {active-if-brand} {disabled-if-missing}">Brand</a>
        <a href="{prefix}docs/prds/PRD-{NNN}-{slug}.html" class="tab {active-if-prd} {disabled-if-missing}">PRD</a>
        <a href="{prefix}.prd/phases/{NN}-{name}/{NN}-PLAN.html" class="tab {active-if-plan} {disabled-if-missing}">Plan</a>
        <a href="{prefix}ERD.html" class="tab disabled">ERD</a>
        <a href="{prefix}FEATURES.html" class="tab disabled">Features</a>
      </div>
    </div>
  </nav>
  <main>
    <!-- artifact content here -->
  </main>
</body>
</html>
```

## Agent Instructions for Embedding

When generating any HTML artifact:

1. Extract brand color (follow extraction steps above)
2. Substitute `{extracted-hex}` into `:root { --accent: ... }`
3. Set `{project-name}` from `CLAUDE.md` or `.prd/PRD-PROJECT.md`
4. Set `{artifact-name}` (e.g., "Design System", "Sprint Plan")
5. Set `{prefix}` based on artifact depth (see table above)
6. For each tab: check file existence, set `active` on current tab, `disabled` on missing files
7. Resolve `{NNN}`, `{slug}`, `{NN}`, `{name}` from `.prd/PRD-STATE.md`
8. Place all artifact-specific content inside `<main>...</main>`

## CSS Custom Properties Pattern

The `:root` block is the only place colors are set. All component styles reference `var(--accent)` etc. Never hardcode hex values in component styles — this ensures brand color changes propagate everywhere.
