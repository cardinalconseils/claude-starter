# Secrets Hook: Discovery

<context>
Phase: Discover (Phase 1)
Runs after: step-4-elements (11 Elements gathered)
Runs before: step-5-validate
Requires: {NN}-CONTEXT.md exists (at least partially)
Produces: {NN}-SECRETS.md
</context>

## Inputs

- Read: `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md` (Technical Context + Dependencies sections)
- Read: `CLAUDE.md` (for existing env var references)
- Read: `.env.example` or `.env.local` (if exists — detect already-configured secrets)
- Read: `${SKILL_ROOT}/workflows/secrets/_manifest-format.md` (for output schema)

## Instructions

### 1. Parse CONTEXT.md for technology mentions

Scan these sections of the CONTEXT.md:
- **Dependencies** — libraries that need API keys
- **API Surface** — external services referenced
- **Technical Context** — infrastructure dependencies
- **Data model changes** — database providers

### 2. Cross-reference with known secrets table

| Technology | Typical Secrets |
|-----------|----------------|
| Stripe | `STRIPE_SECRET_KEY`, `STRIPE_PUBLISHABLE_KEY`, `STRIPE_WEBHOOK_SECRET` |
| Supabase | `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY` |
| Firebase | `FIREBASE_API_KEY`, `FIREBASE_PROJECT_ID`, `FIREBASE_SERVICE_ACCOUNT` |
| Resend | `RESEND_API_KEY` |
| SendGrid | `SENDGRID_API_KEY` |
| Twilio | `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN` |
| OpenAI | `OPENAI_API_KEY` |
| Anthropic | `ANTHROPIC_API_KEY` |
| Clerk | `CLERK_SECRET_KEY`, `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` |
| Auth0 | `AUTH0_SECRET`, `AUTH0_CLIENT_ID`, `AUTH0_CLIENT_SECRET` |
| AWS S3 | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION` |
| Cloudflare | `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID` |
| Railway | `RAILWAY_TOKEN` |
| Vercel | `VERCEL_TOKEN` |
| GitHub | `GITHUB_TOKEN` |
| RevenueCat | `REVENUECAT_API_KEY`, `REVENUECAT_WEBHOOK_SECRET` |
| Postmark | `POSTMARK_SERVER_TOKEN` |
| Upstash Redis | `UPSTASH_REDIS_REST_URL`, `UPSTASH_REDIS_REST_TOKEN` |
| PlanetScale | `DATABASE_URL` |
| Neon | `DATABASE_URL` |

### 3. Check existing environment files

Read `.env.example` or `.env.local` if they exist. For each detected secret, check if it's already present. Mark those as `resolved`.

### 4. Present findings to user

```
AskUserQuestion({
  questions: [{
    question: "These secrets were identified for this feature. Select which ones are needed:",
    header: "Secrets",
    multiSelect: true,
    options: [
      { label: "{SECRET_NAME}", description: "{Provider} — {how to get it}. Status: {pending|resolved}" },
      // ... one per detected secret
      { label: "Add custom secret", description: "I need a secret not listed here" }
    ]
  }]
})
```

If user selects "Add custom secret", ask a follow-up for name, provider, and how to get it.

### 5. Write {NN}-SECRETS.md

Write to `.prd/phases/{NN}-{name}/{NN}-SECRETS.md` using the manifest format from `_manifest-format.md`. Include only the confirmed secrets.

## Success Condition

- `{NN}-SECRETS.md` exists with at least the Secrets table populated
- All identified secrets have a status (`pending` or `resolved`)
- AskUserQuestion was called to confirm the secrets list

## On Failure

- If no secrets detected: write `{NN}-SECRETS.md` with empty table and note "No external secrets identified for this feature"
- If user declines all secrets: write with empty table, note "User confirmed no secrets needed"
