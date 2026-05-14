# Payment Webhooks — Secure Handling Guide

## Why Webhooks Are the Source of Truth

Payment flows are asynchronous. The client redirect after checkout is unreliable:
- User closes the tab before the redirect fires
- JavaScript error in the success handler
- Network timeout before the confirmation page loads
- 3DS authentication delays the final confirmation

The webhook from the processor is fired server-to-server, retried by the processor if it fails, and does not depend on the user's browser. **Never confirm a payment based on a client callback. Always confirm via webhook.**

## Webhook Architecture

```
Stripe → POST /webhooks/stripe → Validate signature
                                        ↓
                                  Fetch event from Stripe (optional, for security)
                                        ↓
                                  Look up payment by processor_id
                                        ↓
                                  Check if already processed (idempotency)
                                        ↓
                                  Update state machine
                                        ↓
                                  Enqueue downstream work (email, provisioning)
                                        ↓
                                  Return 200 immediately
```

## Signature Verification

Every incoming webhook must have its signature verified before you process the body. Skip this check and attackers can fire fake payment confirmations.

```typescript
import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);
const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

async function handleStripeWebhook(req: Request, res: Response) {
  const sig = req.headers['stripe-signature'];

  let event: Stripe.Event;
  try {
    // req.body must be the raw Buffer, not parsed JSON
    event = stripe.webhooks.constructEvent(req.body, sig, webhookSecret);
  } catch (err) {
    console.error('Webhook signature verification failed:', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  // Signature verified — safe to process
  await processEvent(event);
  res.json({ received: true });
}
```

**Critical**: The request body must be raw bytes for signature verification. If you run `express.json()` globally, it will parse the body before the webhook handler sees it, breaking verification. Use `express.raw()` for the webhook route specifically:

```typescript
app.post('/webhooks/stripe',
  express.raw({ type: 'application/json' }), // raw body for signature check
  handleStripeWebhook
);
```

## Idempotent Event Processing

Stripe retries webhooks if your endpoint returns a non-2xx status. Your handler will receive the same event multiple times. Processing it twice must produce the same result as processing it once.

```typescript
async function processEvent(event: Stripe.Event) {
  // Check if already processed
  const alreadyHandled = await db.webhookEvents.findUnique({
    where: { stripe_event_id: event.id }
  });
  if (alreadyHandled) return; // idempotent: skip duplicate delivery

  // Process the event
  switch (event.type) {
    case 'payment_intent.succeeded':
      await handlePaymentSucceeded(event.data.object as Stripe.PaymentIntent);
      break;
    case 'payment_intent.payment_failed':
      await handlePaymentFailed(event.data.object as Stripe.PaymentIntent);
      break;
    case 'customer.subscription.updated':
      await handleSubscriptionUpdated(event.data.object as Stripe.Subscription);
      break;
    case 'customer.subscription.deleted':
      await handleSubscriptionCanceled(event.data.object as Stripe.Subscription);
      break;
    case 'invoice.payment_failed':
      await handleInvoicePaymentFailed(event.data.object as Stripe.Invoice);
      break;
  }

  // Mark as processed
  await db.webhookEvents.create({
    data: { stripe_event_id: event.id, event_type: event.type, processed_at: new Date() }
  });
}
```

### Webhook Events Table

```sql
CREATE TABLE webhook_events (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  stripe_event_id varchar(255) UNIQUE NOT NULL,  -- idempotency key
  event_type     varchar(100) NOT NULL,
  processed_at   timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX idx_webhook_events_stripe_id ON webhook_events(stripe_event_id);
```

## Critical Event Types (Stripe)

| Event | Trigger | Action |
|-------|---------|--------|
| `payment_intent.succeeded` | Payment completed | Fulfill order, mark payment completed |
| `payment_intent.payment_failed` | Payment declined | Mark payment failed, notify user |
| `customer.subscription.created` | Subscription started | Grant access |
| `customer.subscription.updated` | Plan changed, trial ended | Update local subscription record |
| `customer.subscription.deleted` | Subscription canceled | Revoke access at period end |
| `invoice.payment_succeeded` | Recurring payment succeeded | Extend access, send receipt |
| `invoice.payment_failed` | Recurring payment failed | Start dunning, notify user |
| `charge.dispute.created` | Chargeback initiated | Flag order, prepare evidence |
| `charge.refunded` | Refund issued | Update refund amount |

## Return 200 Fast, Process Async

Your webhook endpoint must return 200 within ~30 seconds or Stripe considers it failed and retries. For heavy processing (sending emails, provisioning servers, updating many records), return 200 immediately and enqueue the work:

```typescript
async function handlePaymentSucceeded(intent: Stripe.PaymentIntent) {
  // Synchronous: update payment state (fast, must happen)
  await db.payments.update({
    where: { processor_id: intent.id },
    data: { status: 'completed' }
  });

  // Async: enqueue downstream work (slow, can be retried)
  await queue.add('send-receipt', { paymentId: intent.metadata.payment_id });
  await queue.add('provision-access', { userId: intent.metadata.user_id });
}
```

## Webhook Endpoint Security

- The route must not require authentication (Stripe cannot send an auth token)
- Signature verification IS the authentication
- Do not log the raw request body in production (it contains card fingerprints and PII)
- Return 200 even if downstream processing fails — Stripe will retry if you return 4xx/5xx, which can cause infinite loops if the error is permanent

## Local Development

Use the Stripe CLI to forward webhooks to your local server:

```bash
# Install Stripe CLI, then:
stripe login
stripe listen --forward-to localhost:3000/webhooks/stripe

# The CLI outputs your local webhook signing secret:
# > Ready! Your webhook signing secret is whsec_xxx (^C to quit)
# Use this as STRIPE_WEBHOOK_SECRET in your .env
```

## Verification

- [ ] Signature verified using raw body before any processing
- [ ] Webhook route uses `express.raw()` (not `express.json()`)
- [ ] Each event type has an idempotency check before processing
- [ ] `webhook_events` table tracks processed event IDs
- [ ] Endpoint returns 200 within 30 seconds (heavy work is queued)
- [ ] All subscription lifecycle events handled (created, updated, deleted)
- [ ] Invoice payment failure triggers dunning flow
- [ ] `charge.dispute.created` handler exists
- [ ] Webhook secret stored in environment variable, not hardcoded
- [ ] Local dev uses Stripe CLI with local signing secret
