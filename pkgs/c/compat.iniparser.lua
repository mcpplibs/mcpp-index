local versions = {
    ["4.3.2"] = {
        url    = "https://github.com/ndevilla/iniparser/archive/refs/tags/v4.3.2.tar.gz",
        sha256 = "e9eb6be555c30fbef87e5a07333fcff6ef8c5bbbdc5710321bbad7ebae0612a7",
    },
}

-- compat.iniparser — C library for parsing INI-style files.
-- Compiles `src/dictionary.c` and `src/iniparser.c` as C99 and generates
-- `version.h` (matching upstream `cmake/version.h.in`) so `src/dictionary.h`
-- resolves `#include "version.h"` without running CMake.
--
-- On Linux, `-D_POSIX_C_SOURCE=200809L` provides `strdup` and `fmemopen` for
-- C99 TUs (`iniparser_load_buffer`). On Windows, CRT deprecation macros silence
-- MSVC warnings on `fopen` and `strdup`.
--
-- All `mcpp` paths are GLOBS relative to the verdir; the leading `*/`
-- absorbs the GitHub tarball's `iniparser-<ver>/` wrap layer.
-- Plain upstream URLs are used here because no local gitcode `mcpp-res`
-- credentials are available; CN mirrors can be added by maintainers later.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "iniparser",
    description = "iniParser — stand-alone ini file parsing library in ANSI C",
    licenses    = {"MIT"},
    repo        = "https://github.com/ndevilla/iniparser",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/ndevilla/iniparser/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux   = { ["4.3.2"] = versions["4.3.2"] },
        macosx  = { ["4.3.2"] = versions["4.3.2"] },
        windows = { ["4.3.2"] = versions["4.3.2"] },
    },

    mcpp = {
        language      = "c++23",
        import_std    = false,
        c_standard    = "c99",
        license_files = { "*/LICENSE" },
        include_dirs  = { "*/src", "mcpp_generated" },
        generated_files = {
            ["mcpp_generated/version.h"] = [==[
#define INIPARSER_VERSION_MAJOR 4
#define INIPARSER_VERSION_MINOR 3
#define INIPARSER_VERSION_PATCH 2
]==],
        },
        sources = {
            "*/src/dictionary.c",
            "*/src/iniparser.c",
        },
        targets = { ["iniparser"] = { kind = "lib" } },
        deps    = {},

        linux = {
            cflags = { "-D_POSIX_C_SOURCE=200809L" },
        },
        windows = {
            cflags = { "-D_CRT_SECURE_NO_WARNINGS", "-D_CRT_NONSTDC_NO_DEPRECATE" },
        },
    },
}
