---
description: "Money on track — cost audit, margin per client, invoice draft (gated send), budget burn, SR&ED evidence. Dispatches the finops role."
argument-hint: "[audit | margin | invoice <client> | burn | sred <fiscal-year>] [context]"
allowed-tools: [Read, Agent]
---

# /cks:finops — FinOps

Parse `$ARGUMENTS`: the first word is the mode (`audit`, `margin`, `invoice`, `burn`,
`sred`); the rest is context (a client, a fiscal year, a period). No args → `burn`.

```
Agent(subagent_type="cks:finops", prompt="
  Mode: {mode}
  Context: {rest of arguments, or none}
  Project: {current directory}
  Read skills/finops/SKILL.md and the workflow for this mode, then the state it names.
  Report the headline figure with currency, period, and sources; gated actions as GATED: lines.
")
```

## Quick Reference

```
/cks:finops                     Burn this period — <spend> of <ceiling>
/cks:finops audit               Token / API / infra audit, unit economics, caps
/cks:finops margin              Margin per client and per venture
/cks:finops invoice acme        Invoice draft for a client — send stays gated
/cks:finops burn                Burn line for the mandate brief
/cks:finops sred 2026           SR&ED technical narrative skeleton from git + .prd/
```

State: `.finops/BUDGET.md`, `.finops/costs.jsonl`, `.finops/reports/`, `.finops/invoices/`,
`.finops/sred/`, and the cross-venture `ledger.jsonl` under the HQ finops directory.
