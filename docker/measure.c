/* measure: run a command once and append one CSV line with
 *   tag,wall_s,user_s,sys_s,maxrss_kb,energy_pkg_j,exit,energy_psys_j
 * Energy comes from the RAPL domains in /sys/class/powercap, read before and after the run:
 * energy_pkg_j sums the top-level "package-N" domains (the CPU package), energy_psys_j is the
 * "psys" (platform) domain where the CPU has one, else -1.
 * Usage: measure -o out.csv -t tag -- cmd [args...]
 * The child's stdout/stderr are passed through unchanged.
 * MIT licence. */
#define _GNU_SOURCE
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/resource.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

#define MAXDOM 8
static char dom[MAXDOM][128];
static double range[MAXDOM];
static int ispsys[MAXDOM];
static int ndom;

static int read_u64(const char *path, unsigned long long *v) {
    FILE *f = fopen(path, "r");
    if (!f) return -1;
    int ok = fscanf(f, "%llu", v) == 1;
    fclose(f);
    return ok ? 0 : -1;
}

static void find_domains(void) {
    for (int i = 0; i < MAXDOM && ndom < MAXDOM; i++) {
        char p[160];
        unsigned long long v;
        snprintf(p, sizeof p, "/sys/class/powercap/intel-rapl:%d/energy_uj", i);
        if (read_u64(p, &v) != 0) continue;
        snprintf(dom[ndom], sizeof dom[ndom], "/sys/class/powercap/intel-rapl:%d", i);
        char nm[64] = "";
        snprintf(p, sizeof p, "%s/name", dom[ndom]);
        FILE *nf = fopen(p, "r");
        if (nf) { if (!fgets(nm, sizeof nm, nf)) nm[0] = 0; fclose(nf); }
        if (strncmp(nm, "package", 7) != 0 && strncmp(nm, "psys", 4) != 0) continue;
        ispsys[ndom] = strncmp(nm, "psys", 4) == 0;
        snprintf(p, sizeof p, "%s/max_energy_range_uj", dom[ndom]);
        unsigned long long r = 0;
        read_u64(p, &r);
        range[ndom] = (double)r;
        ndom++;
    }
}

static void energy(double *out) {
    for (int i = 0; i < ndom; i++) {
        char p[160];
        unsigned long long v = 0;
        snprintf(p, sizeof p, "%s/energy_uj", dom[i]);
        read_u64(p, &v);
        out[i] = (double)v;
    }
}

int main(int argc, char **argv) {
    const char *out = NULL, *tag = "run";
    int i = 1;
    for (; i < argc; i++) {
        if (!strcmp(argv[i], "-o") && i + 1 < argc) out = argv[++i];
        else if (!strcmp(argv[i], "-t") && i + 1 < argc) tag = argv[++i];
        else if (!strcmp(argv[i], "--")) { i++; break; }
        else break;
    }
    if (i >= argc) { fprintf(stderr, "usage: measure -o out.csv -t tag -- cmd...\n"); return 2; }
    find_domains();
    double e0[MAXDOM], e1[MAXDOM];
    struct timespec t0, t1;
    energy(e0);
    clock_gettime(CLOCK_MONOTONIC, &t0);
    pid_t pid = fork();
    if (pid == 0) {
        execvp(argv[i], &argv[i]);
        fprintf(stderr, "measure: exec %s: %s\n", argv[i], strerror(errno));
        _exit(127);
    }
    int st = 0;
    struct rusage ru;
    if (wait4(pid, &st, 0, &ru) < 0) { perror("wait4"); return 2; }
    clock_gettime(CLOCK_MONOTONIC, &t1);
    energy(e1);
    double joules = -1, psys = -1;
    for (int d = 0; d < ndom; d++) {
        double de = e1[d] - e0[d];
        if (de < 0) de += range[d];
        if (ispsys[d]) psys = (psys < 0 ? 0 : psys) + de / 1e6;
        else joules = (joules < 0 ? 0 : joules) + de / 1e6;
    }
    double wall = (t1.tv_sec - t0.tv_sec) + (t1.tv_nsec - t0.tv_nsec) / 1e9;
    double user = ru.ru_utime.tv_sec + ru.ru_utime.tv_usec / 1e6;
    double sys = ru.ru_stime.tv_sec + ru.ru_stime.tv_usec / 1e6;
    int code = WIFEXITED(st) ? WEXITSTATUS(st) : 128 + WTERMSIG(st);
    if (out) {
        FILE *f = fopen(out, "a");
        if (f) {
            fprintf(f, "%s,%.6f,%.6f,%.6f,%ld,%.6f,%d,%.6f\n", tag, wall, user, sys, ru.ru_maxrss, joules, code, psys);
            fclose(f);
        }
    }
    return code;
}
