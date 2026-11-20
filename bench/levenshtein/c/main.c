/* levenshtein - C */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned long long state = 42;

static unsigned next(void) {
    state = (state * 48271) % 2147483647;
    return (unsigned)state;
}

static char *make_string(int len) {
    char *s = malloc(len + 1);
    for (int i = 0; i < len; i++) s[i] = "ACGT"[next() % 4];
    s[len] = 0;
    return s;
}

int main(int argc, char **argv) {
    int len = argc > 1 ? atoi(argv[1]) : 300;
    char *s = make_string(len);
    char *t = make_string(len);

    int *prev = malloc((len + 1) * sizeof *prev);
    int *cur = malloc((len + 1) * sizeof *cur);
    for (int j = 0; j <= len; j++) prev[j] = j;
    for (int i = 1; i <= len; i++) {
        cur[0] = i;
        for (int j = 1; j <= len; j++) {
            int sub = prev[j - 1] + (s[i - 1] != t[j - 1]);
            int del = prev[j] + 1;
            int ins = cur[j - 1] + 1;
            int best = sub < del ? sub : del;
            cur[j] = best < ins ? best : ins;
        }
        int *tmp = prev; prev = cur; cur = tmp;
    }
    printf("%d\n", prev[len]);
    free(s); free(t); free(prev); free(cur);
    return 0;
}
