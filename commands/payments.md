---
description: "Payment architecture and implementation guidance — idempotency, webhooks, subscriptions, PCI compliance"
argument-hint: "[design | review | idempotency | webhooks | subscriptions | pci] [topic or context]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:payments — Payment Systems Guidance

Parse the sub-command and dispatch the payment-advisor agent with the appropriate focus.

## Routing

| Invocation | Focus |
|------------|-------|
| `/cks:payments design` | Architecture design — flow, data model, processor selection |
| `/cks:payments review` | Review existing payment code for correctness and security |
| `/cks:payments idempotency` | Idempotency key implementation deep-dive |
| `/cks:payments webhooks` | Webhook ingestion, signature verification, event handling |
| `/cks:payments subscriptions` | Subscription state machine, dunning, trials, proration |
| `/cks:payments pci` | PCI DSS scope reduction and compliance checklist |
| `/cks:payments` (no args) | Ask user what they need |

## Dispatch

Parse `$ARGUMENTS` for sub-command and optional topic/context string.

If no sub-command, use `AskUserQuestion`:
```
What do you need help with for payments?
Options: ["Design a payment flow", "Review existing code", "Idempotency keys", "Webhook handling", "Subscription billing", "PCI compliance"]
```

Then dispatch:
```
Agent(subagent_type="cks:payment-advisor", prompt="...")
```

Pass the sub-command as the advisor's focus, plus any additional context from `$ARGUMENTS`.

## Quick Reference

```
/cks:payments design              → Architecture + data model + processor selection
/cks:payments review              → Code review: idempotency, webhooks, PCI gaps
/cks:payments idempotency         → Full idempotency key implementation guide
/cks:payments webhooks            → Webhook signature verification + event handling
/cks:payments subscriptions       → Subscription state machine + dunning + trials
/cks:payments pci                 → PCI scope reduction + SAQ selection + checklist
```
