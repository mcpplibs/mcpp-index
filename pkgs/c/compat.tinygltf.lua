-- compat.tinygltf — syoyo/tinygltf v3 C11-first glTF 2.0 loader and writer.
-- Three-file archive root layout: tiny_gltf_v3.h, tiny_gltf_v3.c, and
-- tinygltf_json_c.h. `default` implies `fs` (defines TINYGLTF3_ENABLE_FS so
-- tg3_parse_file / tg3_write_to_file use stdio); consumers passing
-- `default-features = false` compile out stdio filesystem helpers.
--
-- All `mcpp` paths are GLOBS relative to the verdir; the leading `*/`
-- absorbs the GitHub tarball's `tinygltf-<ver>/` wrap layer.
-- Plain upstream URLs are used here because no local gitcode `mcpp-res`
-- credentials are available; CN mirrors can be added by maintainers later.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "tinygltf",
    description = "tinygltf v3 — C11-first glTF 2.0 loader and writer (POD API, arena allocator)",
    licenses    = {"MIT"},
    repo        = "https://github.com/syoyo/tinygltf",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/syoyo/tinygltf/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["3.0.1"] = {
                url    = "https://github.com/syoyo/tinygltf/archive/refs/tags/v3.0.1.tar.gz",
                sha256 = "b7e953f13a30d7b6fd677e484de35febde954143a265da15dacd92ed171c73e6",
            },
            ["3.1.0"] = {
                url    = "https://github.com/syoyo/tinygltf/archive/refs/tags/v3.1.0.tar.gz",
                sha256 = "6e3043d1353d31daa4a06b17606bc9f4c46bf8f047bddffe1a63a6a79446182e",
            },
        },
        macosx = {
            ["3.0.1"] = {
                url    = "https://github.com/syoyo/tinygltf/archive/refs/tags/v3.0.1.tar.gz",
                sha256 = "b7e953f13a30d7b6fd677e484de35febde954143a265da15dacd92ed171c73e6",
            },
            ["3.1.0"] = {
                url    = "https://github.com/syoyo/tinygltf/archive/refs/tags/v3.1.0.tar.gz",
                sha256 = "6e3043d1353d31daa4a06b17606bc9f4c46bf8f047bddffe1a63a6a79446182e",
            },
        },
        windows = {
            ["3.0.1"] = {
                url    = "https://github.com/syoyo/tinygltf/archive/refs/tags/v3.0.1.tar.gz",
                sha256 = "b7e953f13a30d7b6fd677e484de35febde954143a265da15dacd92ed171c73e6",
            },
            ["3.1.0"] = {
                url    = "https://github.com/syoyo/tinygltf/archive/refs/tags/v3.1.0.tar.gz",
                sha256 = "6e3043d1353d31daa4a06b17606bc9f4c46bf8f047bddffe1a63a6a79446182e",
            },
        },
    },

    mcpp = {
        language      = "c++23",
        import_std    = false,
        c_standard    = "c11",
        license_files = { "*/LICENSE" },
        include_dirs  = { "*" },
        sources       = { "*/tiny_gltf_v3.c" },
        targets       = { ["tinygltf"] = { kind = "lib" } },
        deps          = {},

        features = {
            ["default"] = {
                implies = { "fs" },
            },
            ["fs"] = {
                defines = { "TINYGLTF3_ENABLE_FS" },
            },
        },

        windows = {
            cflags = { "-D_CRT_SECURE_NO_WARNINGS" },
        },
    },
}
