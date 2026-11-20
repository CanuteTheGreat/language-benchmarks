// sieve - Sieve of Eratosthenes, C
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
    long n = argc > 1 ? atol(argv[1]) : 1000000;
    unsigned char *composite = calloc(n + 1, 1);
    for (long i = 2; i * i <= n; i++)
        if (!composite[i])
            for (long j = i * i; j <= n; j += i) composite[j] = 1;
    long count = 0;
    for (long i = 2; i <= n; i++) count += !composite[i];
    printf("%ld\n", count);
    free(composite);
    return 0;
}
