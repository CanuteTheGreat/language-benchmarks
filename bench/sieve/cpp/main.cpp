// sieve - Sieve of Eratosthenes, C++
#include <cstdlib>
#include <iostream>
#include <vector>

int main(int argc, char **argv) {
    long n = argc > 1 ? std::atol(argv[1]) : 1000000;
    std::vector<bool> composite(n + 1, false);
    for (long i = 2; i * i <= n; i++)
        if (!composite[i])
            for (long j = i * i; j <= n; j += i) composite[j] = true;
    long count = 0;
    for (long i = 2; i <= n; i++) count += !composite[i];
    std::cout << count << "\n";
}
