---
name: project_global_memory_layer
description: CKS global memory layer design — three-tier Hermes-aligned hierarchy, spec and plan written 2026-06-06
metadata:
  type: project
---

CKS is getting a global `~/.cks/memory/` tier (user-level) added to the existing project-level and session-level memory. Design mirrors Hermes three-tier hierarchy.

**Why:** Learnings from one project never reached another. Hermes Agent solves this with a global tier; CKS was missing it.

**How to apply:** When working on memory-related features in CKS, the global tier is at `~/.cks/memory/user/` (facts, preferences, gotchas). Writes are always human-confirmed. SessionStart loads it unconditionally (before control-plane gate). New agent `global-memory-writer` handles writes with AskUserQuestion. `/cks:memory --global` routes to this agent.

Spec+plan: deleted post-implementation (docs/superpowers/ removed 2026-06-07)
Status: Ready to implement (2026-06-06)
