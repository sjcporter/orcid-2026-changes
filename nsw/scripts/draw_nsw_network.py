"""NSW university co-author network across the 2024, 2025 and 2026 snapshots on one shared layout.

Usage: python3 draw_nsw_network.py EDGES_CSV PEOPLE_CSV OUT_DIR

EDGES_CSV columns: snap, a, b, needs_int, a_uni, b_uni
PEOPLE_CSV columns: id, uni, is_staff, pushed
Writes nsw_network_{2024,2025,2026}.png, nsw_network_transition.png (three panels),
nsw_network_by_uni.png (2026, nodes coloured by university) and nsw_network_stats.json.
"""
import csv
import json
import random
import sys
from collections import Counter, defaultdict
from pathlib import Path

import igraph as ig
import matplotlib
import numpy as np

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.collections import LineCollection

BG, OLD, NEW, NODE, FRESH, TEXT, MUTED = "#15212b", "#4fb8ae", "#f2a541", "#9fb3c2", "#f2a541", "#f6f8f9", "#94a5b2"
SNAPS = ("2024", "2025", "2026")
UNI_COLOURS = {
    "UNSW": "#f2c14e", "USyd": "#e4572e", "Macquarie": "#4fb8ae", "UTS": "#5b8def",
    "Newcastle": "#b07cc6", "Charles Sturt": "#7bc96f", "Wollongong": "#ff8fab",
    "Western Sydney": "#c9a227", "New England": "#6fd0e8", "Southern Cross": "#e8a87c", "Notre Dame": "#bfc6cc",
}

Edge = tuple[str, str, bool]


def load(edges_csv: str, people_csv: str) -> tuple[dict[str, list[Edge]], dict[str, str], dict[str, list[dict[str, str]]]]:
    edges: dict[str, list[Edge]] = defaultdict(list)
    rows: dict[str, list[dict[str, str]]] = defaultdict(list)
    with open(edges_csv) as f:
        for r in csv.DictReader(f):
            edges[r["snap"]].append((r["a"], r["b"], r["needs_int"] == "true"))
            rows[r["snap"]].append(r)
    with open(people_csv) as f:
        uni = {r["id"]: r["uni"] for r in csv.DictReader(f)}
    return edges, uni, rows


def snap_stats(es: list[Edge], rows: list[dict[str, str]], names: list[str]) -> dict[str, object]:
    g = ig.Graph()
    g.add_vertices(names)
    g.add_edges([(a, b) for a, b, _ in es])
    between = [r for r in rows if r["a_uni"] != r["b_uni"]]
    pairs = Counter(tuple(sorted((r["a_uni"], r["b_uni"]))) for r in between)
    return {
        "edges": len(es),
        "edges_only_via_integration": sum(1 for *_, u in es if u),
        "researchers_linked": sum(1 for d in g.degree() if d > 0),
        "largest_component": max(len(c) for c in g.connected_components()),
        "edges_between_universities": len(between),
        "between_only_via_integration": sum(1 for r in between if r["needs_int"] == "true"),
        "top_university_pairs": [[f"{a} – {b}", n] for (a, b), n in pairs.most_common(12)],
    }


def frame(ax: plt.Axes, cx: float, cy: float, half: float) -> None:
    ax.set_facecolor(BG)
    ax.set_xlim(cx - half, cx + half)
    ax.set_ylim(cy - half, cy + half)
    ax.axis("off")


def draw_snap(ax: plt.Axes, es: list[Edge], xy: dict[str, tuple[float, float]], linked_first: set[str],
              first_pairs: set[tuple[str, str]]) -> tuple[int, int]:
    # Teal = link already visible in the first snapshot; orange = link that has appeared since.
    old = [(xy[a], xy[b]) for a, b, _ in es if (a, b) in first_pairs and a in xy and b in xy]
    new = [(xy[a], xy[b]) for a, b, _ in es if (a, b) not in first_pairs and a in xy and b in xy]
    ax.add_collection(LineCollection(old, colors=OLD, linewidths=0.13, alpha=0.13))
    if new:
        ax.add_collection(LineCollection(new, colors=NEW, linewidths=0.13, alpha=0.13))
    active = {n for a, b, _ in es for n in (a, b)}
    keep = [n for n in xy if n in active and n in linked_first]
    fresh = [n for n in xy if n in active and n not in linked_first]
    ax.scatter([xy[n][0] for n in keep], [xy[n][1] for n in keep], s=1.2, c=NODE, linewidths=0, alpha=0.85)
    if fresh:
        ax.scatter([xy[n][0] for n in fresh], [xy[n][1] for n in fresh], s=2.6, c=FRESH, linewidths=0, alpha=1)
    return len(keep) + len(fresh), len(fresh)


