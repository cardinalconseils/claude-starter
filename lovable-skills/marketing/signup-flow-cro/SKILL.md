---
name: signup-flow-cro
description: Use when the user wants to optimize their signup, registration, or trial activation flow. Also use when the user mentions 'signup conversions,' 'signup drop-off,' 'onboarding optimization,' 'trial activation,' 'registration friction,' or 'how do I get more people through my signup.'
---

# Signup Flow & Trial Activation CRO

Expert knowledge for optimizing signup, registration, and trial activation flows to increase conversion and reach the product's "aha moment" faster.

## The Two Goals of a Signup Flow

1. **Get them in:** Remove every barrier between intent and account creation
2. **Get them activated:** Guide them to the moment where the product's value becomes real

Most teams optimize for goal 1 and ignore goal 2. Activation is where retention starts.

## Signup Flow Audit

**Flow mapping questions:**
- How many steps from CTA click to active session?
- How many form fields total?
- Is email verification required before product access?
- What is the first screen after signup?
- What is the "aha moment" — the first moment of real value?
- How many steps separate signup from the aha moment?

**Measure drop-off at each step.** The step with the highest drop-off is your first priority.

## Field Reduction

Every form field is a barrier. The fewer fields, the higher the completion rate.

**What to ask at signup (strict minimum):**
- Email address
- Password (or offer social login to skip this entirely)

**What NOT to ask at signup:**
- Full name (ask later)
- Company name (ask later — unless critical for routing)
- Phone number (ask later — or never, for self-serve)
- Role or job title (ask during onboarding)
- Company size, industry (enrich after signup instead)

**Progressive disclosure:** Request additional fields at the moment they become necessary to use the product, not upfront.

## Social Login

Social login (Google, LinkedIn, Microsoft) removes the password field and reduces signup friction by 50-70%.

- For B2B: Prioritize Google and Microsoft (work accounts)
- Position "Sign up with Google" as the primary CTA (not secondary)
- Keep email+password as a fallback, not the default

**OAuth benefits:** Verified email (no bounced verification), often provides name and profile picture, reduced support from forgotten passwords.

## Email Verification Friction

Traditional email verification (verify before access) loses 20-40% of signups.

**Better approaches:**

**Option 1: Access first, verify later**
- User signs up and immediately accesses the product
- Verification email sent in background
- Gate only specific features behind verification (e.g., sending emails)

**Option 2: Magic link**
- User enters email → receives a magic link → clicks → signed in
- Eliminates password creation entirely

**Option 3: Social login** — OAuth = pre-verified email, no password needed.

## Progress Indicators

For multi-step signups, show progress explicitly.

**Progress indicator rules:**
- Show current step number and total ("Step 2 of 4")
- Don't show progress on the first step
- Don't exceed 5 steps for any signup flow

**Why they work:** Reduces abandonment because users know how much remains (Zeigarnik effect). Creates commitment — each completed step makes it harder to abandon.

## Inline Validation

Validate form fields as the user types, not after they submit.

**Good inline validation:**
- Green checkmark appears immediately after a valid email is entered
- Red error appears as soon as they tab away from an invalid field
- "This email is already registered — sign in instead" shown inline

**Bad validation:**
- Submit button clicked → full page error list displayed
- Error messages that say "Invalid input" without explaining what's wrong

## The Activation Milestone

Activation = the moment the user experiences the core value of your product.

**Define your activation milestone precisely:**
- Not "logged in for the second time"
- Not "set up their profile"
- Specific to the product's value: "created their first report," "connected their first integration," "sent their first campaign"

**Test your activation definition:**
- Does it correlate with 90-day retention? (Cohort analysis)
- Do activated users churn at < 2× the rate of non-activated users?
- Is activation achievable in a single session for most users?

If activation is not achievable in a single session, users churn before they see the value. Redesign.

## Empty State Design

The first screen after signup is often an empty state. This is a critical conversion point.

**Empty state principles:**
- Show what it will look like when it's full (preview / illustration)
- Provide one clear action to take ("Create your first [X]")
- Make the first action easy — pre-fill defaults, use templates
- Copy: describe the outcome, not the action ("See all your campaigns in one place — start by adding your first campaign")

## Onboarding Email Sequence (First 7 Days)

| Email | When | Goal |
|---|---|---|
| Welcome | Immediately | Confirm account, set expectation |
| Activation | Day 1 | Drive first key action if not completed |
| Value reminder | Day 2 | Remind why they signed up + success tip |
| Social proof | Day 3 | Case study from similar user |
| Check-in | Day 5 | Did they hit activation? Offer help if not |
| Feature discovery | Day 7 | If activated: introduce next value layer |

**Behavioral triggers beat time-based triggers:** If user completes the activation action, skip the Day 1 activation email and send the value reminder instead.

## A/B Testing Priority Order

1. Social login vs email+password (highest impact)
2. Number of form fields (reduce by 1-2 fields)
3. CTA button copy ("Start free trial" vs "Create your account" vs "Get started")
4. Email verification timing (immediate vs post-activation)
5. Empty state design (template picker vs blank canvas vs guided tour)

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "We need all those fields to qualify leads" | Enrich after signup. Users won't fill 8 fields on a form when your competitor asks for 2. |
| "Email verification is required for security" | Immediate product access with background verification maintains security while reducing drop-off by 20-40%. |
| "Our signup is already one page — it's simple" | One page with 10 fields is not simple. Count fields, not pages. |
| "Onboarding emails are annoying — we'll keep them minimal" | Users who don't activate churn. Onboarding emails that drive activation are valuable, not annoying. |

## Verification

- [ ] Drop-off measured at each step in the signup flow
- [ ] Form fields reduced to strict minimum (email + password or social login only)
- [ ] Social login implemented (Google minimum for B2B)
- [ ] Email verification deferred until after first product use (or magic link implemented)
- [ ] Progress indicator present for multi-step flows (> 2 steps)
- [ ] Inline validation implemented on all form fields
- [ ] Activation milestone defined with retention correlation confirmed
- [ ] Empty state provides a single clear action with outcome-oriented copy
- [ ] 7-day onboarding email sequence with behavioral triggers configured
