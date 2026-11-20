// knucleotide - Computer Language Benchmarks Game specification, C++.
#include <algorithm>
#include <cstdint>
#include <cstdio>
#include <iostream>
#include <string>
#include <unordered_map>
#include <vector>

using Counts = std::unordered_map<uint64_t, uint32_t>;
static const std::string LETTERS = "ACGT";

static Counts count(const std::vector<uint8_t>& s, int k) {
    Counts m;
    const uint64_t mask = (1ULL << (2 * k)) - 1;
    uint64_t key = 0;
    for (size_t i = 0; i < s.size(); i++) {
        key = ((key << 2) | s[i]) & mask;
        if (i + 1 >= static_cast<size_t>(k)) m[key]++;
    }
    return m;
}

static void frequencies(const std::vector<uint8_t>& s, int k) {
    Counts m = count(s, k);
    std::vector<std::pair<uint64_t, uint32_t>> v(m.begin(), m.end());
    std::sort(v.begin(), v.end(), [](const auto& a, const auto& b) {
        return a.second != b.second ? a.second > b.second : a.first < b.first;
    });
    double total = static_cast<double>(s.size() - k + 1);
    for (const auto& [key, cnt] : v) {
        std::string name(k, ' ');
        for (int j = 0; j < k; j++) name[j] = LETTERS[(key >> (2 * (k - 1 - j))) & 3];
        std::printf("%s %.3f\n", name.c_str(), 100.0 * cnt / total);
    }
    std::putchar('\n');
}

static void occurrences(const std::vector<uint8_t>& s, const std::string& seq) {
    int k = static_cast<int>(seq.size());
    uint64_t key = 0;
    for (char c : seq) key = (key << 2) | LETTERS.find(c);
    Counts m = count(s, k);
    auto it = m.find(key);
    std::printf("%u\t%s\n", it == m.end() ? 0u : it->second, seq.c_str());
}

int main() {
    std::ios::sync_with_stdio(false);
    std::vector<uint8_t> s;
    std::string line;
    bool three = false;
    while (std::getline(std::cin, line)) {
        if (!line.empty() && line[0] == '>') {
            three = line.rfind(">THREE", 0) == 0;
        } else if (three) {
            for (char c : line) {
                switch (c & 0xDF) {
                case 'A': s.push_back(0); break;
                case 'C': s.push_back(1); break;
                case 'G': s.push_back(2); break;
                case 'T': s.push_back(3); break;
                }
            }
        }
    }
    frequencies(s, 1);
    frequencies(s, 2);
    for (const char* q : {"GGT", "GGTA", "GGTATT", "GGTATTTTAATT", "GGTATTTTAATTTATAGT"}) occurrences(s, q);
}
