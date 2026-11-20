# factorial - N! with Python's built-in int.
import sys

sys.set_int_max_str_digits(0)
n = int(sys.argv[1]) if len(sys.argv) > 1 else 100
f = 1
for i in range(2, n + 1):
    f *= i
s = str(f)
print(len(s), sum(int(c) for c in s))
