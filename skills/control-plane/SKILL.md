---
name: control-plane
description: "CKS v6 Control Plane — multi-agent orchestration system with personas, memory, RAID logs, and observability. Not a user-facing skill."
version: 1.0.0
---

# Control Plane System

> This is an internal system directory, not a user-facing skill.

The CKS v6 Control Plane provides multi-agent orchestration infrastructure:

- **Personas** — Agent identity definitions, role taxonomy, RAG
- **Memory** — Session snapshots, gatekeeper, correction logs
- **RAID** — Project risks, assumptions, issues, dependencies tracking
- **Observability** — Session metrics, tool counting, cost tracking
- **Improvements** — Self-improvement proposals queue
- **Migrations** — Version-aware state upgrades
- **Coordination** — Agent registry, conflict detection, deconfliction
- **Hardening** — Security posture, least-privilege validation

## Entry Points

- `/cks:control-plane init` — Scaffold `.cks/control-plane/` in project
- `/cks:personas` — View/manage team roster
- `/cks:heartbeat status` — Agent health dashboard
- `/cks:memory` — Project memory KB
- `/cks:cost` — Session cost breakdown

## Directory Layout

```
skills/control-plane/
├── config.yaml.template       → Default control plane config
├── coordination/              → Agent registry, conflict detection
├── db-query-patterns.md       → Supabase queries for control plane
├── hardening/                 → Security hardening recipes
├── improvements/              → Self-improvement proposals
├── memory/                    → Session snapshots, gatekeeper
├── migrations/                → Schema migration scripts
├── observability/             → Metrics, logging, tracing
├── personas/                  → Agent persona definitions
└── raid/                      → Risk, assumption, issue, dependency tracking
```