def main(edges_csv: str, people_csv: str, out_dir: str) -> None:
    edges, uni, rows = load(edges_csv, people_csv)
    names = sorted({n for es in edges.values() for a, b, _ in es for n in (a, b)})
    idx = {n: i for i, n in enumerate(names)}
    union = ig.Graph(n=len(names), edges=list({(idx[a], idx[b]) for es in edges.values() for a, b, _ in es}))
    union.simplify()
    # Lay out only the largest connected part of the combined network; small islands are left off the picture.
    comp = max(union.connected_components(), key=len)
    core = union.induced_subgraph(comp)
    random.seed(7)
    lay = core.layout_drl()
    xy: dict[str, tuple[float, float]] = {names[v]: tuple(lay.coords[k]) for k, v in enumerate(comp)}
    xs = np.array([p[0] for p in xy.values()])
    ys = np.array([p[1] for p in xy.values()])
    lo_x, hi_x = np.percentile(xs, [0.5, 99.5])
    lo_y, hi_y = np.percentile(ys, [0.5, 99.5])
    half = max(hi_x - lo_x, hi_y - lo_y) * 0.54
    cx, cy = (lo_x + hi_x) / 2, (lo_y + hi_y) / 2
    linked_first = {n for a, b, _ in edges[SNAPS[0]] for n in (a, b)}
    first_pairs = {(a, b) for a, b, _ in edges[SNAPS[0]]}

    out = Path(out_dir)
    out.mkdir(parents=True, exist_ok=True)
    stats: dict[str, object] = {}
    for snap in SNAPS:
        stats[snap] = snap_stats(edges[snap], rows[snap], names)
        new = [u for a, b, u in edges[snap] if (a, b) not in first_pairs]
        stats[snap]["new_since_first"] = len(new)
        stats[snap]["new_since_first_only_via_integration"] = sum(new)
        fig = plt.figure(figsize=(8, 8), dpi=200)
        fig.patch.set_facecolor(BG)
        ax = fig.add_axes([0, 0, 1, 1])
        frame(ax, cx, cy, half)
        drawn, fresh = draw_snap(ax, edges[snap], xy, linked_first, first_pairs)
        stats[snap]["drawn_researchers"] = drawn
        stats[snap]["drawn_not_linked_in_2024"] = fresh
        fig.savefig(out / f"nsw_network_{snap}.png", facecolor=BG)
        plt.close(fig)

    # Three panels side by side, for the transition slide.
    fig, axes = plt.subplots(1, 3, figsize=(24, 8.6), dpi=150)
    fig.patch.set_facecolor(BG)
    fig.subplots_adjust(left=0.01, right=0.99, top=0.9, bottom=0.01, wspace=0.02)
    for ax, snap in zip(axes, SNAPS):
        frame(ax, cx, cy, half)
        draw_snap(ax, edges[snap], xy, linked_first, first_pairs)
        s = stats[snap]
        ax.set_title(f"{snap}   ·   {s['edges'] / 1000:.1f}k links", color=TEXT, fontsize=20, loc="left", pad=10)
    fig.savefig(out / "nsw_network_transition.png", facecolor=BG)
    plt.close(fig)

    # 2026 coloured by university, to show who sits where.
    fig = plt.figure(figsize=(8, 8), dpi=200)
    fig.patch.set_facecolor(BG)
    ax = fig.add_axes([0, 0, 1, 1])
    frame(ax, cx, cy, half)
    seg = [(xy[a], xy[b]) for a, b, _ in edges["2026"] if a in xy and b in xy]
    ax.add_collection(LineCollection(seg, colors=MUTED, linewidths=0.12, alpha=0.08))
    for u, col in UNI_COLOURS.items():
        pts = [xy[n] for n in xy if uni.get(n) == u]
        if pts:
            ax.scatter([p[0] for p in pts], [p[1] for p in pts], s=1.6, c=col, linewidths=0, alpha=0.95, label=u)
    leg = ax.legend(loc="lower left", frameon=False, fontsize=7, markerscale=5, labelcolor=TEXT)
    leg.set_alpha(1)
    fig.savefig(out / "nsw_network_by_uni.png", facecolor=BG)
    plt.close(fig)

    stats["core_size"] = len(xy)
    stats["researchers_in_any_snapshot"] = len(names)
    stats["core_by_uni"] = dict(Counter(uni.get(n, "?") for n in xy).most_common())
    (out / "nsw_network_stats.json").write_text(json.dumps(stats, indent=1))
    print(json.dumps(stats, indent=1))


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2], sys.argv[3])
