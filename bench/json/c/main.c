/* json - parse, walk and re-serialise with cJSON. */
#include <cjson/cJSON.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv) {
    if (argc < 2) return 2;
    FILE *f = fopen(argv[1], "rb");
    if (!f) return 1;
    fseek(f, 0, SEEK_END);
    long size = ftell(f);
    fseek(f, 0, SEEK_SET);
    char *text = malloc((size_t)size + 1);
    if (fread(text, 1, (size_t)size, f) != (size_t)size) return 1;
    text[size] = 0;
    fclose(f);

    cJSON *root = cJSON_Parse(text);
    if (!root) return 1;

    long count = 0, active = 0;
    long long score = 0;
    cJSON *rec;
    cJSON_ArrayForEach(rec, root) {
        count++;
        if (cJSON_IsTrue(cJSON_GetObjectItemCaseSensitive(rec, "active"))) active++;
        cJSON *s = cJSON_GetObjectItemCaseSensitive(rec, "score");
        if (cJSON_IsNumber(s)) score += (long long)s->valuedouble;
    }

    char *out = cJSON_PrintUnformatted(root);
    printf("%ld %ld %lld %zu\n", count, active, score, strlen(out));
    return 0;
}
