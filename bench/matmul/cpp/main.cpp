// matmul - naive matrix multiply (i,k,j), C++
#include <cstdlib>
#include <iostream>
#include <vector>

int main(int argc, char **argv) {
    int n = argc > 1 ? std::atoi(argv[1]) : 400;
    std::vector<std::vector<double>> a(n, std::vector<double>(n)), b = a, c(n, std::vector<double>(n, 0.0));
    for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++) {
            a[i][j] = (i + j) % 10;
            b[i][j] = (i * j) % 10;
        }
    for (int i = 0; i < n; i++)
        for (int k = 0; k < n; k++)
            for (int j = 0; j < n; j++) c[i][j] += a[i][k] * b[k][j];
    double sum = 0;
    for (const auto &row : c)
        for (double v : row) sum += v;
    std::cout << (long long)sum << "\n";
}
