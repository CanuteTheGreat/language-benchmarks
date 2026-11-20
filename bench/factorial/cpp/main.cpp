// factorial - N! with GMP (gmpxx), C++.
#include <gmpxx.h>
#include <cstdlib>
#include <iostream>
#include <string>

int main(int argc, char **argv) {
    unsigned long n = argc > 1 ? std::strtoul(argv[1], nullptr, 10) : 100;
    mpz_class f = 1;
    for (unsigned long i = 2; i <= n; i++) f *= i;
    std::string s = f.get_str();
    unsigned long sum = 0;
    for (char c : s) sum += c - '0';
    std::cout << s.size() << ' ' << sum << '\n';
}
