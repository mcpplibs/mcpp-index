local versions = {
    ["2.15.0"] = {
        url = "https://github.com/freetype/freetype/archive/refs/tags/VER-2-15-0.tar.gz",
        sha256 = "87c7f1f8699b91e89f773f7dcfa505b044e1dae67f62a55d4e29c3afdcac4fb8",
    },
}

-- compat.freetype — FreeType 2.13.3 font rendering engine.
-- Built from aggregate source files (~20 .c files), depends on compat.libpng.
-- EUI-NEO uses FreeType for all text/font rendering.
--
-- Build strategy: aggregate source files (one per module directory).
-- This is the recommended approach for non-CMake/autotools builds.
--
-- All `mcpp` paths are GLOBS relative to the verdir; the leading `*/`
-- absorbs the tarball's `freetype-VER-2-13-3/` wrap layer.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "freetype",
    description = "FreeType 2 — portable font engine with TrueType/CFF/WOFF/SVG support",
    licenses    = {"FreeType"},
    repo        = "https://gitlab.freedesktop.org/freetype/freetype",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "VER-${version:dash}",
            url = "https://github.com/freetype/freetype/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["2.13.3"] = {
                url    = "https://github.com/freetype/freetype/archive/refs/tags/VER-2-13-3.tar.gz",
                sha256 = "bc5c898e4756d373e0d991bab053036c5eb2aa7c0d5c67e8662ddc6da40c4103",
            },
            ["2.15.0"] = versions["2.15.0"],
        },
        macosx = {
            ["2.13.3"] = {
                url    = "https://github.com/freetype/freetype/archive/refs/tags/VER-2-13-3.tar.gz",
                sha256 = "bc5c898e4756d373e0d991bab053036c5eb2aa7c0d5c67e8662ddc6da40c4103",
            },
            ["2.15.0"] = versions["2.15.0"],
        },
        windows = {
            ["2.13.3"] = {
                url    = "https://github.com/freetype/freetype/archive/refs/tags/VER-2-13-3.tar.gz",
                sha256 = "bc5c898e4756d373e0d991bab053036c5eb2aa7c0d5c67e8662ddc6da40c4103",
            },
            ["2.15.0"] = versions["2.15.0"],
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "gnu11",
        include_dirs = { "*/include" },
        sources = {
            -- Base (aggregate + required extra files)
            "*/src/base/ftbase.c",
            "*/src/base/ftinit.c",
            "*/src/base/ftglyph.c",
            "*/src/base/ftbitmap.c",
            "*/src/base/ftbbox.c",
            -- Base extra (individual)
            "*/src/base/ftmm.c",
            -- Synthetic bold and oblique. Upstream builds it in `base` and
            -- every distribution ships it; it was missing here and the gap is
            -- invisible until a consumer calls it, because nothing in freetype
            -- itself does.
            --
            -- cairo does, unconditionally: `cairo-ft-font.c:2443` calls
            -- `FT_GlyphSlot_Embolden` when a font is asked for a weight it does
            -- not have, with no HAVE_ guard to turn off. So a cairo built
            -- against this freetype failed to LINK with two undefined
            -- references — measured while adding freedesktop.cairo.
            "*/src/base/ftsynth.c",
            -- The rest of upstream's base extensions (modules.cfg BASE_EXTENSIONS,
            -- CMakeLists.txt BASE_SRCS): the public API of ftstroke.h,
            -- ftgasp.h, ftbdf.h, ftcid.h, ftpfr.h, ftwinfnt.h, t1tables.h
            -- (FT_Get_PS_Font_Info …), FT_Get_FSType_Flags,
            -- FT_Face_CheckTrueTypePatents and the validation entry points
            -- (which report FT_Err_Unimplemented_Feature without the gxvalid /
            -- otvalid modules, as upstream's default build does). Every
            -- distribution builds them; without them those declarations link
            -- to nothing. Measured while wrapping the whole API as modules
            -- (mcpplibs.mwrap.freetype).
            "*/src/base/ftbdf.c",
            "*/src/base/ftcid.c",
            "*/src/base/ftfstype.c",
            "*/src/base/ftgasp.c",
            "*/src/base/ftgxval.c",
            "*/src/base/ftotval.c",
            "*/src/base/ftpatent.c",
            "*/src/base/ftpfr.c",
            "*/src/base/ftstroke.c",
            "*/src/base/fttype1.c",
            "*/src/base/ftwinfnt.c",
            -- Modules (aggregates)
            "*/src/autofit/autofit.c",
            "*/src/bdf/bdf.c",
            -- FT_Stream_OpenBzip2: FT_Err_Unimplemented_Feature without libbz2
            -- (FT_CONFIG_OPTION_USE_BZIP2 stays off), as upstream builds it.
            "*/src/bzip2/ftbzip2.c",
            "*/src/cff/cff.c",
            "*/src/cid/type1cid.c",
            "*/src/cache/ftcache.c",
            "*/src/gzip/ftgzip.c",
            -- 2.15 registers the HVF driver in ftmodule.h; this aggregate is
            -- absent (and the glob unmatched) on the preserved 2.13.3 release.
            "*/src/hvf/hvf.c",
            "*/src/lzw/ftlzw.c",
            "*/src/pcf/pcf.c",
            "*/src/pfr/pfr.c",
            "*/src/psaux/psaux.c",
            "*/src/pshinter/pshinter.c",
            "*/src/psnames/psnames.c",
            "*/src/raster/raster.c",
            "*/src/sdf/sdf.c",
            "*/src/sfnt/sfnt.c",
            "*/src/smooth/smooth.c",
            "*/src/svg/svg.c",
            "*/src/truetype/truetype.c",
            "*/src/type1/type1.c",
            "*/src/type42/type42.c",
            "*/src/winfonts/winfnt.c",
        },
        targets = { ["freetype"] = { kind = "lib" } },
        deps    = { ["compat.libpng"] = "1.6.43" },
        -- Only the FT_* configuration defines are portable. `cl` accepts -D, so
        -- these reach MSVC unchanged; a -W switch does not -- see below.
        cflags  = { "-DFT2_BUILD_LIBRARY", "-DFT_DISABLE_ZLIB", "-DFT_DISABLE_BZIP2", "-DFT_DISABLE_HARFBUZZ", "-DFT_DISABLE_BROTLI" },
        linux = {
            ldflags  = { "-lm" },
            sources  = { "*/builds/unix/ftsystem.c", "*/src/base/ftdebug.c" },
            -- -Wno-implicit-function-declaration is a GCC/Clang switch. It used
            -- to sit in the common cflags, where MSVC rejected it outright with
            -- `D8021: invalid numeric argument`, so the package could not build
            -- on Windows at all.
            cflags   = { "-include", "fcntl.h", "-Wno-implicit-function-declaration" },
        },
        macosx = {
            ldflags  = { "-lm" },
            sources  = { "*/builds/unix/ftsystem.c", "*/src/base/ftdebug.c" },
            -- _DARWIN_C_SOURCE belongs here and nowhere else; it was in the
            -- common cflags, which put an Apple feature macro on every platform.
            cflags   = { "-include", "fcntl.h", "-Wno-implicit-function-declaration", "-D_DARWIN_C_SOURCE" },
        },
        windows = {
            sources = {
                "*/builds/windows/ftdebug.c",
                "*/builds/windows/ftsystem.c",
            },
        },
    },
}
