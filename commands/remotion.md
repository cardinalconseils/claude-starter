---
description: "Remotion video development — build, debug, and optimize programmatic videos in React"
allowed-tools:
  - Agent
  - AskUserQuestion
---

# /cks:remotion

Dispatch to the Remotion specialist agent for video development tasks.

## Quick Reference

```
/cks:remotion                    — General Remotion help
/cks:remotion add captions       — Add captions/subtitles to a composition
/cks:remotion animate text       — Create text animations
/cks:remotion add transition     — Add scene transitions
/cks:remotion debug rendering    — Debug rendering issues
```

---

If no `$ARGUMENTS` provided, ask what they need help with:

```
AskUserQuestion:
  question: "What Remotion task do you need help with?"
  options:
    - "Building a new composition"
    - "Adding animations or transitions"
    - "Working with audio/video/captions"
    - "Debugging a rendering issue"
    - "Something else (describe)"
```

Then dispatch:

```
Agent(subagent_type="cks:remotion-specialist", prompt="Handle Remotion video development task: $ARGUMENTS")
```
