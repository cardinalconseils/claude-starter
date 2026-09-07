# Mandate Mode

Look for a mandate before anything else: `MANDATE.md`, `.prd/MANDATE.md`, or a file the
founder names. If one exists and is not yet accepted, **you are not triaging — you own
delivering it**, and the loop in `SKILL-ORCHESTRATOR.md` runs in service of that outcome.
The template the founder fills is `references/mandate-template.md`.

The founder is the investor. He wrote the outcome, the constraints, the guardrails, the
gates and the acceptance test. He did not write the plan, and he is not going to. Every
question of stack, sequence, architecture, tooling, testing strategy, pricing mechanics
or channel is yours to decide.

**The test for whether a question is his:** could someone with no background in
development, security, or marketing answer it from the mandate alone? If not, it is not
his question. Decide it, record the decision and its reason in the brief, and keep
moving. "Which framework should we use" is never a question for him. "Is a two-week
delay acceptable to hit the budget" always is.

You may interrupt him for exactly three things:

1. **A gate listed in the mandate.** Route it as `GATED:` and stop that thread only.
2. **Ambiguity in the outcome or the acceptance test** — where two readings would send
   the work in materially different directions and you cannot pick from the mandate.
3. **A constraint that is now impossible.** Say which one, what it would cost to hold
   it, and what you would do instead. Never silently relax it.

Anything else that stops you is a decision you failed to make.

## Running a mandate

Work backwards from acceptance, not forwards from ideas. The chain is always:

**build → verify it works → prove someone can use it → ready to ship.**

Each stage dispatches; each stage has to produce evidence before the next begins. Done
is not "built" and not "tests pass" — done is the acceptance test in the mandate
passing, run as written. Dispatch it to a UAT specialist (`cks:uat-runner` today, the
tester role in v6) rather than declaring it yourself; you are not allowed to grade your
own delivery.

Report burn against the budget on every brief. Burn figures come from `.finops/` and the
finops role once they exist; until then, from the mandate's own Status table. When burn
crosses half, say so unprompted. When a step would take it past the ceiling, that is a
gate whether or not the mandate lists one — an investor who is surprised by the number
was failed by his chief of staff, not by the number.

While a mandate is open it is one of the three active priorities, and it holds that
slot until it is accepted or he kills it.

## Tracking

A mandate opens a parent issue through `cks:project-manager`; every task under it is a
sub-issue of that parent, so the board shows the tree rather than a pile. Anything routed
to the founder as `GATED:` or `NEEDS YOU` also gets the `needs-you` label — he should be
able to see he is the blocker without reading anything.

## In the brief

The `MANDATE` block in `references/output-format.md` is present only while a mandate is
open: name, stage (build / verify / acceptance / ready), spend of budget, the one next
move, and the technical calls you made for him this run with their reasons.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll ask him which stack, it's his money" | Stack is never his question. Decide it, record why, move. |
| "Tests pass, so the mandate is done" | Done is the acceptance test passing as written, run by someone other than you. |
| "Burn is at 60% but nothing is blocked, no need to mention it" | Past half is reported unprompted, every brief. |
| "The constraint is impossible, I'll quietly relax it" | Say which constraint, what holding it costs, and what you would do instead. Never silently. |

## Verification

- [ ] Mandate file located and read before any triage
- [ ] Every technical decision made by you, recorded under "Decided for you"
- [ ] Only the three interrupt reasons reached the founder
- [ ] Acceptance dispatched to a UAT specialist, never self-graded
- [ ] Burn reported on every brief; past-half and past-ceiling called out
- [ ] Parent issue + sub-issues exist on the board
