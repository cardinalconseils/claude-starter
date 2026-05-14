# Payment Idempotency — Full Implementation Guide

## The Problem

Duplicate payment requests are inevitable:

| Cause | Mechanism |
|-------|-----------|
| User double-clicks checkout button | Two simultaneous POST requests |
| Network timeout on client | Client retries the same request |
| User refreshes the success page | Browser re-submits or re-calls |
| Server-side retry after timeout | Background job retries failed call |
| Load balancer retry on 5xx | Infrastructure-level duplication |

Frontend button disabling only addresses double-click. It does nothing for the other four.

## The Solution: Idempotency Keys

An idempotency key is a unique token generated per checkout session. It is:
- Generated **client-side** at checkout initiation (or server-side at session creation)
- Tied to a specific purchase attempt — not a user, not a product, but a specific attempt
- Passed to the payment processor on every payment call
- Stored in your database so you can detect and short-circuit duplicates

### Key Generation

```javascript
// Client-side: generate once when checkout session starts
const idempotencyKey = crypto.randomUUID(); // UUIDv4, 36 chars, unpredictable

// Or server-side at session creation
const idempotencyKey = `checkout_${userId}_${Date.now()}_${crypto.randomBytes(8).toString('hex')}`;
```

Rules:
- Must be globally unique (UUID or similar entropy)
- Must be tied to the attempt, not the user (same user can have multiple failed attempts)
- Must be persisted before any payment call — generate and save, then pay

## Database Schema

```sql
CREATE TYPE payment_status AS ENUM ('pending', 'processing', 'completed', 'failed', 'refunded');

CREATE TABLE payments (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  idempotency_key  varchar(255) UNIQUE NOT NULL,
  user_id          uuid NOT NULL REFERENCES users(id),
  amount_cents     integer NOT NULL CHECK (amount_cents > 0),
  currency         char(3) NOT NULL DEFAULT 'usd',
  status           payment_status NOT NULL DEFAULT 'pending',
  processor        varchar(50) NOT NULL,
  processor_id     varchar(255),             -- Stripe PaymentIntent ID, set after creation
  error_message    text,                     -- last error, for debugging
  metadata         jsonb DEFAULT '{}',
  created_at       timestamptz NOT NULL DEFAULT now(),
  updated_at       timestamptz NOT NULL DEFAULT now()
);

-- Index for fast idempotency lookups
CREATE UNIQUE INDEX idx_payments_idempotency_key ON payments(idempotency_key);
-- Index for user payment history
CREATE INDEX idx_payments_user_id ON payments(user_id);
```

## The Complete Idempotent Payment Workflow

```
Step 1: Client clicks checkout
        ↓
        Generate idempotency_key (UUID)
        ↓
Step 2: POST /api/checkout { idempotency_key, amount, ... }
        ↓
Step 3: Server checks DB for idempotency_key
        ├── EXISTS + status = 'completed' → return existing payment (no charge)
        ├── EXISTS + status = 'processing' → return existing payment (charge in flight)
        ├── EXISTS + status = 'failed'     → allow retry (user can try again)
        └── NOT EXISTS → continue ↓
        ↓
Step 4: BEGIN TRANSACTION
        INSERT INTO payments (idempotency_key, user_id, amount_cents, status='pending')
        COMMIT  ← write to DB BEFORE calling Stripe
        ↓
Step 5: Call Stripe with idempotency_key header
        stripe.paymentIntents.create({ amount, currency }, { idempotencyKey })
        ↓
Step 6: Update payment.status = 'processing', payment.processor_id = intent.id
        ↓
Step 7: Stripe fires webhook → server validates signature → updates status = 'completed'|'failed'
```

### Why Write to DB Before Calling Stripe

If you call Stripe first, then save to DB, and the DB write fails: you've charged the user but have no record. If you write to DB first, then call Stripe, and Stripe fails: you have a `pending` record you can retry safely. Write first, pay second.

## Server Implementation

```typescript
async function initiatePayment(req: Request, res: Response) {
  const { idempotencyKey, amountCents, currency, userId } = req.body;

  // Step 1: Check for existing record
  const existing = await db.payments.findUnique({
    where: { idempotency_key: idempotencyKey }
  });

  if (existing) {
    if (existing.status === 'completed') {
      return res.json({ status: 'already_completed', payment: existing });
    }
    if (existing.status === 'processing') {
      return res.json({ status: 'in_progress', payment: existing });
    }
    // 'failed' or 'pending' — allow fresh attempt below
    // but update existing record rather than inserting new one
  }

  // Step 2: Write to DB before calling Stripe
  const payment = await db.payments.upsert({
    where: { idempotency_key: idempotencyKey },
    create: {
      idempotency_key: idempotencyKey,
      user_id: userId,
      amount_cents: amountCents,
      currency,
      status: 'pending',
      processor: 'stripe',
    },
    update: { status: 'pending', error_message: null }, // reset for retry
  });

  // Step 3: Call Stripe (pass same idempotency key)
  try {
    const intent = await stripe.paymentIntents.create(
      { amount: amountCents, currency, metadata: { payment_id: payment.id } },
      { idempotencyKey } // Stripe deduplicates on their side too
    );

    await db.payments.update({
      where: { id: payment.id },
      data: { status: 'processing', processor_id: intent.id },
    });

    return res.json({ clientSecret: intent.client_secret });
  } catch (err) {
    await db.payments.update({
      where: { id: payment.id },
      data: { status: 'failed', error_message: err.message },
    });
    throw err;
  }
}
```

## Race Conditions

Two simultaneous requests with the same idempotency key will both pass the initial DB check before either writes. Handle with a unique constraint + catch:

```typescript
try {
  const payment = await db.payments.create({ data: { idempotency_key, ... } });
} catch (err) {
  if (err.code === 'P2002') { // Prisma unique constraint violation
    // Race condition — another request won. Fetch and return that record.
    const existing = await db.payments.findUnique({ where: { idempotency_key } });
    return res.json({ status: 'in_progress', payment: existing });
  }
  throw err;
}
```

The database unique constraint is the final safety net. The application-level check is an optimization to avoid the constraint violation path.

## Stripe's Own Idempotency

Stripe stores idempotency keys for **24 hours**. If you send the same key within 24 hours with different parameters, Stripe returns a 400. This is a feature: it prevents accidental parameter drift on retries.

After 24 hours, a new request with the same key creates a new charge. This is why your DB-level idempotency key must have a longer TTL than Stripe's, and must carry the status so you can detect completions.

## Key Expiry

- Keep idempotency keys in DB indefinitely (they're small and invaluable for auditing)
- Do NOT delete completed payment records — they're your transaction history
- For abandoned `pending` records (user left before paying): safe to mark `failed` after 1 hour via a scheduled job

## Verification

- [ ] Idempotency key generated before user clicks pay (not on click)
- [ ] Key persisted to DB before calling processor
- [ ] Duplicate key returns existing payment state without new charge
- [ ] Race condition handled via unique constraint catch
- [ ] Stripe called with same idempotency key as DB record
- [ ] Failed payments allow retry (same key, status reset to 'pending')
- [ ] Completed payments are not retried regardless of client retries
