/* factorial - N! with GMP, plain C. */
#include <gmp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv) {
    unsigned long n = argc > 1 ? strtoul(argv[1], NULL, 10) : 100;
    mpz_t f;
    mpz_init_set_ui(f, 1);
    for (unsigned long i = 2; i <= n; i++) mpz_mul_ui(f, f, i);
    char *s = mpz_get_str(NULL, 10, f);
    size_t len = strlen(s);
    unsigned long sum = 0;
    for (size_t i = 0; i < len; i++) sum += s[i] - '0';
    printf("%zu %lu\n", len, sum);
    free(s);
    mpz_clear(f);
    return 0;
}
