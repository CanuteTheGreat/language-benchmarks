/* dijkstra - minstd graph, adjacency via head/next arrays, hand-written binary heap, plain C. */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

typedef struct { int64_t d; int v; } Item;

static Item *heap;
static long hn;

static void push(int64_t d, int v) {
    long i = hn++;
    while (i > 0) {
        long p = (i - 1) / 2;
        if (heap[p].d <= d) break;
        heap[i] = heap[p];
        i = p;
    }
    heap[i].d = d;
    heap[i].v = v;
}

static Item pop(void) {
    Item top = heap[0], last = heap[--hn];
    long i = 0;
    for (;;) {
        long c = 2 * i + 1;
        if (c >= hn) break;
        if (c + 1 < hn && heap[c + 1].d < heap[c].d) c++;
        if (heap[c].d >= last.d) break;
        heap[i] = heap[c];
        i = c;
    }
    if (hn > 0) heap[i] = last;
    return top;
}

int main(int argc, char **argv) {
    long V = argc > 2 ? atol(argv[1]) : 1000;
    long E = argc > 2 ? atol(argv[2]) : 5000;
    int *head = malloc(V * sizeof(int));
    int *tail = malloc(V * sizeof(int));   /* keeps edges in generation order */
    int *next = malloc(E * sizeof(int));
    int *to = malloc(E * sizeof(int));
    int *wt = malloc(E * sizeof(int));
    for (long i = 0; i < V; i++) head[i] = tail[i] = -1;

    uint64_t g = 42;
    for (long e = 0; e < E; e++) {
        g = g * 48271 % 2147483647; long u = g % V;
        g = g * 48271 % 2147483647; long v = g % V;
        g = g * 48271 % 2147483647; int w = g % 100 + 1;
        to[e] = (int)v;
        wt[e] = w;
        next[e] = -1;
        if (tail[u] < 0) head[u] = (int)e; else next[tail[u]] = (int)e;
        tail[u] = (int)e;
    }

    int64_t *dist = malloc(V * sizeof(int64_t));
    for (long i = 0; i < V; i++) dist[i] = INT64_MAX;
    heap = malloc((E + 1) * sizeof(Item));
    dist[0] = 0;
    push(0, 0);
    while (hn > 0) {
        Item it = pop();
        if (it.d > dist[it.v]) continue;
        for (int e = head[it.v]; e >= 0; e = next[e]) {
            int64_t nd = it.d + wt[e];
            if (nd < dist[to[e]]) { dist[to[e]] = nd; push(nd, to[e]); }
        }
    }
    long reached = 0;
    int64_t sum = 0, max = 0;
    for (long i = 0; i < V; i++)
        if (dist[i] != INT64_MAX) { reached++; sum += dist[i]; if (dist[i] > max) max = dist[i]; }
    printf("%ld %lld %lld\n", reached, (long long)sum, (long long)max);
    return 0;
}
