# sieve - Sieve of Eratosthenes, Python
import sys

n = int(sys.argv[1]) if len(sys.argv) > 1 else 1000000
prime = bytearray([1]) * (n + 1)
prime[0] = prime[1] = 0
i = 2
while i * i <= n:
    if prime[i]:
        prime[i * i::i] = bytes(len(range(i * i, n + 1, i)))
    i += 1
print(sum(prime))
