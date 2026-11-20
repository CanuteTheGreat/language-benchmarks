// spectralnorm benchmark, C++ (std::thread)
#include <algorithm>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <thread>
#include <vector>

static unsigned nthreads = std::max(1u, std::thread::hardware_concurrency());

static double eval_a(int i, int j) { return 1.0 / ((i + j) * (i + j + 1) / 2 + i + 1); }

// Run body(lo, hi) over [0, n) split into one contiguous chunk per thread.
template <class F>
static void parallel_rows(int n, F body) {
    std::vector<std::jthread> workers;
    int chunk = (n + nthreads - 1) / nthreads;
    for (int lo = 0; lo < n; lo += chunk)
        workers.emplace_back([=] { body(lo, std::min(n, lo + chunk)); });
}

static void mul_av(const std::vector<double>& v, std::vector<double>& av) {
    const int n = v.size();
    parallel_rows(n, [&](int lo, int hi) {
        for (int i = lo; i < hi; i++) {
            double sum = 0;
            for (int j = 0; j < n; j++) sum += eval_a(i, j) * v[j];
            av[i] = sum;
        }
    });
}

static void mul_atv(const std::vector<double>& v, std::vector<double>& atv) {
    const int n = v.size();
    parallel_rows(n, [&](int lo, int hi) {
        for (int i = lo; i < hi; i++) {
            double sum = 0;
            for (int j = 0; j < n; j++) sum += eval_a(j, i) * v[j];
            atv[i] = sum;
        }
    });
}

static void mul_atav(const std::vector<double>& v, std::vector<double>& out, std::vector<double>& tmp) {
    mul_av(v, tmp);
    mul_atv(tmp, out);
}

int main(int argc, char** argv) {
    int n = argc > 1 ? std::atoi(argv[1]) : 100;
    std::vector<double> u(n, 1.0), v(n), tmp(n);
    for (int i = 0; i < 10; i++) {
        mul_atav(u, v, tmp);
        mul_atav(v, u, tmp);
    }
    double vbv = 0, vv = 0;
    for (int i = 0; i < n; i++) {
        vbv += u[i] * v[i];
        vv += v[i] * v[i];
    }
    std::printf("%0.9f\n", std::sqrt(vbv / vv));
}
