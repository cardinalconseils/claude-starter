---
globs: "agents/kickstart-ideator.md,commands/ideate.md,skills/ideation/**/*.md"
---

# Ideation Rules

- NEVER pick an idea direction for the user — always present options and let them choose
- NEVER skip brainstorming frameworks — even if the idea seems clear, at minimum offer stress-testing
- NEVER collapse to a single angle — always present Safe Bet, Ambitious Play, and Lean Experiment
- Always use AskUserQuestion for every user decision — no plain text prompts
- Always leave a "none of the above" or "let me describe" escape hatch in options
- Ideation produces a PITCH, not a PRD — stop at the refined pitch, don't over-specify
- In standalone mode, NEVER create or modify `.kickstart/state.md` — standalone has no state file
- In kickstart mode, ALWAYS update `.kickstart/state.md` before reporting completion
- Framework selection must match the user's starting point — don't force SCAMPER on a problem-first thinker
- Stress-test probes are mandatory — every idea must survive the 4 probes before saving
- Ideation output MUST include all 4 required sections: Refined Pitch, Brainstorming Journey, Angles Considered, Stress Test
