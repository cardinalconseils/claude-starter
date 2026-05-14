---
name: payments
description: "Stripe payment integration expertise. Use when implementing Stripe Checkout, Payment Intents, Stripe Elements, Stripe Billing, subscription billing, idempotency keys, Stripe webhook handling, refunds, chargebacks, PCI DSS compliance, dunning, invoicing, or any feature involving money movement via Stripe. Essential for designing payment APIs, implementing secure Stripe checkout, debugging billing issues, or reviewing Stripe integration code."
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Payment Processing

## Overview

Stripe-only expertise for building production-grade payment systems. Covers PaymentIntents, Stripe Checkout, Stripe Elements, Stripe Billing, idempotency, webhook handling, PCI compliance, subscription billing, and refunds.

## When to Use

- Implementing checkout, payment intents, or card capture flows
- Adding subscription billing, trials, or invoicing
- Handling Stripe webhooks
- Preventing duplicate charges (idempotency keys)
- Reviewing payment code for security or correctness
- Designing the data model for financial transactions
- Handling refunds, chargebacks, or payment disputes

## Core Principles

### 1. Idempotency is Non-Negotiable

Every payment initiation MUST be idempotent. Network retries, user double-clicks, and page refreshes cause duplicate requests. Without idempotency keys, users get double-charged. Frontend button disabling is not sufficient — you need server-side idempotency.

→ Full implementation guide: `workflows/idempotency.md`

### 2. Webhooks are the Source of Truth

Never trust the client redirect or the browser callback for payment confirmation. The processor's webhook is the authoritative signal. Build your state machine around webhook events, not redirect parameters.

→ Secure handling guide: `workflows/webhooks.md`

### 3. Never Touch Raw Card Data

Use Stripe Checkout (hosted) or Stripe Elements (embedded iframe). Both keep raw card data off your server. A PCI SAQ-A scope is 22 self-assessment questions. SAQ-D (raw card data on server) requires a QSA audit and annual pentest. The cost ratio is enormous.

→ Compliance reference: `workflows/pci-compliance.md`

### 4. Money is Always Integers

Store amounts in the smallest currency unit — cents for USD, pence for GBP, yen for JPY. `$12.99` → `1299` in the database. Never use floats: `0.1 + 0.2 = 0.30000000000000004`.

### 5. Subscriptions are a State Machine

States: `trialing → active → past_due → canceled → unpaid`. Handle every transition explicitly. Billing failures must trigger dunning logic, not silent failure.

→ Patterns and dunning: `workflows/subscription-billing.md`

## Which Stripe Product to Use

| Use Case | Stripe Product | Notes |
|----------|---------------|-------|
| One-time payments (fastest) | Stripe Checkout | Hosted page, SAQ A, zero frontend work |
| Custom payment UI | Stripe Elements | Embedded iframe, SAQ A-EP, full design control |
| Subscriptions + invoicing | Stripe Billing | Adds recurring logic on top of Checkout/Elements |
| Customer self-service billing | Stripe Customer Portal | Prebuilt UI for plan changes, payment method update, cancellation |
| Marketplaces / platforms | Stripe Connect | Split payments between platform and sellers |
| Tax handling included | Use Stripe Tax add-on | Automatic tax calculation per jurisdiction |

**Decision rule**: Use Stripe Checkout unless you need a custom UI. Use Stripe Billing for any recurring revenue. Use Stripe Connect only for multi-party money flows.

## Payment Flow Architecture

```
Client → Server → Processor (Stripe)
          ↓              ↓
     DB (idempotency)  Webhook
          ↓              ↓
     State Machine ←──── Event
```

1. Client initiates → server creates PaymentIntent + writes idempotency key to DB
2. Client confirms on Stripe (Elements/Checkout) → Stripe processes
3. Stripe fires webhook → server validates signature → updates payment state
4. UI reflects state from DB, not from client redirect

## Data Model

