#!/usr/bin/env python3
"""Extra charts for the blog series (matplotlib, same style as charts.py). Each chart is skipped
when its input file is missing.

  charts_extra.py TAG --out DIR
"""
import argparse, csv, glob, json, math, os, statistics
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter

PLAIN = FuncFormatter(lambda v, _: f"{v:g}")
from charts import LABEL, color, label, load  # same names and colours as the per-benchmark charts

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SINGLE_BENCHES = ["fib", "sieve", "collatz", "nbody", "spectralnorm", "mandelbrot", "fannkuchredux", "binarytrees",
                  "fasta", "knucleotide", "revcomp", "regexredux", "json", "hashmap", "quicksort", "sortstd",
                  "dijkstra", "levenshtein", "matmul", "pidigits", "factorial"]


def save(fig, out):
    fig.tight_layout()
    fig.savefig(out)
    plt.close(fig)
    print("wrote", out)


def hbar(items, xlabel, title, out, fmt, log=False):
    """items: [(variant, value)] sorted as they should appear (top first)."""
    plt.style.use("dark_background")
    fig, ax = plt.subplots(figsize=(7.2, 1.2 + 0.42 * len(items)), dpi=150)
    vals = [v for _, v in items]
    ax.barh(range(len(items)), vals, color=[color(k) for k, _ in items])
    ax.set_yticks(range(len(items)))
    ax.set_yticklabels([label(k) for k, _ in items], fontsize=11)
    ax.invert_yaxis()
    if log:
        ax.set_xscale("log")
        ax.xaxis.set_major_formatter(PLAIN)
    for y, v in enumerate(vals):
        ax.text(v * 1.08 if log else v + max(vals) * 0.015, y, fmt(v), va="center", fontsize=10)
    ax.set_xlim(right=max(vals) * (4 if log else 1.3))
    ax.set_xlabel(xlabel, fontsize=10)
    ax.set_title(title, fontsize=13, loc="left")
    ax.grid(axis="x", alpha=0.2)
    save(fig, out)


def thermal(tag, out):
    p = os.path.join(ROOT, "results", "raw", tag, "thermal.csv")
    if not os.path.exists(p):
        return
    rows = list(csv.DictReader(open(p)))
    t0 = int(rows[0]["epoch"])
    xs = [(int(r["epoch"]) - t0) / 3600 for r in rows]
    ys = [int(r["max_temp_c"]) for r in rows]
    plt.style.use("dark_background")
    fig, ax = plt.subplots(figsize=(7.2, 3.6), dpi=150)
    ax.plot(xs, ys, lw=0.6, color="#ff922b")
    ax.set_xlabel("Hours since the start of the run", fontsize=10)
    ax.set_ylabel("Hottest sensor (°C)", fontsize=10)
    ax.set_title("CPU temperature during the measurements", fontsize=13, loc="left")
    ax.set_ylim(30, 105)
    ax.axhline(100, color="#fa5252", lw=0.8, ls="--")
    ax.text(0.02, 101, "100 °C: the i5-1335U's throttle point (TjMax)", fontsize=9, color="#fa5252")
    ax.grid(alpha=0.2)
    save(fig, os.path.join(out, "thermal.png"))


def spread(tag, out):
    rows = [r for r in load(tag) if r["bench"] != "hello"]
    groups = {"single-threaded": [], "multi-threaded": []}
    for r in rows:
        s = (float(r["wall_max_s"]) - float(r["wall_min_s"])) / float(r["wall_median_s"]) * 100
        groups["multi-threaded" if r["variant"].endswith("-mt") else "single-threaded"].append(max(s, 0.05))
    plt.style.use("dark_background")
    fig, ax = plt.subplots(figsize=(7.2, 3.8), dpi=150)
    bins = [10 ** (x / 8) for x in range(-8, 18)]
    ax.hist([groups["single-threaded"], groups["multi-threaded"]], bins=bins, stacked=True,
            color=["#5c7cfa", "#ff922b"], label=[f"{k} ({len(v)})" for k, v in groups.items()])
    ax.set_xscale("log")
    ax.set_xlabel("(slowest run - fastest run) / median, percent, log scale", fontsize=10)
    ax.set_ylabel("Program and language pairs", fontsize=10)
    ax.set_title("How much the ten runs of each program varied", fontsize=13, loc="left")
    ax.legend(fontsize=9, frameon=False)
    ax.grid(alpha=0.2)
    save(fig, os.path.join(out, "spread.png"))


