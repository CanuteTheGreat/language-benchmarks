# spectralnorm benchmark, Python
import sys
from math import sqrt


def mul_av(v, n):
    out = []
    for i in range(n):
        s = 0.0
        for j in range(n):
            s += v[j] / ((i + j) * (i + j + 1) // 2 + i + 1)
        out.append(s)
    return out


def mul_atv(v, n):
    out = []
    for i in range(n):
        s = 0.0
        for j in range(n):
            s += v[j] / ((i + j) * (i + j + 1) // 2 + j + 1)
        out.append(s)
    return out


def mul_atav(v, n):
    return mul_atv(mul_av(v, n), n)


def main():
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 100
    u = [1.0] * n
    v = u
    for _ in range(10):
        v = mul_atav(u, n)
        u = mul_atav(v, n)
    vbv = sum(a * b for a, b in zip(u, v))
    vv = sum(b * b for b in v)
    print("%0.9f" % sqrt(vbv / vv))


main()
