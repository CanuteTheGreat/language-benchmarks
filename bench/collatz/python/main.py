# collatz - longest Collatz sequence below N, Python
import sys

limit = int(sys.argv[1]) if len(sys.argv) > 1 else 1000000
best, best_steps = 1, 0
for s in range(1, limit):
    n, steps = s, 0
    while n != 1:
        n = 3 * n + 1 if n & 1 else n >> 1
        steps += 1
    if steps > best_steps:
        best, best_steps = s, steps
print(best, best_steps)
