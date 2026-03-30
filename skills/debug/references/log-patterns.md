# Debug Log Patterns Reference

Language-agnostic log statement patterns for instrumentation:

| Language | Log Syntax | Remove Pattern |
|----------|-----------|----------------|
| JavaScript/TypeScript | `console.log('[DEBUG]', varName)` | `grep -n "console.log.*DEBUG" file` |
| Python | `print(f'[DEBUG] {var_name=}')` | `grep -n "print.*DEBUG" file` |
| Go | `fmt.Printf("[DEBUG] %v\n", varName)` | `grep -n "fmt.Print.*DEBUG" file` |
| Rust | `println!("[DEBUG] {:?}", var_name);` | `grep -n "println.*DEBUG" file` |
| Ruby | `puts "[DEBUG] #{var_name}"` | `grep -n "puts.*DEBUG" file` |
| Java | `System.out.println("[DEBUG] " + varName);` | `grep -n "System.out.*DEBUG" file` |

All strategic log statements use the `[DEBUG]` prefix for easy cleanup after diagnosis.
