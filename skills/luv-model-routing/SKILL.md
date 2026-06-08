---
name: luv-model-routing
description: >
  Profile-based model routing for Luv Marketing agents. Load when making programmatic
  OpenRouter calls for text generation — reads the active profile (quality/budget/speed),
  resolves the right model per task type, and provides the curl call pattern.
allowed-tools: Read, Bash
---

# Luv Model Routing

Profile-based model selection for the Luv Marketing Suite. Task type → profile → model → OpenRouter call.

## Profile Resolution Order

1. `$LUV_PROFILE` env var (session override)
2. `.luv/active-profile` file in project root (project-level default)
3. `~/.cks/profiles/luv/active` (global Hermes tier)
4. Fallback: `quality`

```bash
get_luv_profile() {
  local p="${LUV_PROFILE:-}"
  [ -z "$p" ] && p=$(cat .luv/active-profile 2>/dev/null)
  [ -z "$p" ] && p=$(cat "${HOME}/.cks/profiles/luv/active" 2>/dev/null)
  echo "${p:-quality}"
}

get_luv_model() {
  local task_type="$1"
  local profile=$(get_luv_profile)
  local pfile="${CLAUDE_PLUGIN_ROOT}/skills/luv-model-routing/profiles/${profile}.yaml"
  # Project override takes precedence over plugin default
  [ -f ".luv/profiles/${profile}.yaml" ] && pfile=".luv/profiles/${profile}.yaml"
  # Global Hermes-tier override
  [ -f "${HOME}/.cks/profiles/luv/${profile}.yaml" ] && pfile="${HOME}/.cks/profiles/luv/${profile}.yaml"
  grep "^${task_type}:" "$pfile" | awk '{print $2}'
}
```

## Task Type → Profile Key

| Luv Agent | Profile key | Meaning |
|-----------|-------------|---------|
| luv:brand-strategist | `strategy` | Deep positioning and reasoning |
| luv:ads-copywriter | `copywriting` | Short-form ad copy |
| luv:alan-sharpe | `copywriting` | B2B direct response copy |
| luv:long-form-copywriter | `long_form` | Blog posts, whitepapers |
| Quick variations, A/B tests | `fast_copy` | High-volume iterations |
| Competitive analysis, research | `analysis` | Research and synthesis |

## OpenRouter Call Pattern (Deterministic)

```bash
luv_or_generate() {
  local model="$1"
  local system_prompt="$2"
  local user_prompt="$3"

  local payload
  payload=$(python3 -c "
import json, sys
print(json.dumps({
  'model': sys.argv[1],
  'messages': [
    {'role': 'system', 'content': sys.argv[2]},
    {'role': 'user',   'content': sys.argv[3]}
  ]
}))" "$model" "$system_prompt" "$user_prompt")

  curl -s -X POST https://openrouter.ai/api/v1/chat/completions \
    -H "Authorization: Bearer $OPENROUTER_API_KEY" \
    -H "Content-Type: application/json" \
    -H "HTTP-Referer: https://github.com/cardinalconseils/claude-starter" \
    -H "X-Title: Luv Marketing Suite" \
    -d "$payload" \
  | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['choices'][0]['message']['content'])"
}
```

Usage in an agent:
```bash
MODEL=$(get_luv_model "copywriting")
RESULT=$(luv_or_generate "$MODEL" "You are a VoC copywriter..." "Write 5 Google Ads headlines for...")
```

## Profiles at a Glance

| Profile | Strategy | Copy | Long-form | Fast | Analysis |
|---------|----------|------|-----------|------|----------|
| `quality` | claude-opus-4-7 | claude-sonnet-4-6 | claude-sonnet-4-6 | claude-haiku-4-5 | claude-opus-4-7 |
| `budget` | claude-sonnet-4-6 | gpt-4o-mini | gpt-4o-mini | gemini-flash-2.0 | claude-sonnet-4-6 |
| `speed` | gemini-2.5-flash | gpt-4o-mini | gpt-4o-mini | gpt-4o-mini | gemini-2.5-flash |

Image (`openai/gpt-image-1`) and video (`kling/kling-v1-5`) are direct-API, not OpenRouter — all profiles use the same values.

## Switching Profiles

```bash
# Session override
export LUV_PROFILE=budget

# Project default
mkdir -p .luv && echo "budget" > .luv/active-profile

# Global default (Hermes tier)
mkdir -p ~/.cks/profiles/luv && echo "quality" > ~/.cks/profiles/luv/active
```

Or use `/cks:luv-profile [name]` to switch from within a session.

## When Luv Agents Call OpenRouter

Luv text agents ARE Claude — they generate copy using their own intelligence by default.
Use OpenRouter programmatically only when:

- **Batch generation**: producing 10+ variants in a single run (efficiency)
- **Non-Claude model specified**: profile routes to GPT-4o-mini, Gemini, etc.
- **User explicitly requests a specific model**: "use the budget profile for this one"
- **Speed profile + rapid iteration**: workshop or live client session

For single-task generation (the common case), the agent uses its own capabilities and the profile just informs which model tier is appropriate.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Just use quality for everything" | For 20 ad variations at 2am, Haiku is 20× cheaper and fast enough. Profile routing exists for this. |
| "Profile reading is complex" | 3 grep lines. The resolution order is deterministic. |
| "Speed profile for final deliverables" | Speed = drafts and workshops only. Final copy → quality. |
| "Direct OpenAI for images is inconsistent" | Images are not on OpenRouter. Direct is correct. Profile documents this explicitly. |
