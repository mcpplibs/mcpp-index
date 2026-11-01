// The C surface of openkal through the implementation for this system.
//
// Observations of the declarations recent rounds added, in the terms a caller
// relies on: a context started with a least stack size is told at least that
// size and has the room; a closed directory's enumeration is refused; and
// (0.17) the system is named, this program names itself with the moment it
// started, and a rename that does not replace refuses a name that is taken;
// (0.17.1) a joined command line is refused where programs receive vectors;
// (0.18) a file is mapped, the region holds its bytes and zero after its end;
// (0.19) the cores are no more than the processors, and a started context
// lowers its claim on the processors where the implementation claims it;
// (0.20) a transfer at an offset neither uses nor moves the file's position,
// this program is told the memory it occupies and its peak, and a region is
// reserved, backed, written, its backing returned and backed again reading
// zero, and released.
// The terminal is not observed here,
// because a test run has none; the implementations observe it on a terminal
// they make.
#include <openkal/env.h>
#include <openkal/fs.h>
#include <openkal/map.h>
#include <openkal/memory.h>
#include <openkal/process.h>
#include <openkal/region.h>
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

int g_claim = -1;
void lowers(void*) { g_claim = kal_task_set_priority(KAL_TASK_PRIORITY_BACKGROUND); }
void room(void* p) {
    auto* q = static_cast<probe*>(p);
    void* base = nullptr; kal_uintptr size = 0;
    if (kal_task_stack(&base, &size) == kal_ok) q->told = size;
    g_recurse(3 * 1024);
    q->done = 1;
}
}

