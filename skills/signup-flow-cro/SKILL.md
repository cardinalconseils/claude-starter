---
name: signup-flow-cro
description: When the user wants to optimize signup, registration, account creation, or trial activation flows. Also use when the user mentions 'signup conversions,' 'registration friction,' 'signup drop-off,' 'onboarding optimization,' or 'trial activation.'
allowed-tools: Read, Write, WebSearch, WebFetch, AskUserQuestion
model: sonnet
---

# Signup Flow & Trial Activation CRO

Expert knowledge for optimizing signup, registration, and trial activation flows to increase conversion and reach the product's "aha moment" faster.

## The Two Goals of a Signup Flow

1. **Get them in:** Remove every barrier between intent and account creation
2. **Get them activated:** Guide them to the moment where the product's value becomes real

Most teams optimize for goal 1 and ignore goal 2. Activation is where retention starts.

## Signup Flow Audit

Before optimizing, map your current flow completely.

**Flow mapping questions:**
- How many steps from CTA click to active session?
- How many form fields total?
- Is email verification required before product access?
- What is the first screen after signup?
- What is the "aha moment" — the first moment of real value?
- How many steps separate signup from the aha moment?

**Measure drop-off at each step:**
- Step 1 → Step 2 conversion
- Step 2 → Step 3 conversion
- Final step → Active session
- Active session → Key action (aha moment)

The step with the highest drop-off is your first priority.

## Field Reduction

Every form field is a barrier. The fewer fields, the higher the completion rate.

**What to ask at signup (strict minimum):**
- Email address (required to send verification and future communication)
- Password (or offer social login to skip this entirely)

**What NOT to ask at signup:**
- Full name (ask later — personalization can wait)
- Company name (ask later — unless it's critical for routing)
- Phone number (ask later — or never, for self-serve)
- Role or job title (ask later — or use in onboarding)
- Company size, industry (ask in onboarding or import from enrichment)

**Enrichment as an alternative:** After email is collected, enrich with Clearbit or Apollo to get company name, size, industry, and name — without asking the user.

**Progressive disclosure:**
Request additional fields at the moment they become necessary to use the product, not upfront. "To set up your first [integration], we need your [company URL]."

## Social Login

Social login (Google, LinkedIn, Microsoft) removes the password field and reduces signup friction by 50-70%.

**Implementation guidance:**
- For B2B: Prioritize Google and Microsoft (work accounts)
- For professional networks: LinkedIn is valuable (also provides company/title data)
- Position "Sign up with Google" as the primary CTA (not secondary)
- Keep email+password as a fallback, not the default

**OAuth benefits beyond UX:**
- Verified email (no bounced verification emails)
- Often provides name and profile picture
- Reduced support from forgotten passwords

## Email Verification Friction

Traditional email verification (verify before access) loses 20-40% of signups.

**Better approaches:**

**Option 1: Access first, verify later**
- User signs up and immediately accesses the product
- Verification email sent in background
- Gentle reminders until verified (in-app banner + email nudges)
- Gate only specific features behind verification (e.g., sending emails requires verification)

**Option 2: Magic link (no password required)**
- User enters email → receives a magic link → clicks → signed in
- One step (enter email), one friction point (click the link)
- Eliminates password creation entirely
- Better UX than OTP for most users

**Option 3: Social login (skip entirely)**
- OAuth signup = pre-verified email, no password needed

## Progress Indicators

For multi-step signups, show progress explicitly.

**Why progress bars work:**
- Reduces abandonment because users know how much remains (Zeigarnik effect)
- Creates commitment — each step completed makes it harder to abandon
- Reduces perceived effort

**Progress indicator rules:**
- Show the current step number and total ("Step 2 of 4")
- Or a visual progress bar with labeled stages
- Don't show progress on the first step (they haven't started yet)
- Don't exceed 5 steps for any signup flow

## Inline Validation

Validate form fields as the user types, not after they submit.

**Good inline validation:**
- Green checkmark appears immediately after a valid email is entered
- Red error appears as soon as they tab away from an invalid field (not on submit)
- Password strength meter updates in real time
- "This email is already registered — sign in instead" shown inline

**Bad validation:**
- Submit button clicked → full page error list displayed
- Error messages that say "Invalid input" without explaining what's wrong
- Clearing all fields on error

