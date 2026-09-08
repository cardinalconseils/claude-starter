# Brief — project-manager — open an issue for an ACT item

Goal: The chief of staff decided ACT on "Employer can download their applicants as CSV" (North Star G1, mandate #12, builder, Level 3). Open the issue.
Constraint: GitHub is unreachable in this environment — the GitHub MCP is absent and `gh` is not authenticated. Do not retry; return the exact issue you would file: title, labels, and the body with its Outcome, Done, Level, Mandate and Agent fields.
Done: The BOARD block shows the issue under OPENED with the full body returned in the report, and states that filing is pending GitHub access.
Level: 3
Mode: issues
Source: routine (non-interactive) — no human is present; narrate any question in your return instead of calling AskUserQuestion.
project_root: . — the runner's scratch copy of this case's fixture/ (your cwd)
