"""Circular network of co-author links between NSW universities, 2024 and 2026 side by side.

Usage: python3 draw_uni_ring.py EDGES_CSV OUT_DIR

EDGES_CSV columns: snap, a, b, needs_int, a_uni, b_uni (one row per researcher pair).
Node size = researchers in the cohort with a link that year; link width = links between the two universities;
the orange core of each link = the part visible only through a university integration.
"""
import csv
import json
import math
import sys
from collections import Counter, defaultdict
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, PathPatch
from matplotlib.path import Path as MPath

BG, OLD, NEW, TEXT, MUTED = "#15212b", "#4fb8ae", "#f2a541", "#f6f8f9", "#94a5b2"
SNAPS = ("2024", "2026")
# Ring order keeps the Sydney metro universities together and the regional ones on the far side.
UNIS = ["USyd", "UNSW", "UTS", "Macquarie", "Western Sydney", "Wollongong", "Southern Cross",
        "New England", "Newcastle", "Charles Sturt"]
LABEL = {"USyd": "Sydney"}
MAX_W = 26.0  # line width (pt) of the busiest pair in the busier year


def load(path: str) -> tuple[dict[str, Counter], dict[str, Counter], dict[str, dict[str, set[str]]]]:
    links: dict[str, Counter] = defaultdict(Counter)
    only: dict[str, Counter] = defaultdict(Counter)
    people: dict[str, dict[str, set[str]]] = defaultdict(lambda: defaultdict(set))
    with open(path) as f:
        for r in csv.DictReader(f):
            s = r["snap"]
            if s not in SNAPS:
                continue
            people[s][r["a_uni"]].add(r["a"])
            people[s][r["b_uni"]].add(r["b"])
            if r["a_uni"] == r["b_uni"] or r["a_uni"] not in UNIS or r["b_uni"] not in UNIS:
                continue
            k = tuple(sorted((r["a_uni"], r["b_uni"])))
            links[s][k] += 1
            if r["needs_int"] == "true":
                only[s][k] += 1
    return links, only, people


def curve(p: tuple[float, float], q: tuple[float, float]) -> MPath:
    # Quadratic Bezier pulled towards the centre, more for pairs far apart on the ring.
    mx, my = (p[0] + q[0]) / 2, (p[1] + q[1]) / 2
    return MPath([p, (mx * 0.25, my * 0.25), q], [MPath.MOVETO, MPath.CURVE3, MPath.CURVE3])


def main(edges_csv: str, out_dir: str) -> None:
    links, only, people = load(edges_csv)
    top = max(max(links[s].values()) for s in SNAPS)
    top_people = max(len(people[s][u]) for s in SNAPS for u in UNIS)
    pos = {u: (math.cos(math.pi / 2 - 2 * math.pi * i / len(UNIS)), math.sin(math.pi / 2 - 2 * math.pi * i / len(UNIS)))
           for i, u in enumerate(UNIS)}

    fig, axes = plt.subplots(1, 2, figsize=(22.2, 9.2), dpi=150)
    fig.patch.set_facecolor(BG)
    fig.subplots_adjust(left=0.0, right=1.0, top=1.0, bottom=0.0, wspace=0.0)
    stats = {}
    for ax, s in zip(axes, SNAPS):
        ax.set_facecolor(BG)
        ax.set_xlim(-1.62, 1.62)
        ax.set_ylim(-1.4, 1.3)
        ax.set_aspect("equal")
        ax.axis("off")
        for k, n in sorted(links[s].items(), key=lambda kv: kv[1]):
            w = MAX_W * n / top
            if w < 0.4:
                continue
            path = curve(pos[k[0]], pos[k[1]])
            ax.add_patch(PathPatch(path, fill=False, edgecolor=OLD, linewidth=w, alpha=0.55, capstyle="round"))
            wo = MAX_W * only[s][k] / top
            if wo >= 0.4:
                ax.add_patch(PathPatch(path, fill=False, edgecolor=NEW, linewidth=wo, alpha=0.95, capstyle="round"))
        for u in UNIS:
            x, y = pos[u]
            size = 300 + 2600 * len(people[s][u]) / top_people
            ax.scatter([x], [y], s=size, c=TEXT, edgecolors=BG, linewidths=2, zorder=5)
            ha = "left" if x > 0.2 else "right" if x < -0.2 else "center"
            va = "bottom" if y > 0.8 else "top" if y < -0.8 else "center"
            ax.text(x * 1.13, y * 1.13, LABEL.get(u, u), color=TEXT, fontsize=19, ha=ha, va=va, zorder=6)
        total = sum(links[s].values())
        ax.text(-1.58, -1.12, s, color=TEXT, fontsize=34, fontweight="bold", ha="left", va="bottom")
        ax.text(-1.58, -1.17, f"{total / 1000:.1f}k links between universities", color=MUTED, fontsize=19, ha="left", va="top")
        stats[s] = {"between_links": total, "only_via_integration": sum(only[s].values()),
                    "pairs": {f"{a} – {b}": [n, only[s][(a, b)]] for (a, b), n in links[s].most_common()}}
    out = Path(out_dir)
    out.mkdir(parents=True, exist_ok=True)
    fig.savefig(out / "nsw_uni_ring.png", facecolor=BG)
    plt.close(fig)
    (out / "nsw_uni_ring_stats.json").write_text(json.dumps(stats, indent=1))
    print(json.dumps({s: {k: v for k, v in stats[s].items() if k != "pairs"} for s in SNAPS}, indent=1))


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
