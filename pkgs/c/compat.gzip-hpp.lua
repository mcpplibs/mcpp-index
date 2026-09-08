-- compat.gzip-hpp — Mapbox's header-only C++ wrapper over zlib's gzip/deflate.
--
-- Shape B over `*/include` (`#include <gzip/compress.hpp>`), with the one
-- thing that makes it not purely header-only from a BUILD point of view: every
-- header here opens `#include <zlib.h>` and every function it defines calls
-- into zlib, so the package carries a real dependency even though it compiles
-- nothing of its own. `compat.zlib` supplies both the header and the symbols;
-- without the dep a consumer gets "zlib.h: No such file or directory" at the
-- first include rather than anything about this package.
--
-- The library is small and frozen — v0.1.0 is from 2019 and upstream has not
-- moved since. That is a reason to be explicit rather than a reason to skip
-- it: what it wraps (zlib's `deflate`/`inflate` with a gzip header) has not
-- moved either, and the alternative for a consumer is hand-rolling the same
-- 60 lines of stream setup.
--
-- ⚠️ AND IT IS FROZEN AT A POINT WHERE IT NO LONGER COMPILES. `utils.hpp`
-- names `uint8_t` six times and `decompress.hpp` once, while neither includes
-- `<cstdint>` — they rode on a transitive include that libstdc++ used to
-- provide and no longer does:
--
--     include/gzip/utils.hpp:14:32: error: 'uint8_t' does not name a type
--
-- Measured here on gcc 16.1.0, and it is a CONSUMER-side failure: this package
-- compiles nothing of its own, so `cxxflags = {"-include", "cstdint"}` — the
-- repair `compat.redis-plus-plus` uses — cannot reach the translation unit
-- that breaks. A descriptor has exactly one lever that does: put a shim of the
-- same header name FIRST on the include path and let it reach upstream's with
-- `#include_next`, the same move `compat.catch2` makes for its `<new>` defect.
--
-- Two shims rather than one, because the two entry points are independent:
-- `decompress.hpp` opens `<gzip/config.hpp>` so shimming that covers it (and
-- `compress.hpp`), while `utils.hpp` includes only `<cstdlib>` and has to be
-- shimmed directly. `include_dirs` therefore lists `mcpp_generated` BEFORE
-- `*/include`; reversing those two lines silently disables both shims.
--
-- CN mirror: `gitcode.com/mcpp-res/gzip-hpp`, the upstream tarball re-hosted
-- BYTE-IDENTICALLY (verified: the mirror's sha256 equals the one declared
-- here, which is what lets one `sha256` serve both arms). GLOBAL stays the
-- default; CN is the fallback `mcpp self config --mirror CN` selects.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "gzip-hpp",
    description = "gzip-hpp — header-only gzip/deflate compression wrappers over zlib",
    licenses    = {"BSD-2-Clause"},
    repo        = "https://github.com/mapbox/gzip-hpp",
    type        = "package",

    xpm = {
        linux = {
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mapbox/gzip-hpp/archive/refs/tags/v0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/gzip-hpp/releases/download/0.1.0/gzip-hpp-0.1.0.tar.gz",
                },
                sha256 = "7ce3908cd13f186987820be97083fc5e62a7c6df0877af44b334a92e868eff06",
            },
        },
        macosx = {
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mapbox/gzip-hpp/archive/refs/tags/v0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/gzip-hpp/releases/download/0.1.0/gzip-hpp-0.1.0.tar.gz",
                },
                sha256 = "7ce3908cd13f186987820be97083fc5e62a7c6df0877af44b334a92e868eff06",
            },
        },
        windows = {
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mapbox/gzip-hpp/archive/refs/tags/v0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/gzip-hpp/releases/download/0.1.0/gzip-hpp-0.1.0.tar.gz",
                },
                sha256 = "7ce3908cd13f186987820be97083fc5e62a7c6df0877af44b334a92e868eff06",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        -- ORDER MATTERS: mcpp_generated first, so the shims below are found
        -- before upstream's own headers, which they then reach with
        -- #include_next.
        include_dirs = { "mcpp_generated", "*/include" },
        generated_files = {
            ["mcpp_generated/gzip_hpp_anchor.c"] =
                "int mcpp_compat_gzip_hpp_anchor(void) { return 0; }\n",
            -- <cstdint> for `uint8_t` in decompress.hpp, which reaches this
            -- file as its first include.
            ["mcpp_generated/gzip/config.hpp"] = [==[
// mcpp-index shim: upstream gzip-hpp 0.1.0 names uint8_t without including
// <cstdint>. See the descriptor header for why this cannot be a -include flag.
#ifndef MCPP_COMPAT_GZIP_HPP_CONFIG_SHIM
#define MCPP_COMPAT_GZIP_HPP_CONFIG_SHIM
#include <cstdint>
#include_next <gzip/config.hpp>
#endif
]==],
            -- utils.hpp includes only <cstdlib> and is a consumer entry point
            -- in its own right, so it needs its own shim.
            ["mcpp_generated/gzip/utils.hpp"] = [==[
// mcpp-index shim: see mcpp_generated/gzip/config.hpp.
#ifndef MCPP_COMPAT_GZIP_HPP_UTILS_SHIM
#define MCPP_COMPAT_GZIP_HPP_UTILS_SHIM
#include <cstdint>
#include_next <gzip/utils.hpp>
#endif
]==],
        },
        sources      = { "mcpp_generated/gzip_hpp_anchor.c" },
        targets      = { ["gzip_hpp"] = { kind = "lib" } },
        deps         = { ["compat.zlib"] = "1.3.2" },
    },
}
