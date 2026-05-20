# Gotchas & Traps
<!-- Append-only. Each entry: ## [YYYY-MM-DD] Gotcha Title -->
<!-- Gotchas: non-obvious behaviors, traps, warnings for future agents -->

## [YYYY-MM-DD] Example Gotcha
The `memory-sync.sh` script always exits 0, even on curl failure. This is intentional — sync errors must never block the Stop hook. Check `.cks/control-plane/memory/` files directly if sync seems stuck.
