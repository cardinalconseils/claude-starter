# Subscription Billing — State Machine, Dunning, and Trials

## Subscription as a State Machine

A subscription is not a simple boolean. It has defined states with explicit transitions:

```
                  ┌─────────────────────────────┐
                  │          trialing            │
                  │  (trial_end not yet reached) │
                  └────────────┬────────────────┘
                               │ trial ends, first invoice
                    ┌──────────▼──────────┐
       ┌────────────│       active         │◄──────────────┐
       │            │  (paying, in good    │               │
       │            │       standing)      │               │ payment
       │            └────────┬────────────┘               │ succeeds
       │                     │ invoice payment fails        │
       │            ┌────────▼────────────┐               │
       │            │      past_due        │───────────────┘
       │            │  (grace period,      │
       │            │  dunning in progress)│
       │            └────────┬────────────┘
       │                     │ max dunning attempts exhausted
       │            ┌────────▼────────────┐
       │            │       unpaid         │
       │            │  (access revoked,    │
       │            │  subscription paused)│
       │            └─────────────────────┘
       │
       │ cancel_at_period_end = true (user cancels)
       │            ┌─────────────────────┐
       └───────────►│      canceled        │
                    │  (no future billing, │
                    │  access until period │
                    │       ends)          │
                    └─────────────────────┘
```

Handle every arrow explicitly in your webhook handler. Missing a transition means users lose access unexpectedly or retain access after non-payment.

## Data Model

```sql
CREATE TYPE subscription_status AS ENUM (
  'trialing', 'active', 'past_due', 'unpaid', 'canceled', 'incomplete', 'incomplete_expired'
);

CREATE TABLE subscriptions (
  id                   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id              uuid NOT NULL REFERENCES users(id),
  plan_id              varchar(100) NOT NULL,
  status               subscription_status NOT NULL,
  current_period_start timestamptz,
  current_period_end   timestamptz,
  trial_end            timestamptz,
  processor_id         varchar(255) UNIQUE,           -- Stripe Subscription ID
  cancel_at_period_end boolean NOT NULL DEFAULT false,
  canceled_at          timestamptz,
  created_at           timestamptz NOT NULL DEFAULT now(),
  updated_at           timestamptz NOT NULL DEFAULT now()
);

-- Fast lookup: does this user have an active subscription?
CREATE INDEX idx_subscriptions_user_status ON subscriptions(user_id, status);
```

## Trial Periods

```typescript
// Creating a subscription with a 14-day trial
const subscription = await stripe.subscriptions.create({
  customer: customerId,
  items: [{ price: priceId }],
  trial_period_days: 14,
  // Collect payment method upfront but don't charge until trial ends
  payment_settings: { save_default_payment_method: 'on_subscription' },
});
```

### Trial Design Decisions

| Pattern | When to Use |
|---------|-------------|
| Trial without credit card | Maximum signup conversion, higher churn at trial end |
| Trial with credit card required | Lower conversion, higher activation, automatic billing start |
| Freemium → paid | Best for PLG — upgrade is voluntary, not forced |

Require credit card at trial start if you have high trial-to-paid conversion rates. If you don't, requiring the card hurts signup without boosting conversion.

### Handling Trial End

Stripe fires `customer.subscription.updated` when a trial ends. If the trial-end invoice fails, the status moves to `past_due` immediately. Your webhook handler:

```typescript
async function handleSubscriptionUpdated(sub: Stripe.Subscription) {
  const local = await db.subscriptions.findUnique({
    where: { processor_id: sub.id }
  });

  await db.subscriptions.update({
    where: { id: local.id },
    data: {
      status: sub.status,
      current_period_start: new Date(sub.current_period_start * 1000),
      current_period_end: new Date(sub.current_period_end * 1000),
      trial_end: sub.trial_end ? new Date(sub.trial_end * 1000) : null,
      cancel_at_period_end: sub.cancel_at_period_end,
    }
  });

  // Update access based on new status
  await updateUserAccess(local.user_id, sub.status);
}
```

