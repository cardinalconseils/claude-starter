# Tool-Use Eval Workflow

Evaluate Claude's tool_use behavior — selection, parameters, sequencing, and error handling.

## What to Measure

- **Tool selection correctness** — did it pick the right tool for the task?
- **Parameter correctness** — correct values, correct types, all required fields present
- **Call ordering** — multi-step flows: correct sequence of tool calls?
- **Over-calling** — called a tool when it shouldn't have (unnecessary call)
- **Under-calling** — missed a required tool call entirely
- **Graceful degradation** — handles tool errors without hallucinating a fake result

## Smoke Tier (3–5 cases)

Run every commit. <2 min.

1. **Single-tool happy path** — unambiguous input maps to one tool; assert correct tool + required params present
2. **Wrong-tool rejection** — input that should NOT trigger a tool call; assert no tool called
3. **Missing-param error handling** — input where a required param can't be inferred; assert model asks for it vs hallucinating a value

All three: binary pass/fail. All must pass.

## Standard Tier (15–25 cases)

Run pre-merge.

Add:
- **Multi-tool sequence** — task requiring 2–3 tool calls in order; assert sequence matches expected
- **Ambiguous input requiring disambiguation** — input matches two tools; assert model picks correct one or asks
- **Parallel tool calls** — input where two independent tools should be called together; assert both called
- **Optional param handling** — input where an optional param can be inferred; assert correctly populated or omitted
- **Tool error propagation** — tool returns error response; assert model surfaces error, not fabricated answer
- **Repeated tool call** — task requiring same tool called twice with different params; assert both calls

## Comprehensive Tier (50–100+ cases)

Run nightly or pre-release.

Add:
- **Adversarial tool descriptions** — tool names/descriptions updated to be subtly misleading; assert selection still correct
- **Tool name confusion** — two tools with similar names; assert correct discrimination
- **Max tools per turn** — input that could naively trigger many tools; assert stays within limit
- **Streaming + tool use** — tool calls interleaved with streaming text; assert no dropped calls
- **Malformed tool result** — tool returns unexpected shape; assert graceful handling
- **Long parameter values** — param value near token limit; assert no truncation

## Assertion Patterns

**Tool name** — exact string match:
```
assert actual_tool_name == expected_tool_name
```

**Required params** — exact match for value and type:
```
assert actual_params["required_field"] == expected_value
assert type(actual_params["count"]) == int
```

**Optional params** — fuzzy acceptable:
```
assert actual_params.get("optional_field") in [expected_value, None, synonym]
```

**Sequence assertions** — for multi-call flows:
```
assert [call.tool for call in actual_calls] == ["search", "lookup", "format"]
```

**No-call assertion** — verify tool NOT called:
```
assert len(actual_calls) == 0
```

## Common Gotchas

- **Tool description wording affects selection more than you expect** — a one-word change in a tool description can cause the model to consistently pick the wrong tool. Include tool description in your eval metadata so changes are caught.
- **Parameter aliasing** — model uses a synonym that doesn't match the schema key (e.g., sends `"query"` when schema expects `"search_term"`). Test aliases explicitly.
- **Tool name typos in schema** — if the tool schema has a typo, the model may still work in tests but fail in production where the actual API enforces exact names.
- **Parallel call order non-determinism** — when parallel calls are valid, assert set equality not sequence equality.
- **Tool result size** — if tool result is very large, model may truncate reasoning. Test with realistic result sizes.

## Output Format

Per case:
```
case_id: tool-001
input: "Search for products matching 'red shoes' under $50"
expected_tool: product_search
expected_params: {query: "red shoes", max_price: 50}
actual_tool: product_search
actual_params: {query: "red shoes", max_price: 50}
tool_name_pass: true
params_pass: true
case_pass: true
```

Multi-call case:
```
case_id: tool-005
expected_sequence: [get_user, check_inventory, place_order]
actual_sequence: [get_user, check_inventory, place_order]
sequence_pass: true
```

Aggregate: `{passed}/{total} | tool selection: X% | param correctness: X% | tier: PASS/FAIL`
