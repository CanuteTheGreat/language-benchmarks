#!/usr/bin/env python3
"""Pairwise comparisons from the raw per-run wall times (hyperfine JSON). Pure Python.

  stats.py TAG BENCH VARIANT_A VARIANT_B [VARIANT_B2 ...]

For each B: median of A and B, ratio B/A of the medians with a 95% bootstrap confidence interval
(10,000 resamples of each sample, percentile method), and the two-sided Mann-Whitney U test
(exact permutation distribution for n <= 12 per side, normal approximation above that).
"""
import itertools, json, os, random, statistics, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def runs(tag, bench, variant):
    h = json.load(open(os.path.join(ROOT, "results", "raw", tag, bench, f"{variant}.hyperfine.json")))["results"][0]
    if "measurements" in h:
        return [m["time_wall_clock"]["value"] for m in h["measurements"]]
    return h["times"]


def u_stat(a, b):
    return sum(1.0 if x > y else 0.5 if x == y else 0.0 for x in a for y in b)


def mann_whitney(a, b):
    n, m = len(a), len(b)
    u = u_stat(a, b)
    mu = n * m / 2
    if n <= 12 and m <= 12:
        pooled = a + b
        order = sorted(range(n + m), key=lambda i: pooled[i])
        rank = [0.0] * (n + m)
        i = 0
        while i < n + m:  # average ranks for ties
            j = i
            while j + 1 < n + m and pooled[order[j + 1]] == pooled[order[i]]:
                j += 1
            for k in range(i, j + 1):
                rank[order[k]] = (i + j) / 2 + 1
            i = j + 1
        base = n * (n + 1) / 2
        dev = abs(u - mu)
        hits = total = 0
        for idx in itertools.combinations(rank, n):
            total += 1
            hits += abs(sum(idx) - base - mu) >= dev - 1e-9
        return u, hits / total
    import math
    sd = math.sqrt(n * m * (n + m + 1) / 12)
    z = (abs(u - mu) - 0.5) / sd
    return u, math.erfc(z / math.sqrt(2))


def boot_ratio(a, b, reps=10000, seed=1):
    rnd = random.Random(seed)
    rs = sorted(statistics.median(rnd.choices(b, k=len(b))) / statistics.median(rnd.choices(a, k=len(a)))
                for _ in range(reps))
    return rs[int(0.025 * reps)], rs[int(0.975 * reps) - 1]


def main():
    tag, bench, va, *vbs = sys.argv[1:]
    a = runs(tag, bench, va)
    for vb in vbs:
        b = runs(tag, bench, vb)
        u, p = mann_whitney(a, b)
        lo, hi = boot_ratio(a, b)
        print(f"{bench}: {va} median {statistics.median(a):.4f}s (n={len(a)})  {vb} median {statistics.median(b):.4f}s (n={len(b)})  "
              f"ratio {statistics.median(b)/statistics.median(a):.3f} [95% CI {lo:.3f}-{hi:.3f}]  U={u:.0f} p={p:.2g}")


if __name__ == "__main__":
    main()
