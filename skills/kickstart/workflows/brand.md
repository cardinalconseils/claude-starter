# Workflow: Brand Guidelines (Phase 4)

## Overview
Captures or generates brand identity — visual (colors, typography, logo), voice (tone, style),
and UI preferences (component library, design direction). Produces `.kickstart/brand.md` which
feeds into the design phase and gets persisted as `.brand/guidelines.md` during handoff.

This phase is **optional** — user must opt in.

## Prerequisites
- `.kickstart/context.md` must exist (run intake first)

## Steps

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "kickstart.phase.started" "_project" "Kickstart Phase 4: Brand" '{"phase_number":"4","phase_name":"Brand"}'`

### Step 1: Determine Brand Source

Ask with AskUserQuestion:
```
question: "Where should I get your brand identity from?"
options:
  - "Canva — pull from my brand kit"
  - "Existing website — extract from a live site"
  - "Manual — I'll describe my brand"
  - "Generate — suggest a brand based on my project"
```

Route to the appropriate sub-step:
- Canva → Step 2A
- Website → Step 2B
- Manual → Step 2C
- Generate → Step 2D

### Step 2A: Pull from Canva Brand Kit

1. Call `mcp__claude_ai_Canva__list-brand-kits` to list available brand kits:
   ```
   mcp__claude_ai_Canva__list-brand-kits(user_intent: "Retrieve brand kit for project brand guidelines")
   ```

2. If multiple kits → ask user to pick one with AskUserQuestion
3. If no kits found → inform user and fall back to Step 2C (Manual)

4. Extract from the brand kit response:
   - Brand name
   - Color palette (primary, secondary, accent)
   - Typography (heading font, body font)
   - Logo assets (note IDs for later use)

5. Present extracted brand to user for confirmation:
   ```
   Pulled from Canva Brand Kit: "{kit_name}"

     Colors:
       Primary:    {color}
       Secondary:  {color}
       Accent:     {color}

     Typography:
       Headings:   {font}
       Body:       {font}

     Logo: {description or "found {N} assets"}

   Does this look right? Anything to adjust?
   ```

6. Ask supplementary questions not covered by Canva (Step 3).

### Step 2B: Extract from Existing Website

1. Ask for the URL:
   ```
   question: "What's the website URL?"
   ```

2. Fetch the site using WebFetch (or Firecrawl if available):
   ```
   WebFetch(url: "{user_url}")
   ```

3. Analyze the HTML/CSS for brand signals:
   - **Colors**: Look for CSS custom properties (`--color-*`, `--primary`, etc.),
     dominant colors in hero sections, button colors, link colors
   - **Typography**: Look for `font-family` declarations, Google Fonts links,
     heading vs body fonts
   - **Logo**: Look for `<img>` in `<header>` or `<nav>`, favicon, og:image
   - **Tone**: Analyze hero text, CTAs, about page copy for voice characteristics

4. Present extracted brand to user for confirmation (same format as 2A step 5).

5. Ask supplementary questions not covered by extraction (Step 3).

### Step 2C: Manual Brand Input

Ask brand questions one at a time with AskUserQuestion:

**Visual Identity:**

1. **Brand name & tagline**
   ```
   question: "What's your brand name? Any tagline?"
   ```

2. **Color palette**
   ```
   question: "What's your primary brand color?"
   options:
     - "Blue (trust, professional)"
     - "Green (growth, health)"
     - "Purple (creative, premium)"
     - "Red (energy, urgency)"
     - "Orange (friendly, affordable)"
     - "Black (luxury, minimal)"
     - "I have specific hex codes"
   ```
   If hex codes → ask for primary, secondary, and accent colors.

3. **Typography**
   ```
   question: "What typography style fits your brand?"
   options:
     - "Clean & modern (Inter, Geist, DM Sans)"
     - "Professional & traditional (Georgia, Merriweather)"
     - "Technical & monospace (JetBrains Mono, Fira Code)"
     - "Playful & rounded (Nunito, Poppins)"
     - "I have specific fonts"
   ```

4. **Logo**
   ```
   question: "Do you have a logo?"
   options:
     - "Yes — I'll provide it later"
     - "No — I'll create one later"
     - "Use text/initials as logo for now"
   ```

### Step 2D: Generate Brand Suggestion

Use the project context from `.kickstart/context.md` to generate a brand suggestion:

1. Read context.md for: project name, target users, problem domain, tone signals
2. Generate a brand identity based on domain conventions:

   | Domain | Typical Brand Direction |
   |--------|------------------------|
   | B2B SaaS | Clean, professional, blue/purple tones, Inter/Geist |
   | Consumer app | Friendly, vibrant, gradient-friendly, rounded fonts |
   | Developer tools | Minimal, dark-mode-first, monospace accents, high contrast |
   | Health/wellness | Soft, green/teal, organic shapes, approachable fonts |
   | Finance/fintech | Trust-focused, blue/navy, sharp typography, data-dense |
   | Creative/design | Bold, colorful, expressive, unique typography |
   | E-commerce | Conversion-focused, clear CTAs, product photography emphasis |

3. Present 2-3 direction options with AskUserQuestion:
   ```
   Based on your project ({domain} targeting {users}), here are brand directions:

   Option A: "{direction name}"
     Colors: {palette description}
     Fonts: {typography}
     Vibe: {one-line mood}

   Option B: "{direction name}"
     Colors: {palette description}
     Fonts: {typography}
     Vibe: {one-line mood}

   Option C: "Custom"
     I'll ask you specific questions
   ```

4. If Custom → fall through to Step 2C.

### Step 3: Supplementary Questions

After any source (Canva/website/manual/generated), ask what's still missing:

**Brand Voice** (always ask):
```
question: "How should your product communicate?"
options:
  - "Professional & authoritative"
  - "Friendly & conversational"
  - "Technical & precise"
  - "Playful & casual"
  - "Minimal — let the product speak"
