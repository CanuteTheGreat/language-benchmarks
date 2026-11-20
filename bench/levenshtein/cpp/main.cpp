// levenshtein - C++
#include <algorithm>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <string>
#include <vector>

static uint64_t state = 42;

static uint32_t next() {
    state = (state * 48271) % 2147483647;
    return static_cast<uint32_t>(state);
}

static std::string make_string(int len) {
    std::string s(len, ' ');
    for (auto &c : s) c = "ACGT"[next() % 4];
    return s;
}

int main(int argc, char **argv) {
    int len = argc > 1 ? std::atoi(argv[1]) : 300;
    std::string s = make_string(len), t = make_string(len);

    std::vector<int> prev(len + 1), cur(len + 1);
    for (int j = 0; j <= len; j++) prev[j] = j;
    for (int i = 1; i <= len; i++) {
        cur[0] = i;
        for (int j = 1; j <= len; j++) {
            int sub = prev[j - 1] + (s[i - 1] != t[j - 1]);
            cur[j] = std::min({sub, prev[j] + 1, cur[j - 1] + 1});
        }
        std::swap(prev, cur);
    }
    std::printf("%d\n", prev[len]);
}
