-- Form B inline descriptor for CLI11 — a modern C++ command line parser.
--
-- CLI11 is HEADER-ONLY in its default mode: every definition under
-- `include/CLI/` is marked `CLI11_INLINE`, and `CLI/CLI.hpp` pulls the
-- implementation headers under `include/CLI/impl/` in behind it. There is
-- nothing to compile for normal use, so this package exposes the header root
-- on the include path and carries a tiny anchor translation unit so mcpp
-- always has a buildable `lib` target (same shape as compat.eigen /
-- compat.opengl).
--
-- Consumers write:
--
--     #include <CLI/CLI.hpp>
--
-- and need no feature or extra configuration.
--
-- All `mcpp` paths are GLOBS relative to the verdir, so the leading `*`
-- absorbs the GitHub archive's `CLI11-<tag>/` wrap layer: the header root is
-- `*/include`, NOT `include`.
--
-- Two upstream extras are deliberately NOT packaged here:
--
--   * `src/Precompile.cpp` — upstream's precompiled mode. It only does
--     anything when `CLI11_COMPILE` is defined, and that define has to reach
--     the CONSUMER's translation units as well (otherwise the headers keep
--     their inline definitions and the compiled ones are dead weight). That
--     makes it an interface define, not a sources-only gate, so it is left
--     out rather than half-expressed.
--   * `src/modules/CLI11.cppm` — upstream's C++20 module interface. A module
--     layer is a separate package shape (see pkgs/n/nlohmann.json.lua), not a
--     feature of the compat package.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "CLI11",
    description = "Modern C++ command line parser (header-only)",
    licenses    = { "BSD-3-Clause" },
    repo        = "https://github.com/CLIUtils/CLI11",
    type        = "package",

    -- Pure headers: one archive and one sha256 serve all three platforms.
    xpm = {
        linux = {
            ["2.7.2"] = {
                url = {
                    GLOBAL = "https://github.com/CLIUtils/CLI11/archive/refs/tags/v2.7.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/cli11/releases/download/2.7.2/cli11-2.7.2.tar.gz",
                },
                sha256 = "46eef3101da70852ec7af026e09d485ccee81813331c8c6052d39344443b83da",
            },
        },

        macosx = {
            ["2.7.2"] = {
                url = {
                    GLOBAL = "https://github.com/CLIUtils/CLI11/archive/refs/tags/v2.7.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/cli11/releases/download/2.7.2/cli11-2.7.2.tar.gz",
                },
                sha256 = "46eef3101da70852ec7af026e09d485ccee81813331c8c6052d39344443b83da",
            },
        },

        windows = {
            ["2.7.2"] = {
                url = {
                    GLOBAL = "https://github.com/CLIUtils/CLI11/archive/refs/tags/v2.7.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/cli11/releases/download/2.7.2/cli11-2.7.2.tar.gz",
                },
                sha256 = "46eef3101da70852ec7af026e09d485ccee81813331c8c6052d39344443b83da",
            },
        },
    },

    mcpp = {
        -- Applies to this package's OWN translation unit (the anchor below);
        -- a consumer compiles the headers at whatever standard it declares,
        -- and CLI11 itself needs only C++11. Kept at c++23 like every other
        -- descriptor in this index.
        language     = "c++23",
        import_std   = false,
        -- Upstream headers live in `include/CLI/`, so the include ROOT is
        -- `include/` — that is what makes `#include <CLI/CLI.hpp>` resolve.
        include_dirs = { "*/include" },
        -- Header-only: a trivial anchor TU gives mcpp a buildable lib target.
        -- The basename is unique across the index on purpose — mcpp's obj/
        -- directory is flat and keyed by basename.
        generated_files = {
            ["mcpp_generated/cli11_anchor.cpp"] = [==[
int mcpp_compat_cli11_headers_anchor(void) {
    return 0;
}
]==],
        },
        sources      = { "mcpp_generated/cli11_anchor.cpp" },
        targets      = { ["CLI11"] = { kind = "lib" } },
        deps         = { },
    },
}
