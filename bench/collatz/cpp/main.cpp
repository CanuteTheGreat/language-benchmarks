// collatz - longest Collatz sequence below N, C++
#include <cstdint>
#include <cstdlib>
#include <iostream>

int main(int argc, char** argv) {
    int64_t limit = argc > 1 ? std::atoll(argv[1]) : 1000000;
    int64_t best = 1, bestSteps = 0;
    for (int64_t s = 1; s < limit; s++) {
        int64_t n = s, steps = 0;
        while (n != 1) {
            n = (n & 1) ? 3 * n + 1 : n / 2;
            steps++;
        }
        if (steps > bestSteps) { bestSteps = steps; best = s; }
    }
    std::cout << best << ' ' << bestSteps << '\n';
}
