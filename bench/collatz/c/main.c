/* collatz - longest Collatz sequence below N, C */
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
    long long limit = argc > 1 ? atoll(argv[1]) : 1000000;
    long long best = 1, best_steps = 0;
    for (long long s = 1; s < limit; s++) {
        long long n = s, steps = 0;
        while (n != 1) {
            n = (n & 1) ? 3 * n + 1 : n / 2;
            steps++;
        }
        if (steps > best_steps) { best_steps = steps; best = s; }
    }
    printf("%lld %lld\n", best, best_steps);
    return 0;
}
