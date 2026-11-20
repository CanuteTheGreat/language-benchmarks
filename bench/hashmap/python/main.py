# hashmap - minstd keys, dict, Python.
import sys

n = int(sys.argv[1]) if len(sys.argv) > 1 else 10000
m = {}
s1 = 42
for i in range(n):
    s1 = s1 * 48271 % 2147483647
    m[s1] = i
s2 = 42
hits = 0
total = 0
for _ in range(2 * n):
    s2 = s2 * 48271 % 2147483647
    v = m.get(s2)
    if v is not None:
        hits += 1
        total += v
print(len(m), hits, total)
