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

Dispatch the Remotion specialist agent with the user's request. If no specific request was provided, ask what they need help with:

1. Building a new composition
2. Adding animations or transitions
3. Working with audio/video/captions
4. Debugging a rendering issue
5. Something else

Use `Agent(subagent_type="remotion-specialist")` to handle all Remotion tasks.
