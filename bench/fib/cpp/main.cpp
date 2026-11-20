// fib - naive recursive Fibonacci, C++
#include <cstdint>
#include <cstdlib>
#include <iostream>

static int64_t fib(int64_t n) { return n < 2 ? n : fib(n - 1) + fib(n - 2); }

int main(int argc, char** argv) {
    int64_t n = argc > 1 ? std::atoll(argv[1]) : 35;
    std::cout << fib(n) << '\n';
}
