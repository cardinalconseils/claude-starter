# UAT Scenario Writing Guide

## What is UAT?

User Acceptance Testing validates that the feature delivers expected value from the **user's perspective**. It's not about code quality (that's QA) — it's about "does this solve the user's problem?"

## UAT vs QA

| | QA Validation (Phase 3 [3e]) | UAT (Phase 3 [3f]) |
|---|---|---|
| **Who** | Developer / QA engineer | Stakeholder / Product Owner / End User |
| **Focus** | Does the code work correctly? | Does the feature deliver value? |
| **Tests** | Unit, integration, E2E automated | Manual scenario walkthrough |
| **Criteria** | Acceptance criteria (technical) | User stories (business value) |
| **Environment** | Test / CI | Staging / Preview URL |

## Writing UAT Scenarios

### Format

```
Scenario: {descriptive name}
  Given {initial state / context}
  When {user action}
  Then {expected outcome}
  And {additional verification}
```

### Example: Invoice Creation

```
Scenario: Freelancer creates and sends their first invoice
  Given I am a new user who just completed onboarding
  And I have added one client "Acme Corp"
  When I click "New Invoice"
  And I select "Acme Corp" as the client
  And I add a line item "Web Development - 10 hours @ $150"
  And I click "Preview"
  Then I see a professional invoice with my logo, Acme Corp's details, and $1,500 total
  When I click "Send"
  Then I see a confirmation message "Invoice sent to Acme Corp"
  And Acme Corp receives an email with the invoice PDF attached
```

### Scenario Categories

Every feature should have UAT scenarios covering:

#### 1. Happy Path (Required)
The ideal user journey — everything works as expected.
```
Scenario: User successfully completes the primary action
```

#### 2. First-Time Experience (Required)
New user encountering the feature for the first time.
```
Scenario: New user discovers and uses the feature
  Given I have never used this feature before
  When I navigate to {feature area}
  Then I see helpful onboarding/empty state guidance
```

#### 3. Error Recovery (Required)
User makes a mistake and recovers.
```
Scenario: User corrects invalid input
  Given I am filling out the form
  When I submit with invalid data
  Then I see clear error messages
  When I correct the errors and resubmit
  Then the action succeeds
```

#### 4. Edge Cases (Required)
Boundary conditions from the user's perspective.
```
Scenario: User reaches a system limit
  Given I have the maximum number of {items}
  When I try to add one more
  Then I see a clear message about the limit
  And I am offered an upgrade or alternative
```

#### 5. Multi-Step Flow (When Applicable)
Flows that span multiple screens or sessions.
```
Scenario: User completes a multi-step process
  Given I started step 1 of 3
  When I complete step 1 and navigate away
  And I return to the feature later
  Then my progress is saved and I can resume from step 2
```

#### 6. Permission Boundary (When Applicable)
Different user roles experience the feature differently.
```
Scenario: Admin user vs regular user
  Given I am logged in as a regular user
  When I navigate to {admin feature}
  Then I see an appropriate access denied message
```

## UAT Scenario Checklist

For each user story in Discovery, ensure:

- [ ] At least one happy path scenario
- [ ] At least one error/recovery scenario
- [ ] First-time user experience covered
- [ ] Edge cases identified (limits, empty states, concurrent actions)
- [ ] Multi-step flows have resume/save scenarios
- [ ] Permission boundaries tested (if applicable)
- [ ] Mobile experience validated (if applicable)

## UAT Execution Protocol

### Before UAT
1. Deploy to staging/preview environment
2. Prepare test accounts with appropriate data
3. Share preview URL with stakeholders
4. Provide the UAT scenario document

### During UAT
1. Stakeholder walks through each scenario
2. Record: PASS / FAIL / PARTIAL for each
3. Capture screenshots of issues
4. Note subjective feedback (UX, clarity, speed)

### After UAT
For each scenario result:
- **PASS**: Feature works as expected
- **FAIL**: Create backlog item with steps to reproduce
- **PARTIAL**: Document what works, what doesn't, decide severity

### Sign-off
UAT is complete when:
- All happy path scenarios PASS
- All critical error scenarios PASS
- Stakeholder provides explicit sign-off
- Any FAIL items are triaged (fix now vs defer)

## Translating UAT to Browser Tests

For automated E2E execution (via `/cks:browse` in Phase 3 [3f] and Phase 5 [5c]):

| UAT Step | Browser Action |
|----------|---------------|
| "I navigate to {page}" | `Navigate to {url}` |
| "I click {button}" | `Click element with text/role {button}` |
| "I fill in {field} with {value}" | `Fill input [name=field] with value` |
| "I see {text}" | `Verify element with text {text} is visible` |
| "I receive an email" | Check test email service / mock |
| "The page shows {state}" | Take screenshot, verify visually |
| "I am redirected to {page}" | Verify current URL matches |
