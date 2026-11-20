# dijkstra - minstd graph, lists of (to, w) tuples, heapq, Python.
import heapq
import sys

nv = int(sys.argv[1]) if len(sys.argv) > 2 else 1000
ne = int(sys.argv[2]) if len(sys.argv) > 2 else 5000
adj = [[] for _ in range(nv)]
g = 42
for _ in range(ne):
    g = g * 48271 % 2147483647
    u = g % nv
    g = g * 48271 % 2147483647
    v = g % nv
    g = g * 48271 % 2147483647
    adj[u].append((v, g % 100 + 1))

INF = float("inf")
dist = [INF] * nv
dist[0] = 0
pq = [(0, 0)]
while pq:
    d, u = heapq.heappop(pq)
    if d > dist[u]:
        continue
    for v, w in adj[u]:
        nd = d + w
        if nd < dist[v]:
            dist[v] = nd
            heapq.heappush(pq, (nd, v))
reached = 0
total = 0
longest = 0
for d in dist:
    if d != INF:
        reached += 1
        total += d
        if d > longest:
            longest = d
print(reached, total, longest)
