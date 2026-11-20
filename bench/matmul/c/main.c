// matmul - naive matrix multiply (i,k,j), C
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
    int n = argc > 1 ? atoi(argv[1]) : 400;
    double *a = malloc(sizeof(double) * n * n);
    double *b = malloc(sizeof(double) * n * n);
    double *c = calloc((size_t)n * n, sizeof(double));
    for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++) {
            a[i * n + j] = (i + j) % 10;
            b[i * n + j] = (i * j) % 10;
        }
    for (int i = 0; i < n; i++)
        for (int k = 0; k < n; k++)
            for (int j = 0; j < n; j++) c[i * n + j] += a[i * n + k] * b[k * n + j];
    double sum = 0;
    for (int i = 0; i < n * n; i++) sum += c[i];
    printf("%lld\n", (long long)sum);
    free(a); free(b); free(c);
    return 0;
}
