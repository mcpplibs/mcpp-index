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
--   * COMPILED (`features = ["compiled"]`). Requesting the `compiled` feature
--     is INTENDED to turn spdlog into a precompiled library: (1) compile the
--     seven src/*.cpp translation units into the lib, and (2) contribute the
--     SPDLOG_COMPILED_LIB define. That define is an INTERFACE define — it must
--     reach BOTH spdlog's own sources (each src/*.cpp #errors out without it)
--     AND every consumer TU that includes a spdlog header (so the consumer's
--     headers switch to the extern-template / non-inline path and link against
--     the compiled objects instead of re-emitting the implementation inline).
--
--     CURRENT ENGINE LIMITATION (mcpp 0.0.91): a dependency's feature-gated
--     `sources` are NOT compiled — only the package's top-level `sources` (the
--     anchor here) and the feature's `defines` take effect. Verified three ways
--     on 0.0.91: this package's `compiled`, compat.cjson's `utils`
--     (cJSON_Utils.c), and compat.eigen's `eigen_blas` (blas/*.cpp) all leave
--     their feature sources uncompiled → link-time `undefined reference`. So
--     with `features=["compiled"]` today the SPDLOG_COMPILED_LIB define DOES
--     reach the consumer (proven: -DSPDLOG_COMPILED_LIB on the consumer TU) but
--     src/*.cpp is not built, so the non-inline symbols do not link. This is the
--     same follow-up compat.eigen's eigen_blas is waiting on ("linking
--     feature-built dependency objects into test binaries is a follow-up"). The
--     recipe declares the correct intent so it works unchanged once mcpp
--     compiles+links feature sources; until then, use the DEFAULT header-only
--     mode (fully working). bundled_fmtlib_format.cpp would compile the bundled
--     fmt implementation into the lib, so compiled mode is likewise
--     self-contained (no external fmt) once the engine supports it.
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
            -- Precompiled mode (declarative intent — see the header's CURRENT
            -- ENGINE LIMITATION note). Meant to compile spdlog's src/*.cpp into
            -- the lib AND publish SPDLOG_COMPILED_LIB as an interface define so
            -- consumer headers take the non-inline / extern-template path.
            -- src/spdlog.cpp (and the other six) #error without this define. On
            -- mcpp 0.0.91 the `defines` DO propagate to the consumer but the
            -- feature `sources` are not yet compiled (same follow-up as
            -- compat.eigen's eigen_blas), so use the default header-only mode
            -- until the engine builds+links feature sources.
            ["compiled"] = {
                sources = { "*/src/*.cpp" },
                defines = { "SPDLOG_COMPILED_LIB" },
            },
        },
        deps         = { },
    },
}
