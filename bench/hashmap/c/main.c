/* hashmap - minstd keys, hand-written open-addressing table, plain C. */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

typedef struct { uint32_t key; int64_t val; } Slot;   /* key 0 = empty (minstd never yields 0) */

static Slot *table;
static uint64_t mask;

static uint64_t hash(uint32_t k) { return ((uint64_t)k * 0x9E3779B97F4A7C15ull) >> 20; }

static Slot *find(uint32_t k) {
    uint64_t i = hash(k) & mask;
    while (table[i].key != 0 && table[i].key != k) i = (i + 1) & mask;
    return &table[i];
}

int main(int argc, char **argv) {
    long n = argc > 1 ? atol(argv[1]) : 10000;
    long size = 0;
    uint64_t cap = 16;
    while (cap < (uint64_t)n * 2) cap <<= 1;           /* load factor <= 0.5 */
    table = calloc(cap, sizeof(Slot));
    mask = cap - 1;

    uint64_t s1 = 42;
    for (long i = 0; i < n; i++) {
        s1 = s1 * 48271 % 2147483647;
        Slot *p = find((uint32_t)s1);
        if (p->key == 0) { p->key = (uint32_t)s1; size++; }
        p->val = i;
    }
    uint64_t s2 = 42;
    long hits = 0;
    int64_t sum = 0;
    for (long j = 0; j < 2 * n; j++) {
        s2 = s2 * 48271 % 2147483647;
        Slot *p = find((uint32_t)s2);
        if (p->key != 0) { hits++; sum += p->val; }
    }
    printf("%ld %ld %lld\n", size, hits, (long long)sum);
    free(table);
    return 0;
}
