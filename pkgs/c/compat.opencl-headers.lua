-- compat.opencl-headers — Khronos OpenCL API headers.
--
-- Header-only, the same shape as `compat.vulkan-headers`, and split from the
-- loader for the same reason: they are separate upstream repositories on
-- separate release cadences, and a consumer that only needs the types should
-- not drag a loader in.
--
-- The repository root IS the include root: `CL/cl.h` sits directly under it,
-- which is why the include glob is `*` rather than `*/include`.
--
-- The version is the Khronos release tag with the `v` dropped, which is how the
-- headers, the loader and the CTS are tied together upstream.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "opencl-headers",
    description = "Khronos OpenCL API headers",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/KhronosGroup/OpenCL-Headers",
    type        = "package",

    xpm = {
        linux = {
            ["2026.05.29"] = {
                url = {
                    GLOBAL = "https://github.com/KhronosGroup/OpenCL-Headers/archive/refs/tags/v2026.05.29.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/opencl-headers/releases/download/2026.05.29/opencl-headers-2026.05.29.tar.gz",
                },
                sha256 = "d9e6c48357de5002da11ce45de600e0c3ffe6ab4f628a3b9fe2b38603161658a",
            },
        },
        macosx = {
            ["2026.05.29"] = {
                url = {
                    GLOBAL = "https://github.com/KhronosGroup/OpenCL-Headers/archive/refs/tags/v2026.05.29.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/opencl-headers/releases/download/2026.05.29/opencl-headers-2026.05.29.tar.gz",
                },
                sha256 = "d9e6c48357de5002da11ce45de600e0c3ffe6ab4f628a3b9fe2b38603161658a",
            },
        },
        windows = {
            ["2026.05.29"] = {
                url = {
                    GLOBAL = "https://github.com/KhronosGroup/OpenCL-Headers/archive/refs/tags/v2026.05.29.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/opencl-headers/releases/download/2026.05.29/opencl-headers-2026.05.29.tar.gz",
                },
                sha256 = "d9e6c48357de5002da11ce45de600e0c3ffe6ab4f628a3b9fe2b38603161658a",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = { "*" },
        generated_files = {
            ["mcpp_generated/opencl_headers_anchor.c"] =
                "int mcpp_compat_opencl_headers_anchor(void) { return 0; }\n",
        },
        sources = { "mcpp_generated/opencl_headers_anchor.c" },
        targets = { ["opencl-headers"] = { kind = "lib" } },
        deps    = {},
    },
}
