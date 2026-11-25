-- compat.sheenbidi — the Unicode bidirectional algorithm (UAX #9), Apache-2.0.
--
-- SheenBidi is a C implementation of UAX #9 with no dependencies: paragraphs,
-- lines and their visual runs, mirroring, bracket pairs, and the script and
-- general category lookups a shaper needs beside them. 3.0.0 implements
-- Unicode 17.0.0 and passes all of Unicode's BidiTest.txt and
-- BidiCharacterTest.txt for that version (upstream's AlgorithmTests).
--
-- It is the permissively licensed alternative to compat.fribidi
-- (LGPL-2.1-or-later): a program can link it statically without the LGPL's
-- relinking terms.
--
-- ─────────────────────────────────────────────────────────────────────────
-- NOTHING TO GENERATE, NOTHING TO CONFIGURE
--
-- The Unicode tables (Source/Data/*Lookup.c) are generated upstream and
-- committed, and SBConfig.h is a header of commented-out switches whose
-- defaults are this build. So the package is the release tarball and one
-- source file:
--
--   Source/SheenBidi.c   upstream's unity build (meson's default,
--                        `unity_mode=enabled`): under SB_CONFIG_UNITY it
--                        #includes every other .c and makes the internal
--                        functions static, so the library exports only the
--                        SB* entry points of the public headers.
--
-- SB_CONFIG_EXPERIMENTAL_TEXT_API is not defined, as upstream's default
-- builds do not define it: the SBText / attribute / run-iterator API is
-- declared experimental, and its headers compile to nothing without it. The
-- algorithm API (SBAlgorithm, SBParagraph, SBLine, SBMirrorLocator,
-- SBScriptLocator, SBCodepoint, SBAllocator) is all there.
--
-- ─────────────────────────────────────────────────────────────────────────
-- THE INTERNAL HEADERS ARE PRIVATE
--
-- The sources include their internal headers by Source-relative names
-- (<API/SBBase.h>, <Core/List.h>, <UBA/BidiChain.h>), so `*/Source` has to be
-- on this package's include path. It is in each PLATFORM block as both
-- `include_dirs` and `private_include_dirs` — the shape compat.eui-neo and
-- gnome.glib measured: the -I reaches this package's own translation units
-- and not its consumers', whose include path gets only `*/Headers` (the
-- public <SheenBidi/…> headers). A base-level `private_include_dirs` is
-- inert, which is why it is not written once.
--
-- kind = "lib": a static library. On Windows SB_PUBLIC is empty unless
-- SB_CONFIG_DLL_EXPORT / SB_CONFIG_DLL_IMPORT is defined, and neither is, so
-- the consumer's declarations match without any define of its own.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "sheenbidi",
    description = "SheenBidi 3.0.0 — the Unicode bidirectional algorithm (UAX #9, Unicode 17.0.0) in C, Apache-2.0, no dependencies",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/Tehreer/SheenBidi",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/Tehreer/SheenBidi/archive/refs/tags/${tag}.tar.gz",
        },
    },

    -- One source tarball for every platform: portable C11 whose platform
    -- choices (atomics, thread-local storage) are made by the compiler's own
    -- predefined macros.
    xpm = {
        linux = {
            ["3.0.0"] = {
                url = {
                    GLOBAL = "https://github.com/Tehreer/SheenBidi/archive/refs/tags/v3.0.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/sheenbidi/releases/download/3.0.0/sheenbidi-3.0.0.tar.gz",
                },
                sha256 = "86c56014034739ba39a24c23eb00323b0bf6f737354f665786015fca842af786",
            },
        },
        macosx = {
            ["3.0.0"] = {
                url = {
                    GLOBAL = "https://github.com/Tehreer/SheenBidi/archive/refs/tags/v3.0.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/sheenbidi/releases/download/3.0.0/sheenbidi-3.0.0.tar.gz",
                },
                sha256 = "86c56014034739ba39a24c23eb00323b0bf6f737354f665786015fca842af786",
            },
        },
        windows = {
            ["3.0.0"] = {
                url = {
                    GLOBAL = "https://github.com/Tehreer/SheenBidi/archive/refs/tags/v3.0.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/sheenbidi/releases/download/3.0.0/sheenbidi-3.0.0.tar.gz",
                },
                sha256 = "86c56014034739ba39a24c23eb00323b0bf6f737354f665786015fca842af786",
            },
        },
    },

    mcpp = {
        language   = "c++23",
        import_std = false,
        -- C11: upstream's atomics and thread-local storage take their C11
        -- paths (<stdatomic.h>, _Thread_local) on every compiler here.
        c_standard = "c11",

        -- The public headers, included as <SheenBidi/SheenBidi.h>. They carry
        -- their own extern "C" (SB_EXTERN_C_BEGIN), so a C++ consumer includes
        -- them as they are.
        include_dirs = { "*/Headers" },

        sources = { "*/Source/SheenBidi.c" },
        cflags  = { "-DSB_CONFIG_UNITY" },

        linux = {
            include_dirs         = { "*/Source" },
            private_include_dirs = { "*/Source" },
            -- Linked into shared objects by its consumers: position independent.
            cflags               = { "-fPIC" },
        },
        macosx = {
            include_dirs         = { "*/Source" },
            private_include_dirs = { "*/Source" },
            cflags               = { "-fPIC" },
        },
        -- No -fPIC: PE/COFF has no such distinction, and clang rejects it for
        -- the MSVC target.
        windows = {
            include_dirs         = { "*/Source" },
            private_include_dirs = { "*/Source" },
        },

        targets = { sheenbidi = { kind = "lib" } },
        deps    = {},
    },
}
