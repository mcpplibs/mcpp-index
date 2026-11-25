/* The reporters' programs, above openkal-musl. Elsewhere this compiles to a
 * main() that reports nothing, because the member names the port for Linux
 * alone. And (0.23) a file mapped with mmap. */
#ifndef HAVE_OPENKAL_MUSL
int main(void) { return 0; }
#else
#define _GNU_SOURCE 1
#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <pthread.h>
#include <stdio.h>
#include <sys/mman.h>
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
    /* 0.23: mmap of a file is openkal.map's; the bytes after the end in the last page are zero. */
    int fd = open("okm.map", O_RDWR | O_CREAT | O_TRUNC, 0644);
    if (fd >= 0 && write(fd, "mapped", 6) == 6) {
        const char* p = (const char*)mmap(NULL, 6, PROT_READ, MAP_PRIVATE, fd, 0);
        check(p != MAP_FAILED, "a file is mapped");
        if (p != MAP_FAILED) {
            check(p[0] == 'm' && p[5] == 'd' && p[6] == 0, "the region holds the file's bytes and zero after its end");
            check(munmap((void*)p, 6) == 0, "the region is released");
        }
    }
    if (fd >= 0) close(fd);
    unlink("okm.map");
    return failures != 0;
}
#endif
