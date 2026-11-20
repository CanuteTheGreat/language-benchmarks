/* regexredux - Computer Language Benchmarks Game specification, C with PCRE2. */
#define PCRE2_CODE_UNIT_WIDTH 8
#include <pcre2.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static pcre2_code *compile(const char *pat) {
    int err;
    PCRE2_SIZE off;
    pcre2_code *re = pcre2_compile((PCRE2_SPTR)pat, PCRE2_ZERO_TERMINATED, 0, &err, &off, NULL);
    if (!re) {
        fprintf(stderr, "bad pattern %s\n", pat);
        exit(1);
    }
    pcre2_jit_compile(re, PCRE2_JIT_COMPLETE);
    return re;
}

static long count(pcre2_code *re, const char *s, size_t n) {
    pcre2_match_data *md = pcre2_match_data_create_from_pattern(re, NULL);
    long c = 0;
    PCRE2_SIZE start = 0;
    while (start <= n && pcre2_match(re, (PCRE2_SPTR)s, n, start, 0, md, NULL) >= 0) {
        PCRE2_SIZE *ov = pcre2_get_ovector_pointer(md);
        c++;
        start = ov[1] > ov[0] ? ov[1] : ov[1] + 1;
    }
    pcre2_match_data_free(md);
    return c;
}

/* Replace every match of pat in s[0..n) with rep; returns a new buffer. */
static char *replace(const char *pat, const char *s, size_t n, const char *rep, size_t *outn) {
    pcre2_code *re = compile(pat);
    pcre2_match_data *md = pcre2_match_data_create_from_pattern(re, NULL);
    size_t rl = strlen(rep), cap = n + 1, len = 0, last = 0;
    char *out = malloc(cap);
    PCRE2_SIZE start = 0;
    while (start <= n && pcre2_match(re, (PCRE2_SPTR)s, n, start, 0, md, NULL) >= 0) {
        PCRE2_SIZE *ov = pcre2_get_ovector_pointer(md);
        size_t need = len + (ov[0] - last) + rl + 1;
        if (need > cap) {
            while (need > cap) cap *= 2;
            out = realloc(out, cap);
        }
        memcpy(out + len, s + last, ov[0] - last);
        len += ov[0] - last;
        memcpy(out + len, rep, rl);
        len += rl;
        last = ov[1];
        start = ov[1] > ov[0] ? ov[1] : ov[1] + 1;
    }
    if (len + (n - last) + 1 > cap) out = realloc(out, len + (n - last) + 1);
    memcpy(out + len, s + last, n - last);
    len += n - last;
    out[len] = 0;
    pcre2_match_data_free(md);
    pcre2_code_free(re);
    *outn = len;
    return out;
}

static const char *variants[] = {
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

static const char *subs[][2] = {
    {"tHa[Nt]", "<4>"},
    {"aND|caN|Ha[DS]|WaS", "<3>"},
    {"a[NSt]|BY", "<2>"},
    {"<[^>]*>", "|"},
    {"\\|[^|][^|]*\\|", "-"},
};

int main(void) {
    size_t cap = 1 << 20, len = 0, r;
    char *buf = malloc(cap);
    while ((r = fread(buf + len, 1, cap - len, stdin)) > 0) {
        len += r;
        if (len == cap) buf = realloc(buf, cap *= 2);
    }
    size_t len0 = len, len1;
    char *seq = replace(">.*\n|\n", buf, len, "", &len1);
    free(buf);

    for (int i = 0; i < 9; i++) {
        pcre2_code *re = compile(variants[i]);
        printf("%s %ld\n", variants[i], count(re, seq, len1));
        pcre2_code_free(re);
    }

    size_t n = len1;
    for (int i = 0; i < 5; i++) {
        size_t m;
        char *next = replace(subs[i][0], seq, n, subs[i][1], &m);
        free(seq);
        seq = next;
        n = m;
    }
    printf("\n%zu\n%zu\n%zu\n", len0, len1, n);
    return 0;
}
