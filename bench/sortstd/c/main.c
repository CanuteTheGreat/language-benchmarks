/* sortstd - minstd data, standard-library qsort, plain C. */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

static int cmp(const void *x, const void *y) {
    int a = *(const int *)x, b = *(const int *)y;
    return (a > b) - (a < b);
}

int main(int argc, char **argv) {
    long n = argc > 1 ? atol(argv[1]) : 10000;
    int *a = malloc(n * sizeof(int));
    uint64_t state = 42;
    for (long i = 0; i < n; i++) {
        state = state * 48271 % 2147483647;
        a[i] = (int)state;
    }
    qsort(a, n, sizeof(int), cmp);
    for (long i = 1; i < n; i++)
        if (a[i - 1] > a[i]) return 1;
    printf("%d %d %d\n", a[0], a[n / 2], a[n - 1]);
    free(a);
    return 0;
}
