// fannkuchredux, C++, multi-threaded (std::thread)
#include <algorithm>
#include <array>
#include <atomic>
#include <cstdio>
#include <cstdlib>
#include <thread>
#include <utility>
#include <vector>

constexpr int MAXN = 16;
using Perm = std::array<int, MAXN>;

static long fact[MAXN + 1];

// Process permutations with index in [start, end); returns {checksum, max flips}.
static std::pair<long, int> work(int n, long start, long end) {
    Perm p{}, pp{}, q{};
    std::array<int, MAXN> count{};
    long idx = start;
    for (int i = 0; i < n; i++) p[i] = i;
    for (int i = n - 1; i > 0; i--) {
        long d = idx / fact[i];
        idx %= fact[i];
        count[i] = static_cast<int>(d);
        pp = p;
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
        q = p;
        int flips = 0;
        while (q[0] != 0) {
            for (int i = 0, j = q[0]; i < j; i++, j--) std::swap(q[i], q[j]);
            flips++;
        }
        if (flips > maxflips) maxflips = flips;
        sum += (k % 2 == 0) ? flips : -flips;
    }
    return {sum, maxflips};
}

int main(int argc, char **argv) {
    int n = argc > 1 ? std::atoi(argv[1]) : 7;
    fact[0] = 1;
    for (int i = 1; i <= n; i++) fact[i] = fact[i - 1] * i;
    long total = fact[n];
    unsigned nthreads = std::max(1u, std::thread::hardware_concurrency());
    long nchunks = std::min<long>(total, static_cast<long>(nthreads) * 16);
    long size = (total + nchunks - 1) / nchunks;

    std::atomic<long> next_chunk{0};
    std::vector<std::pair<long, int>> results(nthreads, {0, 0});
    std::vector<std::thread> threads;
    for (unsigned t = 0; t < nthreads; t++) {
        threads.emplace_back([&, t] {
            for (;;) {
                long c = next_chunk.fetch_add(1);
                if (c >= nchunks) break;
                long s = c * size, e = std::min(total, s + size);
                if (s >= e) continue;
                auto [cs, cm] = work(n, s, e);
                results[t].first += cs;
                results[t].second = std::max(results[t].second, cm);
            }
        });
    }
    for (auto &th : threads) th.join();
    long chk = 0;
    int mx = 0;
    for (auto &r : results) {
        chk += r.first;
        mx = std::max(mx, r.second);
    }
    std::printf("%ld\nPfannkuchen(%d) = %d\n", chk, n, mx);
    return 0;
}