def buildtime(tag, out):
    for b in ("hello", "json"):
        p = os.path.join(ROOT, "results", "raw", tag, b, "buildtime.json")
        if not os.path.exists(p):
            continue
        rows = sorted(json.load(open(p)), key=lambda r: r["median"])
        hbar([(r["variant"], r["median"]) for r in rows],
             f"Clean build time (s), median of {len(rows[0]['times'])} builds, log scale",
             f"Build time: {'hello world' if b == 'hello' else 'the JSON program'}", os.path.join(out, f"buildtime-{b}.png"),
             lambda v: f"{v:.2f} s" if v < 10 else f"{v:.1f} s", log=True)


def hello_size(tag, out):
    p = os.path.join(ROOT, "results", "raw", tag, "hello", "sizes.json")
    if not os.path.exists(p):
        return
    rows = [r for r in json.load(open(p)) if r["variant"] in ("c-gcc", "c-clang", "cpp", "rust", "zig", "go")]
    rows.sort(key=lambda r: r["stripped_bytes"])
    hbar([(r["variant"], r["stripped_bytes"] / 1024) for r in rows], "Stripped executable size (KiB), log scale",
         "Hello world: size of the native executable", os.path.join(out, "hello-size.png"),
         lambda v: f"{v:.0f} KiB" if v < 1024 else f"{v / 1024:.1f} MiB", log=True)


def runtime_size(out):
    p = os.path.join(ROOT, "results", "runtime-sizes.txt")
    if not os.path.exists(p):
        return
    m = {}
    for line in open(p):
        if "\t" in line and not line.startswith("#"):
            k, v = line.rstrip("\n").split("\t")
            m[k] = int(v)
    items = [("java", m.get("java: JDK (as installed)")), ("csharp", m.get("dotnet: shared runtime only (Microsoft.NETCore.App)")),
             ("python", m.get("python: CPython install")), ("pypy", m.get("pypy: install")), ("js", m.get("node: binary")),
             ("php", (m.get("php: binary") or 0) + (m.get("php: extensions dir") or 0))]
    items = sorted([(k, v / 1e6) for k, v in items if v], key=lambda t: t[1])
    hbar(items, "Installed runtime size on disk (MB), log scale", "What the runtime needs on disk",
         os.path.join(out, "runtime-size.png"), lambda v: f"{v:.0f} MB", log=True)


def geomean_rel(tag, key, out, title, xlabel, name):
    rows = load(tag)
    ref = {r["bench"]: float(r[key]) for r in rows if r["variant"] == "c-gcc" and r[key] not in ("", "None")}
    acc = {}
    for r in rows:
        if r["bench"] in SINGLE_BENCHES and r["bench"] in ref and not r["variant"].endswith(("-mt", "-opt")) and r[key] not in ("", "None"):
            v = float(r[key])
            if v > 0 and ref[r["bench"]] > 0:
                acc.setdefault(r["variant"], []).append(v / ref[r["bench"]])
    data = sorted(((v, math.exp(sum(map(math.log, xs)) / len(xs))) for v, xs in acc.items() if len(xs) == len(SINGLE_BENCHES)),
                  key=lambda t: t[1])
    if data:
        hbar(data, xlabel, title, os.path.join(out, name), lambda v: f"{v:.2g}x", log=True)
    return dict(data)


def loc_chart(tag, out):
    per = {}
    for b in SINGLE_BENCHES:
        p = os.path.join(ROOT, "results", "raw", tag, b, "sizes.json")
        if not os.path.exists(p):
            return {}
        for r in json.load(open(p)):
            if not r["variant"].endswith(("-mt", "-opt")) and r.get("loc"):
                per.setdefault(r["variant"], []).append(r["loc"])
    # pypy/php-jit share sources with python/php, c-clang with c-gcc
    data = sorted(((v, sum(xs)) for v, xs in per.items() if v not in ("pypy", "php-jit", "c-clang") and len(xs) == len(SINGLE_BENCHES)),
                  key=lambda t: t[1])
    if data:
        hbar(data, "Lines of code, all 21 programs together (tokei, no comments or blank lines)",
             "How much code each language needed", os.path.join(out, "loc.png"), lambda v: f"{v:.0f}")
    return dict(data)


