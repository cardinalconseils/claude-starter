# PRD File System Layout

```
.prd/                               # Planning state
├── PRD-PROJECT.md                  # Project context
├── PRD-REQUIREMENTS.md             # Tracked requirements with REQ-IDs
├── PRD-STATE.md                    # Session continuity + progress
├── PRD-ROADMAP.md                  # Feature roadmap + phase status
├── PROJECT-MANIFEST.md             # Project composition — sub-projects, deps, build order (from kickstart)
├── logs/
│   ├── lifecycle.jsonl             # Structured event log (append-only JSONL)
│   ├── .current_session_id         # Session correlation (gitignored)
│   ├── features/                   # Per-feature log extracts (optional)
│   └── metrics.json                # Cached velocity metrics
└── phases/
    ├── 01-feature-name/
    │   ├── 01-CONTEXT.md           # Phase 1: Discovery output (11 elements)
    │   ├── 01-DESIGN.md            # Phase 2: Design summary
    │   ├── design/                 # Phase 2: Design artifacts
    │   │   ├── ux-flows.md
    │   │   ├── screens/
    │   │   └── component-specs.md
    │   ├── 01-PLAN.md              # Phase 3: Sprint plan
    │   ├── 01-TDD.md              # Phase 3: Technical design document
    │   ├── 01-SUMMARY.md           # Phase 3: Implementation summary
    │   ├── 01-VERIFICATION.md      # Phase 3: QA results
    │   ├── 01-REVIEW.md            # Phase 4: Review feedback + retro
    │   └── 01-BACKLOG.md           # Phase 4: Iteration backlog (if any)
    └── 02-feature-name/
        └── ...

.context/                           # Persistent research briefs
docs/prds/                          # Individual PRD documents
docs/ROADMAP.md                     # Public roadmap
CHANGELOG.md                        # Auto-generated
```
