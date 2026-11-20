# quicksort - minstd data, hand-written quicksort, Python.
import sys


def insertion(a, lo, hi):
    for i in range(lo + 1, hi + 1):
        v = a[i]
        j = i - 1
        while j >= lo and a[j] > v:
            a[j + 1] = a[j]
            j -= 1
        a[j + 1] = v


def sort(a, lo, hi):
    while hi - lo >= 16:
        x, y, z = a[lo], a[(lo + hi) // 2], a[hi]
        if x < y:
            p = y if y < z else (z if x < z else x)
        else:
            p = x if x < z else (z if y < z else y)
        i, j = lo - 1, hi + 1
        while True:
            i += 1
            while a[i] < p:
                i += 1
            j -= 1
            while a[j] > p:
                j -= 1
            if i >= j:
                break
            a[i], a[j] = a[j], a[i]
        if j - lo < hi - j:
            sort(a, lo, j)
            lo = j + 1
        else:
            sort(a, j + 1, hi)
            hi = j
    insertion(a, lo, hi)


n = int(sys.argv[1]) if len(sys.argv) > 1 else 10000
a = [0] * n
state = 42
for i in range(n):
    state = state * 48271 % 2147483647
    a[i] = state
sort(a, 0, n - 1)
for i in range(1, n):
    if a[i - 1] > a[i]:
        sys.exit(1)
print(a[0], a[n // 2], a[n - 1])
