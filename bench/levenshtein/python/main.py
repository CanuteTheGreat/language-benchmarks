# levenshtein - Python
import sys


def make_string(gen, n):
    return "".join("ACGT"[gen() % 4] for _ in range(n))


def main():
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 300
    state = 42

    def gen():
        nonlocal state
        state = (state * 48271) % 2147483647
        return state

    s = make_string(gen, n)
    t = make_string(gen, n)

    prev = list(range(n + 1))
    for i in range(1, n + 1):
        cur = [i] + [0] * n
        si = s[i - 1]
        for j in range(1, n + 1):
            sub = prev[j - 1] + (si != t[j - 1])
            cur[j] = min(sub, prev[j] + 1, cur[j - 1] + 1)
        prev = cur
    print(prev[n])


main()
