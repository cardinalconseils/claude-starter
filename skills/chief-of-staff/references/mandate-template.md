# Mandate — {name}

You are the investor. This file is the whole of what you say. Everything below the line
is the workforce's problem: which tools, which language, which order, who does it.

Fill five sections. If you find yourself writing *how*, delete it — that is not yours.

---

## 1. Outcome

What must be true when this is done, described as a person using it, not as software
being built. No features, no stack, no architecture.

> Good: "A restaurant owner in Quebec can get a written AI-readiness score in under
> five minutes without talking to anyone, in French or English."
>
> Bad: "Build a Next.js scorecard with a Supabase backend."

The second one is you doing the workforce's job, badly.

**Outcome:** {…}

## 2. Constraints

Things that are fixed. Money, time, anything already decided that is not up for debate.

- **Budget:** {hard ceiling — in dollars, and the workforce reports burn against it}
- **Deadline:** {date, or "none" — "soon" is not a deadline}
- **Already decided:** {platforms, vendors, or choices that are settled and why}
- **Must reuse:** {existing assets it should build on rather than replace}

## 3. Guardrails

What must never happen, regardless of how convenient it would be. State consequences,
not preferences — a guardrail is something you would kill the project over.

- {e.g. no customer data leaves Canadian infrastructure}
- {e.g. nothing bills a real card until you have personally tested checkout}
- {e.g. no public claim about results we cannot evidence}

## 4. Gates

Where the workforce stops and asks you, even mid-flight. Everything not listed here, it
decides alone and tells you afterwards.

Default gates, delete none without deciding to:

- Production deploy to a live customer-facing URL
- Any message sent to a real person — email, SMS, DM, call
- Pricing, or copy that sets a customer expectation
- Deleting anything, or removing a scheduled job
- Spend above {amount} in a single step

## 5. Acceptance

How you will know it works — the test that decides done. Written so a person with no
technical background can run it, or so an agent can run it unattended.

- **A human can:** {the exact thing someone does, start to finish, and what they see}
- **An agent can:** {the same path, run headless, with the observable end state}
- **It fails if:** {the condition that means not done, however much was built}

Acceptance is not "the tests pass". It is someone getting the outcome in section 1.

---

## What you do not write

Stack. Schema. Sequencing. Who does what. Whether to use a queue. Whether to test
first. What to build in week two. If a question needs technical knowledge to answer,
it is not your question — the workforce decides it, records it, and moves.

## Status — maintained by the workforce, not by you

| Field | Value |
|---|---|
| Opened | {date} |
| Spend to date | {updated each run, against the budget above} |
| Blocked on | {a gate, or nothing} |
| Acceptance | {not yet run / passing / failing, with the date} |