```

**UI Component Preference** (always ask):
```
question: "What UI component style do you prefer?"
options:
  - "shadcn/ui (modern, minimal, customizable)"
  - "Material Design (Google-style, comprehensive)"
  - "Ant Design (enterprise, data-heavy)"
  - "Chakra UI (accessible, composable)"
  - "Custom components (from scratch)"
  - "Let Claude recommend based on stack"
```

**Design Direction** (only if not already clear):
```
question: "What's the visual feel?"
options:
  - "Minimal & clean (lots of whitespace)"
  - "Dense & data-rich (dashboards, tables)"
  - "Bold & expressive (gradients, animations)"
  - "Dark mode first"
  - "Light mode first"
```

### Step 4: Save Brand Guidelines

Create `.kickstart/brand.md`:

```markdown
# Brand Guidelines

**Generated:** {date}
**Source:** {Canva Brand Kit | Website Extraction | Manual | Generated}
**Project:** {project name}

## Brand Identity

**Name:** {brand name}
**Tagline:** {tagline or "—"}

## Visual Identity

### Color Palette
| Role | Value | Usage |
|------|-------|-------|
| Primary | {hex} | Main actions, links, focus states |
| Secondary | {hex} | Supporting elements, secondary buttons |
| Accent | {hex} | Highlights, badges, notifications |
| Background | {hex} | Page background |
| Surface | {hex} | Cards, modals, elevated elements |
| Text | {hex} | Primary text |
| Text Muted | {hex} | Secondary text, placeholders |
| Error | {hex} | Error states, destructive actions |
| Success | {hex} | Success states, confirmations |
| Warning | {hex} | Warning states, caution |

### Typography
| Role | Font | Weight | Size |
|------|------|--------|------|
| Headings | {font family} | {weight} | {scale} |
| Body | {font family} | {weight} | {base size} |
| Code/Mono | {font family} | {weight} | {size} |

### Logo
{Description of logo, asset references, or "TBD"}

## Brand Voice

**Tone:** {professional | friendly | technical | playful | minimal}
**Writing style:**
- {Guideline 1 — e.g., "Use active voice"}
- {Guideline 2 — e.g., "Keep sentences under 20 words"}
- {Guideline 3 — e.g., "Address users as 'you', not 'the user'"}

