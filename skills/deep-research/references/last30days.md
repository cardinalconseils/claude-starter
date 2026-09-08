# Reference: `last30days` — the social and market signal layer

`last30days` is a separate Claude Code plugin (MIT; Python 3.12 via `uv`). It answers
"what are people actually saying about X right now" with engagement-weighted evidence from
the last 30 days — the layer web search cannot give you. Not vendored into CKS.

## Install (per machine — surfaced by operator/bootstrap as `▶ ACTION REQUIRED`)

```
/plugin marketplace add mvanhorn/last30days-skill
```

Keys live in `~/.config/last30days/.env`. `PERPLEXITY_API_KEY` is the same one listed in
the CLAUDE.md environment table.

## Presence check (run before every use)

```bash
ls ~/.claude/plugins/cache/*/last30days* 2>/dev/null || command -v last30days
```

Absent → emit the `▶ ACTION REQUIRED` block with the install command above, then continue
with web research and say the signal layer was skipped.

## Sources

| Source | Key | What it adds |
|---|---|---|
| Reddit | none | Threads, upvotes, comment counts — the complaint and workaround layer |
| Hacker News | none | Builder and operator opinion, ranked by points and comments |
| GitHub | none | Issues, stars, release chatter for tools and libraries |
| Polymarket | none | Market-priced probability on events and launches |
| arXiv | none | Recent papers when the topic is research-adjacent |
| X (Twitter) | optional | Real-time reaction, engagement counts |
| YouTube | optional | Long-form explainers, view and comment counts |
| TikTok | optional | Consumer sentiment, view counts |
| Perplexity | optional (`PERPLEXITY_API_KEY`) | Cited synthesis across the web |

Keyless mode is always available; keyed sources appear when their key is configured.

## Invocation forms

```bash
last30days "<topic>" --emit=json --save-dir .research/last30days/
```

| Flag / form | Use |
|---|---|
| `--emit=json` | Structured output — always use it; never read raw stdout |
| `--save-dir <dir>` | Keep the JSON under `.research/last30days/` (gitignored, stays local) |
| `--store` | Persist the run to the local library so later runs can diff against it |
| `--as-of <date>` | Anchor the 30-day window to a past date (reproducible reports) |
| `--hiring-signals` | Job postings and role chatter — use for hiring, talent, and "who is building this" questions |
| `"X vs Y"` | Comparison mode — both sides scored on the same window |
| `library search "<query>"` | Search prior stored runs before spending a fresh query |
| `library feed` | Local digest of stored runs — output stays on the machine |

## Reading the JSON

Cite what the tool measured, not what it summarized: platform, thread or post title,
engagement counts (upvotes, points, comments, views), date. A finding with no engagement
number is a web-search finding, not a signal-layer finding — label it accordingly.

Merge into the research report under a `## Signal layer (last 30 days)` section, then run
the multi-hop loop (`workflows/research-loop.md`) to explain what the signal shows.

## When to run it

Any topic with a social, market, competitor, or hiring signal: product reactions, pricing
complaints, competitor launches, tool adoption, role demand, event buzz. Skip it for pure
API or library documentation questions — Context7 and Firecrawl cover those.
