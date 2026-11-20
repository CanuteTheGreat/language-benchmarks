# spectralnorm benchmark, Python (multiprocessing)
import os
import sys
from math import sqrt
from multiprocessing import Pool


def rows_av(args):
    v, lo, hi = args
    n = len(v)
    out = []
    for i in range(lo, hi):
        s = 0.0
        for j in range(n):
            s += v[j] / ((i + j) * (i + j + 1) // 2 + i + 1)
        out.append(s)
    return out


def rows_atv(args):
    v, lo, hi = args
    n = len(v)
    out = []
    for i in range(lo, hi):
        s = 0.0
        for j in range(n):
            s += v[j] / ((i + j) * (i + j + 1) // 2 + j + 1)
        out.append(s)
    return out


def main():
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 100
    ncpu = len(os.sched_getaffinity(0))
    chunks = [(k * n // ncpu, (k + 1) * n // ncpu) for k in range(ncpu)]

    with Pool(ncpu) as pool:
        def apply(fn, v):
            parts = pool.map(fn, [(v, lo, hi) for lo, hi in chunks])
            return [x for part in parts for x in part]

        def mul_atav(v):
            return apply(rows_atv, apply(rows_av, v))

        u = [1.0] * n
        v = u
        for _ in range(10):
            v = mul_atav(u)
            u = mul_atav(v)
    vbv = sum(a * b for a, b in zip(u, v))
    vv = sum(b * b for b in v)
    print("%0.9f" % sqrt(vbv / vv))


if __name__ == "__main__":
    main()
