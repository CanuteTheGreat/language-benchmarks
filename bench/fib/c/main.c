/* fib - naive recursive Fibonacci, C */
#include <stdio.h>
#include <stdlib.h>

static long long fib(long long n) { return n < 2 ? n : fib(n - 1) + fib(n - 2); }

int main(int argc, char **argv) {
    long long n = argc > 1 ? atoll(argv[1]) : 35;
    printf("%lld\n", fib(n));
    return 0;
}
