# fib - naive recursive Fibonacci, Python
import sys


def fib(n):
    return n if n < 2 else fib(n - 1) + fib(n - 2)


n = int(sys.argv[1]) if len(sys.argv) > 1 else 35
print(fib(n))