**Examples:**
- Button labels: {e.g., "Get Started" not "Click Here"}
- Error messages: {e.g., "Couldn't save — check your connection" not "Error 500"}
- Empty states: {e.g., "No projects yet — create your first one" not "No data found"}

## UI Preferences

**Component Library:** {shadcn/ui | Material | Ant | Chakra | Custom}
**Design Direction:** {minimal | dense | bold | dark-first | light-first}
**Border Radius:** {sharp (2px) | medium (6px) | rounded (12px) | pill (full)}
**Spacing Scale:** {compact (4px base) | comfortable (8px base) | spacious (12px base)}
**Shadows:** {none | subtle | prominent}
**Animations:** {none | subtle transitions | expressive}

## Design Tokens (CSS Custom Properties)

```css
:root {
  /* Colors */
  --color-primary: {hex};
  --color-secondary: {hex};
  --color-accent: {hex};
  --color-background: {hex};
  --color-surface: {hex};
  --color-text: {hex};
  --color-text-muted: {hex};
  --color-error: {hex};
  --color-success: {hex};
  --color-warning: {hex};

  /* Typography */
  --font-family-sans: '{heading font}', system-ui, sans-serif;
  --font-family-mono: '{mono font}', monospace;
  --font-size-xs: 0.75rem;
  --font-size-sm: 0.875rem;
  --font-size-base: 1rem;
  --font-size-lg: 1.125rem;
  --font-size-xl: 1.25rem;
  --font-size-2xl: 1.5rem;
  --font-weight-normal: 400;
  --font-weight-medium: 500;
  --font-weight-bold: 700;

  /* Spacing */
  --space-1: {base}px;
  --space-2: {base*2}px;
  --space-3: {base*3}px;
  --space-4: {base*4}px;
  --space-6: {base*6}px;
  --space-8: {base*8}px;

  /* Borders */
  --radius-sm: {value};
  --radius-md: {value};
  --radius-lg: {value};
  --radius-full: 9999px;

  /* Shadows */
  --shadow-sm: {value or "none"};
  --shadow-md: {value or "none"};
  --shadow-lg: {value or "none"};
}
```

---
*Brand guidelines via /kickstart. Update as your brand evolves.*
```

### Step 5: Offer DESIGN.md Generation (Optional)

After saving brand.md, offer to generate a full DESIGN.md at the project root:

```
AskUserQuestion:
  question: "Brand tokens captured. Generate a full DESIGN.md for AI design tools (Stitch, v0, Lovable)?"
  options:
    - "Yes — generate DESIGN.md from these brand tokens"
    - "Skip — brand.md is enough for now"
```

**If Yes:**
Dispatch the design-system-generator agent to expand brand tokens into a complete 9-section DESIGN.md:
```
Agent(subagent_type="cks:design-system-generator", prompt="Generate DESIGN.md from .kickstart/brand.md. The brand tokens are already extracted — expand them into the full 9-section format.")
```

Wait for completion, then verify `DESIGN.md` exists at project root.

**If Skip:** Continue to validation.

### Step 6: Validate & Report

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "kickstart.phase.completed" "_project" "Kickstart Phase 4 complete" '{"phase_number":"4"}'`

**Validate:** Check that `.kickstart/brand.md` exists and contains (and optionally `DESIGN.md` at project root):
- `## Visual Identity` section with color table
- `## Brand Voice` section
- `## Design Tokens` section with CSS custom properties

**Update state:**
```
Update .kickstart/state.md:
  Phase 4 (Brand) → status: done, completed: {date}
  last_phase: 4
  last_phase_status: done
  brand_opted: true
```

**Report:**
```
  [4] Brand           ✅ done
      Output: .kickstart/brand.md
      Source: {Canva | Website | Manual | Generated}
      Colors: {N} tokens | Fonts: {heading} + {body} | Voice: {tone}
      DESIGN.md: {✅ generated | ⏭ skipped}
```

## Post-Conditions
- `.kickstart/brand.md` exists with complete brand guidelines
- `.kickstart/state.md` updated with Brand → done
- Design tokens are CSS-ready for direct use in the design phase
- Brand voice guidelines inform copy decisions throughout the lifecycle
