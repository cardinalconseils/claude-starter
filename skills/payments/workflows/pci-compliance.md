# PCI DSS Compliance — Scope Reduction Guide

## What PCI DSS Is

The Payment Card Industry Data Security Standard (PCI DSS) applies to any entity that stores, processes, or transmits cardholder data. Non-compliance risks fines ($5k–$100k/month) and loss of ability to accept card payments.

The good news: modern payment processors let you minimize your scope dramatically through tokenization.

## PCI Scope by Integration Method

| Integration | What Your Server Sees | SAQ Type | Complexity |
|-------------|----------------------|----------|------------|
| Stripe Checkout (hosted page) | Nothing — user leaves your site | SAQ A | 22 questions |
| Stripe Elements (embedded JS) | Payment token only — never card number | SAQ A-EP | ~40 questions |
| Direct API (your server handles card number) | Full PAN, CVV, expiry | SAQ D | 200+ questions + QSA audit |

**Always target SAQ A or SAQ A-EP. Never build SAQ D scope unless a QSA has told you it's required.**

## SAQ A: Maximum Scope Reduction

Use Stripe Checkout (hosted payment page). Your server:
- Creates a Checkout Session via Stripe API
- Redirects user to `checkout.stripe.com`
- Receives webhook confirmation when payment succeeds

You never see a card number. Stripe's servers are in scope; yours are not.

```typescript
const session = await stripe.checkout.sessions.create({
  payment_method_types: ['card'],
  line_items: [{ price: priceId, quantity: 1 }],
  mode: 'payment',  // or 'subscription'
  success_url: `${process.env.APP_URL}/success?session_id={CHECKOUT_SESSION_ID}`,
  cancel_url: `${process.env.APP_URL}/cancel`,
  metadata: { idempotency_key: idempotencyKey, user_id: userId },
});

res.redirect(303, session.url);
```

**SAQ A compliance checklist:**
- [ ] No card data is transmitted to or stored on your servers
- [ ] Payment page is hosted by a PCI-compliant processor (Stripe, PayPal)
- [ ] All links from your site to the payment page use HTTPS
- [ ] Your site does not modify the redirected payment page

## SAQ A-EP: Embedded Elements

Use Stripe Elements (embedded in your page via JavaScript). Card numbers are captured directly by Stripe's JS in an iframe — they never reach your DOM or server. You receive a `PaymentMethod` token.

```html
<!-- Stripe.js loads in an iframe — card data never touches your JS -->
<div id="card-element"></div>

<script>
const stripe = Stripe(process.env.STRIPE_PUBLISHABLE_KEY);
const elements = stripe.elements();
const cardElement = elements.create('card');
cardElement.mount('#card-element');

// On submit: tokenize in the browser, send token to your server
const { paymentMethod, error } = await stripe.createPaymentMethod({
  type: 'card',
  card: cardElement,
});

// Send paymentMethod.id to your server — never the card number
await fetch('/api/checkout', {
  method: 'POST',
  body: JSON.stringify({ paymentMethodId: paymentMethod.id, idempotencyKey }),
});
</script>
```

Your server receives `pm_xxxxx` — a Stripe token — not the card number.

**SAQ A-EP adds requirements over SAQ A:**
- [ ] Stripe.js loaded from `js.stripe.com` (not self-hosted)
- [ ] Your server is not directly processing card data
- [ ] HTTPS on all pages, including non-payment pages
- [ ] Annual vulnerability scan by an ASV (Approved Scanning Vendor)

## Data You Must Never Store

Even with SAQ A/A-EP, you are still prohibited from storing:

| Data | Prohibited |
|------|-----------|
| Full card number (PAN) | Always |
| CVV/CVC/CVV2 | Always — even temporarily |
| PIN block | Always |
| Magnetic stripe data | Always |
| Cardholder name (with PAN) | Prohibited alongside PAN |

Store Stripe's token (`pm_xxx`, `pi_xxx`, `cus_xxx`) instead. Never log request bodies that might contain card fields.

## Network and Infrastructure Requirements

Even with low-scope SAQ A/A-EP, basic security is required:

- HTTPS everywhere (TLS 1.2+, prefer TLS 1.3)
- Valid, non-expired SSL certificate
- HTTP redirects to HTTPS for all pages
- No mixed content warnings on payment pages
- Firewall rules restricting database access to application servers only

## Logging Rules

- Never log raw card numbers, CVV, or full PANs — ever
- Log payment tokens (`pm_xxx`, `pi_xxx`) — safe
- Log amounts, currencies, timestamps, user IDs — safe
- Review logging middleware to ensure no card data passes through before the rule is tested

```typescript
// Safe: log the token, not card data
logger.info('Payment initiated', {
  paymentMethodId: paymentMethod.id,  // safe token
  amountCents,
  userId,
  // NEVER: cardNumber, cvv, expiry
});
```

## Breach Response

If you suspect cardholder data was exposed:
1. Isolate affected systems immediately (do not delete logs)
2. Notify your payment processor (Stripe has a 24-hour notification requirement)
3. Notify card brands if full PANs were exposed (Visa, Mastercard have breach notification programs)
4. Engage a PCI Forensic Investigator (PFI) for SAQ D breaches

## Verification

- [ ] Integration uses Stripe Checkout or Stripe Elements — not direct card API
- [ ] Card numbers never appear in server logs or database
- [ ] CVV/CVC not stored anywhere — not even temporarily in a session
- [ ] All pages served over HTTPS (including non-payment pages)
- [ ] Stripe.js loaded from `js.stripe.com`, not self-hosted
- [ ] SAQ A or SAQ A-EP self-assessment completed annually
- [ ] TLS 1.2+ configured, TLS 1.0/1.1 disabled
- [ ] Database access firewall-restricted to app servers
- [ ] Logging middleware audited — no card data in logs
- [ ] Test mode keys used in all non-production environments
