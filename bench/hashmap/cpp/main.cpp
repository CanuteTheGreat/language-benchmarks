// hashmap - minstd keys, std::unordered_map, C++.
#include <cstdint>
#include <cstdlib>
#include <iostream>
#include <unordered_map>

int main(int argc, char **argv) {
    long n = argc > 1 ? std::atol(argv[1]) : 10000;
    std::unordered_map<int, long long> m;
    uint64_t s1 = 42;
    for (long i = 0; i < n; i++) {
        s1 = s1 * 48271 % 2147483647;
        m[(int)s1] = i;
    }
    uint64_t s2 = 42;
    long hits = 0;
    long long sum = 0;
    for (long j = 0; j < 2 * n; j++) {
        s2 = s2 * 48271 % 2147483647;
        auto it = m.find((int)s2);
        if (it != m.end()) { hits++; sum += it->second; }
    }
    std::cout << m.size() << ' ' << hits << ' ' << sum << '\n';
}
