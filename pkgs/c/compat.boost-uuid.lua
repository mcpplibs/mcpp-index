-- Form B inline descriptor for Boost.UUID 1.92.0 — RFC 4122/9562 UUIDs:
-- random (v4), name (SHA1/MD5 v5), time (v1/v6/v7) generators, string
-- round-trip, std::hash. Header-only since forever — the historical
-- src/sha1.cpp is long gone; sha1/md5/chacha20 live inline under detail/.
-- Part of the modular-boost header family; see compat.boost-config for the
-- family wiring and version-train policy.
--
-- Header references (verified by grep across the include tree, matching
-- upstream CMakeLists' INTERFACE line): boost/assert, boost/config,
-- boost/throw_exception, boost/type_traits — all packaged in this index as
-- compat.boost-{assert,config,throw-exception,type-traits}; everything else
-- stays inside boost/uuid/. The closure is exactly these four deps.
--
-- One upstream CMake wrinkle deliberately NOT carried over:
-- BOOST_UUID_LINK_LIBATOMIC adds -latomic as an INTERFACE link requirement on
-- GCC / non-Windows non-Apple Clang for the uint128 paths. Our consumer test
-- exercises the standard v4/name/string surface without it; add a linux
-- ldflags entry here only if a future member actually links 128-bit paths.
--
-- SIMD dispatch (SSE2..AVX10 via uuid_x86/generic .ipp) is auto-detected from
-- compiler/arch macros — no flags needed; BOOST_UUID_NO_SIMD is the escape
-- hatch if a toolchain ever misreports.
--
-- Header-only, traditional `#include` consumption; no CN mirror yet; BSL-1.0.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "boost-uuid",
    description = "Boost.UUID 1.92.0 — RFC 4122/9562 UUID generation and parsing",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/boostorg/uuid",
    type        = "package",

    xpm = {
        linux = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/uuid/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "a5fca6d0499b7e47e7bbdf59afb1aaf6876d7788b27c3c6b2bbacfc795234e35",
            },
        },
        macosx = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/uuid/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "a5fca6d0499b7e47e7bbdf59afb1aaf6876d7788b27c3c6b2bbacfc795234e35",
            },
        },
        windows = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/uuid/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "a5fca6d0499b7e47e7bbdf59afb1aaf6876d7788b27c3c6b2bbacfc795234e35",
            },
        },
    },

    mcpp = {
        language     = "c++20",
        import_std   = false,
        include_dirs = { "*/include" },   -- exposes boost/uuid/* (+ boost/uuid.hpp shim)
        generated_files = {
            ["mcpp_generated/boost_uuid_anchor.cpp"] = [==[
int mcpp_compat_boost_uuid_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/boost_uuid_anchor.cpp" },
        targets      = { ["boost_uuid"] = { kind = "lib" } },
        deps         = {
            ["compat.boost-assert"]          = "1.92.0",
            ["compat.boost-config"]          = "1.92.0",
            ["compat.boost-throw-exception"] = "1.92.0",
            ["compat.boost-type-traits"]     = "1.92.0",
        },
    },
}
