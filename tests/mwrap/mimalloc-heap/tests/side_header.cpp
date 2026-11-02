// The side header from the installed package, beside the import: the typed
// macros with the module's entities, one allocator under both spellings.
#include <mwrap/mimalloc/macros.hpp>

import std;
import mcpplibs.mwrap.mimalloc;

struct pair { long a, b; };

int main() {
    pair* p = mi_malloc_tp(pair);
    if (!p) return 1;
    p->a = 20; p->b = 22;
    const long sum = p->a + p->b;
    mi_free_tp(pair, p);
    pair* many = mi_mallocn_tp(pair, 64);
    if (!many || mi_usable_size(many) < 64 * sizeof(pair)) return 2;
    mi_free(many);
    mi_stats_t_decl(stats);
    if (static_cast<int>(stats.version) != mcpplibs::mwrap::mimalloc::macros::MI_STAT_VERSION) return 3;
    return sum == 42 ? 0 : 4;
}
