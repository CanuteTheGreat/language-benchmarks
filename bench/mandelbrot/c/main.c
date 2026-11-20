// mandelbrot, C
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv) {
    int n = argc > 1 ? atoi(argv[1]) : 200;
    int rb = (n + 7) / 8;
    unsigned char *row = malloc(rb);
    printf("P4\n%d %d\n", n, n);
    for (int y = 0; y < n; y++) {
        memset(row, 0, rb);
        double ci = 2.0 * y / n - 1.0;
        for (int x = 0; x < n; x++) {
            double cr = 2.0 * x / n - 1.5;
            double zr = 0, zi = 0, tr = 0, ti = 0;
            for (int i = 0; i < 50 && tr + ti <= 4.0; i++) {
                zi = 2.0 * zr * zi + ci;
                zr = tr - ti + cr;
                tr = zr * zr;
                ti = zi * zi;
            }
            if (tr + ti <= 4.0) row[x >> 3] |= 0x80 >> (x & 7);
        }
        fwrite(row, 1, rb, stdout);
    }
    free(row);
    return 0;
}
