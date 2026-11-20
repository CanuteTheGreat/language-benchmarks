// dijkstra - minstd graph, vector<vector<pair>>, std::priority_queue, C++.
#include <cstdint>
#include <cstdlib>
#include <functional>
#include <iostream>
#include <limits>
#include <queue>
#include <utility>
#include <vector>

int main(int argc, char **argv) {
    long V = argc > 2 ? std::atol(argv[1]) : 1000;
    long E = argc > 2 ? std::atol(argv[2]) : 5000;
    std::vector<std::vector<std::pair<int, int>>> adj(V);
    uint64_t g = 42;
    for (long e = 0; e < E; e++) {
        g = g * 48271 % 2147483647; long u = g % V;
        g = g * 48271 % 2147483647; long v = g % V;
        g = g * 48271 % 2147483647; int w = g % 100 + 1;
        adj[u].emplace_back((int)v, w);
    }
    const long long INF = std::numeric_limits<long long>::max();
    std::vector<long long> dist(V, INF);
    using Item = std::pair<long long, int>;
    std::priority_queue<Item, std::vector<Item>, std::greater<Item>> pq;
    dist[0] = 0;
    pq.emplace(0, 0);
    while (!pq.empty()) {
        auto [d, u] = pq.top();
        pq.pop();
        if (d > dist[u]) continue;
        for (auto [v, w] : adj[u]) {
            long long nd = d + w;
            if (nd < dist[v]) { dist[v] = nd; pq.emplace(nd, v); }
        }
    }
    long reached = 0;
    long long sum = 0, mx = 0;
    for (long i = 0; i < V; i++)
        if (dist[i] != INF) { reached++; sum += dist[i]; if (dist[i] > mx) mx = dist[i]; }
    std::cout << reached << ' ' << sum << ' ' << mx << '\n';
}
