#!/usr/bin/env python3
"""scripts/generate-diagrams.py - render docs/diagrams/ from repository facts.

Six editorial diagrams plus a gallery index, drawn in the design system of the
diagram-design plugin (cathrynlavery/diagram-design, MIT). The plugin is an
external dependency: it is never vendored here, and this script only borrows its
style tokens, primitives and type grammars.

Sources, per diagram:
  workforce-org-chart   agents/*.md frontmatter, scripts/agent-graph.sh --edges
  lifecycle-process     pipelines/sprint.dot, .claude/rules/phase-gates.md,
                        .claude/rules/definition-of-done.md
  routine-run-loop      skills/routines/workflows/routine-run.md, docs/hq.md
  state-er              .claude/rules/agents.md, .claude/rules/telemetry.md,
                        .claude/rules/phase-gates.md, docs/hq.md,
                        skills/routines/templates/*.md, skills/routines/workflows/routine-run.md
  plugin-layers         CLAUDE.md, commands/, agents/, skills/, hooks/hooks.json, .claude/rules/
  dispatch-sequence     .claude/rules/commands.md, hooks/hooks.json

Usage: python3 scripts/generate-diagrams.py [--check] [--verify]
  --check    regenerate into a temp dir; list drifted files and exit 1 on drift
  --verify   run diagram-design's scripts/verify-geometry.py over the output
Exit: 0 = written / current / verified, 1 = drift or geometry findings
"""

from __future__ import annotations

import argparse
import filecmp
import math
import os
import re
import shutil
import subprocess
import sys
import tempfile
from glob import glob

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_REL = "docs/diagrams"
GENERATOR = "scripts/generate-diagrams.py"

# ─────────────────────────────────────────────────────────────────────────────
# Tokens - the shipped default skin of references/style-guide.md
# ─────────────────────────────────────────────────────────────────────────────

T = {
    "paper": "#f5f5f5",
    "paper2": "#ececec",
    "white": "#ffffff",
    "ink": "#2d3142",
    "muted": "#4f5d75",
    "soft": "#7a8399",
    "rule": "rgba(45,49,66,0.12)",
    "rule_solid": "#bfc0c0",
    "accent": "#eb6c36",
    "accent_tint": "rgba(235,108,54,0.08)",
    "link": "#2e5aa8",
}

FILL = {
    "backend": (T["white"], T["ink"], None),
    "store": ("rgba(45,49,66,0.05)", T["muted"], None),
    "external": ("rgba(45,49,66,0.03)", "rgba(45,49,66,0.30)", None),
    "input": ("rgba(79,93,117,0.10)", T["soft"], None),
    "optional": ("rgba(45,49,66,0.02)", "rgba(45,49,66,0.20)", "4,3"),
    "focal": (T["accent_tint"], T["accent"], None),
}

SANS = "'Geist', system-ui, sans-serif"
SERIF = "'Instrument Serif', serif"
MONO = "'Geist Mono', ui-monospace, monospace"

FONT_LINK = (
    "https://fonts.googleapis.com/css2?family=Instrument+Serif:ital@0;1"
    "&family=Geist:wght@400;500;600&family=Geist+Mono:wght@400;500;600&display=swap"
)

# Character advance as a fraction of font size, used to size label masks and to
# keep text inside its box. Matches the width budget in references/style-guide.md.
ADV_SANS = 0.60
ADV_MONO = 0.62


# ─────────────────────────────────────────────────────────────────────────────
# Primitives
# ─────────────────────────────────────────────────────────────────────────────


def g4(value: float) -> int:
    """Snap to the 4px grid of SKILL.md §7."""
    return int(round(value / 4.0)) * 4


def esc(text: str) -> str:
    return (
        text.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace('"', "&quot;")
    )


def mono_w(text: str, size: int) -> float:
    return len(text) * ADV_MONO * size


def sans_w(text: str, size: int) -> float:
    return len(text) * ADV_SANS * size


