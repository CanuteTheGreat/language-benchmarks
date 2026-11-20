/* revcomp - Computer Language Benchmarks Game specification, plain C. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define LINE 60

static unsigned char comp[256];

static void init_comp(void) {
    const char *from = "ACGTUMRWSYKVHDBN", *to = "TGCAAKYWSRMBDHVN";
    for (int i = 0; i < 256; i++) comp[i] = (unsigned char)i;
    for (int i = 0; from[i]; i++) {
        comp[(unsigned char)from[i]] = (unsigned char)to[i];
        comp[(unsigned char)from[i] | 0x20] = (unsigned char)to[i];
    }
}

/* Print the reverse complement of seq[0..n) in lines of 60. */
static void emit(const unsigned char *seq, size_t n) {
    unsigned char line[LINE + 1];
    while (n > 0) {
        size_t m = n < LINE ? n : LINE;
        for (size_t j = 0; j < m; j++) line[j] = comp[seq[--n]];
        line[m] = '\n';
        fwrite(line, 1, m + 1, stdout);
    }
}

int main(void) {
    init_comp();
    size_t cap = 1 << 20, len = 0, r;
    unsigned char *buf = malloc(cap);
    while ((r = fread(buf + len, 1, cap - len, stdin)) > 0) {
        len += r;
        if (len == cap) buf = realloc(buf, cap *= 2);
    }
    unsigned char *seq = malloc(len + 1);
    size_t n = 0, pos = 0;
    while (pos < len) {
        unsigned char *nl = memchr(buf + pos, '\n', len - pos);
        size_t end = nl ? (size_t)(nl - buf) : len;
        if (buf[pos] == '>') {
            emit(seq, n);
            n = 0;
            fwrite(buf + pos, 1, end - pos, stdout);
            putchar('\n');
        } else {
            memcpy(seq + n, buf + pos, end - pos);
            n += end - pos;
        }
        pos = end + 1;
    }
    emit(seq, n);
    return 0;
}
