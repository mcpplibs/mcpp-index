local versions = {
    ["14.3.0"] = {
        url    = "https://github.com/xtensor-stack/xsimd/archive/refs/tags/14.3.0.tar.gz",
        sha256 = "b3d50e7a73fbf4642ceef30131c93414901d69eee41c2a5302db650b03e2c792",
    },
}

-- Form B inline descriptor for xsimd — C++ wrappers over SIMD intrinsics.
--
-- HEADER-ONLY: upstream's CMake target exposes exactly `include/`, where
-- consumers find `<xsimd/xsimd.hpp>`. Tests, examples, benchmarks and docs
-- stay outside the include path. A trivial anchor TU gives mcpp a buildable
-- `xsimd` lib target, following compat.gtl / compat.safeint.
--
-- LANGUAGE FLOOR: xsimd requires C++14 (`target_compile_features` says
-- `cxx_std_14`). The package's own anchor is compiled as C++; consumers may
-- use any C++14-or-newer language mode supported by their toolchain.
--
-- No features: xsimd is header-only and has no optional compilable library
-- component. Its optional `xtl::xcomplex` integration is controlled by the
-- consumer's XSIMD_ENABLE_XTL_COMPLEX define and an external xtl dependency,
-- so a sources-only feature cannot represent it and is deliberately omitted.
--
-- No verified mcpp-res mirror is available, so the upstream URL is a plain
-- string rather than a fabricated GLOBAL/CN resource table.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "xsimd",
    description = "C++ wrappers for SIMD intrinsics with runtime architecture selection (header-only)",
    licenses    = {"BSD-3-Clause"},
    repo        = "https://github.com/xtensor-stack/xsimd",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "${version}",
            url = "https://github.com/xtensor-stack/xsimd/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["14.3.0"] = versions["14.3.0"],
        },
        macosx = {
            ["14.3.0"] = versions["14.3.0"],
        },
        windows = {
            ["14.3.0"] = versions["14.3.0"],
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/xsimd_anchor.c"] = [==[
int mcpp_compat_xsimd_headers_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/xsimd_anchor.c" },
        targets      = { ["xsimd"] = { kind = "lib" } },
        deps         = { },
    },
}