def scatter(tag, out, speed, locs):
    if not speed or not locs:
        return
    plt.style.use("dark_background")
    fig, ax = plt.subplots(figsize=(7.2, 5.4), dpi=150)
    src = {"c-clang": "c-gcc", "pypy": "python", "php-jit": "php"}
    for v, s in speed.items():
        l = locs.get(src.get(v, v))
        if l is None:
            continue
        ax.scatter([l], [s], s=70, color=color(v), edgecolor="white", linewidth=0.5, zorder=3)
        off = {"pypy": (6, -13), "c-gcc": (6, -11)}.get(v, (6, 4))
        ax.annotate(label(v), (l, s), textcoords="offset points", xytext=off, fontsize=9)
    ax.set_yscale("log")
    ax.yaxis.set_major_formatter(PLAIN)
    ax.set_xlabel("Lines of code, all 21 programs", fontsize=10)
    ax.set_ylabel("Time relative to C (GCC), geometric mean, log", fontsize=10)
    ax.set_title("Speed against code size", fontsize=13, loc="left")
    ax.grid(alpha=0.2)
    xs = [locs.get(src.get(v, v)) for v in speed if locs.get(src.get(v, v))]
    ax.set_xlim(min(xs) * 0.85, max(xs) * 1.25)
    save(fig, os.path.join(out, "speed-vs-loc.png"))


def perf_rows(tag, bench):
    d = os.path.join(ROOT, "results", "raw", tag, "extras", "perf", bench)
    res = {}
    for p in glob.glob(os.path.join(d, "*.csv")):
        v = os.path.basename(p)[:-4]
        c = {}
        for line in open(p):
            f = line.strip().split(",")
            if len(f) > 3 and f[2].startswith("cpu_core/"):
                try:
                    c[f[2][len("cpu_core/"):].rstrip("/")] = float(f[0])
                except ValueError:
                    pass
        if c.get("cycles"):
            res[v] = c
    return res


def ipc_chart(tag, bench, out):
    r = perf_rows(tag, bench)
    if not r:
        return
    items = sorted(((v, c["instructions"] / c["cycles"]) for v, c in r.items() if c.get("instructions")), key=lambda t: -t[1])
    from charts import TITLES
    hbar(items, "Instructions per cycle on the performance cores (perf stat, one run)",
         f"{TITLES.get(bench, bench)}: instructions per cycle", os.path.join(out, f"{bench}-ipc.png"), lambda v: f"{v:.2f}")


def hello_inner(tag, out):
    """Start-up time measured by the wrapper itself (fork to exit), without hyperfine/taskset/wrapper start-up."""
    d = os.path.join(ROOT, "results", "raw", tag, "hello")
    items = []
    for p in glob.glob(os.path.join(d, "*.measure.csv")):
        v = os.path.basename(p)[: -len(".measure.csv")]
        rows = [r for r in csv.reader(open(p))][3:]  # 3 warm-up runs
        if rows:
            items.append((v, statistics.median(float(r[1]) for r in rows) * 1000))
    if not items:
        return
    items.sort(key=lambda t: t[1])
    hbar(items, "Process start to exit (ms), median of 50 runs, log scale", "Hello world: start-up time",
         os.path.join(out, "hello-startup.png"), lambda v: f"{v:.2f} ms" if v < 10 else f"{v:.1f} ms", log=True)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("tag")
    ap.add_argument("--out", default=None)
    ap.add_argument("--ipc", nargs="*", default=[])
    a = ap.parse_args()
    out = a.out or os.path.join(ROOT, "results", "charts", a.tag)
    os.makedirs(out, exist_ok=True)
    thermal(a.tag, out)
    hello_inner(a.tag, out)
    spread(a.tag, out)
    buildtime(a.tag, out)
    hello_size(a.tag, out)
    runtime_size(out)
    speed = geomean_rel(a.tag, "wall_median_s", out, "All 21 programs: time relative to C (GCC)",
                        "Time relative to C (GCC), geometric mean, log scale", "geomean-time.png")
    geomean_rel(a.tag, "maxrss_median_mb", out, "Peak memory relative to C (GCC)",
                "Peak RSS relative to C (GCC), geometric mean over 21 programs, log scale", "geomean-rss.png")
    geomean_rel(a.tag, "energy_median_j", out, "Package energy relative to C (GCC)",
                "Energy relative to C (GCC), geometric mean over 21 programs, log scale", "geomean-energy.png")
    locs = loc_chart(a.tag, out)
    scatter(a.tag, out, speed, locs)
    for b in a.ipc:
        ipc_chart(a.tag, b, out)


if __name__ == "__main__":
    main()
