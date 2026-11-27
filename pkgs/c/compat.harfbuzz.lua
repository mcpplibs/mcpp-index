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
-- ONE GENERATED config.h, no configure step. HarfBuzz reads a config.h under
-- HAVE_CONFIG_H; the one below (mcpp_generated/config.h) only names the
-- backend's HAVE_* switches, so `hb-config.hh` still supplies every default.
-- It exists for the switch no-freetype (below), which a command-line define
-- could not take back.
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
                -- (the HAVE_FT_* below): installed copies take them.
                -- 2: the switch no-freetype, read in the generated config.h.
                -- 3: the switches no-unused-api and no-aat-vertical, read there too.
                revision = 3,
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
                -- (the HAVE_FT_* below): installed copies take them.
                -- 2: the switch no-freetype, read in the generated config.h.
                -- 3: the switches no-unused-api and no-aat-vertical, read there too.
                revision = 3,
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
                -- (the HAVE_FT_* below): installed copies take them.
                -- 2: the switch no-freetype, read in the generated config.h.
                -- 3: the switches no-unused-api and no-aat-vertical, read there too.
                revision = 3,
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        include_dirs = { "mcpp_generated", "*/src" },
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
        --
        -- They are in config.h, not cxxflags, for the switch no-freetype:
        -- with HAVE_FREETYPE, hb_font_create() reaches hb_ft_font_set_funcs
        -- through hb_font_set_funcs_using()'s table of backends, so every
        -- program that makes a font links all of FreeType (its core and every
        -- driver), whether or not it ever names FreeType. A consumer whose
        -- fonts take HarfBuzz's own `ot` functions (the default first in that
        -- table) turns it on and carries none of it; <hb-ft.h>'s functions
        -- are then not defined.
        cxxflags     = { "-DHAVE_CONFIG_H=1" },
        generated_files = {
            ["mcpp_generated/config.h"] = [==[
/* compat.harfbuzz: the backend HarfBuzz is built with. mcpp defines
   MCPP_FEATURE_NO_FREETYPE for this package's units when the switch is on. */
#ifndef MCPP_FEATURE_NO_FREETYPE
#define HAVE_FREETYPE 1
#define HAVE_FT_GET_VAR_BLEND_COORDINATES 1
#define HAVE_FT_SET_VAR_BLEND_COORDINATES 1
#define HAVE_FT_DONE_MM_VAR 1
#define HAVE_FT_GET_TRANSFORM 1
#endif
/* compat.harfbuzz: parts of HarfBuzz a consumer leaves out (hb-config.hh's
   HB_NO_*). mcpp defines MCPP_FEATURE_NO_UNUSED_API, MCPP_FEATURE_NO_AAT_VERTICAL
   for this package's units when those switches are on. */
#ifdef MCPP_FEATURE_NO_UNUSED_API
#define HB_NO_BUFFER_SERIALIZE
#define HB_NO_BUFFER_VERIFY
#define HB_NO_BUFFER_MESSAGE
#define HB_NO_MATH
#define HB_NO_META
#define HB_NO_LAYOUT_UNUSED
#define HB_NO_OT_FONT_GLYPH_NAMES
#define HB_NO_STYLE
#endif
#ifdef MCPP_FEATURE_NO_AAT_VERTICAL
#define HB_NO_AAT
#define HB_NO_VERTICAL
#endif
]==],
        },
        --   no-freetype      HarfBuzz without its FreeType backend (hb-ft): off by
        --                    default, the build it always was.
        --   no-unused-api    Without the APIs a program that shapes and draws text
        --                    need not call: buffer serialisation, verification and
        --                    messages, the MATH and meta tables, the layout API no
        --                    shaper uses, glyph names, style queries. Shaping and
        --                    drawing are unchanged; those functions answer empty.
        --                    Measured (emsdk 6.0.9, -Oz, a program linking the 57
        --                    hb_* functions a shaper over its own fonts calls):
        --                    wasm 556,891 → 531,727 B, gzip 218,946 → 208,442.
        --   no-aat-vertical  Also without Apple's AAT shaping (morx, kerx, trak)
        --                    and vertical layout: a program whose fonts carry
        --                    OpenType layout and that shapes horizontally only.
        --                    With no-unused-api: 461,992 B, gzip 187,747.
        -- All off by default: the build it always was.
        features     = {
            ["no-freetype"] = {},
            ["no-unused-api"] = {},
            ["no-aat-vertical"] = {},
        },
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
