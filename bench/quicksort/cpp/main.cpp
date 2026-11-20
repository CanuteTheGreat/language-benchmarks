// quicksort - minstd data, hand-written quicksort, C++.
#include <cstdint>
#include <cstdlib>
#include <iostream>
#include <utility>
#include <vector>

static void insertion(std::vector<int> &a, long lo, long hi) {
    for (long i = lo + 1; i <= hi; i++) {
        int v = a[i];
        long j = i - 1;
        while (j >= lo && a[j] > v) { a[j + 1] = a[j]; j--; }
        a[j + 1] = v;
    }
}

static int median3(int x, int y, int z) {
    if (x < y) return y < z ? y : (x < z ? z : x);
    return x < z ? x : (y < z ? z : y);
}

static void sort(std::vector<int> &a, long lo, long hi) {
    while (hi - lo >= 16) {
        int p = median3(a[lo], a[(lo + hi) / 2], a[hi]);
        long i = lo - 1, j = hi + 1;
        for (;;) {
            do i++; while (a[i] < p);
            do j--; while (a[j] > p);
            if (i >= j) break;
            std::swap(a[i], a[j]);
        }
        if (j - lo < hi - j) { sort(a, lo, j); lo = j + 1; }
        else { sort(a, j + 1, hi); hi = j; }
    }
    insertion(a, lo, hi);
}

int main(int argc, char **argv) {
    long n = argc > 1 ? std::atol(argv[1]) : 10000;
    std::vector<int> a(n);
    uint64_t state = 42;
    for (long i = 0; i < n; i++) {
        state = state * 48271 % 2147483647;
        a[i] = (int)state;
    }
    sort(a, 0, n - 1);
    for (long i = 1; i < n; i++)
        if (a[i - 1] > a[i]) return 1;
    std::cout << a[0] << ' ' << a[n / 2] << ' ' << a[n - 1] << '\n';
}