int main() {
    check(KAL_VERSION_MINOR >= 17u || KAL_VERSION_MAJOR > 0u, "the declarations are openkal 0.17 or later");
    check(KAL_VERSION_MINOR > 17u || KAL_VERSION_PATCH >= 1u || KAL_VERSION_MAJOR > 0u, "and 0.17.1 or later");
    check(KAL_VERSION_MINOR >= 18u || KAL_VERSION_MAJOR > 0u, "and 0.18 or later");
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

    {
        char system[32];
        const kal_intptr n = kal_env_system(system, sizeof system);
        check(n > 0, "the system this program runs upon is named");
    }
    {
        kal_process me{};
        kal_program_info info{};
        info.self_size = sizeof info;
        check(kal_process_self(&me) == kal_ok && kal_process_info(me, KAL_PINFO_ALL, &info) == kal_ok
                  && info.id != 0 && info.started_ns != 0 && info.ended == 0,
              "this program names itself, with the moment it started");
        if (me.h) kal_process_close(me);
    }
    if (root.h && (kal_fs_props(root) & KAL_FS_PROP_RENAME_NO_REPLACE) != 0) {
        kal_file f{};
        if (kal_fs_open(root, "okt.a", 5, KAL_OPEN_WRITE | KAL_OPEN_CREATE | KAL_OPEN_TRUNCATE, &f) == kal_ok) kal_fs_close_file(f);
        if (kal_fs_open(root, "okt.b", 5, KAL_OPEN_WRITE | KAL_OPEN_CREATE | KAL_OPEN_TRUNCATE, &f) == kal_ok) kal_fs_close_file(f);
        check(kal_fs_rename_flags(root, "okt.a", 5, root, "okt.b", 5, KAL_RENAME_NO_REPLACE) == kal_err_exists,
              "a rename that does not replace refuses a name that is taken");
        kal_fs_remove(root, "okt.a", 5);
        kal_fs_remove(root, "okt.b", 5);
    }

    if ((kal_process_props() & KAL_PROCESS_PROP_ONE_STRING) == 0 && root.h) {
        // Where a program receives a vector, a joined command line has no
        // meaning and the start is refused before anything runs.
        const char* argv[] = { "x" };
        const kal_uintptr lens[] = { 1 };
        const kal_spawn how{ root, root, nullptr, nullptr, 0, KAL_SPAWN_ONE_STRING };
        kal_process p{};
        check(kal_process_spawn(&how, "x", 1, argv, lens, 1, nullptr, nullptr, 0, nullptr, &p)
                  == kal_err_not_supported,
              "a joined command line is refused where programs receive vectors");
    }

    if (root.h && (kal_interfaces() & KAL_IFACE_MAP) != 0) {
        kal_file f{};
        if (kal_fs_open(root, "okt.m", 5, KAL_OPEN_READ | KAL_OPEN_WRITE | KAL_OPEN_CREATE | KAL_OPEN_TRUNCATE, &f) == kal_ok) {
            kal_stream_write(kal_fs_stream(f), "mapped", 6);
            void* region = nullptr;
            check(kal_map_file(f, 0, 6, 0, &region) == kal_ok, "a file is mapped");
            if (region) {
                const volatile char* b = static_cast<const char*>(region);
                check(b[0] == 'm' && b[5] == 'd' && b[6] == 0, "the region holds the file's bytes and zero after its end");
                kal_map_release(region, 6);
            }
            kal_fs_close_file(f);
        }
        kal_fs_remove(root, "okt.m", 5);
    }

    {
        const kal_uintptr cores = kal_task_cores(), processors = kal_task_parallelism();
        check(processors == 0 || cores <= processors, "the cores are no more than the processors");
        kal_task t{};
        if (kal_task_start(lowers, nullptr, &t) == kal_ok) {
            kal_task_join(t);
            const bool claims = (kal_task_props() & KAL_TASK_PROP_PRIORITY) != 0;
            check(claims ? g_claim == kal_ok : g_claim == kal_err_not_supported,
                  "a started context lowers its claim to background, or is told the implementation has none");
        }
    }

    if (kal_fs_preopen_count() > 0 && kal_fs_preopen(0, &root, nullptr, 0, nullptr) == kal_ok) {
        kal_file f{};
        if (kal_fs_open(root, "okt.p", 5, KAL_OPEN_READ | KAL_OPEN_WRITE | KAL_OPEN_CREATE | KAL_OPEN_TRUNCATE, &f) == kal_ok) {
            kal_stream_write(kal_fs_stream(f), "abcdef", 6);
            check(kal_fs_write_at(f, "XY", 2, 1) == 2, "a write at an offset writes the whole buffer");
            kal_u64 at = 0;
            check(kal_fs_seek(f, 0, KAL_SEEK_CURRENT, &at) == kal_ok && at == 6,
                  "and leaves the position where it was");
            char b[8] = {};
            check(kal_fs_read_at(f, b, 6, 0) == 6 && b[0] == 'a' && b[1] == 'X' && b[2] == 'Y' && b[5] == 'f',
                  "a read at an offset reads what is there");
            check(kal_fs_read_at(f, b, 6, 6) == 0, "a read at the end reads nothing");
            kal_fs_close_file(f);
        }
        kal_fs_remove(root, "okt.p", 5);
    }

    {
        kal_process me{};
        if (kal_process_self(&me) == kal_ok) {
            kal_program_info info{};
            info.self_size = sizeof info;
            if (kal_process_info(me, KAL_PINFO_MEMORY, &info) == kal_ok && (info.present & KAL_PINFO_MEMORY))
                check(info.memory_bytes > 0 && info.memory_peak_bytes >= info.memory_bytes,
                      "this program is told the memory it occupies, and a peak no smaller");
            kal_process_close(me);
        }
    }

    if (kal_interfaces() & KAL_IFACE_REGION) {
        const kal_uintptr g = kal_memory_granularity();
        auto* r = static_cast<unsigned char*>(kal_region_reserve(4 * g, g, 0));
        check(r != nullptr, "a region is reserved");
        if (r) {
            check(kal_region_commit(r, g) == kal_ok, "a part of it is backed");
            r[0] = 7; r[g - 1] = 9;
            check(kal_region_decommit(r, g) == kal_ok && kal_region_commit(r, g) == kal_ok,
                  "its backing is returned and it is backed again");
            check(r[0] == 0 && r[g - 1] == 0, "and it reads as zero");
            kal_region_release(r, 4 * g);
        }
    }

    if (failures == 0) kal_stream_write(kal_stdout(), "openkal: held\n", 14);
    return failures == 0 ? 0 : 1;
}
