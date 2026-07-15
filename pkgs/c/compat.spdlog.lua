-- Form B inline descriptor for spdlog — a very fast, header-only / compiled C++
-- logging library. spdlog is DUAL-MODAL and this recipe exposes both modes off
-- one descriptor:
--
--   * DEFAULT (header-only). No feature requested. spdlog's headers are
--     self-contained: including <spdlog/spdlog.h> pulls the -inl.h
--     implementation inline (common.h flips on SPDLOG_HEADER_ONLY when
--     SPDLOG_COMPILED_LIB is NOT defined). Nothing under src/ compiles; a tiny
--     anchor TU gives mcpp a buildable `lib` target (same shape as
--     compat.eigen / compat.opengl). The bundled {fmt} (include/spdlog/fmt/
--     bundled/) is used in FMT_HEADER_ONLY mode, so this package is
--     self-contained and needs NO external fmt dependency.
--
--   * COMPILED (`features = ["compiled"]`). Turns spdlog into a precompiled
--     library: (1) compiles the seven src/*.cpp translation units into the lib,
--     and (2) contributes the SPDLOG_COMPILED_LIB define. That define is an
--     INTERFACE define — it must reach BOTH spdlog's own sources (each src/*.cpp
--     #errors out without it) AND every consumer TU that includes a spdlog
--     header (so the consumer's headers switch to the extern-template /
--     non-inline path and link against the compiled objects instead of
--     re-emitting the implementation inline). bundled_fmtlib_format.cpp compiles
--     the bundled fmt implementation into the lib, so compiled mode is
--     self-contained too — still NO external fmt dependency.
--
--     REQUIRES mcpp >= 0.0.94 under `mcpp test`. mcpp 0.0.93 and older gated the
--     whole feature-source resolution on build mode, so an active feature's
--     `sources` were never compiled under `mcpp test` → link-time `undefined
--     reference` (`mcpp build` was always fine). Fixed in mcpp 0.0.94; the same
--     bug is what compat.cjson's `utils` and compat.eigen's `eigen_blas`
--     (`dgemm_`) hit. Header-only mode is unaffected and works on any version,
--     which is why the index floor (`index.toml` min_mcpp) does not move: that
--     floor tracks descriptor GRAMMAR, and this descriptor parses everywhere.
--
-- All `mcpp` paths are GLOBS relative to the verdir; the leading `*` absorbs the
-- GitHub archive's `spdlog-<tag>/` wrap layer. include_dirs points at
-- `*/include` so consumers write `#include <spdlog/spdlog.h>`.
--
-- No CN mirror yet: `url` is a plain string (upstream GitHub release only), the
-- documented fallback when there is no mcpp-res write access (docs/cn-mirror.md;
-- precedent: pkgs/t/tensorvia-cpu.lua). CN users fall back to the upstream
-- source. A maintainer can later rewrite each `url` to a { GLOBAL, CN } table
-- (sha256 unchanged) once the gitcode mcpp-res/spdlog mirror exists.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "compat.spdlog",
    description = "Fast C++ logging library (header-only by default, compiled via the `compiled` feature)",
    licenses    = {"MIT"},
    repo        = "https://github.com/gabime/spdlog",
    type        = "package",

    xpm = {
        linux = {
            ["1.17.0"] = {
                url    = "https://github.com/gabime/spdlog/archive/refs/tags/v1.17.0.tar.gz",
                sha256 = "d8862955c6d74e5846b3f580b1605d2428b11d97a410d86e2fb13e857cd3a744",
            },
        },
        macosx = {
            ["1.17.0"] = {
                url    = "https://github.com/gabime/spdlog/archive/refs/tags/v1.17.0.tar.gz",
                sha256 = "d8862955c6d74e5846b3f580b1605d2428b11d97a410d86e2fb13e857cd3a744",
            },
        },
        windows = {
            ["1.17.0"] = {
                url    = "https://github.com/gabime/spdlog/archive/refs/tags/v1.17.0.tar.gz",
                sha256 = "d8862955c6d74e5846b3f580b1605d2428b11d97a410d86e2fb13e857cd3a744",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        -- Exposes include/spdlog/** so consumers write `#include <spdlog/...>`.
        -- The bundled fmt under include/spdlog/fmt/bundled/ rides along, so no
        -- external fmt dependency is needed in either mode.
        include_dirs = { "*/include" },
        -- Header-only default: a trivial anchor TU gives mcpp a buildable lib
        -- target when no source is compiled.
        generated_files = {
            ["mcpp_generated/spdlog_anchor.c"] = [==[
int mcpp_compat_spdlog_headers_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/spdlog_anchor.c" },
        targets      = { ["spdlog"] = { kind = "lib" } },
        features     = {
            -- Precompiled mode: compiles spdlog's src/*.cpp into the lib AND
            -- publishes SPDLOG_COMPILED_LIB as an interface define so consumer
            -- headers take the non-inline / extern-template path. src/spdlog.cpp
            -- (and the other six) #error without this define. Needs mcpp >=
            -- 0.0.94 under `mcpp test` — see the header note.
            ["compiled"] = {
                sources = { "*/src/*.cpp" },
                defines = { "SPDLOG_COMPILED_LIB" },
            },
        },
        deps         = { },
    },
}
