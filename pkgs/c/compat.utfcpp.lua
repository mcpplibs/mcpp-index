local versions = {
    ["5.0.0"] = {
        url    = "https://github.com/nemtrif/utfcpp/archive/refs/tags/v5.0.0.tar.gz",
        sha256 = "42c36e1ef1307b1186996e4644f9999970e26325670b99019f3408bf0d3c952a",
    },
}

-- compat.utfcpp — UTF-8 with C++ in a Portable Way (header-only).
-- Exposes `*/source` on the include path so consumers `#include <utf8.h>` and
-- `#include <utf8/cpp17.h>` / `<utf8/cpp20.h>`. A trivial C anchor translation
-- unit gives mcpp a buildable lib target.
--
-- All `mcpp` paths are GLOBS relative to the verdir; the leading `*/`
-- absorbs the GitHub tarball's `utfcpp-<ver>/` wrap layer.
-- Plain upstream URLs are used here because no local gitcode `mcpp-res`
-- credentials are available; CN mirrors can be added by maintainers later.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "utfcpp",
    description = "UTF8-CPP — UTF-8 with C++ in a portable way (header-only)",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/nemtrif/utfcpp",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/nemtrif/utfcpp/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux   = { ["5.0.0"] = versions["5.0.0"] },
        macosx  = { ["5.0.0"] = versions["5.0.0"] },
        windows = { ["5.0.0"] = versions["5.0.0"] },
    },

    mcpp = {
        language      = "c++23",
        import_std    = false,
        c_standard    = "c11",
        license_files = { "*/LICENSE" },
        include_dirs  = { "*/source" },
        generated_files = {
            ["mcpp_generated/utfcpp_anchor.c"] = "int mcpp_compat_utfcpp_anchor(void) { return 0; }\n",
        },
        sources = { "mcpp_generated/utfcpp_anchor.c" },
        targets = { ["utfcpp"] = { kind = "lib" } },
        deps    = {},
    },
}
