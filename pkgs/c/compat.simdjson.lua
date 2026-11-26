local versions = {
    ["5.3.0"] = {
        url    = "https://github.com/simdjson/simdjson/archive/refs/tags/v5.3.0.tar.gz",
        sha256 = "5e59df8bd3fa760937e6a2ca68193399c85b52b5042716700b149a734737dced",
    },
}

-- compat.simdjson — Parsing gigabytes of JSON per second.
-- Uses upstream's official singleheader amalgamation (`singleheader/simdjson.h`
-- and `singleheader/simdjson.cpp`) so `include_dirs` exposes only `<simdjson.h>`
-- without leaking internal `src/` headers.
--
-- Features:
--   `default` implies `threads` (defines `SIMDJSON_THREADS_ENABLED=1` for both
--   `simdjson.cpp` and consumers, matching upstream CMake's `SIMDJSON_ENABLE_THREADS=ON`
--   and keeping `dom::parser` / `stage1_worker` layout ODR-consistent across TUs).
--   Consumers passing `default-features = false` omit `SIMDJSON_THREADS_ENABLED=1`.
--
-- All `mcpp` paths are GLOBS relative to the verdir; the leading `*/`
-- absorbs the GitHub tarball's `simdjson-<ver>/` wrap layer.
-- Plain upstream URLs are used here because no local gitcode `mcpp-res`
-- credentials are available; CN mirrors can be added by maintainers later.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "simdjson",
    description = "Parsing gigabytes of JSON per second — SIMD-accelerated C++ JSON parser",
    licenses    = {"Apache-2.0", "MIT"},
    repo        = "https://github.com/simdjson/simdjson",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/simdjson/simdjson/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux   = { ["5.3.0"] = versions["5.3.0"] },
        macosx  = { ["5.3.0"] = versions["5.3.0"] },
        windows = { ["5.3.0"] = versions["5.3.0"] },
    },

    mcpp = {
        language      = "c++23",
        import_std    = false,
        license_files = { "*/LICENSE", "*/LICENSE-MIT" },
        include_dirs  = { "*/singleheader" },
        sources       = { "*/singleheader/simdjson.cpp" },
        targets       = { ["simdjson"] = { kind = "lib" } },
        deps          = {},

        features = {
            ["default"] = {
                implies = { "threads" },
            },
            ["threads"] = {
                defines = { "SIMDJSON_THREADS_ENABLED=1" },
            },
        },

        linux = {
            ldflags = { "-lpthread" },
        },
    },
}