## Dunning Management

Dunning is the process of recovering failed recurring payments. The default Stripe Billing retry schedule: immediately → 3 days → 5 days → 7 days (configurable in Dashboard).

### Dunning Webhook Flow

```
invoice.payment_failed
        ↓
  Update subscription status → past_due
        ↓
  Send "payment failed" email to customer
        ↓
  Stripe retries per schedule
        ↓
  invoice.payment_failed again → send reminder email
        ↓
  (max retries reached)
        ↓
  customer.subscription.updated { status: 'unpaid' }
        ↓
  Revoke access, send "subscription paused" email
```

```typescript
async function handleInvoicePaymentFailed(invoice: Stripe.Invoice) {
  const sub = await db.subscriptions.findUnique({
    where: { processor_id: invoice.subscription as string }
  });

  // Status already updated via subscription.updated event
  // Here: trigger dunning communications

  const attemptCount = invoice.attempt_count;

  if (attemptCount === 1) {
    await queue.add('send-email', {
      template: 'payment-failed-first',
      userId: sub.user_id,
      updateBillingUrl: `${process.env.APP_URL}/billing`,
    });
  } else {
    await queue.add('send-email', {
      template: 'payment-failed-retry',
      userId: sub.user_id,
      attempt: attemptCount,
    });
  }
}
```

### Providing a Self-Service Billing Portal

Let customers update payment methods without contacting support. Stripe Billing Portal is the easiest option:

```typescript
const session = await stripe.billingPortal.sessions.create({
  customer: stripeCustomerId,
  return_url: `${process.env.APP_URL}/billing`,
});

// Redirect user to session.url
```

## Upgrades and Downgrades

### Proration

When a user changes plans mid-period, Stripe calculates proration by default:
- Upgrade: charge the difference immediately
- Downgrade: credit the unused time toward the next invoice

```typescript
// Upgrade: immediate proration (default behavior)
await stripe.subscriptions.update(subscriptionId, {
  items: [{ id: subscriptionItemId, price: newPriceId }],
  proration_behavior: 'create_prorations', // default
});

// Downgrade at period end (no proration, just switch at renewal)
await stripe.subscriptions.update(subscriptionId, {
  items: [{ id: subscriptionItemId, price: newPriceId }],
  proration_behavior: 'none',
  billing_cycle_anchor: 'unchanged',
});
```

### Access Control During Transition

```typescript
function hasActiveAccess(subscription: Subscription): boolean {
  return ['trialing', 'active'].includes(subscription.status)
    || (subscription.status === 'canceled' && subscription.current_period_end > new Date());
  // Users who canceled still get access until their paid period ends
}
```

## Cancellation

Cancellation options:
1. **Immediate**: access removed now, no refund (use sparingly)
2. **At period end**: `cancel_at_period_end = true`, access continues until paid period expires (recommended)

```typescript
// Preferred: cancel at period end
await stripe.subscriptions.update(subscriptionId, {
  cancel_at_period_end: true,
});

// Fire reactivation UX until period_end passes
// If user reactivates before period_end, set cancel_at_period_end = false
await stripe.subscriptions.update(subscriptionId, {
  cancel_at_period_end: false,
});
```

## Verification

- [ ] All subscription status transitions handled in webhook handler
- [ ] `past_due` triggers dunning email sequence
- [ ] `unpaid` revokes access
- [ ] `canceled` preserves access until `current_period_end`
- [ ] Trial end handled via `subscription.updated` webhook (not a cron job)
- [ ] Billing portal link available for self-service payment method updates
- [ ] Plan upgrade charges proration immediately
- [ ] Plan downgrade takes effect at period end (not immediately)
- [ ] `hasActiveAccess()` check uses status + period_end, not just status
- [ ] Reactivation path exists for canceled-but-within-period subscriptions