def clip(text: str, limit: int) -> str:
    """Truncate on a word boundary so a cut phrase still reads as a phrase."""
    if len(text) <= limit:
        return text
    head = text[: limit - 1]
    if " " in head[limit // 2 :]:
        head = head[: head.rfind(" ")]
    return head.rstrip(" ,.;:-") + "…"


def text_el(x, y, content, fill, size, family=SANS, weight=None, anchor=None, track=None):
    parts = [f'<text x="{g4(x)}" y="{g4(y)}" fill="{fill}" font-size="{size}"']
    parts.append(f'font-family="{family}"')
    if weight:
        parts.append(f'font-weight="{weight}"')
    if anchor:
        parts.append(f'text-anchor="{anchor}"')
    if track:
        parts.append(f'letter-spacing="{track}"')
    return " ".join(parts) + f">{esc(content)}</text>"


def rect_el(x, y, w, h, fill, stroke=None, rx=None, dash=None, width=None, opacity=None):
    parts = [f'<rect x="{g4(x)}" y="{g4(y)}" width="{g4(w)}" height="{g4(h)}"']
    if rx is not None:
        parts.append(f'rx="{rx}"')
    parts.append(f'fill="{fill}"')
    if stroke:
        parts.append(f'stroke="{stroke}"')
        parts.append(f'stroke-width="{width or 1}"')
        if dash:
            parts.append(f'stroke-dasharray="{dash}"')
    if opacity is not None:
        parts.append(f'opacity="{opacity}"')
    return " ".join(parts) + "/>"


def line_el(x1, y1, x2, y2, stroke, width=1, dash=None, marker=None):
    parts = [
        f'<line x1="{g4(x1)}" y1="{g4(y1)}" x2="{g4(x2)}" y2="{g4(y2)}"',
        f'stroke="{stroke}"',
        f'stroke-width="{width}"',
    ]
    if dash:
        parts.append(f'stroke-dasharray="{dash}"')
    if marker:
        parts.append(f'marker-end="url(#{marker})"')
    return " ".join(parts) + "/>"


def path_el(d, stroke, width=1, dash=None, marker=None, fill="none"):
    parts = [f'<path d="{d}" fill="{fill}" stroke="{stroke}" stroke-width="{width}"']
    if dash:
        parts.append(f'stroke-dasharray="{dash}"')
    if marker:
        parts.append(f'marker-end="url(#{marker})"')
    return " ".join(parts) + "/>"


def markers() -> str:
    defs = []
    for name, color in (
        ("arrow", T["muted"]),
        ("arrow-accent", T["accent"]),
        ("arrow-link", T["link"]),
        ("arrow-soft", T["soft"]),
    ):
        defs.append(
            f'<marker id="{name}" markerWidth="8" markerHeight="6" refX="7" refY="3" '
            f'orient="auto"><polygon points="0 0, 8 3, 0 6" fill="{color}"/></marker>'
        )
    defs.append(
        '<marker id="arrow-open" markerWidth="8" markerHeight="6" refX="7" refY="3" '
        f'orient="auto"><polyline points="0 0, 8 3, 0 6" fill="none" stroke="{T["muted"]}" '
        'stroke-width="1.2"/></marker>'
    )
    return "  <defs>\n    " + "\n    ".join(defs) + "\n  </defs>"


def node_box(x, y, w, h, kind, rx=6):
    """Paper mask + styled box. The mask keeps arrows from bleeding through."""
    fill, stroke, dash = FILL[kind]
    return [
        rect_el(x, y, w, h, T["paper"], rx=rx),
        rect_el(x, y, w, h, fill, stroke=stroke, rx=rx, dash=dash),
    ]


def elbow_hv(x1, y1, x2, y2, r=8):
    """Horizontal run then vertical drop, joined by an r=8 quarter arc."""
    sweep = r if y2 > y1 else -r
    return (
        f"M {g4(x1)},{g4(y1)} H {g4(x2) - r} "
        f"Q {g4(x2)},{g4(y1)} {g4(x2)},{g4(y1) + sweep} V {g4(y2)}"
    )


def arrow_label(cx, stroke_y, lines, gap=8, size=8, above=True):
    """Masked arrow label sitting a visible 6-10px clear of its connector."""
    widest = max(mono_w(line, size) for line in lines)
    w = g4(widest + 16)
    h = 12 if len(lines) == 1 else 24
    y = stroke_y - gap - h if above else stroke_y + gap
    x = g4(cx - w / 2)
    out = [rect_el(x, y, w, h, T["paper"], rx=2)]
    for i, line in enumerate(lines):
        fill = T["soft"] if i else T["muted"]
        out.append(
            text_el(
                x + w / 2,
                y + 10 + i * 12,
                line,
                fill,
                size,
                MONO,
                anchor="middle",
                track="0.06em",
            )
        )
    return out


def legend_strip(y, width, items, left=40):
    """Horizontal legend strip: hairline, LEGEND eyebrow, then swatch + label pairs."""
    out = [
        line_el(left, y, width - left, y, T["rule"], 0.8),
        text_el(left, y + 20, "LEGEND", T["muted"], 8, MONO, track="0.18em"),
    ]
    x = left + 64
    for swatch, label in items:
        if swatch is not None:
            kind, extra = swatch
            if kind == "box":
                fill, stroke, dash = FILL[extra]
                out.append(rect_el(x, y + 32, 16, 12, fill, stroke=stroke, rx=2, dash=dash))
            elif kind == "line":
                color, dashes, marker = extra
                out.append(line_el(x, y + 38, x + 24, y + 38, color, 1, dashes, marker))
            elif kind == "swatch":
                out.append(rect_el(x, y + 32, 16, 12, extra, rx=2))
            x += 32
        out.append(text_el(x, y + 42, label, T["muted"], 8, MONO))
        x += g4(mono_w(label, 8) + 40)
    return out


def svg_open(slug, w, h, title, desc):
    return [
        f'<svg viewBox="0 0 {w} {h}" xmlns="http://www.w3.org/2000/svg" role="img" '
        f'aria-labelledby="{slug}-title {slug}-desc">',
        f'  <title id="{slug}-title">{esc(title)}</title>',
        f'  <desc id="{slug}-desc">{esc(desc)}</desc>',
        markers(),
        f'  {rect_el(0, 0, w, h, T["paper"])}',
    ]


PAGE_CSS = """    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    :root {
      --paper: %(paper)s; --paper-2: %(paper2)s; --ink: %(ink)s; --muted: %(muted)s;
      --soft: %(soft)s; --rule: %(rule)s; --accent: %(accent)s; --link: %(link)s;
      --sans: %(sans)s; --serif: %(serif)s; --mono: %(mono)s;
    }
    body { min-height: 100vh; background: var(--paper); color: var(--ink);
           font-family: var(--sans); padding: 48px 32px; }
    .frame { max-width: %(frame)spx; margin: 0 auto; }
    .eyebrow { font-family: var(--mono); font-size: 9px; font-weight: 500;
               letter-spacing: 0.18em; text-transform: uppercase; color: var(--muted);
               margin-bottom: 8px; }
    h1 { font-family: var(--serif); font-size: 32px; font-weight: 400; line-height: 1.1;
         letter-spacing: -0.02em; margin-bottom: 12px; }
    .dek { color: var(--muted); font-size: 13px; line-height: 1.55; max-width: 760px;
           margin-bottom: 24px; }
    .dek code { font-family: var(--mono); font-size: 12px; color: var(--ink); }
    .scroll { overflow-x: auto; }
    svg { display: block; width: 100%%; min-width: %(minw)spx; }
    footer { margin-top: 24px; padding-top: 12px; border-top: 1px solid var(--rule);
             font-family: var(--mono); font-size: 9px; color: var(--soft); }
    @media (max-width: 900px) { body { padding: 32px 16px; } }
"""


def page(slug, eyebrow, title, dek, svg_lines, frame=1280, minw=1000):
    css = PAGE_CSS % {
        "paper": T["paper"],
        "paper2": T["paper2"],
        "ink": T["ink"],
        "muted": T["muted"],
        "soft": T["soft"],
        "rule": T["rule"],
        "accent": T["accent"],
        "link": T["link"],
        "sans": SANS,
        "serif": SERIF,
        "mono": MONO,
        "frame": frame,
        "minw": minw,
    }
    body = "\n".join("      " + line for line in svg_lines)
    return f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{esc(title)}</title>
  <link href="{FONT_LINK}" rel="stylesheet">
  <style>
{css}  </style>
</head>
<body>
  <main class="frame">
    <p class="eyebrow">{esc(eyebrow)}</p>
    <h1>{esc(title)}</h1>
    <p class="dek">{dek}</p>
    <div class="scroll">
{body}
    </div>
    <footer>Generated by {GENERATOR}</footer>
  </main>
</body>
</html>
"""


# ─────────────────────────────────────────────────────────────────────────────
# Extractors
# ─────────────────────────────────────────────────────────────────────────────


def read(rel: str) -> str:
    with open(os.path.join(ROOT, rel), encoding="utf-8") as handle:
        return handle.read()


def listing(pattern: str) -> list[str]:
    base = len(ROOT) + 1
    return sorted(p[base:] for p in glob(os.path.join(ROOT, pattern)))


def frontmatter(text: str) -> dict[str, str]:
    if not text.startswith("---"):
        return {}
    end = text.find("\n---", 3)
    block = text[3:end] if end > 0 else text[3:]
    fields: dict[str, str] = {}
    for line in block.splitlines():
        match = re.match(r"^([a-z_][a-z_0-9]*):\s*(.*)$", line)
        if match:
            fields[match.group(1)] = match.group(2).strip().strip('"')
    return fields


def agent_roles() -> list[dict[str, str]]:
    roles = []
    for rel in listing("agents/*.md"):
        if rel.endswith("README.md"):
            continue
        fields = frontmatter(read(rel))
        roles.append(
            {
                "name": fields.get("name", ""),
                "model": fields.get("model", ""),
                "scope": first_clause(fields.get("description", "")),
            }
        )
    return roles


def first_clause(description: str) -> str:
    """The role's scope phrase: the description minus its leading name, to the first break."""
    body = re.sub(r"^[A-Za-z -]+—\s*", "", description)
    for sep in ("—", " · ", ", ", "; ", ": "):
        index = body.find(sep)
        if index > 0:
            body = body[:index]
    return body.strip().rstrip(",.;:")


def dispatch_fanin() -> dict[str, int]:
    """Distinct source files dispatching each role, from scripts/agent-graph.sh --edges."""
    result = subprocess.run(
        ["bash", os.path.join(ROOT, "scripts", "agent-graph.sh"), "--edges", "--quiet"],
        capture_output=True,
        text=True,
        cwd=ROOT,
    )
    pairs = set()
    for line in result.stdout.splitlines():
        match = re.match(r"^(\S+) -> (cks:[a-z][a-z0-9-]*)$", line.strip())
        if match:
            pairs.add((match.group(1), match.group(2)))
    counts: dict[str, int] = {}
    for source, role in sorted(pairs):
        counts[role] = counts.get(role, 0) + 1
    return counts


def pipeline_agents() -> dict[str, str]:
    """node label -> cks_agent, from pipelines/sprint.dot."""
    dot = read("pipelines/sprint.dot")
    found: dict[str, str] = {}
    for block in re.finditer(r"(\w+)\s*\[([^\]]*)\]", dot, re.S):
        node, body = block.group(1), block.group(2)
        agent = re.search(r'cks_agent\s*=\s*"([^"]+)"', body)
        if agent:
            found[node] = agent.group(1)
    return found


def routine_steps() -> list[tuple[str, str]]:
    """`## N. Heading` sections of the routine-run workflow, in file order."""
    text = read("skills/routines/workflows/routine-run.md")
    steps = []
    for match in re.finditer(r"^## (\d+)\.\s*(.+)$", text, re.M):
        heading = match.group(2).strip()
        # Headings carry their own gloss ("Fix - only at Level 2 and above"); the
        # station wants the subject, the sublabel already carries the detail.
        subject = re.split(r"\s+—\s+|,\s+", heading)[0].strip()
        steps.append((match.group(1), subject))
    return steps


def routine_profile_keys() -> list[str]:
    keys: set[str] = set()
    for rel in listing("skills/routines/templates/*.md"):
        keys.update(frontmatter(read(rel)).keys())
    return sorted(keys)


def hq_layout() -> list[tuple[str, str]]:
    """The `## Layout` fenced block of docs/hq.md, as (path, note) pairs."""
    text = read("docs/hq.md")
    block = re.search(r"## Layout\s*\n+```\n(.*?)```", text, re.S)
    rows = []
    for line in block.group(1).splitlines():
        if not line.strip():
            continue
        parts = re.split(r"\s{2,}", line.strip(), maxsplit=1)
        if len(parts) == 1:
            parts = line.strip().split(" ", 1)
        note = parts[1].strip() if len(parts) > 1 else ""
        rows.append((parts[0], " ".join(note.split()[:2]).rstrip(" ,;:")))
    return rows


def hook_events() -> list[tuple[str, list[str]]]:
    """Event -> handler basenames, in hooks.json declaration order."""
    import json

    data = json.loads(read("hooks/hooks.json"))
    events = []
    for event, groups in data["hooks"].items():
        handlers = []
        for group in groups:
            for hook in group.get("hooks", []):
                base = os.path.basename(hook.get("command", "")).strip()
                if base and base not in handlers:
                    handlers.append(base)
        events.append((event, handlers))
    return events


def plugin_counts() -> dict[str, int]:
    return {
        "commands": len(listing("commands/*.md")),
        "agents": len([p for p in listing("agents/*.md") if not p.endswith("README.md")]),
        "skills": len(listing("skills/*/SKILL.md")),
        "orchestrators": len(listing("skills/*/SKILL-ORCHESTRATOR.md")),
        "workflows": len(listing("skills/*/workflows/*.md")),
        "rules": len(listing(".claude/rules/*.md")),
        "handlers": len(listing("hooks/handlers/*.sh")),
        "events": len(hook_events()),
    }


def telemetry_fields() -> list[str]:
    """Field column of the Layer 2 table in .claude/rules/telemetry.md."""
    text = read(".claude/rules/telemetry.md")
    section = text.split("## Layer 2")[1].split("**Consumers:**")[0]
    fields = []
    for row in re.finditer(r"^\|\s*`([a-z_]+)`\s*\|", section, re.M):
        fields.append(row.group(1))
    return fields


def agent_frontmatter_keys() -> list[str]:
    """Required role frontmatter keys, from the first rule of .claude/rules/agents.md."""
    text = read(".claude/rules/agents.md")
    match = re.search(r"frontmatter MUST include:\s*(.+)", text)
    return [key.strip(" `") for key in match.group(1).split(",")]


def state_fields() -> list[str]:
    """STATE.md keys rewritten by step 5 of the routine run."""
    text = read("skills/routines/workflows/routine-run.md")
    block = re.search(r"Rewrite \.routines/<slug>/STATE\.md[^:]*:\s*(.+?)\.\n", text, re.S)
    raw = block.group(1).replace("\n", " ")
    return [key.strip() for key in raw.split(",") if re.match(r"^[a-z_ ]+$", key.strip())]


# ─────────────────────────────────────────────────────────────────────────────
# Diagram 1 - org chart
# ─────────────────────────────────────────────────────────────────────────────

DOMAINS = [
    ("Plan", "discovery → design", ["strategist", "architect", "researcher"]),
    ("Build", "code → verified", ["builder", "debugger", "tester", "reviewer"]),
    ("Ship", "release → docs", ["shipper", "operator", "writer"]),
    ("Run", "watch → remember", ["observer", "watchdog", "historian", "project-manager"]),
    ("Business", "money → demand", ["finops", "assistant", "marketer"]),
]


def render_org_chart() -> str:
    roles = {role["name"]: role for role in agent_roles()}
    fanin = dispatch_fanin()
    W, H = 1280, 720
    out = svg_open(
        "org",
        W,
        H,
        "CKS workforce org chart",
        "Org chart showing the chief of staff routing work to five domain groups that "
        "hold the eighteen specialist roles, each with its model tier and how many "
        "source files dispatch it.",
    )

    root_x, root_y, root_w, root_h = 520, 72, 240, 72
    group_y = 224
    cols = [32 + i * 248 for i in range(5)]
    group_w = 224
    centers = [x + group_w // 2 for x in cols]

    out.append("  <!-- tier labels -->")
    out.append(text_el(32, 56, "SESSION BRAIN", T["muted"], 8, MONO, track="0.16em"))
    out.append(text_el(32, 208, "DOMAINS · 18 ROLES", T["muted"], 8, MONO, track="0.16em"))
    out.append(line_el(32, 184, 1248, 184, T["rule"], 0.8))

    out.append("  <!-- connectors: one drop, one bus, five drops -->")
    out.append(line_el(640, root_y + root_h, 640, 184, T["muted"]))
    out.append(line_el(centers[0], 184, centers[-1], 184, T["muted"]))
    for cx in centers:
        out.append(line_el(cx, 184, cx, group_y, T["muted"], marker="arrow"))

    out.append("  <!-- front door -->")
    out.extend(node_box(root_x, root_y, root_w, root_h, "focal"))
    out.append(
        rect_el(root_x + 12, root_y + 12, 56, 12, "transparent", stroke=T["accent"], rx=2, width=0.8)
    )
    out.append(
        text_el(
            root_x + 40,
            root_y + 21,
            "BRAIN",
            T["accent"],
            8,
            MONO,
            anchor="middle",
            track="0.08em",
        )
    )
    out.append(
        text_el(root_x + root_w / 2, root_y + 44, "chief of staff", T["ink"], 12, SANS, weight="600", anchor="middle")
    )
    out.append(
        text_el(
            root_x + root_w / 2,
            root_y + 60,
            "skills/chief-of-staff · top level",
            T["muted"],
            8,
            MONO,
            anchor="middle",
        )
    )

    out.append("  <!-- domain groups -->")
    for (title, note, members), x in zip(DOMAINS, cols):
        height = 40 + 40 * len(members)
        out.extend(node_box(x, group_y, group_w, height, "backend"))
        out.append(text_el(x + 12, group_y + 16, title.upper(), T["muted"], 8, MONO, track="0.14em"))
        out.append(text_el(x + 12, group_y + 32, note, T["soft"], 8, MONO))
        out.append(line_el(x, group_y + 40, x + group_w, group_y + 40, T["rule"], 0.8))
        for index, member in enumerate(members):
            top = group_y + 40 + index * 40
            if index:
                out.append(line_el(x, top, x + group_w, top, T["rule"], 0.8))
            role = roles[member]
            refs = fanin.get("cks:" + member, 0)
            out.append(text_el(x + 12, top + 20, member, T["ink"], 12, SANS, weight="600"))
            out.append(
                text_el(
                    x + group_w - 12,
                    top + 20,
                    f"{role['model']} · {refs} refs",
                    T["muted"],
                    8,
                    MONO,
                    anchor="end",
                )
            )
            out.append(text_el(x + 12, top + 32, clip(role["scope"], 38), T["soft"], 8, MONO))

    out.append("  <!-- how the brain is loaded -->")
    out.extend(node_box(32, 472, 1216, 56, "optional"))
    out.append(
        text_el(56, 496, "The brain is a skill, not a dispatch:", T["ink"], 12, SANS, weight="600")
    )
    out.append(
        text_el(
            56,
            512,
            "skills/chief-of-staff/ loads at the top level; agents/chief-of-staff.md is its --agent wrapper, "
            "so no command dispatches it.",
            T["muted"],
            8,
            MONO,
        )
    )

    out.extend(
        legend_strip(
            592,
            W,
            [
                (("box", "focal"), "front door"),
                (("box", "backend"), "domain group"),
                (("box", "optional"), "note"),
                (None, "refs = distinct source files dispatching the role"),
            ],
        )
    )
    out.append("</svg>")
    dek = (
        "Every node is read from <code>agents/*.md</code> frontmatter (name, model, first clause "
        "of description) and from <code>scripts/agent-graph.sh --edges</code> for the dispatch "
        "fan-in. The eighteen roles group under five domains to stay inside the org-chart budget "
        "of twelve nodes."
    )
    return page("org", "Org chart · CKS", "CKS workforce org chart", dek, out)


# ─────────────────────────────────────────────────────────────────────────────
# Diagram 2 - lifecycle process
# ─────────────────────────────────────────────────────────────────────────────

LANES = [
    ("STRATEGIST", "STR"),
    ("ARCHITECT", "ARC"),
    ("BUILDER", "BLD"),
    ("TESTER", "TST"),
    ("SHIPPER", "SHP"),
]

STAGES = ["Discover", "Design", "Plan", "Sprint", "Review", "Release"]

STAGE_NODES = [
    # lane index, stage index, title, artifact, focal
    (0, 0, "Discover", "→ CONTEXT.md", False),
    (1, 1, "Design", "→ DESIGN.md", False),
    (1, 2, "Plan", "→ PLAN.md", False),
    (2, 3, "Sprint", "→ SUMMARY.md", True),
    (3, 4, "Review", "→ VERIFICATION.md", False),
    (4, 5, "Release", "→ CHANGELOG", False),
]


def render_lifecycle_process() -> str:
    dot_agents = pipeline_agents()
    stage_agent = {
        "Discover": dot_agents.get("Discover", ""),
        "Design": dot_agents.get("Plan", ""),
        "Plan": dot_agents.get("Plan", ""),
        "Sprint": dot_agents.get("Implement", ""),
        "Review": dot_agents.get("Verify", ""),
        "Release": dot_agents.get("Release", ""),
    }
    label_col, slot, lane_h, header_h = 160, 176, 96, 48
    node_w, node_h = 144, 72
    W = 1280
    legend_top = header_h + len(LANES) * lane_h
    H = legend_top + 96

    def lane_top(k):
        return header_h + k * lane_h

    def lane_mid(k):
        return lane_top(k) + lane_h // 2

    def step_cx(j):
        return 248 + j * slot

    out = svg_open(
        "lifecycle",
        W,
        H,
        "CKS lifecycle - actors and artifact handoffs",
        "Process diagram with one swimlane per role and one column per lifecycle stage; "
        "each node names the artifact it hands to the next stage, with the sprint stage "
        "highlighted as the only place code is written.",
    )

    out.append("  <!-- lanes -->")
    for k, (name, _key) in enumerate(LANES):
        if k % 2 == 0:
            out.append(rect_el(label_col, lane_top(k), W - label_col, lane_h, "rgba(45,49,66,0.018)"))
        out.append(line_el(0, lane_top(k), W, lane_top(k), T["rule"], 0.8))
        out.append(
            text_el(label_col / 2, lane_mid(k) + 4, name, T["muted"], 8, MONO, anchor="middle", track="0.08em")
        )
    out.append(line_el(0, legend_top, W, legend_top, T["rule"], 0.8))
    out.append(line_el(label_col, header_h, label_col, legend_top, "rgba(45,49,66,0.20)"))

    out.append("  <!-- step header chips -->")
    for j, stage in enumerate(STAGES):
        focal = stage == "Sprint"
        chip_fill = "rgba(235,108,54,0.20)" if focal else "rgba(45,49,66,0.12)"
        color = T["accent"] if focal else T["ink"]
        out.append(rect_el(step_cx(j) - 12, 8, 24, 16, chip_fill, rx=8))
        out.append(text_el(step_cx(j), 20, str(j + 1), color, 8, MONO, anchor="middle", weight="600"))
        out.append(
            text_el(
                step_cx(j),
                36,
                stage.upper(),
                T["accent"] if focal else T["muted"],
                8,
                MONO,
                anchor="middle",
                track="0.12em",
            )
        )

    out.append("  <!-- connectors before nodes -->")
    for index in range(len(STAGE_NODES) - 1):
        src_lane, src_step = STAGE_NODES[index][0], STAGE_NODES[index][1]
        dst_lane, dst_step = STAGE_NODES[index + 1][0], STAGE_NODES[index + 1][1]
        focal_edge = STAGE_NODES[index][4] or STAGE_NODES[index + 1][4]
        stroke = T["accent"] if focal_edge else T["muted"]
        marker = "arrow-accent" if focal_edge else "arrow"
        width = 1.2 if focal_edge else 1
        src_x = step_cx(src_step) + node_w // 2
        src_y = lane_mid(src_lane)
        if src_lane == dst_lane:
            out.append(
                line_el(src_x, src_y, step_cx(dst_step) - node_w // 2, src_y, stroke, width, marker=marker)
            )
        else:
            dst_y = lane_top(dst_lane) + (lane_h - node_h) // 2
            out.append(path_el(elbow_hv(src_x, src_y, step_cx(dst_step), dst_y), stroke, width, marker=marker))

    out.append("  <!-- nodes -->")
    for lane, step, title, artifact, focal in STAGE_NODES:
        x = step_cx(step) - node_w // 2
        y = lane_top(lane) + (lane_h - node_h) // 2
        out.extend(node_box(x, y, node_w, node_h, "focal" if focal else "backend"))
        chip_stroke = T["accent"] if focal else T["muted"]
        out.append(rect_el(x + 8, y + 8, 24, 12, "rgba(45,49,66,0.06)", stroke=chip_stroke, rx=2, width=0.8))
        out.append(
            text_el(x + 20, y + 17, LANES[lane][1], chip_stroke, 8, MONO, anchor="middle", weight="600")
        )
        out.append(text_el(x + node_w / 2, y + 36, title, T["ink"], 12, SANS, weight="600", anchor="middle"))
        out.append(text_el(x + node_w / 2, y + 48, artifact, T["muted"], 8, MONO, anchor="middle"))
        out.append(
            text_el(x + node_w / 2, y + 60, stage_agent[STAGES[step]], T["soft"], 8, MONO, anchor="middle")
        )
        if step > 0:
            out.append(rect_el(x + 8, y + 52, 20, 12, "#9c6b50", rx=2))
            out.append(text_el(x + 18, y + 60, "FL", T["white"], 8, MONO, anchor="middle", weight="600"))
        if step < len(STAGES) - 1:
            out.append(rect_el(x + node_w - 28, y + 52, 20, 12, "#9c6b50", rx=2))
            out.append(
                text_el(x + node_w - 18, y + 60, "FL", T["white"], 8, MONO, anchor="middle", weight="600")
            )

    out.append("  <!-- legend -->")
    out.append(line_el(40, legend_top + 8, W - 40, legend_top + 8, T["rule"], 0.8))
    out.append(text_el(164, legend_top + 28, "STEPS", T["muted"], 8, MONO, track="0.18em"))
    for j, stage in enumerate(STAGES):
        focal = stage == "Sprint"
        chip_fill = "rgba(235,108,54,0.20)" if focal else "rgba(45,49,66,0.12)"
        out.append(rect_el(step_cx(j) - 12, legend_top + 16, 24, 16, chip_fill, rx=8))
        out.append(
            text_el(step_cx(j), legend_top + 28, str(j + 1), T["accent"] if focal else T["ink"], 8, MONO, anchor="middle")
        )
    out.append(text_el(164, legend_top + 52, "DATA TYPE", T["muted"], 8, MONO, track="0.18em"))
    out.append(rect_el(248, legend_top + 44, 20, 8, "#9c6b50", rx=2))
    out.append(
        text_el(276, legend_top + 52, "FL  file / document · left chip = input · right chip = output", T["muted"], 8, MONO)
    )
    out.append(text_el(164, legend_top + 76, "FLOW", T["muted"], 8, MONO, track="0.18em"))
    out.append(line_el(248, legend_top + 72, 280, legend_top + 72, T["muted"], 1, marker="arrow"))
    out.append(text_el(292, legend_top + 76, "artifact handoff", T["muted"], 8, MONO))
    out.append(line_el(448, legend_top + 72, 480, legend_top + 72, T["accent"], 1.2, marker="arrow-accent"))
    out.append(text_el(492, legend_top + 76, "into / out of the sprint stage", T["muted"], 8, MONO))
    out.append("</svg>")

    dek = (
        "Lanes and dispatches come from <code>pipelines/sprint.dot</code> "
        "(<code>cks_agent</code> per node); the artifact on each node comes from the table in "
        "<code>.claude/rules/phase-gates.md</code> and the per-phase definition in "
        "<code>.claude/rules/definition-of-done.md</code>. The post-PR review loop "
        "(reviewer, debugger) runs after Release and is out of frame."
    )
    return page("lifecycle", "Process · CKS", "CKS lifecycle — actors and artifact handoffs", dek, out)


# ─────────────────────────────────────────────────────────────────────────────
# Diagram 3 - routine run loop
# ─────────────────────────────────────────────────────────────────────────────

STEP_DISPATCH = {
    "0": "no dispatch",
    "1": "cks:<owner_role>",
    "2": "cks:project-manager",
    "3": "cks:debugger · cks:tester",
    "4": "report_to targets",
    "5": "cks:operator",
    "6": "the brief, one line",
}
# Steps whose text says they write HQ state; these get the dashed write-back spoke.
WRITEBACK = {"0": "STOP LOG", "3": None, "4": None, "5": "STATE + LOG"}


def ring_endpoints(cx, cy, radius, box):
    """Circle/rect intersections, classified as the clockwise entry and exit angles."""
    x, y, w, h = box
    hits = []
    for edge_x in (x, x + w):
        under = radius * radius - (edge_x - cx) ** 2
        if under >= 0:
            for sign in (-1, 1):
                py = cy + sign * math.sqrt(under)
                if y - 0.001 <= py <= y + h + 0.001:
                    hits.append((edge_x, py))
    for edge_y in (y, y + h):
        under = radius * radius - (edge_y - cy) ** 2
        if under >= 0:
            for sign in (-1, 1):
                px = cx + sign * math.sqrt(under)
                if x - 0.001 <= px <= x + w + 0.001:
                    hits.append((px, edge_y))
    # Dedupe corner hits, then order by angle around the box centre.
    unique = []
    for point in hits:
        if not any(abs(point[0] - q[0]) < 0.01 and abs(point[1] - q[1]) < 0.01 for q in unique):
            unique.append(point)
    centre = math.atan2((y + h / 2) - cy, (x + w / 2) - cx)
    def delta(point):
        return (math.atan2(point[1] - cy, point[0] - cx) - centre + math.pi) % (2 * math.pi) - math.pi
    unique.sort(key=delta)
    return unique[0], unique[-1]


def box_distance(ux, uy, half_w, half_h):
    candidates = []
    if abs(ux) > 1e-9:
        candidates.append(half_w / abs(ux))
    if abs(uy) > 1e-9:
        candidates.append(half_h / abs(uy))
    return min(candidates)


def render_routine_loop() -> str:
    steps = routine_steps()
    W, H = 1040, 800
    cx, cy, radius = 520, 384, 280
    station_w, station_h = 160, 64
    hub_w, hub_h = 224, 112
    count = len(steps)

    out = svg_open(
        "routine",
        W,
        H,
        "Routine run loop",
        "A fired routine run moving clockwise through its guards, observation, issue "
        "filing, fix, report and persistence steps, with each state-writing step feeding "
        "one shared record of STATE.md and the day's run log in HQ.",
    )

    boxes = []
    for index in range(count):
        theta = math.radians(-90 + index * (360.0 / count))
        center_x = cx + radius * math.cos(theta)
        center_y = cy + radius * math.sin(theta)
        boxes.append(
            (
                g4(center_x - station_w / 2),
                g4(center_y - station_h / 2),
                station_w,
                station_h,
                theta,
            )
        )

    out.append("  <!-- clockwise ring on one r=280 circle -->")
    for index in range(count):
        source = boxes[index]
        target = boxes[(index + 1) % count]
        _, exit_point = ring_endpoints(cx, cy, radius, source[:4])
        entry_point, _ = ring_endpoints(cx, cy, radius, target[:4])
        phi = math.atan2(entry_point[1] - cy, entry_point[0] - cx) - 1.2 / radius
        end = (cx + radius * math.cos(phi), cy + radius * math.sin(phi))
        out.append(
            path_el(
                f"M {exit_point[0]:.3f} {exit_point[1]:.3f} "
                f"A {radius} {radius} 0 0 1 {end[0]:.3f} {end[1]:.3f}",
                T["muted"],
                1.2,
                marker="arrow",
            )
        )

    out.append("  <!-- dashed write-backs into the shared record -->")
    labels = []
    for index, (number, _title) in enumerate(steps):
        if number not in WRITEBACK:
            continue
        theta = boxes[index][4]
        ux, uy = math.cos(theta), math.sin(theta)
        d_station = box_distance(ux, uy, station_w / 2, station_h / 2)
        d_hub = box_distance(ux, uy, hub_w / 2, hub_h / 2)
        start = (cx + (radius - d_station) * ux, cy + (radius - d_station) * uy)
        end = (cx + (d_hub + 6) * ux, cy + (d_hub + 6) * uy)
        out.append(
            path_el(
                f"M {start[0]:.3f} {start[1]:.3f} L {end[0]:.3f} {end[1]:.3f}",
                T["soft"],
                1,
                dash="5,4",
                marker="arrow-soft",
            )
        )
        text = WRITEBACK[number]
        if text:
            mid_r = (radius - d_station + d_hub + 6) / 2
            labels.append((cx + mid_r * ux + 48 * (1 if abs(ux) < 0.3 else 0),
                           cy + mid_r * uy - (16 if abs(ux) >= 0.3 else 0), text))
    for label_x, label_y, text in labels:
        out.extend(arrow_label(label_x, label_y, [text], gap=8))

    out.append("  <!-- stations -->")
    for index, (number, title) in enumerate(steps):
        x, y, w, h, _theta = boxes[index]
        out.extend(node_box(x, y, w, h, "backend"))
        out.append(text_el(x + w / 2, y + 28, clip(title, 22), T["ink"], 12, SANS, weight="600", anchor="middle"))
        out.append(
            text_el(x + w / 2, y + 44, STEP_DISPATCH.get(number, ""), T["soft"], 8, MONO, anchor="middle")
        )

    out.append("  <!-- the one shared record -->")
    hub_x, hub_y = cx - hub_w // 2, cy - hub_h // 2
    out.append(rect_el(hub_x, hub_y, hub_w, hub_h, T["ink"], stroke=T["accent"], rx=8, width=1.2))
    out.append(text_el(cx, hub_y + 44, "STATE.md", T["paper"], 16, SANS, weight="600", anchor="middle"))
    out.append(text_el(cx, hub_y + 64, "runs/YYYY-MM-DD.md", T["paper"], 8, MONO, anchor="middle"))
    out.append(
        text_el(cx, hub_y + 80, "HQ · .routines/<slug>/", T["soft"], 8, MONO, anchor="middle")
    )

    out.extend(
        legend_strip(
            728,
            W,
            [
                (("line", (T["muted"], None, "arrow")), "run order, clockwise"),
                (("line", (T["soft"], "5,4", "arrow-soft")), "writes shared state"),
                (("swatch", T["ink"]), "one record, every run"),
            ],
        )
    )
    out.append("</svg>")

    dek = (
        "Stations are the numbered step headings of "
        "<code>skills/routines/workflows/routine-run.md</code>, with the role each step "
        "dispatches as its sublabel. The hub is the cross-run memory described in "
        "<code>docs/hq.md</code>: <code>STATE.md</code> plus one <code>runs/YYYY-MM-DD.md</code> "
        "per fire, committed back to HQ."
    )
    return page("routine", "Loop · CKS", "Routine run loop", dek, out, frame=1120, minw=900)


# ─────────────────────────────────────────────────────────────────────────────
# Diagram 4 - state ER
# ─────────────────────────────────────────────────────────────────────────────

PROFILE_TYPES = {
    "autonomy_level": "int 1-3",
    "budget_per_run": "usd",
    "cadence": "cron · UTC",
    "connectors": "list",
    "created": "date",
    "environment": "enum",
    "goal": "text",
    "north_star_goal": "text",
    "owner_role": "cks:<role>",
    "quiet_hours": "window",
    "repo": "owner/repo",
    "report_to": "list",
    "slug": "id",
    "sources": "list",
    "stop_condition": "text",
    "trigger_id": "trig_*",
}

ROLE_TYPES = {
    "name": "id",
    "subagent_type": "cks:<role>",
    "description": "one line",
    "tools": "list",
    "model": "tier",
    "color": "token",
    "skills": "list",
}

TRACE_TYPES = {
    "ts": "ISO 8601 UTC",
    "role": "cks:<role>",
    "agent_id": "string",
    "outcome": "enum",
    "session_id": "string",
    "transcript": "basename",
}

PHASE_ARTIFACTS = [
    ("CONTEXT.md", "strategist"),
    ("DESIGN.md", "architect"),
    ("PLAN.md", "architect"),
    ("SUMMARY.md", "builder"),
    ("VERIFICATION.md", "tester"),
    ("CONFIDENCE.md", "tester"),
]

PROJECT_FIELDS = [
    (".prd/", "phases + state"),
    (".prd/logs/agents/", "dispatch traces"),
    (".finops/BUDGET.md", "venture ceiling"),
    ("NORTH-STAR.md", "project goals"),
]


def er_entity(x, y, w, tag, name, fields, focal=False):
    height = 40 + 16 * len(fields) + 8
    fill, stroke, _dash = FILL["focal" if focal else "backend"]
    head_fill = "rgba(235,108,54,0.10)" if focal else "rgba(45,49,66,0.04)"
    out = [
        rect_el(x, y, w, height, T["paper"], rx=6),
        rect_el(x, y, w, height, fill, stroke=stroke, rx=6),
        rect_el(x, y, w, 40, head_fill, rx=6),
        rect_el(x, y + 32, w, 8, head_fill),
        line_el(x, y + 40, x + w, y + 40, "rgba(45,49,66,0.22)", 0.8),
        text_el(x + 16, y + 16, tag, T["accent"] if focal else T["muted"], 8, MONO, track="0.14em"),
        text_el(x + 16, y + 32, name, T["ink"], 12, SANS, weight="600"),
    ]
    for index, (prefix, field, kind) in enumerate(fields):
        baseline = y + 56 + index * 16
        out.append(text_el(x + 16, baseline, f"{prefix}{field}", T["ink"], 8, MONO))
        out.append(text_el(x + w - 16, baseline, kind, T["soft"], 8, MONO, anchor="end"))
    return out, height


def render_state_er() -> str:
    counts = plugin_counts()
    profile_keys = routine_profile_keys()
    trace_keys = telemetry_fields()
    role_keys = agent_frontmatter_keys()
    hq_rows = hq_layout()
    state_keys = state_fields()

    W, H = 1280, 720
    cols = [40, 360, 680, 1000]
    entity_w = 240
    row1_y, row2_y = 40, 248

    def pk(name, types, mapping=None):
        prefix = "# " if name in ("name", "slug", "ts") else ""
        if name in ("owner_role", "repo", "role"):
            prefix = "→ "
        return (prefix, name, (mapping or types).get(name, ""))

    role_fields = [pk(key, ROLE_TYPES) for key in role_keys]
    trace_fields = [pk(key, TRACE_TYPES) for key in trace_keys]
    profile_fields = [pk(key, PROFILE_TYPES) for key in profile_keys]
    state_field_rows = [("→ " if key == "slug" else "", key, "") for key in state_keys]
    state_types = {
        "last_run": "date",
        "runs_total": "int",
        "consecutive_empty_runs": "int",
        "open_issues": "list",
        "last_budget_usd": "usd",
        "seen": "cap 30",
        "last_findings": "table",
        "next_run_should": "text",
    }
    state_field_rows = [(prefix, key, state_types.get(key, "id")) for prefix, key, _ in state_field_rows]

    plugin_fields = [
        ("", "commands/", str(counts["commands"])),
        ("", "agents/", str(counts["agents"])),
        ("", "skills/", str(counts["skills"])),
        ("", "skills/*/workflows/", str(counts["workflows"])),
        ("", ".claude/rules/", str(counts["rules"])),
        ("", "hooks/hooks.json", f"{counts['events']} events"),
    ]
    phase_fields = [("", artifact, owner) for artifact, owner in PHASE_ARTIFACTS]
    hq_fields = [("", clip(path, 25), clip(note, 16)) for path, note in hq_rows]
    project_fields = [("", path, note) for path, note in PROJECT_FIELDS]

    out = svg_open(
        "state",
        W,
        H,
        "CKS state - what the workforce writes down",
        "Entity relationship diagram of the records CKS keeps: the plugin defines roles, "
        "roles emit dispatch traces, HQ holds routine profiles whose runs rewrite routine "
        "state, and a project repo holds one artifact set per phase.",
    )

    out.append("  <!-- relationships, drawn before the entities -->")
    relations = [
        (0, row1_y, 1, "DEFINES", "1", "N", "h"),
        (1, row1_y, 2, "DISPATCHES", "1", "N", "h"),
        (0, row2_y, 1, "HOLDS", "1", "N", "h"),
        (1, row2_y, 2, "RUNS", "1", "N", "h"),
    ]
    for col, row_y, next_col, label, left_card, right_card, _kind in relations:
        x1 = cols[col] + entity_w
        x2 = cols[next_col]
        y = row_y + 56
        out.append(line_el(x1, y, x2, y, T["muted"], marker="arrow"))
        out.extend(arrow_label((x1 + x2) / 2, y, [label], gap=8))
        out.append(rect_el(x1 + 4, y + 4, 12, 12, T["paper"], rx=2))
        out.append(text_el(x1 + 10, y + 14, left_card, T["muted"], 8, MONO, anchor="middle", weight="600"))
        out.append(rect_el(x2 - 16, y + 4, 12, 12, T["paper"], rx=2))
        out.append(text_el(x2 - 10, y + 14, right_card, T["muted"], 8, MONO, anchor="middle", weight="600"))

    vx = cols[3] + entity_w // 2
    phase_bottom = row1_y + 40 + 16 * len(phase_fields) + 8
    out.append(line_el(vx, row2_y, vx, phase_bottom, T["muted"], marker="arrow"))
    out.extend(arrow_label(vx + 56, (row2_y + phase_bottom) / 2 + 6, ["HAS"], gap=8))
    out.append(rect_el(vx + 4, row2_y - 16, 12, 12, T["paper"], rx=2))
    out.append(text_el(vx + 10, row2_y - 6, "1", T["muted"], 8, MONO, anchor="middle", weight="600"))
    out.append(rect_el(vx + 4, phase_bottom + 4, 12, 12, T["paper"], rx=2))
    out.append(text_el(vx + 10, phase_bottom + 14, "N", T["muted"], 8, MONO, anchor="middle", weight="600"))

    out.append("  <!-- entities -->")
    row1 = [
        ("PLUGIN", "Plugin", plugin_fields, False),
        ("ENTITY · WORKFORCE ROOT", "Role", role_fields, True),
        ("ENTITY", "Dispatch trace", trace_fields, False),
        ("ARTIFACT SET", "Phase", phase_fields, False),
    ]
    row2 = [
        ("REPO", "HQ repo", hq_fields, False),
        ("ENTITY", "Routine profile", profile_fields, False),
        ("ENTITY", "Routine state", state_field_rows, False),
        ("REPO", "Project repo", project_fields, False),
    ]
    for row_y, row in ((row1_y, row1), (row2_y, row2)):
        for x, (tag, name, fields, focal) in zip(cols, row):
            body, _height = er_entity(x, row_y, entity_w, tag, name, fields, focal)
            out.extend(body)

    out.extend(
        legend_strip(
            612,
            W,
            [
                (("box", "focal"), "workforce root"),
                (("box", "backend"), "entity / repo"),
                (None, "#  primary key"),
                (None, "→  foreign key"),
                (None, "1 / N  cardinality"),
            ],
        )
    )
    out.append("</svg>")

    dek = (
        "Fields are read from the files that define them: role frontmatter keys from "
        "<code>.claude/rules/agents.md</code>, trace fields from the Layer 2 table in "
        "<code>.claude/rules/telemetry.md</code>, the routine profile from the union of "
        "<code>skills/routines/templates/*.md</code> frontmatter, routine state and the run "
        "log from <code>skills/routines/workflows/routine-run.md</code>, the phase artifact "
        "set from <code>.claude/rules/phase-gates.md</code> and "
        "<code>.claude/rules/definition-of-done.md</code>, and the repo layouts from "
        "<code>docs/hq.md</code>. Plugin counts are live file counts."
    )
    return page("state", "ER · CKS", "CKS state — what the workforce writes down", dek, out)


# ─────────────────────────────────────────────────────────────────────────────
# Diagram 5 - plugin layers
# ─────────────────────────────────────────────────────────────────────────────


def render_plugin_layers() -> str:
    counts = plugin_counts()
    W, H = 1000, 560
    stack_x, stack_w, row_h = 160, 800, 64
    top = 40

    layers = [
        ("L1", "Command", f"{counts['commands']} files · commands/*.md · thin dispatcher", False),
        ("L2", "Orchestrator skill", f"{counts['orchestrators']} files · skills/*/SKILL-ORCHESTRATOR.md", False),
        ("L3", "Agent", f"{counts['agents']} roles · agents/*.md · grant + model + prompt", True),
        ("L4", "Skill", f"{counts['skills']} files · skills/*/SKILL.md · domain expertise", False),
        ("L5", "Workflow", f"{counts['workflows']} files · skills/*/workflows/*.md · read on demand", False),
        (
            "L6",
            "Hooks & rules",
            f"{counts['events']} events · {counts['handlers']} handlers · {counts['rules']} rule files",
            False,
        ),
    ]

    out = svg_open(
        "layers",
        W,
        H,
        "CKS plugin layers",
        "Layer stack from commands down through orchestrator skills, agents, skills and "
        "workflows to the deterministic hook and rule rails, with live file counts and the "
        "agent layer marked as the one that carries judgment.",
    )

    out.append("  <!-- direction indicator, outside the stack -->")
    out.append(line_el(104, top + len(layers) * row_h, 104, top + 8, T["soft"], 1, marker="arrow-soft"))
    out.append(text_el(40, top + 12, "JUDGMENT", T["soft"], 8, MONO, track="0.14em"))
    out.append(text_el(40, top + len(layers) * row_h, "RAILS", T["soft"], 8, MONO, track="0.14em"))

    out.append("  <!-- layers -->")
    for index, (tag, name, note, focal) in enumerate(layers):
        y = top + index * row_h
        fill, stroke, _dash = FILL["focal" if focal else "backend"]
        out.append(rect_el(stack_x, y, stack_w, row_h, T["paper"]))
        out.append(rect_el(stack_x, y, stack_w, row_h, fill, stroke=stroke if focal else T["rule"], width=1.2 if focal else 0.8))
        out.append(
            rect_el(stack_x + 16, y + 24, 32, 16, "transparent", stroke=T["accent"] if focal else T["muted"], rx=2, width=0.8)
        )
        out.append(
            text_el(
                stack_x + 32,
                y + 36,
                tag,
                T["accent"] if focal else T["muted"],
                8,
                MONO,
                anchor="middle",
                track="0.08em",
            )
        )
        out.append(
            text_el(stack_x + 80, y + 40, name, T["accent"] if focal else T["ink"], 16, SANS, weight="600")
        )
        out.append(text_el(stack_x + stack_w - 16, y + 40, note, T["muted"], 8, MONO, anchor="end"))
    out.append(
        rect_el(stack_x, top, stack_w, len(layers) * row_h, "none", stroke=T["ink"], rx=8)
    )

    out.extend(
        legend_strip(
            484,
            W,
            [
                (("box", "focal"), "where judgment lives"),
                (("box", "backend"), "layer"),
                (None, "counts are live file counts"),
            ],
        )
    )
    out.append("</svg>")

    dek = (
        "The order is the Architecture Pattern block of <code>CLAUDE.md</code> "
        "(Command → Agent → Skill → Workflow) with the orchestrator exception of "
        "<code>.claude/rules/commands.md</code> inserted as its own layer. Counts are read at "
        "generation time from <code>commands/</code>, <code>agents/</code>, "
        "<code>skills/</code>, <code>hooks/hooks.json</code> and <code>.claude/rules/</code>."
    )
    return page("layers", "Layer stack · CKS", "CKS plugin layers", dek, out, frame=1040, minw=880)


# ─────────────────────────────────────────────────────────────────────────────
# Diagram 6 - dispatch sequence
# ─────────────────────────────────────────────────────────────────────────────

ACTORS = [
    ("User", "the founder", "input"),
    ("Command", "/cks:* · thin dispatcher", "backend"),
    ("Chief of staff", "top-level skill", "backend"),
    ("Role agent", "cks:<role>", "backend"),
    ("Hooks", "hooks/hooks.json", "store"),
]


def render_dispatch_sequence() -> str:
    events = dict(hook_events())
    handler = {
        "SessionStart": events["SessionStart"][0],
        "UserPromptSubmit": events["UserPromptSubmit"][0],
        "PreToolUse": next(h for h in events["PreToolUse"] if "guard" in h),
        "PostToolUse": next(h for h in events["PostToolUse"] if "trace" in h),
        "SubagentStop": next(h for h in events["SubagentStop"] if "trace" in h),
        "Stop": next(h for h in events["Stop"] if h.startswith("stop")),
    }

    W, H = 1280, 720
    actor_w, actor_h, actor_y = 176, 56, 40
    centers = [192 + i * 224 for i in range(5)]
    lifeline_top, lifeline_bottom = 96, 576

    out = svg_open(
        "dispatch",
        W,
        H,
        "One dispatch, end to end",
        "Sequence diagram of a single CKS dispatch: a command routes the user's request to "
        "the chief of staff, which dispatches one role agent, while the hook rail observes "
        "every step and can block a tool call outright.",
    )

    def gap_label_x(src, dst):
        """Put a label in a gap between lifelines, never on one."""
        low, high = sorted((src, dst))
        gaps = [(centers[i] + centers[i + 1]) / 2 for i in range(low, high)]
        mid = (centers[src] + centers[dst]) / 2
        return min(gaps, key=lambda g: (abs(g - mid), g))

    out.append("  <!-- lifelines -->")
    for cx in centers:
        out.append(line_el(cx, lifeline_top, cx, lifeline_bottom, "rgba(45,49,66,0.20)", 1, "3,3"))

    out.append("  <!-- activation bars -->")
    out.append(rect_el(centers[2] - 4, 224, 8, 296, "rgba(45,49,66,0.06)", stroke=T["muted"], width=0.8))
    out.append(rect_el(centers[3] - 4, 256, 8, 200, "rgba(45,49,66,0.06)", stroke=T["muted"], width=0.8))

    frame_x = centers[3] - 24
    frame_w = centers[4] + 24 - frame_x
    out.append("  <!-- opt fragment: the guard can refuse the tool call -->")
    out.append(rect_el(frame_x, 280, frame_w, 120, "rgba(45,49,66,0.02)", stroke="rgba(45,49,66,0.22)", rx=4))
    out.append(rect_el(frame_x, 280, 40, 16, T["paper"], stroke="rgba(45,49,66,0.22)", rx=2))
    out.append(text_el(frame_x + 20, 292, "OPT", T["muted"], 8, MONO, anchor="middle", track="0.12em"))
    out.append(text_el(centers[3] + 16, 312, "[CRITICAL command pattern]", T["muted"], 8, MONO))

    messages = [
        (4, 2, 128, "dashed", "open", T["muted"], "SESSIONSTART", handler["SessionStart"]),
        (0, 1, 160, "solid", "filled", T["muted"], "/CKS:ARCHITECTURE", "diagrams"),
        (0, 4, 192, "dashed", "open", T["muted"], "USERPROMPTSUBMIT", handler["UserPromptSubmit"]),
        (1, 2, 224, "solid", "filled", T["muted"], "DISPATCH", "thin dispatcher"),
        (2, 3, 256, "solid", "filled", T["muted"], "AGENT", 'subagent_type="cks:<role>"'),
        (3, 4, 344, "dashed", "open", T["muted"], "PRETOOLUSE", handler["PreToolUse"]),
        (4, 3, 380, "dashed", "filled", T["muted"], "BLOCKED", "exit 2 · the tool never runs"),
        (3, 4, 424, "dashed", "open", T["muted"], "POSTTOOLUSE", handler["PostToolUse"]),
        (3, 2, 456, "dashed", "filled", T["muted"], "RETURN", "artifact paths + gaps"),
        (3, 4, 488, "dashed", "open", T["muted"], "SUBAGENTSTOP", handler["SubagentStop"]),
        (2, 0, 520, "solid", "filled", T["accent"], "BRIEF", "what shipped · next dispatch"),
        (2, 4, 552, "dashed", "open", T["muted"], "STOP", handler["Stop"]),
    ]

    out.append("  <!-- messages, top to bottom -->")
    for src, dst, y, style, head, color, label, sub in messages:
        x1, x2 = centers[src], centers[dst]
        x1 += 4 if x2 > x1 else -4
        x2 += -4 if x2 > x1 else 4
        marker = {"open": "arrow-open", "filled": "arrow-accent" if color == T["accent"] else "arrow"}[head]
        out.append(
            line_el(x1, y, x2, y, color, 1.2 if color == T["accent"] else 1, "5,4" if style == "dashed" else None, marker)
        )
        out.extend(arrow_label(gap_label_x(src, dst), y, [f"{label} · {sub}"], gap=8))

    out.append("  <!-- actors -->")
    for (name, note, kind), cx in zip(ACTORS, centers):
        x = cx - actor_w // 2
        out.extend(node_box(x, actor_y, actor_w, actor_h, kind))
        out.append(text_el(cx, actor_y + 24, name, T["ink"], 12, SANS, weight="600", anchor="middle"))
        out.append(text_el(cx, actor_y + 40, note, T["muted"], 8, MONO, anchor="middle"))

    out.extend(
        legend_strip(
            616,
            W,
            [
                (("line", (T["muted"], None, "arrow")), "call"),
                (("line", (T["muted"], "5,4", "arrow")), "return"),
                (("line", (T["muted"], "5,4", "arrow-open")), "hook event, fire and forget"),
                (("line", (T["accent"], None, "arrow-accent")), "the answer the user sees"),
            ],
        )
    )
    out.append("</svg>")

    dek = (
        "The command is a thin dispatcher per <code>.claude/rules/commands.md</code>; the hook "
        "events and the handler on each message are read from <code>hooks/hooks.json</code> in "
        "lifecycle order. The <code>OPT</code> fragment is the "
        "<code>PreToolUse</code> guard refusing a destructive command."
    )
    return page("dispatch", "Sequence · CKS", "One dispatch, end to end", dek, out)


# ─────────────────────────────────────────────────────────────────────────────
# Index
# ─────────────────────────────────────────────────────────────────────────────

CARDS = [
    (
        "workforce-org-chart.html",
        "Org chart",
        "CKS workforce org chart",
        "Who the eighteen roles are, which domain they sit in, and how often each is dispatched.",
        ["agents/*.md", "scripts/agent-graph.sh --edges"],
    ),
    (
        "lifecycle-process.html",
        "Process",
        "CKS lifecycle — actors and artifact handoffs",
        "Six stages, one role per stage, and the artifact each stage hands to the next.",
        ["pipelines/sprint.dot", ".claude/rules/phase-gates.md", ".claude/rules/definition-of-done.md"],
    ),
    (
        "routine-run-loop.html",
        "Loop",
        "Routine run loop",
        "What an unattended routine run does, and the shared record every pass writes back to.",
        ["skills/routines/workflows/routine-run.md", "docs/hq.md"],
    ),
    (
        "state-er.html",
        "ER / data model",
        "CKS state — what the workforce writes down",
        "The eight records CKS keeps, their fields, and how they relate.",
        [
            ".claude/rules/agents.md",
            ".claude/rules/telemetry.md",
            ".claude/rules/phase-gates.md",
            "skills/routines/templates/*.md",
            "docs/hq.md",
        ],
    ),
    (
        "plugin-layers.html",
        "Layer stack",
        "CKS plugin layers",
        "Command to workflow, with the hook and rule rails underneath and live file counts.",
        ["CLAUDE.md", "commands/", "agents/", "skills/", "hooks/hooks.json", ".claude/rules/"],
    ),
    (
        "dispatch-sequence.html",
        "Sequence",
        "One dispatch, end to end",
        "A single dispatch from the user's command to the brief, with every hook event on the way.",
        [".claude/rules/commands.md", "hooks/hooks.json"],
    ),
]


def render_index() -> str:
    cards = []
    for href, kind, title, blurb, sources in CARDS:
        source_items = "".join(f"<li><code>{esc(s)}</code></li>" for s in sources)
        cards.append(
            f"""      <a class="card" href="{href}">
        <p class="kind">{esc(kind)}</p>
        <h2>{esc(title)}</h2>
        <p class="blurb">{esc(blurb)}</p>
        <p class="from">Generated from</p>
        <ul>{source_items}</ul>
      </a>"""
        )
    body = "\n".join(cards)
    return f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>CKS process maps</title>
  <link href="{FONT_LINK}" rel="stylesheet">
  <style>
    *, *::before, *::after {{ box-sizing: border-box; margin: 0; padding: 0; }}
    :root {{
      --paper: {T["paper"]}; --ink: {T["ink"]}; --muted: {T["muted"]}; --soft: {T["soft"]};
      --rule: {T["rule"]}; --accent: {T["accent"]};
      --sans: {SANS}; --serif: {SERIF}; --mono: {MONO};
    }}
    body {{ min-height: 100vh; background: var(--paper); color: var(--ink);
           font-family: var(--sans); padding: 48px 32px; }}
    .frame {{ max-width: 1180px; margin: 0 auto; }}
    .eyebrow {{ font-family: var(--mono); font-size: 9px; font-weight: 500;
               letter-spacing: 0.18em; text-transform: uppercase; color: var(--muted);
               margin-bottom: 8px; }}
    h1 {{ font-family: var(--serif); font-size: 32px; font-weight: 400; line-height: 1.1;
         letter-spacing: -0.02em; margin-bottom: 12px; }}
    .dek {{ color: var(--muted); font-size: 13px; line-height: 1.55; max-width: 760px;
           margin-bottom: 32px; }}
    .dek code {{ font-family: var(--mono); font-size: 12px; color: var(--ink); }}
    .cards {{ display: grid; grid-template-columns: 1.1fr 1fr 0.9fr; gap: 16px; }}
    .card {{ display: block; background: #ffffff; border: 1px solid var(--rule);
            border-radius: 6px; padding: 20px; text-decoration: none; color: inherit; }}
    .card:hover {{ border-color: var(--accent); }}
    .kind {{ font-family: var(--mono); font-size: 8px; letter-spacing: 0.18em;
            text-transform: uppercase; color: var(--accent); margin-bottom: 8px; }}
    .card h2 {{ font-size: 14px; font-weight: 600; line-height: 1.3; margin-bottom: 8px; }}
    .blurb {{ font-size: 12px; line-height: 1.5; color: var(--muted); margin-bottom: 16px; }}
    .from {{ font-family: var(--mono); font-size: 8px; letter-spacing: 0.14em;
            text-transform: uppercase; color: var(--soft); margin-bottom: 4px; }}
    .card ul {{ list-style: none; }}
    .card li {{ font-family: var(--mono); font-size: 9px; line-height: 1.6; color: var(--muted); }}
    footer {{ margin-top: 32px; padding-top: 12px; border-top: 1px solid var(--rule);
             font-family: var(--mono); font-size: 9px; color: var(--soft); }}
    @media (max-width: 900px) {{ .cards {{ grid-template-columns: 1fr; }}
                                body {{ padding: 32px 16px; }} }}
  </style>
</head>
<body>
  <main class="frame">
    <p class="eyebrow">Process maps · CKS</p>
    <h1>CKS process maps</h1>
    <p class="dek">Six maps of the CKS workforce, drawn from the repository itself — every node
      traces to a file. Regenerate with <code>python3 {GENERATOR}</code>.</p>
    <div class="cards">
{body}
    </div>
    <footer>Generated by {GENERATOR}</footer>
  </main>
</body>
</html>
"""


# ─────────────────────────────────────────────────────────────────────────────
# Driver
# ─────────────────────────────────────────────────────────────────────────────

RENDERERS = [
    ("workforce-org-chart.html", render_org_chart),
    ("lifecycle-process.html", render_lifecycle_process),
    ("routine-run-loop.html", render_routine_loop),
    ("state-er.html", render_state_er),
    ("plugin-layers.html", render_plugin_layers),
    ("dispatch-sequence.html", render_dispatch_sequence),
    ("index.html", render_index),
]


def build() -> dict[str, str]:
    return {name: renderer() for name, renderer in RENDERERS}


def write_all(target: str, files: dict[str, str]) -> None:
    os.makedirs(target, exist_ok=True)
    for name, content in sorted(files.items()):
        with open(os.path.join(target, name), "w", encoding="utf-8") as handle:
            handle.write(content)


def find_diagram_design() -> str | None:
    candidates = []
    env = os.environ.get("DIAGRAM_DESIGN_ROOT")
    if env:
        candidates.append(env)
    home = os.path.expanduser("~")
    candidates.extend(sorted(glob(os.path.join(home, ".claude/plugins/cache/*/diagram-design*"))))
    candidates.append(os.path.join(home, ".claude/plugins/marketplaces/diagram-design"))
    for base in candidates:
        for relative in ("scripts/verify-geometry.py", "skills/diagram-design/scripts/verify-geometry.py"):
            script = os.path.join(base, relative)
            if os.path.isfile(script):
                return script
    return None


INSTALL_HINT = (
    "verification skipped: diagram-design not found — install it with "
    "`/plugin marketplace add cathrynlavery/diagram-design` then "
    "`/plugin install diagram-design@diagram-design`, or set DIAGRAM_DESIGN_ROOT."
)


def run_verify(target: str, files: dict[str, str]) -> int:
    script = find_diagram_design()
    if not script:
        print(INSTALL_HINT)
        return 0
    paths = [os.path.join(target, name) for name in sorted(files)]
    result = subprocess.run([sys.executable, script, *paths], capture_output=True, text=True)
    sys.stdout.write(result.stdout)
    sys.stderr.write(result.stderr)
    return result.returncode


def main() -> int:
    parser = argparse.ArgumentParser(description="Render docs/diagrams/ from repository facts.")
    parser.add_argument("--check", action="store_true", help="fail on drift instead of writing")
    parser.add_argument("--verify", action="store_true", help="run diagram-design's geometry check")
    args = parser.parse_args()

    files = build()
    target = os.path.join(ROOT, OUT_REL)

    if args.check:
        temp = tempfile.mkdtemp(prefix="cks-diagrams-")
        try:
            write_all(temp, files)
            drifted = []
            for name in sorted(files):
                current = os.path.join(target, name)
                if not os.path.exists(current) or not filecmp.cmp(
                    current, os.path.join(temp, name), shallow=False
                ):
                    drifted.append(name)
            extra = [
                os.path.basename(path)
                for path in sorted(glob(os.path.join(target, "*.html")))
                if os.path.basename(path) not in files
            ]
            for name in drifted:
                print(f"drift: {OUT_REL}/{name}")
            for name in extra:
                print(f"orphan: {OUT_REL}/{name}")
            if drifted or extra:
                return 1
            print(f"{len(files)} diagram(s) current in {OUT_REL}/")
            return 0
        finally:
            shutil.rmtree(temp, ignore_errors=True)

    write_all(target, files)
    print(f"wrote {len(files)} file(s) to {OUT_REL}/")
    if args.verify:
        return run_verify(target, files)
    return 0


if __name__ == "__main__":
    sys.exit(main())
