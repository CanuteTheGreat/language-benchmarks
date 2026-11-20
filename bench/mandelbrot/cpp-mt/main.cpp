// mandelbrot, C++, multi-threaded (std::thread)
#include <algorithm>
#include <atomic>
#include <cstdio>
#include <cstdlib>
#include <thread>
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
    std::vector<unsigned char> img((size_t)rb * n, 0);
    std::atomic<int> next{0};
    auto worker = [&] {
        for (int y; (y = next.fetch_add(1)) < n;) row_bits(n, y, img.data() + (size_t)y * rb);
    };
    unsigned nt = std::max(1u, std::thread::hardware_concurrency());
    std::vector<std::thread> threads;
    for (unsigned t = 0; t < nt; t++) threads.emplace_back(worker);
    for (auto &t : threads) t.join();
    std::printf("P4\n%d %d\n", n, n);
    std::fwrite(img.data(), 1, img.size(), stdout);
}
