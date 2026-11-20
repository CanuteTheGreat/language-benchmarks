// regexredux - Computer Language Benchmarks Game specification, C++ (std::regex).
#include <cstdio>
#include <iostream>
#include <iterator>
#include <regex>
#include <string>
#include <utility>
#include <vector>

int main() {
    std::ios::sync_with_stdio(false);
    std::string input((std::istreambuf_iterator<char>(std::cin)), std::istreambuf_iterator<char>());
    const size_t len0 = input.size();

    const auto flags = std::regex::optimize;
    std::string seq = std::regex_replace(input, std::regex(">.*\n|\n", flags), "");
    const size_t len1 = seq.size();
    input.clear();
    input.shrink_to_fit();

    const std::vector<std::string> variants = {
        "agggtaaa|tttaccct",
        "[cgt]gggtaaa|tttaccc[acg]",
        "a[act]ggtaaa|tttacc[agt]t",
        "ag[act]gtaaa|tttac[agt]ct",
        "agg[act]taaa|ttta[agt]cct",
        "aggg[acg]aaa|ttt[cgt]ccct",
        "agggt[cgt]aa|tt[acg]accct",
        "agggta[cgt]a|t[acg]taccct",
        "agggtaa[cgt]|[acg]ttaccct",
    };
    for (const auto& v : variants) {
        std::regex re(v, flags);
        std::ptrdiff_t n = std::distance(std::sregex_iterator(seq.begin(), seq.end(), re), std::sregex_iterator());
        std::printf("%s %td\n", v.c_str(), n);
    }

    const std::vector<std::pair<std::string, std::string>> subs = {
        {"tHa[Nt]", "<4>"},
        {"aND|caN|Ha[DS]|WaS", "<3>"},
        {"a[NSt]|BY", "<2>"},
        {"<[^>]*>", "|"},
        {"\\|[^|][^|]*\\|", "-"},
    };
    for (const auto& [pat, rep] : subs) {
        seq = std::regex_replace(seq, std::regex(pat, flags), rep);
    }
    std::printf("\n%zu\n%zu\n%zu\n", len0, len1, seq.size());
}
