# sortstd - minstd data, list.sort(), Python.
import sys

n = int(sys.argv[1]) if len(sys.argv) > 1 else 10000
a = [0] * n
state = 42
for i in range(n):
    state = state * 48271 % 2147483647
    a[i] = state
a.sort()
for i in range(1, n):
    if a[i - 1] > a[i]:
        sys.exit(1)
print(a[0], a[n // 2], a[n - 1])
