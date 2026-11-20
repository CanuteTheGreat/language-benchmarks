#!/usr/bin/env python3
"""Table of hardware counters from results/raw/TAG/extras/perf/BENCH/*.csv (perf stat -x, output).
Only the performance-core PMU (cpu_core) is used: single-threaded programs are pinned to those cores.

  perfsummary.py TAG BENCH [BENCH...]      prints one row per variant
  perfsummary.py TAG --csv                  writes results/TAG-perf.csv for every benchmark
"""
import csv, glob, os, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def read(path):
    c = {}
    for line in open(path):
        f = line.strip().split(",")
        if len(f) > 3 and f[2].startswith("cpu_core/"):
            try:
                c[f[2][len("cpu_core/"):].rstrip("/")] = float(f[0])
            except ValueError:
                pass
    return c


def rows(tag, bench):
    out = []
    for p in sorted(glob.glob(os.path.join(ROOT, "results", "raw", tag, "extras", "perf", bench, "*.csv"))):
        c = read(p)
        if not c.get("cycles") or not c.get("instructions"):
            continue
        ki = c["instructions"] / 1000
        out.append({"bench": bench, "variant": os.path.basename(p)[:-4],
                    "cycles_g": c["cycles"] / 1e9, "instructions_g": c["instructions"] / 1e9,
                    "ipc": c["instructions"] / c["cycles"],
                    "branch_miss_pct": 100 * c.get("branch-misses", 0) / c["branches"] if c.get("branches") else None,
                    "branch_mpki": c.get("branch-misses", 0) / ki,
                    "l1d_mpki": c.get("L1-dcache-load-misses", 0) / ki,
                    "llc_mpki": c.get("cache-misses", 0) / ki,
                    "dtlb_mpki": c.get("dTLB-load-misses", 0) / ki})
    return out


def main():
    tag = sys.argv[1]
    if "--csv" in sys.argv:
        benches = sorted(os.path.basename(d) for d in glob.glob(os.path.join(ROOT, "results", "raw", tag, "extras", "perf", "*")))
        allr = [r for b in benches for r in rows(tag, b)]
        out = os.path.join(ROOT, "results", f"{tag}-perf.csv")
        with open(out, "w", newline="") as f:
            w = csv.DictWriter(f, fieldnames=list(allr[0].keys()))
            w.writeheader()
            w.writerows(allr)
        print("wrote", out, len(allr), "rows")
        return
    for b in sys.argv[2:]:
        for r in sorted(rows(tag, b), key=lambda r: r["cycles_g"]):
            print(f"{b:13s} {r['variant']:9s} cyc {r['cycles_g']:7.2f}G ins {r['instructions_g']:7.2f}G IPC {r['ipc']:.2f} "
                  f"br-miss {r['branch_miss_pct'] or 0:.2f}% ({r['branch_mpki']:.2f}/ki) L1d {r['l1d_mpki']:.1f}/ki "
                  f"LLC {r['llc_mpki']:.2f}/ki dTLB {r['dtlb_mpki']:.3f}/ki")


if __name__ == "__main__":
    main()
