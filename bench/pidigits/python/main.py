# pidigits - Benchmarks Game spigot with Python's built-in int.
import sys

n = int(sys.argv[1]) if len(sys.argv) > 1 else 30
numer, accum, denom = 1, 0, 1
out = []
i = 0
k = 0
while i < n:
    k += 1
    y2 = k * 2 + 1
    accum = (accum + numer * 2) * y2
    numer *= k
    denom *= y2
    if numer > accum:
        continue
    d = (numer * 3 + accum) // denom
    if d != (numer * 4 + accum) // denom:
        continue
    out.append(str(d))
    i += 1
    if i % 10 == 0:
        out.append("\t:%d\n" % i)
    accum = (accum - denom * d) * 10
    numer *= 10
if n % 10:
    out.append(" " * (10 - n % 10) + "\t:%d\n" % n)
sys.stdout.write("".join(out))
