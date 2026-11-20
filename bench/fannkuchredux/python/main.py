# fannkuchredux, Python
import sys


def work(n, fact, start, end):
    """Process permutations with index in [start, end); returns (checksum, max flips)."""
    p = list(range(n))
    count = [0] * n
    idx = start
    for i in range(n - 1, 0, -1):
        d, idx = divmod(idx, fact[i])
        count[i] = d
        pp = p[:]
        for j in range(i + 1):
            p[j] = pp[j + d] if j + d <= i else pp[j + d - i - 1]
    total = 0
    maxflips = 0
    for k in range(start, end):
        if k > start:
            first = p[1]
            p[1] = p[0]
            p[0] = first
            i = 1
            count[i] += 1
            while count[i] > i:
                count[i] = 0
                i += 1
                nxt = p[1]
                p[0] = nxt
                for j in range(1, i):
                    p[j] = p[j + 1]
                p[i] = first
                first = nxt
                count[i] += 1
        q = p[:]
        flips = 0
        while q[0]:
            f = q[0]
            q[: f + 1] = q[f::-1]
            flips += 1
        if flips > maxflips:
            maxflips = flips
        total += flips if k % 2 == 0 else -flips
    return total, maxflips


def main():
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 7
    fact = [1] * (n + 1)
    for i in range(1, n + 1):
        fact[i] = fact[i - 1] * i
    chk, mx = work(n, fact, 0, fact[n])
    print(f"{chk}\nPfannkuchen({n}) = {mx}")


main()
