// fannkuchredux, C, multi-threaded (OpenMP)
#include <omp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXN 16

static long fact[MAXN + 1];

// Process permutations with index in [start, end); returns checksum and max flips.
static void work(int n, long start, long end, long *chk, int *mx) {
    int p[MAXN], pp[MAXN], q[MAXN], count[MAXN] = {0};
    long idx = start;
    for (int i = 0; i < n; i++) p[i] = i;
    for (int i = n - 1; i > 0; i--) {
        long d = idx / fact[i];
        idx %= fact[i];
        count[i] = (int)d;
        memcpy(pp, p, sizeof p);
        for (int j = 0; j <= i; j++) p[j] = (j + d <= i) ? pp[j + d] : pp[j + d - i - 1];
    }
    long sum = 0;
    int maxflips = 0;
    for (long k = start; k < end; k++) {
        if (k > start) {
            int first = p[1];
            p[1] = p[0];
            p[0] = first;
            int i = 1;
            while (++count[i] > i) {
                count[i++] = 0;
                int next = p[0] = p[1];
                for (int j = 1; j < i; j++) p[j] = p[j + 1];
                p[i] = first;
                first = next;
            }
        }
        memcpy(q, p, sizeof p);
        int flips = 0;
        while (q[0] != 0) {
            for (int i = 0, j = q[0]; i < j; i++, j--) {
                int t = q[i];
                q[i] = q[j];
                q[j] = t;
            }
            flips++;
        }
        if (flips > maxflips) maxflips = flips;
        sum += (k % 2 == 0) ? flips : -flips;
    }
    *chk = sum;
    *mx = maxflips;
}

int main(int argc, char **argv) {
    int n = argc > 1 ? atoi(argv[1]) : 7;
    fact[0] = 1;
    for (int i = 1; i <= n; i++) fact[i] = fact[i - 1] * i;
    long total = fact[n];
    long nchunks = (long)omp_get_max_threads() * 16;
    if (nchunks > total) nchunks = total;
    long size = (total + nchunks - 1) / nchunks;
    long chk = 0;
    int mx = 0;
#pragma omp parallel for schedule(dynamic) reduction(+ : chk) reduction(max : mx)
    for (long c = 0; c < nchunks; c++) {
        long s = c * size, e = s + size < total ? s + size : total;
        if (s >= e) continue;
        long cs;
        int cm;
        work(n, s, e, &cs, &cm);
        chk += cs;
        if (cm > mx) mx = cm;
    }
    printf("%ld\nPfannkuchen(%d) = %d\n", chk, n, mx);
    return 0;
}
