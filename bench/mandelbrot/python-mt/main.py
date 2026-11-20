# mandelbrot, Python, multi-threaded (multiprocessing)
import os
import sys
from functools import partial
from multiprocessing import Pool


def row_bits(n, y):
    row = bytearray((n + 7) // 8)
    ci = 2.0 * y / n - 1.0
    for x in range(n):
        cr = 2.0 * x / n - 1.5
        zr = zi = tr = ti = 0.0
        for _ in range(50):
            zi = 2.0 * zr * zi + ci
            zr = tr - ti + cr
            tr = zr * zr
            ti = zi * zi
            if tr + ti > 4.0:
                break
        if tr + ti <= 4.0:
            row[x >> 3] |= 0x80 >> (x & 7)
    return bytes(row)


def main():
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 200
    ncpu = len(os.sched_getaffinity(0))
    with Pool(ncpu) as pool:
        rows = pool.map(partial(row_bits, n), range(n), chunksize=max(1, n // (ncpu * 16)))
    out = sys.stdout.buffer
    out.write(b"P4\n%d %d\n" % (n, n))
    out.write(b"".join(rows))
    out.flush()


if __name__ == "__main__":
    main()
