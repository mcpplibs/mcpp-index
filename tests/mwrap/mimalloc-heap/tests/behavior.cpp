// The installed wrapper, as a consumer reaches it: each check names what the
// allocator promises.
import std;
import mcpplibs.mwrap.mimalloc;

namespace {
int failures = 0;
void check(bool ok, std::string_view what)
{
    std::println("{} {}", ok ? "ok  " : "FAIL", what);
    if (!ok) ++failures;
}
}

int main()
{
    namespace m = mcpplibs::mwrap::mimalloc::macros;
    check(mi_version() == m::MI_MALLOC_VERSION && mi_version() == 30601, "the library is mimalloc 3.6.1");

    void* p = mi_malloc(1000);
    std::memset(p, 0x5a, 1000);
    p = mi_realloc(p, 1 << 20);
    check(p && static_cast<unsigned char*>(p)[999] == 0x5a && mi_usable_size(p) >= (1u << 20),
          "a block grows and keeps its bytes");
    mi_free(p);

    for (std::size_t align : {16u, 256u, 4096u, 65536u}) {
        void* a = mi_malloc_aligned(align + 3, align);
        check(a && reinterpret_cast<std::uintptr_t>(a) % align == 0, std::format("a block aligned to {}", align));
        mi_free(a);
    }

    mi_heap_t* heap = mi_heap_new();
    std::vector<void*> blocks;
    for (int i = 0; i < 2000; ++i) blocks.push_back(mi_heap_malloc(heap, 8 + i % 700));
    std::size_t seen = 0;
    mi_heap_visit_blocks(heap, true, [](const mi_heap_t*, const mi_heap_area_t*, void* block, std::size_t, void* arg) {
        if (block) ++*static_cast<std::size_t*>(arg);
        return true;
    }, &seen);
    check(seen == blocks.size() && mi_heap_contains(heap, blocks.back()),
          "a private heap holds and visits every block it handed out");
    mi_heap_destroy(heap);

    std::vector<std::string, mi_stl_allocator<std::string>> names;
    for (int i = 0; i < 5000; ++i) names.push_back(std::format("module{}.cppm", i));
    check(names.size() == 5000 && names[4999] == "module4999.cppm", "a container's elements live in mimalloc");

    const long before = mi_option_get(mi_option_purge_delay);
    mi_option_set(mi_option_purge_delay, before + 5);
    check(mi_option_get(mi_option_purge_delay) == before + 5, "an option is set and read back");
    mi_option_set(mi_option_purge_delay, before);

    // Blocks freed by a thread other than the one that allocated them, and the
    // memory taken again afterwards.
    std::vector<void*> handed(20000);
    std::thread([&] { for (auto& b : handed) b = mi_malloc(48); }).join();
    const bool all = std::ranges::all_of(handed, [](void* b) { return b != nullptr; });
    std::thread([&] { for (auto* b : handed) mi_free(b); }).join();
    mi_collect(true);
    void* again = mi_malloc(48);
    check(all && again != nullptr, "blocks allocated in one thread are freed in another");
    mi_free(again);

    mi_stats_t stats;
    mcpplibs::mwrap::mimalloc::mi_stats_init(&stats);
    check(mi_stats_get(&stats) && stats.size == sizeof stats, "the process's statistics are read");

    std::println("-- failures: {} --", failures);
    return failures == 0 ? 0 : 1;
}
