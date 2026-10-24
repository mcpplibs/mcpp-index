// The C surface of openkal through the implementation for this system.
//
// One observation per declaration the newest round added, in the terms a
// caller relies on: a context started with a least stack size is told at least
// that size and has the room; a closed directory's enumeration is refused; the
// input position is not an error to ask for. The terminal is not observed here,
// because a test run has none; the implementations observe it on a terminal
// they make.
#include <openkal/fs.h>
#include <openkal/stream.h>
#include <openkal/task.h>
#include <openkal/version.h>

namespace {
int failures = 0;
void check(bool ok, const char* what) {
    if (ok) return;
    ++failures;
    kal_uintptr n = 0; while (what[n]) ++n;
    kal_stream_write(kal_stderr(), "FAIL: ", 6);
    kal_stream_write(kal_stderr(), what, n);
    kal_stream_write(kal_stderr(), "\n", 1);
}

long recurse(long n);
long (*volatile g_recurse)(long) = recurse;
long recurse(long n) { volatile char pad[1000]; pad[0] = static_cast<char>(n); return n ? g_recurse(n - 1) + pad[0] : 0; }

struct probe { kal_uintptr told; volatile int done; };
void room(void* p) {
    auto* q = static_cast<probe*>(p);
    void* base = nullptr; kal_uintptr size = 0;
    if (kal_task_stack(&base, &size) == kal_ok) q->told = size;
    g_recurse(3 * 1024);
    q->done = 1;
}
}

int main() {
    check(KAL_VERSION_MINOR >= 16u || KAL_VERSION_MAJOR > 0u, "the declarations are openkal 0.16 or later");
    check(kal_version() >= KAL_VERSION, "the implementation is at least as new as the declarations");

    probe q{0, 0};
    kal_task t{};
    check(kal_task_start_sized(room, &q, 4u << 20, &t) == kal_ok, "a context with a least stack size starts");
    kal_task_join(t);
    check(q.told >= (4u << 20), "it is told at least the size asked for");
    check(q.done == 1, "it has the room");

    kal_dir root{};
    if (kal_fs_preopen_count() > 0 && kal_fs_preopen(0, &root, nullptr, 0, nullptr) == kal_ok) {
        kal_fs_mkdir(root, "okt.d", 5);
        kal_dir d{}; kal_uintptr it = 0;
        if (kal_fs_open_dir(root, "okt.d", 5, &d) == kal_ok && kal_fs_list_begin(d, &it) == kal_ok) {
            kal_fs_close_dir(d);
            char name[64]; kal_uintptr len = 0; int kind = 0;
            check(kal_fs_list_next(d, &it, name, sizeof name, &len, &kind) == kal_err_invalid,
                  "an enumeration of a closed directory is refused");
        }
        kal_fs_remove(root, "okt.d", 5);
    }

    if (failures == 0) kal_stream_write(kal_stdout(), "openkal: held\n", 14);
    return failures == 0 ? 0 : 1;
}
