// pidigits - Benchmarks Game spigot with GMP (gmpxx), C++.
#include <gmpxx.h>
#include <cstdio>
#include <cstdlib>

static mpz_class numer = 1, accum = 0, denom = 1, tmp;

static unsigned extract_digit(unsigned long nth) {
    tmp = (numer * nth + accum) / denom;
    return tmp.get_ui();
}

static void next_term(unsigned long k) {
    unsigned long y2 = k * 2 + 1;
    accum = (accum + numer * 2) * y2;
    numer *= k;
    denom *= y2;
}

static void eliminate_digit(unsigned d) {
    accum -= denom * d;
    accum *= 10;
    numer *= 10;
}

int main(int argc, char **argv) {
    int n = argc > 1 ? std::atoi(argv[1]) : 30;
    int i = 0;
    unsigned long k = 0;
    while (i < n) {
        k++;
        next_term(k);
        if (numer > accum) continue;
        unsigned d = extract_digit(3);
        if (d != extract_digit(4)) continue;
        std::putchar('0' + d);
        i++;
        if (i % 10 == 0) std::printf("\t:%d\n", i);
        eliminate_digit(d);
    }
    if (n % 10 != 0) std::printf("%*s\t:%d\n", 10 - n % 10, "", n);
}
