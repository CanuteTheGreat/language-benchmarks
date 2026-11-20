// revcomp - Computer Language Benchmarks Game specification, C++.
#include <iostream>
#include <string>

static unsigned char comp[256];

static void init_comp() {
    const std::string from = "ACGTUMRWSYKVHDBN", to = "TGCAAKYWSRMBDHVN";
    for (int i = 0; i < 256; i++) comp[i] = static_cast<unsigned char>(i);
    for (size_t i = 0; i < from.size(); i++) {
        comp[static_cast<unsigned char>(from[i])] = to[i];
        comp[static_cast<unsigned char>(from[i]) | 0x20] = to[i];
    }
}

// Write the reverse complement of seq in lines of 60.
static void emit(const std::string& seq) {
    std::string line;
    size_t n = seq.size();
    while (n > 0) {
        size_t m = n < 60 ? n : 60;
        line.clear();
        for (size_t j = 0; j < m; j++) line.push_back(static_cast<char>(comp[static_cast<unsigned char>(seq[--n])]));
        line.push_back('\n');
        std::cout.write(line.data(), static_cast<std::streamsize>(line.size()));
    }
}

int main() {
    std::ios::sync_with_stdio(false);
    init_comp();
    std::string line, seq;
    while (std::getline(std::cin, line)) {
        if (!line.empty() && line[0] == '>') {
            emit(seq);
            seq.clear();
            std::cout << line << '\n';
        } else {
            seq += line;
        }
    }
    emit(seq);
}
