#!/usr/bin/env python3
"""Turn raw results into one CSV per tag: results/TAG-summary.csv

  summarize.py TAG [--warmup 1]

Per benchmark/variant: wall time from hyperfine (median, mean, stddev, min, max, all runs),
CPU time, peak RSS and package energy from the `measure` wrapper (median of the timed runs; the
first WARMUP rows of each .measure.csv are hyperfine's warm-up runs and are dropped),
artifact size and lines of code from sizes.json.
"""
import csv, glob, json, os, statistics, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def med(xs):
    return statistics.median(xs) if xs else None


def main():
    tag = sys.argv[1]
    warm = int(sys.argv[sys.argv.index("--warmup") + 1]) if "--warmup" in sys.argv else 1
    raw = os.path.join(ROOT, "results", "raw", tag)
    idle = []
    p = os.path.join(raw, "idle.measure.csv")
    if os.path.exists(p):
        for r in csv.reader(open(p)):
            idle.append(float(r[5]) / float(r[1]))
    idle_w = med(idle)
    rows = []
    for bdir in sorted(glob.glob(os.path.join(raw, "*/"))):
        bench = os.path.basename(bdir.rstrip("/"))
        sizes = {}
        sp = os.path.join(bdir, "sizes.json")
        if os.path.exists(sp):
            sizes = {r["variant"]: r for r in json.load(open(sp))}
        for js in sorted(glob.glob(os.path.join(bdir, "*.hyperfine.json"))):
            v = os.path.basename(js)[: -len(".hyperfine.json")]
            h = json.load(open(js))["results"][0]
            if "summary" in h:  # hyperfine 2.x schema
                t = h["summary"]["time_wall_clock"]
                h = {"times": [m["time_wall_clock"]["value"] for m in h["measurements"]], "median": t["median"],
                     "mean": t["mean"], "stddev": t.get("stddev"), "min": t["min"], "max": t["max"]}
            m = []
            mp = os.path.join(bdir, f"{v}.measure.csv")
            if os.path.exists(mp):
                m = [r for r in csv.reader(open(mp))][warm:]
            wall_inner = [float(r[1]) for r in m]
            cpu = [float(r[2]) + float(r[3]) for r in m]
            rss = [int(r[4]) / 1024 for r in m]
            joules = [float(r[5]) for r in m if float(r[5]) >= 0]
            psys = [float(r[7]) for r in m if len(r) > 7 and float(r[7]) >= 0]
            bad = [r for r in m if r[6] != "0"]
            s = sizes.get(v, {})
            rows.append({
                "bench": bench, "variant": v, "runs": len(h["times"]),
                "wall_median_s": h["median"], "wall_mean_s": h["mean"], "wall_stddev_s": h.get("stddev"),
                "wall_min_s": h["min"], "wall_max_s": h["max"],
                "inner_wall_median_s": med(wall_inner),
                "cpu_median_s": med(cpu), "maxrss_median_mb": med(rss),
                "energy_median_j": med(joules), "energy_psys_median_j": med(psys),
                "energy_above_idle_j": (med(joules) - idle_w * med(wall_inner)) if (joules and idle_w and wall_inner) else None,
                "nonzero_exits": len(bad),
                "artifact_bytes": s.get("artifact_bytes"), "stripped_bytes": s.get("stripped_bytes"), "loc": s.get("loc"),
            })
    out = os.path.join(ROOT, "results", f"{tag}-summary.csv")
    with open(out, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        w.writeheader()
        w.writerows(rows)
    print(f"wrote {out}: {len(rows)} rows; idle package power {idle_w:.2f} W" if idle_w else f"wrote {out}: {len(rows)} rows")


if __name__ == "__main__":
    main()
