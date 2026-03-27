# Kickstart Skill

Project enabler — takes a raw idea and transforms it into a fully scaffolded project with research-backed design artifacts and a personalized `.claude/` ecosystem.

## Flow

```
/kickstart "my idea..."
    ↓
Phase 1: INTAKE        — Deep Q&A (domain, users, data model, integrations)
Phase 2: RESEARCH      — Market research (optional — Perplexity or WebSearch)
Phase 3: MONETIZE      — Revenue model evaluation via /monetize (optional)
Phase 4: BRAND         — Brand guidelines — colors, typography, voice (optional)
Phase 5: DESIGN        — Generate ERD → schema.sql → PRD → API design → architecture (5 sub-steps)
Phase 6: HANDOFF       — Feed context into /bootstrap, initialize PRD system
    ↓
Auto-chains into: /cks:new → /cks:next → discover → design → sprint → ...
```

## Files

```
kickstart/
├── SKILL.md                    Main orchestrator
├── README.md                   This file
├── workflows/
│   ├── intake.md               Phase 1 — guided Q&A
│   ├── research.md             Phase 2 — market research (Perplexity or WebSearch)
│   ├── brand.md                Phase 4 — brand guidelines (Canva, website, manual, or generated)
│   ├── design.md               Phase 5 — artifact generation
│   └── handoff.md              Phase 6 — bootstrap + brand persist + PRD init + auto-chain
└── references/
    └── ai-glossary.md          AI vocabulary for educational mode
```

## Output Artifacts

| File | Content |
|------|---------|
| `.kickstart/context.md` | Structured idea context from intake |
| `.kickstart/research.md` | Market research with citations |
| `.kickstart/brand.md` | Brand guidelines — colors, typography, voice, UI prefs |
| `.kickstart/artifacts/PRD.md` | First-draft Product Requirements |
| `.kickstart/artifacts/ERD.md` | Entity Relationship Diagram (Mermaid) |
| `.kickstart/artifacts/schema.sql` | Database schema DDL (target DB dialect) |
| `.kickstart/artifacts/API.md` | API endpoint contracts + request/response shapes |
| `.kickstart/artifacts/ARCHITECTURE.md` | Stack decisions + architecture |
| `.kickstart/bootstrap-context.md` | Pre-filled answers for `/bootstrap` |
| `.brand/guidelines.md` | Persisted brand guidelines for CKS design phase |

## Requirements

- `PERPLEXITY_API_KEY` in `.env.local` (optional — enhances research quality, falls back to WebSearch)
- Phases 2, 3, and 4 are opt-in — Claude asks before running them
- Canva MCP (optional — enables pulling brand kits in Phase 4)
