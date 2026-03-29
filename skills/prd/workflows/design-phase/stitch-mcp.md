# Stitch MCP Integration Reference

## Overview

The designer agent uses Stitch MCP (Google's MCP server) to create UI mockups, flowcharts, and design artifacts.

## Screen Mockups

**Screen generation prompt pattern:**
```
"Create a {screen_type} screen for {app_name}.
{user_story_description}
Requirements:
- {acceptance_criterion_1}
- {acceptance_criterion_2}
Style: {project_design_system_or_preferences}"
```

**Screen editing prompt pattern:**
```
"Edit this screen: {edit_instruction_from_user_feedback}"
```

**Variant generation:**
```
"Generate a mobile variant of this screen"
"Generate a tablet variant of this screen"
```

## Flowcharts & Diagrams

**User flow diagram:**
```
"Create a user flow diagram for {feature_name}.
Show the complete journey: {start_state} → {step_1} → {step_2} → {end_state}
Include decision points and error paths.
Actors: {user, system, external service}
Style: clean flowchart with labeled arrows"
```

**State transition diagram:**
```
"Create a state diagram for {entity} in {feature_name}.
States: {state_1}, {state_2}, {state_3}
Transitions: {state_1} → {state_2} on {event}, {state_2} → {state_3} on {event}
Show guards/conditions on transitions."
```

**API sequence diagram:**
```
"Create a sequence diagram showing the API flow for {feature_name}.
Participants: Client, API Server, Database, {external_service}
Show: request → processing → response for {endpoint}.
Include auth flow and error handling."
```

## Chrome DevTools MCP (Browser Review)

Used in [2d] Design Iteration to preview generated HTML screens in a real browser:
- Open `source.html` at different viewport sizes (375px, 768px, 1440px)
- Take screenshots for visual comparison
- Inspect accessibility: contrast ratios, focus order, semantic HTML
- If not configured, the designer reviews screens via file content and screenshots only

## Excalidraw MCP (Fallback)

If Stitch MCP is not configured, Excalidraw MCP serves as the diagram fallback:
- Generates wireframe-style diagrams and flowcharts
- Outputs `.excalidraw` or `.svg` files to `design/diagrams/`
- Less polished than Stitch but functional for user flows and architecture diagrams

## Text Fallback (No MCP Tools)

If neither Stitch MCP nor Excalidraw MCP is available:
- Generate Mermaid syntax diagrams embedded in `ux-flows.md`
- Write text-based wireframe descriptions (component layout + content)
- Document design decisions in prose for Sprint implementation
