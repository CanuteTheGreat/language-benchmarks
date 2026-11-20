// json - parse, walk and re-serialise with nlohmann::json.
#include <cstdio>
#include <fstream>
#include <nlohmann/json.hpp>
#include <string>

int main(int argc, char** argv) {
    if (argc < 2) return 2;
    std::ifstream in(argv[1]);
    nlohmann::json root = nlohmann::json::parse(in);

    long count = 0, active = 0;
    long long score = 0;
    for (const auto& rec : root) {
        count++;
        if (rec.at("active").get<bool>()) active++;
        score += rec.at("score").get<long long>();
    }

    std::string out = root.dump();
    std::printf("%ld %ld %lld %zu\n", count, active, score, out.size());
}
