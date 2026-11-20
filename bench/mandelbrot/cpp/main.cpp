// mandelbrot, C++
#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <vector>

static void row_bits(int n, int y, unsigned char *row) {
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
}

int main(int argc, char **argv) {
    int n = argc > 1 ? std::atoi(argv[1]) : 200;
    int rb = (n + 7) / 8;
    std::vector<unsigned char> row(rb);
    std::printf("P4\n%d %d\n", n, n);
    for (int y = 0; y < n; y++) {
        std::fill(row.begin(), row.end(), 0);
        row_bits(n, y, row.data());
        std::fwrite(row.data(), 1, rb, stdout);
    }
}
