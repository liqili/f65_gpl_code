/*
 * gen_hardver - write the per-board additional-hardversion.bin used for the
 * factory "add-hardver" partition of TP-Link NAND images.
 *
 * TP-Link's EAP65x GPL Makefile calls tools/gen_hardver but does not ship it.
 * This is a minimal replacement with the same command line:
 *
 *     gen_hardver [-d] -a additional-hardversion.bin -c build.ini
 *
 * It reads "additional_hw_version=<n>" from the board build.ini (whitespace is
 * ignored, the value is decimal, e.g. "additional_hw_version = 0003") and writes
 * it as a 4-byte big-endian integer, the same encoding gen_softver uses for the
 * additionalHardVer field of soft-version.bin.
 *
 * Unlike gen_softver it fails (non-zero exit) when the value is missing, so an
 * incomplete board directory cannot silently produce add-hardver = 0.
 */
#include <arpa/inet.h>
#include <getopt.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define PATH_LEN 512

static int debugOn = 0;

#define DEBUG_PRINTF(fmt, args...) \
    do { if (debugOn) printf(fmt, ##args); } while (0)

static void show_usage(void)
{
    printf("usage: gen_hardver [OPTIONS]\n\n"
           "   -a, --addhard=FILE      Output additional-hardversion file\n"
           "   -c, --config=FILE       build.ini holding additional_hw_version=\n"
           "   -d, --debug             Show debug information\n"
           "   -h, --help              Show this message\n");
}

static void strip_space(char *s)
{
    char *dst = s;

    for (; *s; s++) {
        if (*s != ' ' && *s != '\t' && *s != '\r' && *s != '\n')
            *dst++ = *s;
    }
    *dst = '\0';
}

static int parse_hardver(const char *path, int *hardVer)
{
    FILE *fp = fopen(path, "r");
    char *line = NULL;
    size_t len = 0;
    int found = 0;

    if (!fp) {
        printf("gen_hardver: failed to open %s\n", path);
        return -1;
    }

    while (getline(&line, &len, fp) != -1) {
        strip_space(line);
        if (line[0] == '#')
            continue;
        if (sscanf(line, "additional_hw_version=%d", hardVer) == 1)
            found = 1; /* keep scanning: the last definition wins, like gen_softver */
    }

    free(line);
    fclose(fp);

    if (!found) {
        printf("gen_hardver: no additional_hw_version in %s\n", path);
        return -1;
    }
    return 0;
}

int main(int argc, char *argv[])
{
    static const struct option opts[] = {
        {"addhard", required_argument, 0, 'a'},
        {"config",  required_argument, 0, 'c'},
        {"debug",   no_argument,       0, 'd'},
        {"help",    no_argument,       0, 'h'},
        {0, 0, 0, 0}
    };
    char outPath[PATH_LEN] = {0};
    char cfgPath[PATH_LEN] = {0};
    int hardVer = 0;
    uint32_t be;
    FILE *fp;
    int c;

    while ((c = getopt_long(argc, argv, "a:c:dh", opts, NULL)) != -1) {
        switch (c) {
        case 'a':
            strncpy(outPath, optarg, PATH_LEN - 1);
            break;
        case 'c':
            strncpy(cfgPath, optarg, PATH_LEN - 1);
            break;
        case 'd':
            debugOn = 1;
            break;
        case 'h':
            show_usage();
            return 0;
        default:
            show_usage();
            return 1;
        }
    }

    if (!outPath[0] || !cfgPath[0]) {
        show_usage();
        return 1;
    }

    if (parse_hardver(cfgPath, &hardVer) != 0)
        return 1;

    be = htonl((uint32_t)hardVer);
    fp = fopen(outPath, "wb");
    if (!fp || fwrite(&be, sizeof(be), 1, fp) != 1) {
        printf("gen_hardver: failed to write %s\n", outPath);
        if (fp)
            fclose(fp);
        return 1;
    }
    fclose(fp);

    DEBUG_PRINTF("gen_hardver: additional_hw_version=%d -> %s\n", hardVer, outPath);
    return 0;
}
