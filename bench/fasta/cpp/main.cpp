// fasta - C++
#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <string>
#include <vector>

constexpr size_t LINE = 60;
constexpr unsigned IM = 139968, IA = 3877, IC = 29573;

static unsigned last_ = 42;

static double rnd(double max) {
    last_ = (last_ * IA + IC) % IM;
    return max * last_ / IM;
}

struct AminoAcid {
    char c;
    double p;
};

static const std::string alu =
    "GGCCGGGCGCGGTGGCTCACGCCTGTAATCCCAGCACTTTGG"
    "GAGGCCGAGGCGGGCGGATCACCTGAGGTCAGGAGTTCGAGA"
    "CCAGCCTGGCCAACATGGTGAAACCCCGTCTCTACTAAAAAT"
    "ACAAAAATTAGCCGGGCGTGGTGGCGCGCGCCTGTAATCCCA"
    "GCTACTCGGGAGGCTGAGGCAGGAGAATCGCTTGAACCCGGG"
    "AGGCGGAGGTTGCAGTGAGCCGAGATCGCGCCACTGCACTCC"
    "AGCCTGGGCGACAGAGCGAGACTCCGTCTCAAAAA";

static std::string out;

static void flush_if_big() {
    if (out.size() >= 1 << 16) {
        std::fwrite(out.data(), 1, out.size(), stdout);
        out.clear();
    }
}

static void repeat_fasta(const std::string &s, size_t n) {
    size_t pos = 0;
    while (n > 0) {
        size_t m = std::min(n, LINE);
        for (size_t i = 0; i < m; i++) {
            out.push_back(s[pos++]);
            if (pos == s.size()) pos = 0;
        }
        out.push_back('\n');
        n -= m;
        flush_if_big();
    }
}

static void random_fasta(std::vector<AminoAcid> genes, size_t n) {
    double cum = 0;
    for (auto &g : genes) {
        cum += g.p;
        g.p = cum;
    }
    while (n > 0) {
        size_t m = std::min(n, LINE);
        for (size_t i = 0; i < m; i++) {
            double r = rnd(1.0);
            size_t k = 0;
            while (k < genes.size() - 1 && r >= genes[k].p) k++;
            out.push_back(genes[k].c);
        }
        out.push_back('\n');
        n -= m;
        flush_if_big();
    }
}

int main(int argc, char **argv) {
    size_t n = argc > 1 ? std::strtoul(argv[1], nullptr, 10) : 1000;
    std::vector<AminoAcid> iub = {
        {'a', 0.27}, {'c', 0.12}, {'g', 0.12}, {'t', 0.27}, {'B', 0.02}, {'D', 0.02}, {'H', 0.02}, {'K', 0.02},
        {'M', 0.02}, {'N', 0.02}, {'R', 0.02}, {'S', 0.02}, {'V', 0.02}, {'W', 0.02}, {'Y', 0.02},
    };
    std::vector<AminoAcid> homosapiens = {
        {'a', 0.3029549426680},
        {'c', 0.1979883004921},
        {'g', 0.1975473066391},
        {'t', 0.3015094502008},
    };
    out += ">ONE Homo sapiens alu\n";
    repeat_fasta(alu, n * 2);
    out += ">TWO IUB ambiguity codes\n";
    random_fasta(iub, n * 3);
    out += ">THREE Homo sapiens frequency\n";
    random_fasta(homosapiens, n * 5);
    std::fwrite(out.data(), 1, out.size(), stdout);
}
