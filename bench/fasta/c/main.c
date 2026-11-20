/* fasta - Computer Language Benchmarks Game specification, plain C. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define LINE 60
#define IM 139968
#define IA 3877
#define IC 29573

static unsigned last = 42;

static double rnd(double max) {
    last = (last * IA + IC) % IM;
    return max * last / IM;
}

struct aminoacid {
    char c;
    double p;
};

static const char alu[] =
    "GGCCGGGCGCGGTGGCTCACGCCTGTAATCCCAGCACTTTGG"
    "GAGGCCGAGGCGGGCGGATCACCTGAGGTCAGGAGTTCGAGA"
    "CCAGCCTGGCCAACATGGTGAAACCCCGTCTCTACTAAAAAT"
    "ACAAAAATTAGCCGGGCGTGGTGGCGCGCGCCTGTAATCCCA"
    "GCTACTCGGGAGGCTGAGGCAGGAGAATCGCTTGAACCCGGG"
    "AGGCGGAGGTTGCAGTGAGCCGAGATCGCGCCACTGCACTCC"
    "AGCCTGGGCGACAGAGCGAGACTCCGTCTCAAAAA";

static struct aminoacid iub[] = {
    {'a', 0.27}, {'c', 0.12}, {'g', 0.12}, {'t', 0.27},
    {'B', 0.02}, {'D', 0.02}, {'H', 0.02}, {'K', 0.02},
    {'M', 0.02}, {'N', 0.02}, {'R', 0.02}, {'S', 0.02},
    {'V', 0.02}, {'W', 0.02}, {'Y', 0.02},
};

static struct aminoacid homosapiens[] = {
    {'a', 0.3029549426680},
    {'c', 0.1979883004921},
    {'g', 0.1975473066391},
    {'t', 0.3015094502008},
};

static void repeat_fasta(const char *s, size_t n) {
    char line[LINE + 1];
    size_t len = strlen(s), pos = 0;
    while (n > 0) {
        size_t m = n < LINE ? n : LINE;
        for (size_t i = 0; i < m; i++) {
            line[i] = s[pos++];
            if (pos == len) pos = 0;
        }
        line[m] = '\n';
        fwrite(line, 1, m + 1, stdout);
        n -= m;
    }
}

static void random_fasta(struct aminoacid *genelist, size_t count, size_t n) {
    double cum = 0;
    for (size_t i = 0; i < count; i++) {
        cum += genelist[i].p;
        genelist[i].p = cum;
    }
    char line[LINE + 1];
    while (n > 0) {
        size_t m = n < LINE ? n : LINE;
        for (size_t i = 0; i < m; i++) {
            double r = rnd(1.0);
            size_t k = 0;
            while (k < count - 1 && r >= genelist[k].p) k++;
            line[i] = genelist[k].c;
        }
        line[m] = '\n';
        fwrite(line, 1, m + 1, stdout);
        n -= m;
    }
}

int main(int argc, char **argv) {
    size_t n = argc > 1 ? strtoul(argv[1], NULL, 10) : 1000;
    fputs(">ONE Homo sapiens alu\n", stdout);
    repeat_fasta(alu, n * 2);
    fputs(">TWO IUB ambiguity codes\n", stdout);
    random_fasta(iub, sizeof iub / sizeof iub[0], n * 3);
    fputs(">THREE Homo sapiens frequency\n", stdout);
    random_fasta(homosapiens, sizeof homosapiens / sizeof homosapiens[0], n * 5);
    return 0;
}
