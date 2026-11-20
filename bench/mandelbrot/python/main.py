# mandelbrot, Python
import sys


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
    out = sys.stdout.buffer
    out.write(b"P4\n%d %d\n" % (n, n))
    for y in range(n):
        out.write(row_bits(n, y))
    out.flush()


main()
