# CKS — Requirements Register

Tracks functional requirements across all features. Each REQ-ID links to its source PRD.

| REQ-ID | Requirement | PRD | Phase | Priority | Status |
|--------|-------------|-----|-------|----------|--------|
| REQ-001 | Consolidate onto the Attractor spine; rename `sprint-runner` → `attractor-runner`, archive PRD spine | PRD-001 | 03 | Must | Accepted |
| REQ-002 | `tools/github-project-sync.js` GraphQL wrapper with null-config no-op (opt-in) | PRD-001 | 03 | Must | Accepted |
| REQ-003 | GitHub Project: 6-column Kanban, custom fields, label set, 9 Phase items (0–8) | PRD-001 | 03 | Must | Accepted |
| REQ-004 | Bidirectional automation: webhook listener with HMAC-SHA256 verification + 60s reconciliation loop | PRD-001 | 03 | Must | Accepted |
| REQ-005 | Preserve entry points: `/cks:new` (feature spine), `/cks:investigate` → `/cks:debug` (bug spine) | PRD-001 | 03 | Must | Accepted |
| REQ-006 | Every phase ships behind `attractor_mode: false`; Phase 8 flips default-on | PRD-001 | 03 | Must | Accepted |
| REQ-007 | Parallel dispatch layer: Build node dispatches ≤4 worker agents in worktrees, merges results | PRD-001 | 03 | Must | Accepted |
| REQ-008 | Release node composes `go-runner` → `deployer`; auto-closes child Issues; posts release URL | PRD-001 | 03 | Must | Accepted |
| REQ-009 | `/console` replaces `/board` for live telemetry; webhook endpoint hosted on console server | PRD-001 | 03 | Should | Accepted |
| REQ-010 | Migration script + migrator agent v4 detection; v5.0.0 cut via the new Release node (dogfood) | PRD-001 | 03 | Must | Accepted |
