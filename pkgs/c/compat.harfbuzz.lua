-- compat.harfbuzz — HarfBuzz text shaping engine, with the FreeType font backend.
--
-- Shape A (C-source compat, C++ flavour): the user writes `#include <hb.h>`
-- and, for the FreeType bridge, `#include <hb-ft.h>`.
--
-- ONE TRANSLATION UNIT, ON PURPOSE.
-- Upstream builds with meson (or a CMake port), and reproducing either here
-- would mean tracking ~137 .cc files plus their generated config. HarfBuzz
-- ships `src/harfbuzz.cc` for exactly this case: an amalgamation that
-- #includes every implementation file. It is upstream's own supported
-- "just compile one file" path, so the source list stays one line and cannot
-- drift out of sync with a release.
--
-- The amalgamation also #includes the backends this package does not enable
-- (CoreText, DirectWrite, GDI, GLib, Graphite2, ICU). Each of those is behind
-- its own HAVE_* gate and compiles to nothing when the gate is absent, so
-- naming only HAVE_FREETYPE selects precisely the FreeType backend without
-- editing anything.
--
-- NO config.h. HarfBuzz reads one only under HAVE_CONFIG_H, which is not
-- defined here; `hb-config.hh` then supplies the defaults. That is what keeps
-- this a source-only package with no configure step.
--
-- HB_NO_MT IS DELIBERATELY NOT SET. It drops HarfBuzz's atomics and locks,
-- which is only sound when the consumer guarantees single-threaded use --
-- a promise a shared index package cannot make on its consumers' behalf.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "harfbuzz",
    description = "HarfBuzz — OpenType text shaping engine with the FreeType backend",
    licenses    = {"MIT"},
    repo        = "https://github.com/harfbuzz/harfbuzz",
    type        = "package",

    xpm = {
        linux = {
            ["14.3.0"] = {
                url = {
                    GLOBAL = "https://github.com/harfbuzz/harfbuzz/archive/refs/tags/14.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/harfbuzz/releases/download/14.3.0/harfbuzz-14.3.0.tar.gz",
                },
                sha256 = "566e996a1b40486954fb7110ffe6eb88a0f7958bb466cdb023b0302618acea4a",
                -- 1: hb-ft with FreeType's variation and transform entry points
                -- (the HAVE_FT_* cxxflags below): installed copies take them.
                revision = 1,
            },
        },
        macosx = {
            ["14.3.0"] = {
                url = {
                    GLOBAL = "https://github.com/harfbuzz/harfbuzz/archive/refs/tags/14.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/harfbuzz/releases/download/14.3.0/harfbuzz-14.3.0.tar.gz",
                },
                sha256 = "566e996a1b40486954fb7110ffe6eb88a0f7958bb466cdb023b0302618acea4a",
                -- 1: hb-ft with FreeType's variation and transform entry points
                -- (the HAVE_FT_* cxxflags below): installed copies take them.
                revision = 1,
            },
        },
        windows = {
            ["14.3.0"] = {
                url = {
                    GLOBAL = "https://github.com/harfbuzz/harfbuzz/archive/refs/tags/14.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/harfbuzz/releases/download/14.3.0/harfbuzz-14.3.0.tar.gz",
                },
                sha256 = "566e996a1b40486954fb7110ffe6eb88a0f7958bb466cdb023b0302618acea4a",
                -- 1: hb-ft with FreeType's variation and transform entry points
                -- (the HAVE_FT_* cxxflags below): installed copies take them.
                revision = 1,
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        include_dirs = { "*/src" },
        sources      = { "*/src/harfbuzz.cc" },
        -- HAVE_FREETYPE turns on hb-ft.cc inside the amalgamation, which is
        -- what makes <hb-ft.h> more than a set of declarations. The public
        -- header is installed either way, so without this the consumer gets a
        -- link error rather than a compile error -- worth pinning down here.
        --
        -- The four HAVE_FT_* are what upstream's meson.build sets for every
        -- FreeType that has these entry points (check_freetype_funcs; all of
        -- them since FreeType 2.11, so compat.freetype 2.13.3 too). Without
        -- them hb-ft.cc compiles out its variation and transform support: the
        -- FreeType font functions ignore hb_font_set_variations() and the
        -- face's FT_Set_Transform, and upstream's shaping suites fail with
        -- --font-funcs=ft on every variable font (TestGVAR*, TestHVAR*,
        -- TestCVARGVAR*, HBTest-VF …).
        cxxflags     = { "-DHAVE_FREETYPE=1",
                         "-DHAVE_FT_GET_VAR_BLEND_COORDINATES=1",
                         "-DHAVE_FT_SET_VAR_BLEND_COORDINATES=1",
                         "-DHAVE_FT_DONE_MM_VAR=1",
                         "-DHAVE_FT_GET_TRANSFORM=1" },
        targets      = { ["harfbuzz"] = { kind = "lib" } },
        deps         = { ["compat.freetype"] = "2.13.3" },
        linux = {
            ldflags = { "-lm", "-lpthread" },
        },
        macosx = {
            ldflags = { "-lm" },
        },
    },
}
