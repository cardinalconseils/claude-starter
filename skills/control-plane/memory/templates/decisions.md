# Architectural Decisions
<!-- Append-only. Each entry: ## [YYYY-MM-DD] Decision Title -->
<!-- Decisions: why something was built the way it was -->

## [YYYY-MM-DD] Example Decision
Chose file-first memory (`.md`) over DB-first because files survive DB outages and cost nothing in dev mode. Supabase sync is additive durability, not the primary store.
