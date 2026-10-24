/* The reporters' programs, above openkal-musl. Elsewhere this compiles to a
 * main() that reports nothing, because the member names the port for Linux
 * alone. */
#ifndef HAVE_OPENKAL_MUSL
int main(void) { return 0; }
#else
#define _GNU_SOURCE 1
#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <pthread.h>
#include <stdio.h>
#include <sys/stat.h>
#include <unistd.h>

static int failures = 0;

static void check(int ok, const char* what) { printf("%s %s\n", ok ? "  ok  " : "  FAIL", what); if (!ok) failures++; }

static int open_descriptors(void) {
    DIR* d = opendir("/proc/self/fd"); if (!d) return -1;
    int n = 0; while (readdir(d)) n++; closedir(d); return n;
}

static long recurse(long n) { volatile char pad[1000]; pad[0] = 1; return n ? recurse(n - 1) + pad[0] : 0; }
static void* body(void* arg) { *(long*)arg = recurse(*(long*)arg); return nullptr; }

int main(void) {
    char name[64];
    mkdir("okm.d", 0755);
    for (int i = 0; i < 300; i++) { snprintf(name, sizeof name, "okm.d/e%03d", i); close(open(name, O_WRONLY | O_CREAT, 0644)); }
    const int before = open_descriptors();
    for (int i = 0; i < 64; i++) { DIR* d = opendir("okm.d"); if (d) { readdir(d); closedir(d); } }
    const int after = open_descriptors();
    for (int i = 0; i < 300; i++) { snprintf(name, sizeof name, "okm.d/e%03d", i); unlink(name); }
    rmdir("okm.d");
    printf("descriptors before=%d after=%d\n", before, after);
    if (before >= 0) check(before == after, "a directory closed early leaves nothing open");

    pthread_attr_t attr; pthread_t t; long depth = 3900;
    pthread_attr_init(&attr);
    pthread_attr_setstacksize(&attr, 4u << 20);
    check(pthread_create(&t, &attr, body, &depth) == 0 && pthread_join(t, 0) == 0 && depth == 3900,
          "a thread that asked for 4 MiB recursed 3900 levels of about 1 KiB");
    static char region[1 << 20];
    pthread_attr_setstack(&attr, region, sizeof region);
    check(pthread_create(&t, &attr, body, &depth) == EINVAL, "a stack the caller supplies is refused");
    return failures != 0;
}
#endif
