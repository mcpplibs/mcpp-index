-- compat.redis-plus-plus — redis-plus-plus 1.3.13, C++ client for Redis.
--
-- Shape A (C++-source compat) with one small Shape-E trait: the single header
-- upstream's CMake would generate (hiredis_features.h) is snapshotted through
-- generated_files — exactly like compat.curl's curl_config.h. The base build
-- is the SYNC client only (17 TUs from upstream CMake's
-- `REDIS_PLUS_PLUS_SOURCES` plus patterns/redlock.cpp); async (libuv) and TLS
-- (OpenSSL) TUs are not compiled, so this package has exactly one dependency:
-- compat.hiredis.
--
-- INCLUDE LAYOUT mirrors upstream's own target_include_directories:
--   */src                      -> `#include <sw/redis++/redis++.h>`
--   */src/sw/redis++/cxx17     -> `sw/redis++/cxx_utils.h` (the C++17 variant,
--                                  selected because mcpp compiles C++23)
--   */src/sw/redis++/no_tls    -> `sw/redis++/tls.h` (upstream's no-op TLS stub)
--   mcpp_generated             -> the generated hiredis_features.h
-- The compat.hiredis dependency's include dirs propagate, so
-- `<hiredis/hiredis.h>` resolves through its `hiredis/` wrapper headers.
--
-- generated_files snapshot: connection.h includes
-- `sw/redis++/hiredis_features.h`, which upstream produces via
-- configure_file(hiredis_features.h.in). hiredis 1.2.0 HAS
-- redisEnableKeepAliveWithInterval, so the define is on.
--
-- VERSION / MULTI-VERSION UNION. Two versions today, one on each side of the
-- source-structure watershed:
--   * 1.3.13 (2024-10) — the classic stable release, long-standing vcpkg/conan
--     default before the 2025 releases; 1.3.6+ all share this exact source list
--     (diffed against 1.3.15: identical .cpp set), so 1.3.14/1.3.15 later are
--     just new xpm rows.
--   * 1.3.3 (2021-12) — the pre-watershed structure: 15 sync TUs (it lacks
--     redis_uri.cpp and patterns/redlock.cpp, both added in 1.3.6+), no
--     hiredis_features.h (connection.h never includes it, so the generated
--     header is simply unused), and its no_tls stub is FLAT (no_tls/tls.h,
--     included as "tls.h") instead of namespaced.
-- One mcpp block serves both because the two layouts are a SUBSET/SUPERSET
-- pair (same trick as compat.catch2's disjoint union, but simpler): the source
-- list below is 1.3.13's 17 TUs, and for 1.3.3 exactly two globs match nothing
-- (redis_uri.cpp, patterns/redlock.cpp) — a zero-hit glob is a warning, not an
-- error. Re-check the table when adding a version (mcpp-community/mcpp#290 is
-- the long-term per-version build blocks that removes this assumption).
--
-- No CN mirror yet: plain-string upstream URL (see compat.hiredis).
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "redis-plus-plus",
    description = "C++ client for Redis (sync API; built from source, depends on compat.hiredis)",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/sewenew/redis-plus-plus",
    type        = "package",

    xpm = {
        linux = {
            ["1.3.3"] = {
                url    = "https://github.com/sewenew/redis-plus-plus/archive/refs/tags/1.3.3.tar.gz",
                sha256 = "23689059b7ba50fcd8fa673c5dbb7bdb010b896b14abad5aa80a5ec48eb64f26",
            },
            ["1.3.13"] = {
                url    = "https://github.com/sewenew/redis-plus-plus/archive/refs/tags/1.3.13.tar.gz",
                sha256 = "678a61898ed72f0c692102c7ce103a1bcae1e6ff85a4ad03e6002c1ba8fe1e08",
            },
        },
        macosx = {
            ["1.3.3"] = {
                url    = "https://github.com/sewenew/redis-plus-plus/archive/refs/tags/1.3.3.tar.gz",
                sha256 = "23689059b7ba50fcd8fa673c5dbb7bdb010b896b14abad5aa80a5ec48eb64f26",
            },
            ["1.3.13"] = {
                url    = "https://github.com/sewenew/redis-plus-plus/archive/refs/tags/1.3.13.tar.gz",
                sha256 = "678a61898ed72f0c692102c7ce103a1bcae1e6ff85a4ad03e6002c1ba8fe1e08",
            },
        },
        windows = {
            ["1.3.3"] = {
                url    = "https://github.com/sewenew/redis-plus-plus/archive/refs/tags/1.3.3.tar.gz",
                sha256 = "23689059b7ba50fcd8fa673c5dbb7bdb010b896b14abad5aa80a5ec48eb64f26",
            },
            ["1.3.13"] = {
                url    = "https://github.com/sewenew/redis-plus-plus/archive/refs/tags/1.3.13.tar.gz",
                sha256 = "678a61898ed72f0c692102c7ce103a1bcae1e6ff85a4ad03e6002c1ba8fe1e08",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,

        include_dirs = {
            "*/src",
            "*/src/sw/redis++/cxx17",
            "*/src/sw/redis++/no_tls",
            "mcpp_generated",
        },

        -- Upstream CMake `REDIS_PLUS_PLUS_SOURCES` (sync core) +
        -- patterns/redlock.cpp. async_*.cpp / event_loop.cpp /
        -- tls/sw/redis++/tls.cpp are intentionally absent — they need
        -- libuv / OpenSSL, which this base build does not pull in.
        sources = {
            "*/src/sw/redis++/command.cpp",
            "*/src/sw/redis++/command_options.cpp",
            "*/src/sw/redis++/connection.cpp",
            "*/src/sw/redis++/connection_pool.cpp",
            "*/src/sw/redis++/crc16.cpp",
            "*/src/sw/redis++/errors.cpp",
            "*/src/sw/redis++/pipeline.cpp",
            "*/src/sw/redis++/redis.cpp",
            "*/src/sw/redis++/redis_cluster.cpp",
            "*/src/sw/redis++/redis_uri.cpp",
            "*/src/sw/redis++/reply.cpp",
            "*/src/sw/redis++/sentinel.cpp",
            "*/src/sw/redis++/shards.cpp",
            "*/src/sw/redis++/shards_pool.cpp",
            "*/src/sw/redis++/subscriber.cpp",
            "*/src/sw/redis++/transaction.cpp",
            "*/src/sw/redis++/patterns/redlock.cpp",
        },

        targets = { ["redis_plus_plus"] = { kind = "lib" } },
        deps    = { ["compat.hiredis"] = "1.2.0" },

        generated_files = {
            ["mcpp_generated/sw/redis++/hiredis_features.h"] = "#define REDIS_PLUS_PLUS_HAS_redisEnableKeepAliveWithInterval\n",
        },

        -- 1.3.3's utils.h declares `uint16_t crc16(...)` WITHOUT including
        -- <cstdint> (upstream added the include in 1.3.6+). clang's libc++
        -- pulls it in transitively, but the vendored gcc/libstdc++ sysroot
        -- does not, so the 1.3.3 build fails with "'uint16_t' does not name a
        -- type" on the linux-default (gcc) CI leg. -include cstdint forces the
        -- header into every C++ TU; harmless for 1.3.13 (which includes it
        -- itself). Recipe repair with CI regression evidence (PR #188).
        cxxflags = { "-include", "cstdint" },

        windows = {
            -- Upstream CMake adds NOMINMAX to its static-lib target on WIN32;
            -- ws2_32 arrives through compat.hiredis' propagated ldflags.
            cxxflags = { "-DNOMINMAX" },
        },
    },
}
