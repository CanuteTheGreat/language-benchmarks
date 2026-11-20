#!/usr/bin/env python3
"""Charts from results/TAG-summary.csv (matplotlib, sized for phones).

  charts.py TAG BENCH [BENCH...] [--metric wall|cpu|rss|energy] [--out DIR] [--log]
  charts.py TAG --relative BENCH... --out DIR    (median wall time relative to C/GCC, one row per language)
"""
import argparse, csv, math, os
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LABEL = {"c-gcc": "C (GCC)", "c-clang": "C (Clang)", "cpp": "C++", "rust": "Rust", "zig": "Zig", "go": "Go",
         "java": "Java", "csharp": "C#", "js": "JavaScript (Node)", "python": "Python (CPython)", "pypy": "Python (PyPy)",
         "php": "PHP", "php-jit": "PHP (JIT)"}
COLOR = {"c-gcc": "#5c7cfa", "c-clang": "#748ffc", "cpp": "#4dabf7", "rust": "#ff922b", "zig": "#fcc419",
         "go": "#3bc9db", "java": "#e64980", "csharp": "#9775fa", "js": "#94d82d", "python": "#69db7c",
         "pypy": "#a9e34b", "php": "#b197fc", "php-jit": "#d0bfff"}
METRIC = {"wall": ("wall_median_s", "Median wall time (s)"), "cpu": ("cpu_median_s", "Median CPU time (s)"),
          "rss": ("maxrss_median_mb", "Peak memory (MB, RSS)"), "energy": ("energy_median_j", "Package energy (J)")}


def label(v):
    for suf, txt in (("-mt", " multi-thread"), ("-opt", " optimised")):
        if v.endswith(suf):
            return LABEL.get(v[: -len(suf)], v) + txt
    return LABEL.get(v, v)


def color(v):
    return COLOR.get(v.replace("-mt", "").replace("-opt", ""), "#adb5bd")


def load(tag):
    return list(csv.DictReader(open(os.path.join(ROOT, "results", f"{tag}-summary.csv"))))


def fmt(x):
    return f"{x:.3g}" if x < 10 else f"{x:.0f}"


def bar(rows, bench, metric, out, log, title=None, variants=None):
    key, xl = METRIC[metric]
    rs = [r for r in rows if r["bench"] == bench and r[key] not in ("", "None") and (variants is None or r["variant"] in variants)]
    rs.sort(key=lambda r: float(r[key]))
    plt.style.use("dark_background")
    h = 1.2 + 0.42 * len(rs)
    fig, ax = plt.subplots(figsize=(7.2, h), dpi=150)
    ys = range(len(rs))
    vals = [float(r[key]) for r in rs]
    ax.barh(list(ys), vals, color=[color(r["variant"]) for r in rs])
    if metric == "wall":
        lo = [max(0, float(r["wall_median_s"]) - float(r["wall_min_s"])) for r in rs]
        hi = [max(0, float(r["wall_max_s"]) - float(r["wall_median_s"])) for r in rs]
        ax.errorbar(vals, list(ys), xerr=[lo, hi], fmt="none", ecolor="#dee2e6", elinewidth=0.8, capsize=2)
    ax.set_yticks(list(ys))
    ax.set_yticklabels([label(r["variant"]) for r in rs], fontsize=11)
    ax.invert_yaxis()
    if log:
        ax.set_xscale("log")
    for y, v in zip(ys, vals):
        ax.text(v * (1.08 if log else 1.0) + (0 if log else max(vals) * 0.01), y, fmt(v), va="center", fontsize=10)
    ax.set_xlabel(xl + (" (log scale)" if log else ""), fontsize=11)
    ax.set_title(title or bench, fontsize=13, loc="left")
    ax.set_xlim(right=max(vals) * (3 if log else 1.15))
    ax.grid(axis="x", alpha=0.2)
    fig.tight_layout()
    fig.savefig(out)
    plt.close(fig)
    print("wrote", out)


def relative(rows, benches, out, title):
    """Geometric mean of (variant time / C GCC time) across the given benchmarks."""
    ref = {r["bench"]: float(r["wall_median_s"]) for r in rows if r["variant"] == "c-gcc"}
    acc = {}
    for r in rows:
        if r["bench"] in benches and r["bench"] in ref and not r["variant"].endswith(("-mt", "-opt")):
            acc.setdefault(r["variant"], []).append(float(r["wall_median_s"]) / ref[r["bench"]])
    data = sorted(((v, math.exp(sum(map(math.log, xs)) / len(xs)), len(xs)) for v, xs in acc.items() if len(xs) == len(benches)),
                  key=lambda t: t[1])
    plt.style.use("dark_background")
    fig, ax = plt.subplots(figsize=(7.2, 1.2 + 0.42 * len(data)), dpi=150)
    ax.barh(range(len(data)), [d[1] for d in data], color=[color(d[0]) for d in data])
    ax.set_yticks(range(len(data)))
    ax.set_yticklabels([label(d[0]) for d in data], fontsize=11)
    ax.invert_yaxis()
    ax.set_xscale("log")
    for y, d in enumerate(data):
        ax.text(d[1] * 1.08, y, f"{d[1]:.2g}x", va="center", fontsize=10)
    ax.set_xlim(left=min(0.5, min(d[1] for d in data) * 0.8), right=max(d[1] for d in data) * 3)
    ax.set_xlabel("Time relative to C (GCC), geometric mean, log scale", fontsize=11)
    ax.set_title(title, fontsize=13, loc="left")
    ax.grid(axis="x", alpha=0.2)
    fig.tight_layout()
    fig.savefig(out)
    plt.close(fig)
    print("wrote", out)
    return data


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("tag")
    ap.add_argument("benches", nargs="+")
    ap.add_argument("--metric", default="wall")
    ap.add_argument("--out", default=os.path.join(ROOT, "results", "charts"))
    ap.add_argument("--log", action="store_true")
    ap.add_argument("--relative", action="store_true")
    ap.add_argument("--title")
    ap.add_argument("--mt", action="store_true", help="only -mt variants plus their single-thread counterparts")
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    rows = load(a.tag)
    if a.relative:
        relative(rows, a.benches, os.path.join(a.out, "relative-" + "-".join(a.benches)[:60] + ".png"), a.title or "Relative speed")
        return
    for b in a.benches:
        bar(rows, b, a.metric, os.path.join(a.out, f"{b}-{a.metric}{'-log' if a.log else ''}.png"), a.log, a.title)


if __name__ == "__main__":
    main()
