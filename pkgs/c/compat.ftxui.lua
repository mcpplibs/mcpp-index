-- M6.x glob-aware Form B descriptor for FTXUI 6.1.9 and 7.0.3.
--
-- Compiled sources + public headers by default; 7.0.3 additionally offers
-- upstream's named modules behind the opt-in `modules` feature (see below).
-- Uses mcpp 0.0.4's glob exclusion (`!` prefix) to skip the
-- *_test.cpp / *_fuzzer.cpp files that live alongside the library
-- sources in the same directories (6.1.9: ~30 test / ~16 fuzzer;
-- 7.0.3: 47 test / 6 fuzzer).
--
-- 7.0.3: source layout is unchanged (include/ftxui + src/ftxui/{screen,dom,
-- component,util}), so the 6.1.9 globs apply verbatim, and the public header
-- API this index's smoke test uses (hbox/text/separator, `Dimension::Fit`,
-- `Screen::Create(Dimensions, Dimensions)`, `Render`) is source-compatible
-- with 6.1.9. Upstream added C++20 module units (src/ftxui/*.cppm,
-- FTXUI_BUILD_MODULES, off by default); the `*.cpp` globs never match them,
-- and the plain .cpp sources still compile header-only style.
--
-- The `modules` feature (7.0.3+)
-- ------------------------------
-- 7.x ships upstream's own named modules — an `ftxui` umbrella that
-- `export import`s four sub-modules (ftxui.component/.dom/.screen/.util),
-- each of which textually includes the matching public headers in its global
-- module fragment. `features.modules` adds exactly the five files upstream's
-- cmake/ftxui_modules.cmake lists, so `import ftxui;` becomes available
-- without touching the header surface: the module units carry no definitions
-- of their own (they are `export namespace ftxui { using ... }` re-exports),
-- so they layer ON TOP of the same libftxui.a the default build produces.
-- Both surfaces coexist in one archive; a consumer picks either.
--
-- OFF BY DEFAULT — but NOT because the units fail to build. They build and
-- run under gcc 16.1.0 and llvm 22.1.8 alike, verified on the mcpp version CI
-- pins. The reason is cost and choice: the module surface is five extra TUs
-- and their BMIs that no header consumer of 7.0.3 should pay for unasked,
-- upstream itself defaults FTXUI_BUILD_MODULES to OFF, and there is a
-- consumer-side constraint below that only the consumer can honour.
--
-- ⚠️ THE CONSTRAINT IS IN THE CONSUMER'S TU, NOT IN THIS PACKAGE, AND #292
-- IS WHY IT IS WORTH SPELLING OUT. Because each sub-module puts the public
-- headers — and transitively libstdc++ — into a global module fragment, a
-- consumer TU that writes `import ftxui;` and ALSO textually `#include`s a
-- standard header hands gcc two copies of the standard library's
-- declarations. gcc 16 refuses, at volume:
--
--     c++config.h:355:15: error: redefinition of 'void std::__terminate()'
--     memoryfwd.h:68:11:  error: conflicting declaration of template
--                                'template<class> struct std::allocator'
--     stringfwd.h:55:12:  error: conflicting declaration of template
--                                'template<class _CharT> struct std::char_traits'
--
-- That is exactly what sank #292's first attempt at this. Its smoke TU wrote
-- `import ftxui;` above `#include <string>` and `#include <gtest/gtest.h>`,
-- and the linux gcc leg died on those three errors (and ~16k more) while
-- llvm, macOS and windows stayed green — clang accepts the mixed TU. The one
-- object that failed in that run was the smoke TU's own (`obj/module.o`); the
-- package's five module units had already compiled.
--
-- A consumer that stays ON the module surface — `import std;` beside
-- `import ftxui;`, no textual includes, the discipline tests/examples/
-- asio-module already documents — builds clean on both compilers. That is
-- what tests/examples/ftxui-module asserts, and it is why that member can run
-- on both of CI's linux legs rather than needing a toolchain pin.
--
-- Upstream's own module CI is llvm-only (`test_modules` in
-- .github/workflows/build.yaml: a one-entry ubuntu + llvm matrix carrying
-- `# TODO add gcc / msvc`), and ftxui_modules.cmake still forces
-- `-fmodules-ts` under CMAKE_COMPILER_IS_GNUCXX above a bare
-- `# TODO: Explain why this is needed.`. So gcc is UNTESTED upstream — worth
-- knowing before trusting the combination far — but, as measured here, it is
-- not broken.
--
-- On 6.1.9 the feature's glob matches nothing (no .cppm before 7.0.0), which
-- is a warning rather than an error — the same union-of-layouts tolerance
-- compat.catch2 and compat.redis-plus-plus rely on. `modules` below is the
-- declared export set, in the same spelling every other module package in
-- this index uses. Note what it does NOT buy here: mcpp validates
-- `[modules].exports` against the scanner only for the PRIMARY manifest of a
-- build, so a DEPENDENCY's list is never checked — measured by deleting
-- `ftxui.util` from it and rebuilding with the package cache bypassed, which
-- built and passed. It is documentation and metadata, not a guard.
--
-- ONE version skew the globs cannot express (no per-version build blocks,
-- mcpp-community/mcpp#290): FTXUI 7 moved Loop's method definitions from
-- loop.cpp into app.cpp and dropped loop.cpp from the CMake build, but the
-- stale file still ships in the 7.0.3 tarball. Compiling both duplicates
-- `Loop::{~Loop,RunOnce,...}` at the consumer's link (a dependency's objects
-- ALL enter the link — no lazy archive selection). 6.1.9 has no app.cpp and
-- genuinely needs loop.cpp. The install() hook below deletes loop.cpp only
-- when app.cpp exists, i.e. exactly on the 7.x layout.
--
-- Produces a single static archive `libftxui.a` covering all three
-- upstream cmake targets (ftxui-screen, ftxui-dom, ftxui-component).

package = {
    spec        = "1",
    namespace = "compat",
    name        = "ftxui",
    description = "C++ Functional Terminal User Interface (screen + dom + component)",
    licenses    = {"MIT"},
    repo        = "https://github.com/ArthurSonzogni/FTXUI",
    type        = "package",

    xpm = {
        linux = {
            ["6.1.9"] = {
                url    = {
                    GLOBAL = "https://github.com/ArthurSonzogni/FTXUI/archive/refs/tags/v6.1.9.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/ftxui/releases/download/6.1.9/ftxui-6.1.9.tar.gz",
                },
                sha256 = "45819c1e54914783d4a1ca5633885035d74146778a1f74e1213cdb7b76340e71",
            },
            -- 7.0.3 has no CN mirror yet (never published to mcpp-res);
            -- plain-string GLOBAL fallback. Flip to { GLOBAL, CN } if it gets
            -- mirrored — sha256 stays the same.
            ["7.0.3"] = {
                url    = "https://github.com/ArthurSonzogni/FTXUI/archive/refs/tags/v7.0.3.tar.gz",
                sha256 = "e7c62ffe19009759821b4f0f8df7f2a6fb83784c3a9f1477d81f56d3ee723c88",
            },
        },
        macosx = {
            ["6.1.9"] = {
                url    = {
                    GLOBAL = "https://github.com/ArthurSonzogni/FTXUI/archive/refs/tags/v6.1.9.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/ftxui/releases/download/6.1.9/ftxui-6.1.9.tar.gz",
                },
                sha256 = "45819c1e54914783d4a1ca5633885035d74146778a1f74e1213cdb7b76340e71",
            },
            -- 7.0.3 has no CN mirror yet (never published to mcpp-res);
            -- plain-string GLOBAL fallback. Flip to { GLOBAL, CN } if it gets
            -- mirrored — sha256 stays the same.
            ["7.0.3"] = {
                url    = "https://github.com/ArthurSonzogni/FTXUI/archive/refs/tags/v7.0.3.tar.gz",
                sha256 = "e7c62ffe19009759821b4f0f8df7f2a6fb83784c3a9f1477d81f56d3ee723c88",
            },
        },
        windows = {
            ["6.1.9"] = {
                url    = {
                    GLOBAL = "https://github.com/ArthurSonzogni/FTXUI/archive/refs/tags/v6.1.9.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/ftxui/releases/download/6.1.9/ftxui-6.1.9.tar.gz",
                },
                sha256 = "45819c1e54914783d4a1ca5633885035d74146778a1f74e1213cdb7b76340e71",
            },
            -- 7.0.3 has no CN mirror yet (never published to mcpp-res);
            -- plain-string GLOBAL fallback. Flip to { GLOBAL, CN } if it gets
            -- mirrored — sha256 stays the same.
            ["7.0.3"] = {
                url    = "https://github.com/ArthurSonzogni/FTXUI/archive/refs/tags/v7.0.3.tar.gz",
                sha256 = "e7c62ffe19009759821b4f0f8df7f2a6fb83784c3a9f1477d81f56d3ee723c88",
            },
        },
    },

    -- Form B `mcpp` segment: paths are globs relative to the verdir.
    -- The leading `*/` absorbs the GitHub tarball's `FTXUI-<ver>/` wrap.
    mcpp = {
        language     = "c++23",
        import_std   = false,          -- pure compiled lib, no `import std;`
        include_dirs = { "*/include", "*/src" },   -- src/ for private headers (box_helper.hpp etc.),
        sources = {
            "*/src/ftxui/**/*.cpp",
            "!*/src/ftxui/**/*_test.cpp",      -- gtest files (30+ in 6.1.9, 47 in 7.0.3)
            "!*/src/ftxui/**/*_fuzzer.cpp",     -- fuzz targets (16 in 6.1.9, 6 in 7.0.3)
        },
        targets = { ["ftxui"] = { kind = "lib" } },
        -- The export set of the `modules` feature, in the spelling every other
        -- module package in this index uses. Documentation and metadata only:
        -- mcpp checks `[modules].exports` against the scanner for the PRIMARY
        -- manifest of a build, never for a dependency's, so nothing here is
        -- enforced at a consumer's build (measured — see the header comment).
        -- Order follows upstream's ftxui_modules.cmake.
        modules = {
            "ftxui",
            "ftxui.component",
            "ftxui.dom",
            "ftxui.screen",
            "ftxui.util",
        },
        features = {
            -- Upstream's five module units, verbatim from
            -- cmake/ftxui_modules.cmake. `*.cppm` cannot collide with the base
            -- `**/*.cpp` globs (different extension), so this is a pure
            -- ADDITION — no `!` exclusion is involved and the base source set
            -- is untouched whether the feature is on or off. That matters:
            -- a `!` exclusion in mcpp is global and would out-rank a feature
            -- entry naming the same file, so "exclude in base, add back in the
            -- feature" is not an expressible shape.
            --
            -- No `include_dirs` here (features cannot carry them, and none is
            -- needed): the GMF `#include <ftxui/...>` resolve through the
            -- package-level `*/include`, which mcpp applies to the package's
            -- own TUs as well as to consumers.
            --
            -- Consumer-side rule, gcc only: don't mix `import ftxui;` with a
            -- textual `#include` in one TU. See the header comment.
            ["modules"] = {
                sources = { "*/src/ftxui/*.cppm" },
            },
        },
        deps    = { },
        windows = {
            cxxflags = { "-DUNICODE", "-D_UNICODE" },
        },
    },
}

