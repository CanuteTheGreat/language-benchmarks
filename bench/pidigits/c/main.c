/* pidigits - Benchmarks Game spigot with GMP, plain C. */
#include <gmp.h>
#include <stdio.h>
#include <stdlib.h>

static mpz_t numer, accum, denom, tmp1, tmp2;

static unsigned extract_digit(unsigned long nth) {
    mpz_mul_ui(tmp1, numer, nth);
    mpz_add(tmp2, tmp1, accum);
    mpz_tdiv_q(tmp1, tmp2, denom);
    return mpz_get_ui(tmp1);
}

static void next_term(unsigned long k) {
    unsigned long y2 = k * 2 + 1;
    mpz_mul_2exp(tmp1, numer, 1);
    mpz_add(accum, accum, tmp1);
    mpz_mul_ui(accum, accum, y2);
    mpz_mul_ui(numer, numer, k);
    mpz_mul_ui(denom, denom, y2);
}

static void eliminate_digit(unsigned d) {
    mpz_submul_ui(accum, denom, d);
    mpz_mul_ui(accum, accum, 10);
    mpz_mul_ui(numer, numer, 10);
}

int main(int argc, char **argv) {
    int n = argc > 1 ? atoi(argv[1]) : 30;
    mpz_init_set_ui(numer, 1);
    mpz_init_set_ui(accum, 0);
    mpz_init_set_ui(denom, 1);
    mpz_init(tmp1);
    mpz_init(tmp2);

    int i = 0;
    unsigned long k = 0;
    while (i < n) {
        k++;
        next_term(k);
        if (mpz_cmp(numer, accum) > 0) continue;
        unsigned d = extract_digit(3);
        if (d != extract_digit(4)) continue;
        putchar('0' + d);
        i++;
        if (i % 10 == 0) printf("\t:%d\n", i);
        eliminate_digit(d);
    }
    if (n % 10 != 0) printf("%*s\t:%d\n", 10 - n % 10, "", n);
    return 0;
}
