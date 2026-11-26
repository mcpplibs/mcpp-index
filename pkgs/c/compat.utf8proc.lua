-- compat.utf8proc — Unicode normalization, case-folding, width, and grapheme clusters (C, MIT + Unicode-3.0).
--
-- Form B source-built package compiling `*/utf8proc.c` (which includes
-- `utf8proc_data.c`) against `<utf8proc.h>`.
--
-- `utf8proc.h` decorates public symbols with `__declspec(dllimport)` on Windows
-- unless `UTF8PROC_STATIC` is defined. Following `compat.curl` /
-- `compat.libarchive` / `compat.thorvg`, the `default` feature implies
-- `staticlib` so `UTF8PROC_STATIC` reaches both `compat.utf8proc` and every
-- downstream consumer without needing `-DUTF8PROC_STATIC` manually; `cflags`
-- also passes `-DUTF8PROC_STATIC` directly to `utf8proc.c`.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "utf8proc",
    description = "Clean, small, and portable C library for processing UTF-8 Unicode data",
    licenses    = { "MIT", "Unicode-3.0" },
    repo        = "https://github.com/JuliaStrings/utf8proc",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/JuliaStrings/utf8proc/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["2.10.0"] = {
                url    = "https://github.com/JuliaStrings/utf8proc/archive/refs/tags/v2.10.0.tar.gz",
                sha256 = "6f4f1b639daa6dca9f80bc5db1233e9cbaa31a67790887106160b33ef743f136",
            },
        },
        macosx = {
            ["2.10.0"] = {
                url    = "https://github.com/JuliaStrings/utf8proc/archive/refs/tags/v2.10.0.tar.gz",
                sha256 = "6f4f1b639daa6dca9f80bc5db1233e9cbaa31a67790887106160b33ef743f136",
            },
        },
        windows = {
            ["2.10.0"] = {
                url    = "https://github.com/JuliaStrings/utf8proc/archive/refs/tags/v2.10.0.tar.gz",
                sha256 = "6f4f1b639daa6dca9f80bc5db1233e9cbaa31a67790887106160b33ef743f136",
            },
        },
    },

    mcpp = {
        language      = "c++23",
        import_std    = false,
        c_standard    = "c11",
        license_files = { "*/LICENSE.md" },
        include_dirs  = { "*" },
        cflags        = { "-DUTF8PROC_STATIC" },
        features      = {
            ["default"]   = { implies = { "staticlib" } },
            ["staticlib"] = { defines = { "UTF8PROC_STATIC" } },
        },
        sources       = { "*/utf8proc.c" },
        targets       = { utf8proc = { kind = "lib" } },
        deps          = {},
    },
}
