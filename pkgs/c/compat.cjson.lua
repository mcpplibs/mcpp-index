-- Form B inline descriptor for cJSON — an ultralightweight JSON parser in
-- ANSI C. Pure-C source build (same shape as compat.zlib): compile cJSON.c
-- into a lib, expose cJSON.h via include_dirs. The optional cJSON_Utils
-- extension (JSON Pointer / Patch / merge) is gated behind the `utils`
-- feature, mirroring how compat.gtest gates gtest_main behind `main`:
-- listed under features only, so it is excluded by default and pulled in
-- when `features = ["utils"]` is requested on the dependency.
--
-- All `mcpp` paths are GLOBS relative to the verdir; the leading `*/`
-- absorbs the GitHub tarball's `cJSON-<tag>/` wrap layer.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "compat.cjson",
    description = "Ultralightweight JSON parser in ANSI C",
    licenses    = {"MIT"},
    repo        = "https://github.com/DaveGamble/cJSON",
    type        = "package",

    xpm = {
        linux = {
            ["1.7.19"] = {
                url    = {
                    GLOBAL = "https://github.com/DaveGamble/cJSON/archive/refs/tags/v1.7.19.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/cjson/releases/download/1.7.19/cjson-1.7.19.tar.gz",
                },
                sha256 = "7fa616e3046edfa7a28a32d5f9eacfd23f92900fe1f8ccd988c1662f30454562",
            },
        },
        macosx = {
            ["1.7.19"] = {
                url    = {
                    GLOBAL = "https://github.com/DaveGamble/cJSON/archive/refs/tags/v1.7.19.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/cjson/releases/download/1.7.19/cjson-1.7.19.tar.gz",
                },
                sha256 = "7fa616e3046edfa7a28a32d5f9eacfd23f92900fe1f8ccd988c1662f30454562",
            },
        },
        windows = {
            ["1.7.19"] = {
                url    = {
                    GLOBAL = "https://github.com/DaveGamble/cJSON/archive/refs/tags/v1.7.19.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/cjson/releases/download/1.7.19/cjson-1.7.19.tar.gz",
                },
                sha256 = "7fa616e3046edfa7a28a32d5f9eacfd23f92900fe1f8ccd988c1662f30454562",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c99",
        include_dirs = { "*" },
        sources      = { "*/cJSON.c" },
        targets      = { ["cjson"] = { kind = "lib" } },
        -- cJSON_Utils is an optional extension; excluded by default, pulled in
        -- only when `features = ["utils"]` is requested on the dependency.
        features     = {
            ["utils"] = { sources = { "*/cJSON_Utils.c" } },
        },
        deps         = { },
    },
}
