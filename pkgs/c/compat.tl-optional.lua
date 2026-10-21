-- Form B inline descriptor for tl::optional — a single-header implementation
-- of std::optional with monadic extensions and optional references.
--
-- HEADER-ONLY: upstream's CMake INTERFACE target exposes `include/`, and the
-- only public header is `include/tl/optional.hpp`. Tests and packaging files
-- stay outside the consumer's include path. A trivial anchor TU gives mcpp a
-- buildable `optional` lib target, following compat.gtl / compat.safeint.
--
-- LANGUAGE FLOOR: upstream describes the library as C++11/14/17 and selects
-- its monadic overloads with TL_OPTIONAL_CXX14. The package's own anchor is
-- compiled as C++; consumers choose their language mode. The test uses the
-- workspace default C++23 mode and directly compiles the same API in C++14.
--
-- No features: the library has one header and no optional compilable source.
-- Its tests fetch Catch2 and are not part of the library.
--
-- No verified mcpp-res mirror is available, so the upstream URL is a plain
-- string rather than a fabricated GLOBAL/CN resource table.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "tl-optional",
    description = "tl::optional — std::optional with monadic operations and reference support (header-only)",
    licenses    = {"CC0-1.0"},
    repo        = "https://github.com/TartanLlama/optional",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/TartanLlama/optional/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["1.1.0"] = {
                url    = "https://github.com/TartanLlama/optional/archive/refs/tags/v1.1.0.tar.gz",
                sha256 = "88ece79f3de5ccaec4191951a222f95cc80c4381dafd3163bdb1ff87cedf3118",
            },
        },
        macosx = {
            ["1.1.0"] = {
                url    = "https://github.com/TartanLlama/optional/archive/refs/tags/v1.1.0.tar.gz",
                sha256 = "88ece79f3de5ccaec4191951a222f95cc80c4381dafd3163bdb1ff87cedf3118",
            },
        },
        windows = {
            ["1.1.0"] = {
                url    = "https://github.com/TartanLlama/optional/archive/refs/tags/v1.1.0.tar.gz",
                sha256 = "88ece79f3de5ccaec4191951a222f95cc80c4381dafd3163bdb1ff87cedf3118",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/tl_optional_anchor.c"] = [==[
int mcpp_compat_tl_optional_headers_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/tl_optional_anchor.c" },
        targets      = { ["optional"] = { kind = "lib" } },
        deps         = { },
    },
}
