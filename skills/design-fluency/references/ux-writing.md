> Attribution: Adapted from [impeccable](https://github.com/pbakaus/impeccable) by Peter Bakaus, Apache-2.0.

# UX Writing Reference

Signals covered: `placeholder-as-label`, `vague-cta`, error message patterns, empty states, microcopy tone

## Button Labels — Verb + Noun

Never use "OK", "Submit", "Yes", or "No" for actions. These are ambiguous and lazy.

Use specific verb + object patterns:

| Bad | Good | Why |
|-----|------|-----|
| OK | Save changes | Says what will happen |
| Submit | Create account | Outcome-focused |
| Yes | Delete message | Confirms the action |
| Cancel | Keep editing | Clarifies "cancel" — do not lose work |
| Click here | Download PDF | Describes the destination |
| Learn more | See pricing | Specific destination, not generic prompt |

**For destructive actions, name the destruction:**
- "Delete" not "Remove" (delete is permanent, remove implies recoverable)
- "Delete 5 items" not "Delete selected" — show the count
- "Permanently delete account" not "Close account"

**`vague-cta` fires on:** "Learn more", "Click here", "Get started" as the only information in a link or button — no destination or outcome specified.

## Placeholder-as-Label

**`placeholder-as-label` fires when form inputs have no visible label and use placeholder text to communicate the field purpose.**

Placeholders disappear when the user starts typing. They have insufficient contrast by design. They cannot convey required state, format, or additional help.

Fix: always use a visible `<label>` element. Placeholder text is for example input, not field identity:

```html
<!-- Bad -->
<input type="email" placeholder="Email address">

<!-- Good -->
<label for="email">Email address</label>
<input type="email" id="email" placeholder="you@example.com">
```

Placeholder text should give an example, not repeat the label.

## Error Messages — The Formula

Every error message answers: (1) What happened? (2) Why? (3) How to fix it?

**Formula:** `[Field] [what's wrong]. [How to fix it].`

Examples:
- "Email address isn't valid. Include an @ symbol." not "Invalid input."
- "Password is too short. Use at least 8 characters." not "Error."
- "That username is taken. Try adding a number or your initial."

**Error message templates:**

| Situation | Template |
|-----------|---------|
| Format error | "[Field] needs to be [format]. Example: [example]" |
| Missing required | "Please enter [what's missing]" |
| Permission denied | "You don't have access to [thing]. [What to do instead]" |
| Network error | "We couldn't reach [thing]. Check your connection and [action]." |
| Server error | "Something went wrong on our end. We're looking into it. [Alternative action]" |

**Never blame the user:**
- "Please enter a date in MM/DD/YYYY format" not "You entered an invalid date"
- "That didn't work" not "You made an error"

**Placement:** Error messages below the field, connected via `aria-describedby`. Use `role="alert"` for dynamically injected errors so screen readers announce them.

## Empty States

Empty states are onboarding moments, not error states. Structure:
1. **Acknowledge briefly** — "No projects yet"
2. **Explain the value** — "Projects keep your work organized in one place"
3. **Clear action** — "Create your first project →"

Not just: "No items found."

For search/filter empty states:
- Acknowledge the search term: "No results for 'invoice'"
- Offer recovery: "Clear filters" or "Try a different search"
- Avoid generic: "No results" with no path forward

## Voice vs. Tone

**Voice** is your brand's consistent personality. **Tone** adapts to the moment.

| Moment | Tone |
|--------|------|
| Success | Celebratory, brief: "Done! Your changes are live." |
| Error | Empathetic, helpful: "That didn't work. Here's what to try..." |
| Loading | Reassuring: "Saving your work..." |
| Destructive confirm | Serious, clear: "Delete this project? This can't be undone." |
| Onboarding | Encouraging: "You're set up. Here's what to do first." |

Never use humor for errors — users are frustrated. Be helpful, not cute.
Never use passive voice for errors — "an error occurred" vs. "we couldn't save your file."

## Writing for Accessibility

**Link text** must have standalone meaning. Screen readers announce links out of context:
- "View pricing plans" not "Click here"
- "Download annual report PDF (2.3 MB)" not "Download"

**Alt text** describes information, not the image appearance:
- "Revenue increased 40% in Q4 2024" not "Bar chart"
- Use `alt=""` for purely decorative images

**Icon-only buttons** need `aria-label`:
```html
<button aria-label="Close dialog">
  <svg aria-hidden="true">...</svg>
</button>
```

**Microcopy length:** Shorter is almost always better. Cut every word that doesn't earn its place. Test: remove the word — does the meaning change? If not, cut it.

## Verification

- [ ] No "Submit", "OK", "Yes/No" buttons — verb + noun labels
- [ ] No placeholder-as-label — all inputs have visible labels
- [ ] Error messages follow what/why/fix formula
- [ ] Error messages don't blame the user
- [ ] Empty states have acknowledge + value + action structure
- [ ] All links have meaningful text (no "click here")
- [ ] Icon-only buttons have `aria-label`
- [ ] Tone adapts to moment (helpful for errors, serious for destructive)