## Value Framing at Each Signup Step

Every screen in the signup flow should remind the user why they're doing this.

**Techniques:**
- Testimonial sidebar: Keep a customer quote visible throughout the flow
- Progress-reinforcing copy: "Almost there — one more step to [specific outcome]"
- Outcome reminder: "You're setting up your [specific outcome] dashboard"
- Social proof: "Joining [X] teams who use [Product] to [outcome]"

## The Activation Milestone

Activation = the moment the user experiences the core value of your product.

**Define your activation milestone precisely:**
- Not "logged in for the second time"
- Not "set up their profile"
- Specific to the product's value: "created their first report," "connected their first integration," "sent their first campaign"

**Test your activation definition:**
- Does it correlate with 90-day retention? (Use cohort analysis)
- Do activated users churn at < 2× the rate of non-activated users?
- Is activation achievable in a single session for most users?

If your activation milestone is not achievable in a single session, users churn before they see the value. Redesign.

## Aha Moment Mapping

The "aha moment" is when the user thinks "this is exactly what I needed."

**Examples:**
- Slack: 2,000 messages sent within the team
- Dropbox: A file saved and shared
- Twitter: Following 30 people
- Your product: [Define based on retention correlation data]

**Path from signup to aha moment:**
Map every step between signup and the aha moment. Then:
1. Remove steps that aren't necessary for reaching the aha moment
2. Reorder to get to the aha moment faster
3. Guide users with empty-state design and tooltips toward the first key action

## Empty State Design

The first screen after signup is often an empty state. This is a critical conversion point.

**Empty state principles:**
- Show what it will look like when it's full (preview / illustration)
- Provide one clear action to take ("Create your first [X]")
- Make the first action easy — pre-fill defaults, use templates
- Use copy that describes the outcome, not the action: "See all your campaigns in one place — start by adding your first campaign"

## Onboarding Email Sequence (First 7 Days)

| Email | When | Goal |
|---|---|---|
| Welcome | Immediately | Confirm account, set expectation |
| Activation | Day 1 | Drive first key action if not completed |
| Value reminder | Day 2 | Remind why they signed up + success tip |
| Social proof | Day 3 | Case study or testimonial from similar user |
| Check-in | Day 5 | Did they hit activation? Offer help if not |
| Upgrade/feature discovery | Day 7 | If activated: introduce next value layer |

**Behavioral triggers beat time-based triggers:**
- "If user hasn't created first [X] in 24 hours → send activation email"
- "If user created first [X] → skip activation email, send value-add email instead"

## A/B Testing Priority Order for Signup

1. Social login vs email+password (highest impact)
2. Number of form fields (reduce by 1-2 fields)
3. CTA button copy ("Start free trial" vs "Create your account" vs "Get started")
4. Email verification timing (immediate vs post-activation)
5. Progress indicator style (steps vs progress bar)
6. Empty state design (template picker vs blank canvas vs guided tour)

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "We need all those fields to qualify leads" | You don't. Enrich after signup. Users won't fill 8 fields on a form when your competitor asks for 2. |
| "Email verification is required for security" | Immediate product access with background verification maintains security while reducing drop-off by 20-40%. |
| "Our signup is already one page — it's simple" | One page with 10 fields is not simple. Count fields, not pages. |
| "Onboarding emails are annoying — we'll keep them minimal" | Users who don't activate churn. Onboarding emails that drive activation are valuable, not annoying. |
| "Social login reduces our data collection" | Social login enriches your data (verified email, name, sometimes company) while improving conversion. Net positive. |

## Verification

- [ ] Drop-off measured at each step in the signup flow
- [ ] Form fields reduced to strict minimum (email + password or social login only)
- [ ] Social login implemented (Google minimum for B2B)
- [ ] Email verification deferred until after first product use (or magic link implemented)
- [ ] Progress indicator present for multi-step flows (> 2 steps)
- [ ] Inline validation implemented on all form fields
- [ ] Activation milestone defined with retention correlation confirmed
- [ ] Path from signup to aha moment mapped and shortest-path identified
- [ ] Empty state provides a single clear action with outcome-oriented copy
- [ ] 7-day onboarding email sequence with behavioral triggers configured
