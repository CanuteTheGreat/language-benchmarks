// sortstd - minstd data, std::sort, C++.
#include <algorithm>
#include <cstdint>
#include <cstdlib>
#include <iostream>
#include <vector>

int main(int argc, char **argv) {
    long n = argc > 1 ? std::atol(argv[1]) : 10000;
    std::vector<int> a(n);
    uint64_t state = 42;
    for (long i = 0; i < n; i++) {
        state = state * 48271 % 2147483647;
        a[i] = (int)state;
    }
    std::sort(a.begin(), a.end());
    for (long i = 1; i < n; i++)
        if (a[i - 1] > a[i]) return 1;
    std::cout << a[0] << ' ' << a[n / 2] << ' ' << a[n - 1] << '\n';
}
