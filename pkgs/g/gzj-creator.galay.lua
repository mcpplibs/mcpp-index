-- Form A descriptor: Galay publishes its own mcpp.toml at the archive root.
-- The manifest builds the default utils/kernel C++23 module surface and keeps
-- protocol/database/TLS components behind its upstream features.
--
-- v5.0.2 is Unix-only in the upstream manifest (Linux and macOS). Windows is
-- intentionally absent until Galay publishes a Windows-compatible manifest.
-- No mcpp-res mirror is configured locally, so the plain GLOBAL URL is the
-- documented fallback for CN consumers until a maintainer creates the mirror.
package = {
    spec        = "1",
    namespace   = "gzj-creator",
    name        = "galay",
    description = "C++23 coroutine networking and protocol framework with named Galay modules",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/gzj-creator/galay",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/gzj-creator/galay/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["5.0.2"] = {
                url    = "https://github.com/gzj-creator/galay/archive/refs/tags/v5.0.2.tar.gz",
                sha256 = "93a93fabcfeb1b0ae160f3082ed472571532ce208c112bf2697f94267b27332a",
            },
        },
        macosx = {
            ["5.0.2"] = {
                url    = "https://github.com/gzj-creator/galay/archive/refs/tags/v5.0.2.tar.gz",
                sha256 = "93a93fabcfeb1b0ae160f3082ed472571532ce208c112bf2697f94267b27332a",
            },
        },
    },

    mcpp = "*/mcpp.toml",
}
