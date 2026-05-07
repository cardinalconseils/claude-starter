---
name: agentic-os-builder
description: >
  Agentic OS — three-layer architecture for turning any project into a structured, AI-navigable
  operating system. Use when scaffolding project domains, memory layers, or observability dashboards.
  Triggered by /cks:agentic-os, or when the user wants to organize work into domains + tasks,
  set up a Raw/Wiki/Output memory structure, or create a dashboard for non-technical stakeholders.
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion, Glob, Grep
---

# Agentic OS — Domain Knowledge

This skill provides domain expertise for the `agentic-os-builder` agent. Read `templates/` files
when generating scaffolded output.

## The Three Layers

### Layer 1 — Architecture (The Backbone)
Codifies the project's recurring work into navigable, repeatable units.

- **Domains**: Top-level areas of work (e.g. Research, Proposals, Client Reports, Sales)
- **Tasks**: Discrete repeatable activities within a domain (e.g. "Write competitive analysis")
- **Skills**: Standardized instructions for Claude to execute a task consistently every time

Good domains are things the user does repeatedly — not one-time project phases. If a domain only
has one task, it's probably not a real domain.

### Layer 2 — Memory (The Knowledge Store)
Gives Claude a navigable, token-efficient knowledge base across sessions.

```
memory/
  raw/     Staging: meeting notes, research dumps, raw context — process and move to wiki/
  wiki/    Codified: crystallized reports, decisions, reference docs — stable, referenceable
  output/  Deliverables: exports, proposals, client-ready docs — final products
  index.md Navigation map — Claude reads this first to find the right file without scanning all of memory/
```

The index.md is critical. Without it, Claude spends tokens listing and reading memory files to
find context. With it, one read gives a map of what exists and where.

### Layer 3 — Observability (The Dashboard)
Makes the OS visible and accessible to non-technical users.

- **Terminal dashboard** (`/cks:agentic-os status`): Real-time view of domains, memory state, skill shortcuts
- **HTML dashboard** (`dashboard/index.html`): Static file with pre-filled `claude` CLI buttons for each domain's tasks

The HTML dashboard requires no backend — buttons contain pre-filled terminal commands that
stakeholders copy-paste (or technical users can script to run headlessly).

## Domain Naming Guidelines

- Use nouns, not verbs: "Research" not "Researching"
- Match the user's vocabulary — use the words they actually say
- 3–7 domains is the sweet spot — fewer is too coarse, more is hard to navigate
- Each domain should have 3–7 tasks — if it has more, split the domain

## Templates

- `templates/domains.md` — `.agentic-os/domains.md` structure
- `templates/domain-skill.md` — per-domain skill stub
- `templates/memory-index.md` — `memory/index.md` starter
- `templates/dashboard.html` — static HTML dashboard
- `templates/claude-md-injection.md` — CLAUDE.md blocks to inject

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "I'll fill in the skill stubs later" | Stubs are useless unfilled — ask for at least 2 tasks per domain during init |
| "memory/index.md isn't important" | Without it Claude scans all files wasting tokens — it's the most important file |
| "The dashboard is overkill" | It's a static HTML file; the user explicitly asked for it |
| "One domain covers everything" | Monolithic domains defeat the purpose — push back and split |
