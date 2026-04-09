---
description: "Run pre-launch readiness checklist before deployment — adapts gates to maturity stage"
allowed-tools:
  - Agent
---

# /cks:launch-check — Pre-Launch Readiness

Dispatch the **launch-readiness** agent (which has `skills: shipping-checklist, product-maturity, monitoring, environment-management` loaded at startup).

## Dispatch

Agent(subagent_type="cks:launch-readiness", prompt="Run the pre-launch shipping checklist for this project. Detect maturity stage from .prd/PRD-STATE.md or ask the user. Run all applicable gate checks (code quality, security, performance, accessibility, infrastructure, documentation). Report blocking issues with recommended fixes. Arguments: $ARGUMENTS")

## Quick Reference

```
/cks:launch-check                  Auto-detect stage, run all gates
/cks:launch-check pilot            Check pilot-stage gates
/cks:launch-check production       Check all production gates
/cks:launch-check --focus security Check security gate only
```