import("xim.libxpkg.pkginfo")

function install()
    -- Reproduce the default unpack shape — install_dir/<wrap>/src/... — so
    -- the descriptor's `*/` globs keep matching exactly one wrap level (same
    -- normalisation as compat.eui-neo). ⚠️ NO SHELL and no directory listing
    -- in this sandbox: the wrap is asked about by name, not discovered.
    local v = pkginfo.version()
    local idir = pkginfo.install_dir()
    local layer = path.join(idir, "FTXUI-" .. v)
    os.tryrm(idir)
    os.mkdir(idir)
    for _, name in ipairs({ "FTXUI-" .. v, "ftxui-" .. v,
                            "FTXUI-v" .. v, "ftxui-v" .. v }) do
        if os.isfile(path.join(name, "CMakeLists.txt")) then
            os.mv(name, layer)
            break
        end
    end
    if not os.isfile(path.join(layer, "CMakeLists.txt")) then
        log.error("ftxui: no CMakeLists.txt under %s after unpacking; the "
                  .. "archive layout is neither wrapped nor flat", layer)
        return false
    end

    -- See the header comment: drop the stale loop.cpp on the 7.x layout
    -- (app.cpp present) where its Loop methods are duplicated; keep it for
    -- 6.1.9, which has no app.cpp.
    if os.isfile(path.join(layer, "src", "ftxui", "component", "app.cpp")) then
        os.tryrm(path.join(layer, "src", "ftxui", "component", "loop.cpp"))
    end
    return true
end
