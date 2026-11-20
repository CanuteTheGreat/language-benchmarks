/* knucleotide - Computer Language Benchmarks Game specification, plain C. */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Small open-addressing hash table: 2-bit packed k-mer -> count. */
typedef struct {
    uint64_t *keys;
    uint32_t *vals;
    size_t mask;
    int shift;
} table;

#define EMPTY (~0ULL)

static table tnew(size_t entries) {
    int bits = 4;
    while (((size_t)1 << bits) < entries * 2) bits++;
    size_t cap = (size_t)1 << bits;
    table t;
    t.mask = cap - 1;
    t.shift = 64 - bits;
    t.keys = malloc(cap * sizeof(uint64_t));
    t.vals = calloc(cap, sizeof(uint32_t));
    memset(t.keys, 0xff, cap * sizeof(uint64_t));
    return t;
}

static size_t slot(const table *t, uint64_t key) {
    size_t i = (key * 0x9E3779B97F4A7C15ULL) >> t->shift;
    while (t->keys[i] != EMPTY && t->keys[i] != key) i = (i + 1) & t->mask;
    return i;
}

static void tinc(table *t, uint64_t key) {
    size_t i = slot(t, key);
    t->keys[i] = key;
    t->vals[i]++;
}

static uint32_t tget(const table *t, uint64_t key) {
    size_t i = slot(t, key);
    return t->keys[i] == key ? t->vals[i] : 0;
}

static void tfree(table *t) {
    free(t->keys);
    free(t->vals);
}

static const char LETTERS[4] = {'A', 'C', 'G', 'T'};

static table count(const uint8_t *s, size_t n, int k) {
    size_t kmers = n - k + 1;
    size_t possible = (size_t)1 << (2 * k);
    table t = tnew(kmers < possible ? kmers : possible);
    uint64_t mask = (1ULL << (2 * k)) - 1, key = 0;
    for (size_t i = 0; i < n; i++) {
        key = ((key << 2) | s[i]) & mask;
        if (i + 1 >= (size_t)k) tinc(&t, key);
    }
    return t;
}

typedef struct {
    uint64_t key;
    uint32_t cnt;
} entry;

static int cmp(const void *a, const void *b) {
    const entry *x = a, *y = b;
    if (x->cnt != y->cnt) return x->cnt < y->cnt ? 1 : -1;
    return x->key < y->key ? -1 : x->key > y->key;
}

static void frequencies(const uint8_t *s, size_t n, int k) {
    table t = count(s, n, k);
    size_t cap = t.mask + 1, m = 0;
    entry *e = malloc(cap * sizeof(entry));
    for (size_t i = 0; i < cap; i++)
        if (t.keys[i] != EMPTY) e[m++] = (entry){t.keys[i], t.vals[i]};
    qsort(e, m, sizeof(entry), cmp);
    double total = (double)(n - k + 1);
    for (size_t i = 0; i < m; i++) {
        char name[33];
        for (int j = 0; j < k; j++) name[j] = LETTERS[(e[i].key >> (2 * (k - 1 - j))) & 3];
        name[k] = 0;
        printf("%s %.3f\n", name, 100.0 * e[i].cnt / total);
    }
    putchar('\n');
    free(e);
    tfree(&t);
}

static void occurrences(const uint8_t *s, size_t n, const char *seq) {
    int k = (int)strlen(seq);
    uint64_t key = 0;
    for (int j = 0; j < k; j++) key = (key << 2) | (uint64_t)(strchr("ACGT", seq[j]) - "ACGT");
    table t = count(s, n, k);
    printf("%u\t%s\n", tget(&t, key), seq);
    tfree(&t);
}

int main(void) {
    size_t cap = 1 << 20, len = 0, r;
    char *buf = malloc(cap);
    while ((r = fread(buf + len, 1, cap - len, stdin)) > 0) {
        len += r;
        if (len == cap) buf = realloc(buf, cap *= 2);
    }
    /* Extract the sequence after the ">THREE" header as 2-bit codes. */
    uint8_t *s = malloc(len + 1);
    size_t n = 0, pos = 0;
    int in_three = 0;
    while (pos < len) {
        char *nl = memchr(buf + pos, '\n', len - pos);
        size_t end = nl ? (size_t)(nl - buf) : len;
        if (buf[pos] == '>') {
            in_three = strncmp(buf + pos, ">THREE", 6) == 0;
        } else if (in_three) {
            for (size_t i = pos; i < end; i++) {
                switch (buf[i] & 0xDF) {
                case 'A': s[n++] = 0; break;
                case 'C': s[n++] = 1; break;
                case 'G': s[n++] = 2; break;
                case 'T': s[n++] = 3; break;
                }
            }
        }
        pos = end + 1;
    }
    frequencies(s, n, 1);
    frequencies(s, n, 2);
    occurrences(s, n, "GGT");
    occurrences(s, n, "GGTA");
    occurrences(s, n, "GGTATT");
    occurrences(s, n, "GGTATTTTAATT");
    occurrences(s, n, "GGTATTTTAATTTATAGT");
    return 0;
}
