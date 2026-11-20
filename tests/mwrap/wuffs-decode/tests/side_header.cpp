// The side header before the import: the header's entities are the module's,
// its macros work beside it, and an adapted helper is the header's function.
#include <mwrap/wuffs/macros.hpp>

#include <cstdio>
#include <cstdlib>
#include <type_traits>

import mcpplibs.mwrap.wuffs;

static_assert(std::is_same_v<decltype(&mcpplibs::mwrap::wuffs::wuffs_base__make_slice_u8),
                             decltype(&::wuffs_base__make_slice_u8)>);
static_assert(WUFFS_VERSION_MAJOR == 0 && WUFFS_VERSION_MINOR == 3);

int main() {
    std::uint8_t bytes[3] = {1, 2, 3};
    wuffs_base__slice_u8 a = ::wuffs_base__make_slice_u8(bytes, 3);                         // the header's
    wuffs_base__slice_u8 b = mcpplibs::mwrap::wuffs::wuffs_base__make_slice_u8(bytes, 3);   // the module's
    wuffs_crc32__ieee_hasher* hasher = wuffs_crc32__ieee_hasher__alloc();  // the header's declaration, the library's definition
    bool ok = a.ptr == b.ptr && a.len == b.len && hasher != nullptr;
    std::free(hasher);
    std::puts(ok ? "side header and module agree" : "FAIL");
    return ok ? 0 : 1;
}