```sql
-- Core payments table
payments (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  idempotency_key  varchar(255) UNIQUE NOT NULL,   -- duplicates return existing record
  user_id          uuid REFERENCES users NOT NULL,
  amount_cents     integer NOT NULL,                -- always integers, never floats
  currency         char(3) NOT NULL DEFAULT 'usd',
  status           payment_status NOT NULL,          -- pending|processing|completed|failed|refunded
  stripe_account   varchar(50) NOT NULL DEFAULT 'stripe',
  processor_id     varchar(255),                     -- Stripe PaymentIntent ID
  amount_refunded_cents integer NOT NULL DEFAULT 0,
  metadata         jsonb,
  created_at       timestamptz NOT NULL DEFAULT now(),
  updated_at       timestamptz NOT NULL DEFAULT now()
);

-- Subscriptions
subscriptions (
  id                   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id              uuid REFERENCES users NOT NULL,
  plan_id              varchar(100) NOT NULL,
  status               subscription_status NOT NULL, -- trialing|active|past_due|canceled|unpaid
  current_period_start timestamptz,
  current_period_end   timestamptz,
  trial_end            timestamptz,
  processor_id         varchar(255),                 -- Stripe Subscription ID
  cancel_at_period_end boolean NOT NULL DEFAULT false,
  canceled_at          timestamptz,
  created_at           timestamptz NOT NULL DEFAULT now()
);
```

## Refunds and Chargebacks

- Refund through Stripe's API (`stripe.refunds.create`) — never create a new payment going the other way
- Track `amount_refunded_cents` to prevent over-refunding
- Partial refunds: pass `amount` to `stripe.refunds.create` to refund less than the full charge
- Chargebacks are initiated by the card network via Stripe's `charge.dispute.created` webhook — respond with evidence within Stripe's deadline (typically 7–21 days)
- Chargeback prevention: capture CVV/AVS, require 3DS for high-value, log IP + device fingerprint

## Testing

| Scenario | Stripe Test Card |
|----------|-----------------|
| Success | `4242 4242 4242 4242` |
| Declined | `4000 0000 0000 0002` |
| Insufficient funds | `4000 0000 0000 9995` |
| 3DS required | `4000 0025 0000 3155` |
| Webhook testing | `stripe listen --forward-to localhost:3000/webhooks/stripe` |

Always test the full webhook path, not just PaymentIntent creation.

## Common Rationalizations

| Rationalization | Reality |
|----------------|---------|
| "We'll add idempotency later" | You'll add it after the first double-charge complaint, under pressure. |
| "Frontend success callback is enough" | Redirects fail, tabs close, JS throws. Webhooks are the only reliable signal. |
| "Floats are fine for money" | `0.1 + 0.2 = 0.30000000000000004`. Use integers. |
| "We'll handle subscriptions manually" | Dunning, proration, trials, and invoice generation are weeks of work. Use Stripe Billing. |
| "PCI is optional for small apps" | If your checkout submits to your server, you're in scope. SAQ-A is 22 questions and costs nothing. |
| "Chargebacks are rare, not our problem" | 0.1% chargeback rate triggers Stripe monitoring. Over 1% risks account termination. |
| "We can test with production keys" | You'll charge real customers. Always use test keys outside production. |

## Verification

- [ ] All payment requests include idempotency keys written to DB before calling processor
- [ ] Payment status updated via webhook only — not from client-side callbacks
- [ ] Webhook signatures verified before processing any event
- [ ] All monetary amounts stored as integers (cents/pence)
- [ ] No raw card data passes through your server
- [ ] Test mode keys used in all non-production environments
- [ ] Webhook processing is itself idempotent (re-delivery safe)
- [ ] Subscription state machine handles all transitions including payment failure
- [ ] Refund logic guards against over-refunding
- [ ] Chargeback webhook handler exists and has evidence-submission flow

## Workflow Files

- `workflows/idempotency.md` — Full idempotency system: key generation, DB schema, race conditions, expiry
- `workflows/webhooks.md` — Secure webhook ingestion, signature verification, event processing
- `workflows/subscription-billing.md` — Subscription state machine, dunning, trials, proration
- `workflows/pci-compliance.md` — PCI DSS scope reduction, SAQ types, compliance checklist
