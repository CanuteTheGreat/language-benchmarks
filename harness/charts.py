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
TITLES = {"binarytrees": "binary-trees", "fannkuchredux": "fannkuch-redux", "spectralnorm": "spectral-norm",
          "knucleotide": "k-nucleotide", "revcomp": "reverse-complement", "regexredux": "regex-redux",
          "nbody": "n-body", "sortstd": "standard library sort", "fib": "recursive Fibonacci", "matmul": "matrix multiply",
          "hello": "hello world", "collatz": "Collatz", "dijkstra": "Dijkstra", "levenshtein": "Levenshtein", "json": "JSON",
          "hashmap": "hash map", "quicksort": "quicksort", "sieve": "sieve of Eratosthenes", "factorial": "100,000!",
          "pidigits": "pidigits", "mandelbrot": "mandelbrot", "fasta": "fasta"}
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


def fmt(x, metric="wall"):
    if metric in ("wall", "cpu"):
        if x < 0.01:
            return f"{x * 1000:.1f} ms"
        if x < 1:
            return f"{x * 1000:.0f} ms"
        return f"{x:.2f} s" if x < 100 else f"{x:.0f} s"
    if metric == "rss":
        return f"{x:.1f} MB" if x < 10 else f"{x:.0f} MB"
    if metric == "energy":
        return f"{x:.2g} J" if x < 10 else f"{x:.0f} J"
    return f"{x:.3g}"


def pick(v, which):
    mt = v.endswith("-mt")
    return which == "all" or (which == "mt" and mt) or (which == "single" and not mt and not v.endswith("-opt"))


def bar(rows, bench, metric, out, log, title=None, which="single"):
    key, xl = METRIC[metric]
    rs = [r for r in rows if r["bench"] == bench and r[key] not in ("", "None") and pick(r["variant"], which)]
    rs.sort(key=lambda r: float(r[key]))
    plt.style.use("dark_background")
    h = 1.2 + 0.42 * len(rs)
    fig, ax = plt.subplots(figsize=(7.2, h), dpi=150)
    ys = range(len(rs))
    vals = [float(r[key]) for r in rs]
    ax.barh(list(ys), vals, color=[color(r["variant"]) for r in rs])
    ends = list(vals)
    if metric == "wall":
        lo = [max(0, float(r["wall_median_s"]) - float(r["wall_min_s"])) for r in rs]
        hi = [max(0, float(r["wall_max_s"]) - float(r["wall_median_s"])) for r in rs]
        ax.errorbar(vals, list(ys), xerr=[lo, hi], fmt="none", ecolor="#dee2e6", elinewidth=0.8, capsize=2)
        ends = [v + h for v, h in zip(vals, hi)]
    ax.set_yticks(list(ys))
    ax.set_yticklabels([label(r["variant"]) for r in rs], fontsize=11)
    ax.invert_yaxis()
    if log:
        ax.set_xscale("log")
    for y, v, e in zip(ys, vals, ends):
        ax.text(e * (1.1 if log else 1.0) + (0 if log else max(ends) * 0.015), y, fmt(v, metric), va="center", fontsize=10)
    n = rs[0].get("runs", "10")
    note = f"median of {n} runs, whiskers min/max" if metric == "wall" else f"median of {n} runs"
    ax.set_xlabel(xl + (", log scale" if log else "") + "\n" + note + ", lower is better", fontsize=10)
    ax.set_title(title or TITLES.get(bench, bench) + (" (multi-threaded)" if which == "mt" else ""), fontsize=13, loc="left")
    ax.set_xlim(right=max(ends) * (4 if log else 1.3))
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


def speedup(rows, bench, out, title=None):
    """single-thread median wall / multi-thread median wall, per language."""
    by = {r["variant"]: float(r["wall_median_s"]) for r in rows if r["bench"] == bench}
    data = sorted(((v[:-3], by[v[:-3]] / by[v]) for v in by if v.endswith("-mt") and v[:-3] in by), key=lambda t: -t[1])
    plt.style.use("dark_background")
    fig, ax = plt.subplots(figsize=(7.2, 1.2 + 0.42 * len(data)), dpi=150)
    ax.barh(range(len(data)), [d[1] for d in data], color=[color(d[0]) for d in data])
    ax.set_yticks(range(len(data)))
    ax.set_yticklabels([label(d[0]) for d in data], fontsize=11)
    ax.invert_yaxis()
    for y, d in enumerate(data):
        ax.text(d[1] + 0.05, y, f"{d[1]:.1f}x", va="center", fontsize=10)
    ax.axvline(1.0, color="#868e96", lw=0.8)
    ax.set_xlim(0, max(d[1] for d in data) * 1.2)
    ax.set_xlabel("Speed-up of the multi-threaded version over single-threaded (wall time)", fontsize=10)
    ax.set_title(title or f"{bench}: multi-thread speed-up", fontsize=13, loc="left")
    ax.grid(axis="x", alpha=0.2)
    fig.tight_layout()
    fig.savefig(out)
    plt.close(fig)
    print("wrote", out)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("tag")
    ap.add_argument("benches", nargs="+")
    ap.add_argument("--metric", default="wall")
    ap.add_argument("--out", default=os.path.join(ROOT, "results", "charts"))
    ap.add_argument("--log", action="store_true")
    ap.add_argument("--relative", action="store_true")
    ap.add_argument("--title")
    ap.add_argument("--which", default="single", choices=["single", "mt", "all"], help="variants to include")
    ap.add_argument("--speedup", action="store_true", help="multi-thread speed-up chart")
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    rows = load(a.tag)
    if a.relative:
        relative(rows, a.benches, os.path.join(a.out, "relative-" + "-".join(a.benches)[:60] + ".png"), a.title or "Relative speed")
        return
    for b in a.benches:
        if a.speedup:
            speedup(rows, b, os.path.join(a.out, f"{b}-speedup.png"), a.title)
            continue
        suffix = "" if a.which == "single" else "-" + a.which
        bar(rows, b, a.metric, os.path.join(a.out, f"{b}-{a.metric}{suffix}{'-log' if a.log else ''}.png"), a.log, a.title, a.which)


if __name__ == "__main__":
    main()
